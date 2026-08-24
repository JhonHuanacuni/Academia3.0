import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner } from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { pagoConfig } from "./pago.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormModal from "../../components/mantenedor/FormModal";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import EstudianteSearchField from "../mensualidad/EstudianteSearchField";
import PagoDetalleModal from "./PagoDetalleModal";
import { dbToView, dbToInput, hoyInput, inputToDb, sumarDiasInput } from "../../utils/fecha";
import "../../styles/mantenedor.css";
import "./pago.css";

function mapCatalogos(data) {
  return {
    planes: (data.planes || []).map((p) => ({ value: p.IDPLAN, label: p.NOMBRE })),
    aulas: (data.aulas || []).map((a) => ({ value: a.IDAULA, label: a.NOMBRE })),
    tutores: (data.tutores || []).map((a) => ({ value: a.IDTUTOR, label: a.NOMBRE })),
    metodosPago: (data.metodosPago || []).map((m) => ({
      value: m.IDMETODOPAGO,
      label: m.TITULO,
    })),
  };
}

function dinero(n) {
  const v = Number(n);
  if (Number.isNaN(v)) return "—";
  return `S/ ${v.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function duracionDiasDb(inicioDb, finDb) {
  const a = dbToInput(String(inicioDb || ""));
  const b = dbToInput(String(finDb || ""));
  if (!a || !b) return null;
  const d1 = new Date(`${a}T12:00:00`);
  const d2 = new Date(`${b}T12:00:00`);
  if (Number.isNaN(d1.getTime()) || Number.isNaN(d2.getTime())) return null;
  const dias = Math.round((d2 - d1) / 86400000);
  return dias > 0 ? dias : null;
}

const emptyAbono = () => ({
  IDCUOTA: "",
  MONTO: "",
  MONTO_CUOTA: "",
  MORA: "",
  IDMETODOPAGO: "MPG001",
  OBSERVACIONES: "",
});

function cuotaLabel(c) {
  const rango = `${dbToView(String(c.FECHAINICIO || ""))} — ${dbToView(String(c.FECHAFIN || ""))}`;
  return `Cuota ${c.NUMERO}: ${rango}`;
}

function primeraCuotaExigible(cuotas) {
  if (!Array.isArray(cuotas) || !cuotas.length) return null;
  return (
    cuotas.find((c) => c.EXIGIBLE && Number(c.DEUDA) > 0) ||
    cuotas.find((c) => Number(c.DEUDA) > 0) ||
    null
  );
}

function abonoDesdeCuota(cuota) {
  const deuda = Number(cuota?.DEUDA) || 0;
  return {
    ...emptyAbono(),
    IDCUOTA: cuota?.IDCUOTA || "",
    MONTO: deuda > 0 ? String(deuda) : "",
    MONTO_CUOTA: cuota?.MONTO != null ? String(cuota.MONTO) : "",
  };
}

const emptyNueva = () => ({
  IDPLAN: "",
  FECHAINICIO: hoyInput(),
  FECHAFIN: "",
  MONTOTOTAL: "",
  MONTO: "",
  IDMETODOPAGO: "MPG001",
  IDAULA: "",
  IDTUTOR: "",
  OBSERVACIONES: "",
});

/** Copia datos de la membresía anterior; deja vacío solo el monto del pago. */
function prefillsDesdeMensualidad(m) {
  const base = emptyNueva();
  if (!m) return base;
  const duracion = duracionDiasDb(m.FECHAINICIO, m.FECHAFIN);
  const inicio = hoyInput();
  return {
    ...base,
    IDPLAN: m.IDPLAN || "",
    FECHAINICIO: inicio,
    FECHAFIN: duracion != null ? sumarDiasInput(inicio, duracion) : "",
    MONTOTOTAL: m.MONTOTOTAL != null && m.MONTOTOTAL !== "" ? String(m.MONTOTOTAL) : "",
    MONTO: "",
    IDAULA: m.IDAULA || "",
    IDTUTOR: m.IDTUTOR || "",
    OBSERVACIONES: m.OBSERVACIONES || "",
  };
}

export default function PagoPage() {
  const cfg = pagoConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "ESTUDIANTE_NOMBRE", direccion: "ASC" },
  });

  const [vista, setVista] = useState("lista");
  const [toast, setToast] = useState(null);
  const [modalAbierto, setModalAbierto] = useState(false);
  const [modoDetalle, setModoDetalle] = useState("ver");
  const [confirm, setConfirm] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [catalogos, setCatalogos] = useState({
    planes: [],
    aulas: [],
    tutores: [],
    metodosPago: [],
  });
  const [estudiante, setEstudiante] = useState(null);
  const [mensualidades, setMensualidades] = useState([]);
  const [cargandoMem, setCargandoMem] = useState(false);
  const [seleccionada, setSeleccionada] = useState(null);
  const [modo, setModo] = useState("nueva"); // abono | nueva
  const [abono, setAbono] = useState(emptyAbono());
  const [nueva, setNueva] = useState(emptyNueva());
  const [enviando, setEnviando] = useState(false);
  const [errors, setErrors] = useState({});
  const [grupoSel, setGrupoSel] = useState(null);
  const [detalleAbierto, setDetalleAbierto] = useState(false);
  const [pagosDetalle, setPagosDetalle] = useState([]);
  const [cargandoDetalle, setCargandoDetalle] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/pagos/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) setCatalogos(mapCatalogos(data.data || {}));
      } catch {
        /* opcional */
      }
    })();
  }, []);

  const cargarMensualidades = async (idUsuario) => {
    if (!idUsuario) {
      setMensualidades([]);
      return;
    }
    setCargandoMem(true);
    try {
      const res = await fetch(
        `/api/pagos/estudiante/${encodeURIComponent(idUsuario)}/mensualidades/`,
      );
      const data = await parseJsonResponse(res);
      if (res.ok) {
        const list = data.data || [];
        setMensualidades(list);
        const conDeuda = list.find((m) => Number(m.DEUDA) > 0);
        if (conDeuda) {
          setSeleccionada(conDeuda);
          setModo("abono");
          const cuota = primeraCuotaExigible(conDeuda.CUOTAS);
          setAbono(cuota ? abonoDesdeCuota(cuota) : { ...emptyAbono(), MONTO: String(conDeuda.DEUDA) });
        } else {
          setSeleccionada(null);
          setModo("nueva");
          setNueva(prefillsDesdeMensualidad(list[0] || null));
        }
      }
    } catch {
      setMensualidades([]);
    } finally {
      setCargandoMem(false);
    }
  };

  const volverLista = () => {
    setVista("lista");
    setEstudiante(null);
    setMensualidades([]);
    setSeleccionada(null);
    setModo("nueva");
    setAbono(emptyAbono());
    setNueva(emptyNueva());
    setErrors({});
  };

  const abrirNuevo = () => {
    volverLista();
    setVista("nuevo");
  };

  const abrirVer = async (row) => {
    const idPago = row.IDPAGOMENSUALIDAD;
    if (!idPago) {
      setToast({ mensaje: "Este registro no tiene un pago para mostrar.", tipo: "error" });
      return;
    }
    try {
      const data = await crud.obtener(idPago);
      crud.setRegistro(data);
      setModoDetalle("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row.IDPAGOMENSUALIDAD);
      crud.setRegistro(data);
      setModoDetalle("editar");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    const nombre = row.ESTUDIANTE_NOMBRE || row[cfg.pk];
    const total = Number(row.MONTO || 0) + Number(row.MORA || 0);
    setConfirm({
      id: row.IDPAGOMENSUALIDAD,
      mensaje: `¿Eliminar el pago de «${nombre}» por ${dinero(total)}? Esta acción no se puede deshacer.`,
      grupo: grupoSel,
    });
  };

  const cargarDetalleGrupo = async (grupo) => {
    if (!grupo?.IDMENSUALIDAD) return;
    setCargandoDetalle(true);
    try {
      const params = new URLSearchParams({ idMensualidad: grupo.IDMENSUALIDAD });
      const res = await fetch(`/api/pagos/detalle/?${params}`);
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "Error al cargar pagos");
      setPagosDetalle(data.data || []);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
      setPagosDetalle([]);
    } finally {
      setCargandoDetalle(false);
    }
  };

  const abrirDetalleGrupo = async (row) => {
    setGrupoSel(row);
    setDetalleAbierto(true);
    await cargarDetalleGrupo(row);
  };

  const cerrarDetalleGrupo = () => {
    setDetalleAbierto(false);
    setGrupoSel(null);
    setPagosDetalle([]);
  };

  const handleGuardarDetalle = async (payload) => {
    const mensaje = await crud.actualizar(crud.registro[cfg.pk], {
      MONTO: payload.MONTO === "" ? null : Number(payload.MONTO),
      MORA: payload.MORA === "" ? 0 : Number(payload.MORA),
      IDMETODOPAGO: payload.IDMETODOPAGO,
      FECHAPAGO: payload.FECHAPAGO,
      OBSERVACIONES: payload.OBSERVACIONES || null,
    });
    setToast({ mensaje, tipo: "success" });
    setModalAbierto(false);
    await crud.listar();
    if (grupoSel) await cargarDetalleGrupo(grupoSel);
  };

  const handleConfirmEliminar = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      const mensaje = await crud.eliminar(confirm.id);
      setToast({ mensaje, tipo: "success" });
      setConfirm(null);
      await crud.listar();
      if (confirm.grupo) await cargarDetalleGrupo(confirm.grupo);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setConfirmando(false);
    }
  };

  const onEstudianteChange = (id, est) => {
    setEstudiante(est);
    setErrors({});
    if (est?.IDUSUARIO) cargarMensualidades(est.IDUSUARIO);
    else {
      setMensualidades([]);
      setSeleccionada(null);
      setModo("nueva");
    }
  };

  const clickMensualidad = (m) => {
    const deuda = Number(m.DEUDA) || 0;
    if (deuda <= 0) return;
    setSeleccionada(m);
    setModo("abono");
    const cuota = primeraCuotaExigible(m.CUOTAS);
    setAbono(cuota ? abonoDesdeCuota(cuota) : { ...emptyAbono(), MONTO: String(deuda) });
    setErrors({});
  };

  const seleccionarCuota = (idCuota) => {
    const cuotas = seleccionada?.CUOTAS || [];
    const cuota = cuotas.find((c) => c.IDCUOTA === idCuota);
    if (!cuota) {
      setAbono((p) => ({ ...p, IDCUOTA: idCuota }));
      return;
    }
    setAbono(abonoDesdeCuota(cuota));
    setErrors({});
  };

  const cuotaSeleccionada = (seleccionada?.CUOTAS || []).find(
    (c) => c.IDCUOTA === abono.IDCUOTA,
  );
  const deudaAbono = seleccionada?.TIENE_CUOTAS
    ? Number(cuotaSeleccionada?.DEUDA) || 0
    : Number(seleccionada?.DEUDA) || 0;

  const iniciarNueva = () => {
    setSeleccionada(null);
    setModo("nueva");
    setNueva(prefillsDesdeMensualidad(mensualidades[0] || null));
    setErrors({});
  };

  const validar = () => {
    const e = {};
    if (!estudiante?.IDUSUARIO) e.estudiante = "Selecciona un estudiante.";
    if (modo === "abono") {
      if (!seleccionada?.IDMENSUALIDAD) e.mensualidad = "Selecciona una mensualidad con deuda.";
      if (seleccionada?.TIENE_CUOTAS && !abono.IDCUOTA) {
        e.IDCUOTA = "Selecciona la cuota a cobrar.";
      }
      if (!abono.MONTO || Number(abono.MONTO) <= 0) e.MONTO = "Ingresa el monto del abono.";
      if (abono.MORA !== "" && Number(abono.MORA) < 0) {
        e.MORA = "La mora no puede ser negativa.";
      }
      if (!abono.IDMETODOPAGO) e.IDMETODOPAGO = "Selecciona el método de pago.";
      const deuda = deudaAbono;
      const montoCuotaEdit = abono.MONTO_CUOTA !== "" ? Number(abono.MONTO_CUOTA) : null;
      let deudaMax = deuda;
      if (
        seleccionada?.TIENE_CUOTAS &&
        cuotaSeleccionada &&
        montoCuotaEdit != null &&
        !Number.isNaN(montoCuotaEdit)
      ) {
        const pagado = Number(cuotaSeleccionada.PAGADO) || 0;
        deudaMax = Math.max(0, montoCuotaEdit - pagado);
      }
      if (Number(abono.MONTO) > deudaMax + 0.001) {
        e.MONTO = `No puede superar la deuda (${dinero(deudaMax)}).`;
      }
    } else {
      if (!nueva.IDPLAN) e.IDPLAN = "Selecciona el plan.";
      if (!nueva.FECHAINICIO) e.FECHAINICIO = "Ingresa fecha de inicio.";
      if (!nueva.FECHAFIN) e.FECHAFIN = "Ingresa fecha de fin.";
      if (!nueva.MONTOTOTAL || Number(nueva.MONTOTOTAL) <= 0) e.MONTOTOTAL = "Ingresa el monto total.";
      if (!nueva.MONTO || Number(nueva.MONTO) <= 0) e.MONTO = "Ingresa el monto del pago.";
      if (!nueva.IDMETODOPAGO) e.IDMETODOPAGO = "Selecciona el método de pago.";
    }
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleGuardar = async (ev) => {
    ev.preventDefault();
    if (!validar()) return;
    setEnviando(true);
    try {
      const registradoPor = localStorage.getItem("idusuario") || "";
      let body;
      if (modo === "abono") {
        body = {
          TIPO: "abono",
          IDMENSUALIDAD: seleccionada.IDMENSUALIDAD,
          IDCUOTA: abono.IDCUOTA || null,
          MONTO: Number(abono.MONTO),
          MORA: abono.MORA === "" ? 0 : Number(abono.MORA),
          MONTO_CUOTA:
            abono.MONTO_CUOTA !== "" && abono.MONTO_CUOTA != null
              ? Number(abono.MONTO_CUOTA)
              : null,
          IDMETODOPAGO: abono.IDMETODOPAGO,
          OBSERVACIONES: abono.OBSERVACIONES || "Abono",
          REGISTRADOPOR: registradoPor,
        };
      } else {
        body = {
          TIPO: "nueva_mensualidad",
          IDUSUARIO: estudiante.IDUSUARIO,
          IDPLAN: nueva.IDPLAN,
          ESTADOMIEMBRO: 2,
          FECHAINICIO: inputToDb(nueva.FECHAINICIO),
          FECHAFIN: inputToDb(nueva.FECHAFIN),
          MONTOTOTAL: Number(nueva.MONTOTOTAL),
          MONTO: Number(nueva.MONTO),
          IDMETODOPAGO: nueva.IDMETODOPAGO,
          IDAULA: nueva.IDAULA || null,
          IDTUTOR: nueva.IDTUTOR || null,
          OBSERVACIONES: nueva.OBSERVACIONES || null,
          REGISTRADOPOR: registradoPor,
        };
      }
      const res = await fetch("/api/pagos/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await parseJsonResponse(res);
      if (!res.ok || !data.ok) throw new Error(data.mensaje || data.error || "Error al registrar");
      setToast({ mensaje: data.mensaje, tipo: "success" });
      volverLista();
      setVista("lista");
      await crud.listar();
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setEnviando(false);
    }
  };

  if (vista === "nuevo") {
    return (
      <>
        <div className="mantenedor-page form-page">
          <PageHeader
            modulo={cfg.modulo}
            listado={cfg.titulo}
            vista="Nuevo pago"
            titulo="Nuevo pago"
            mostrarNuevo={false}
            onListadoClick={volverLista}
          />

          <div className="pago-nuevo-layout">
            <form className="pago-nuevo-form mantenedor-card" onSubmit={handleGuardar}>
              <h3 className="pago-section-title">Estudiante</h3>
              <div className={`form-field full ${errors.estudiante ? "has-error" : ""}`}>
                <label>Buscar estudiante</label>
                <EstudianteSearchField
                  value={estudiante?.IDUSUARIO || ""}
                  estudianteSeleccionado={estudiante}
                  onChange={onEstudianteChange}
                />
                {errors.estudiante && <span className="field-error">{errors.estudiante}</span>}
              </div>

              {modo === "abono" && seleccionada && (
                <>
                  <h3 className="pago-section-title">Abono a mensualidad</h3>
                  <div className="pago-abono-info">
                    <div>
                      <strong>{seleccionada.PLAN_NOMBRE}</strong>
                      <span>
                        {dbToView(String(seleccionada.FECHAINICIO || ""))} —{" "}
                        {dbToView(String(seleccionada.FECHAFIN || ""))}
                      </span>
                    </div>
                    <div className="pago-abono-deuda">
                      Deuda exigible: <strong>{dinero(seleccionada.DEUDA)}</strong>
                    </div>
                  </div>
                  {errors.mensualidad && <span className="field-error">{errors.mensualidad}</span>}

                  {seleccionada.TIENE_CUOTAS && (
                    <div className={`form-field full ${errors.IDCUOTA ? "has-error" : ""}`}>
                      <label>Cuota a cobrar</label>
                      <select
                        value={abono.IDCUOTA}
                        onChange={(e) => seleccionarCuota(e.target.value)}
                      >
                        <option value="">Selecciona una cuota...</option>
                        {(seleccionada.CUOTAS || []).map((c) => (
                          <option key={c.IDCUOTA} value={c.IDCUOTA}>
                            {cuotaLabel(c)} · {dinero(c.MONTO)} · saldo {dinero(c.DEUDA)} ·{" "}
                            {c.ESTADO_CALC || c.ESTADO}
                          </option>
                        ))}
                      </select>
                      {errors.IDCUOTA && <span className="field-error">{errors.IDCUOTA}</span>}
                      {cuotaSeleccionada && (
                        <div className="pago-cuota-detalle">
                          <span>Pagado: {dinero(cuotaSeleccionada.PAGADO)}</span>
                          <span>Saldo: {dinero(cuotaSeleccionada.DEUDA)}</span>
                          <span className={`pago-cuota-estado estado-${(cuotaSeleccionada.ESTADO_CALC || "").toLowerCase()}`}>
                            {cuotaSeleccionada.ESTADO_CALC}
                          </span>
                        </div>
                      )}
                    </div>
                  )}

                  <div className="form-grid form-grid--half">
                    {seleccionada.TIENE_CUOTAS && (
                      <div className="form-field">
                        <label>Monto de la cuota (editable)</label>
                        <input
                          type="number"
                          step="0.01"
                          min="0"
                          value={abono.MONTO_CUOTA}
                          onChange={(e) =>
                            setAbono((p) => ({ ...p, MONTO_CUOTA: e.target.value }))
                          }
                        />
                      </div>
                    )}
                    <div className={`form-field ${errors.MONTO ? "has-error" : ""}`}>
                      <label>Monto a abonar</label>
                      <input
                        type="number"
                        step="0.01"
                        min="0"
                        value={abono.MONTO}
                        onChange={(e) => setAbono((p) => ({ ...p, MONTO: e.target.value }))}
                      />
                      {errors.MONTO && <span className="field-error">{errors.MONTO}</span>}
                    </div>
                    {cuotaSeleccionada?.VENCIDA && (
                      <div className={`form-field ${errors.MORA ? "has-error" : ""}`}>
                        <label>Mora por pago fuera de fecha</label>
                        <input
                          type="number"
                          step="0.01"
                          min="0"
                          value={abono.MORA}
                          placeholder="0.00"
                          onChange={(e) => setAbono((p) => ({ ...p, MORA: e.target.value }))}
                        />
                        <span className="field-hint">
                          Monto extra; no reduce el saldo de la cuota.
                        </span>
                        {errors.MORA && <span className="field-error">{errors.MORA}</span>}
                      </div>
                    )}
                    <div className={`form-field ${errors.IDMETODOPAGO ? "has-error" : ""}`}>
                      <label>Método de pago</label>
                      <select
                        value={abono.IDMETODOPAGO}
                        onChange={(e) => setAbono((p) => ({ ...p, IDMETODOPAGO: e.target.value }))}
                      >
                        <option value="">Selecciona...</option>
                        {catalogos.metodosPago.map((m) => (
                          <option key={m.value} value={m.value}>
                            {m.label}
                          </option>
                        ))}
                      </select>
                      {errors.IDMETODOPAGO && (
                        <span className="field-error">{errors.IDMETODOPAGO}</span>
                      )}
                    </div>
                    <div className="form-field full">
                      <label>Observaciones</label>
                      <textarea
                        rows={2}
                        value={abono.OBSERVACIONES}
                        onChange={(e) =>
                          setAbono((p) => ({ ...p, OBSERVACIONES: e.target.value }))
                        }
                      />
                    </div>
                  </div>
                </>
              )}

              {modo === "nueva" && (
                <>
                  <div className="form-grid form-grid--half">
                    <div className={`form-field ${errors.IDPLAN ? "has-error" : ""}`}>
                      <label>Plan</label>
                      <select
                        value={nueva.IDPLAN}
                        onChange={(e) => setNueva((p) => ({ ...p, IDPLAN: e.target.value }))}
                      >
                        <option value="">Selecciona...</option>
                        {catalogos.planes.map((m) => (
                          <option key={m.value} value={m.value}>
                            {m.label}
                          </option>
                        ))}
                      </select>
                      {errors.IDPLAN && <span className="field-error">{errors.IDPLAN}</span>}
                    </div>
                    <div className={`form-field ${errors.FECHAINICIO ? "has-error" : ""}`}>
                      <label>Fecha inicio</label>
                      <input
                        type="date"
                        value={nueva.FECHAINICIO}
                        onChange={(e) => setNueva((p) => ({ ...p, FECHAINICIO: e.target.value }))}
                      />
                      {errors.FECHAINICIO && (
                        <span className="field-error">{errors.FECHAINICIO}</span>
                      )}
                    </div>
                    <div className={`form-field ${errors.FECHAFIN ? "has-error" : ""}`}>
                      <label>Fecha fin</label>
                      <input
                        type="date"
                        value={nueva.FECHAFIN}
                        onChange={(e) => setNueva((p) => ({ ...p, FECHAFIN: e.target.value }))}
                      />
                      {errors.FECHAFIN && <span className="field-error">{errors.FECHAFIN}</span>}
                    </div>
                    <div className={`form-field ${errors.MONTOTOTAL ? "has-error" : ""}`}>
                      <label>Monto total mensualidad</label>
                      <input
                        type="number"
                        step="0.01"
                        min="0"
                        value={nueva.MONTOTOTAL}
                        onChange={(e) => setNueva((p) => ({ ...p, MONTOTOTAL: e.target.value }))}
                      />
                      {errors.MONTOTOTAL && (
                        <span className="field-error">{errors.MONTOTOTAL}</span>
                      )}
                    </div>
                    <div className={`form-field ${errors.MONTO ? "has-error" : ""}`}>
                      <label>Monto del pago</label>
                      <input
                        type="number"
                        step="0.01"
                        min="0"
                        value={nueva.MONTO}
                        onChange={(e) => setNueva((p) => ({ ...p, MONTO: e.target.value }))}
                      />
                      {errors.MONTO && <span className="field-error">{errors.MONTO}</span>}
                    </div>
                    <div className={`form-field ${errors.IDMETODOPAGO ? "has-error" : ""}`}>
                      <label>Método de pago</label>
                      <select
                        value={nueva.IDMETODOPAGO}
                        onChange={(e) => setNueva((p) => ({ ...p, IDMETODOPAGO: e.target.value }))}
                      >
                        <option value="">Selecciona...</option>
                        {catalogos.metodosPago.map((m) => (
                          <option key={m.value} value={m.value}>
                            {m.label}
                          </option>
                        ))}
                      </select>
                      {errors.IDMETODOPAGO && (
                        <span className="field-error">{errors.IDMETODOPAGO}</span>
                      )}
                    </div>
                    <div className="form-field">
                      <label>Salón</label>
                      <select
                        value={nueva.IDAULA}
                        onChange={(e) => setNueva((p) => ({ ...p, IDAULA: e.target.value }))}
                      >
                        <option value="">Selecciona...</option>
                        {catalogos.aulas.map((m) => (
                          <option key={m.value} value={m.value}>
                            {m.label}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="form-field">
                      <label>Tutor</label>
                      <select
                        value={nueva.IDTUTOR}
                        onChange={(e) => setNueva((p) => ({ ...p, IDTUTOR: e.target.value }))}
                      >
                        <option value="">Selecciona...</option>
                        {catalogos.tutores.map((m) => (
                          <option key={m.value} value={m.value}>
                            {m.label}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="form-field full">
                      <label>Observaciones</label>
                      <textarea
                        rows={2}
                        value={nueva.OBSERVACIONES}
                        onChange={(e) =>
                          setNueva((p) => ({ ...p, OBSERVACIONES: e.target.value }))
                        }
                      />
                    </div>
                  </div>
                </>
              )}

              <div className="pago-form-actions">
                {modo === "abono" && (
                  <button type="button" className="btn-secondary" onClick={iniciarNueva}>
                    Crear nueva mensualidad
                  </button>
                )}
                <button type="button" className="btn-secondary" onClick={volverLista}>
                  Cancelar
                </button>
                <button type="submit" className="btn-primary" disabled={enviando || !estudiante}>
                  {enviando && <FontAwesomeIcon icon={faSpinner} spin />}
                  {modo === "abono" ? "Registrar abono" : "Registrar pago y mensualidad"}
                </button>
              </div>
            </form>

            <aside className="pago-mensualidades-panel mantenedor-card">
              <h3 className="pago-section-title">Últimas mensualidades</h3>
              {!estudiante && (
                <p className="pago-hint">Busca un estudiante para ver sus últimas 3 mensualidades.</p>
              )}
              {estudiante && cargandoMem && <p className="pago-hint">Cargando...</p>}
              {estudiante && !cargandoMem && mensualidades.length === 0 && (
                <p className="pago-hint">Sin mensualidades activas. Registra una nueva con el pago.</p>
              )}
              <div className="pago-mensualidades-list">
                {mensualidades.map((m) => {
                  const deuda = Number(m.DEUDA) || 0;
                  const activa = seleccionada?.IDMENSUALIDAD === m.IDMENSUALIDAD;
                  const contenido = (
                    <>
                      <div className="pago-mensualidad-top">
                        <span
                          className={`badge-estado ${
                            m.ESTADOMIEMBRO_DESCRIPCION === "Vencido" ? "vencido" : "activo"
                          }`}
                        >
                          {m.ESTADOMIEMBRO_DESCRIPCION}
                        </span>
                      </div>
                      <div className="pago-mensualidad-resumen">
                        <div className="pago-mensualidad-resumen-izq">
                          <span className="pago-mensualidad-plan-tipo">{m.PLAN_NOMBRE}</span>
                          <span className="pago-mensualidad-mensual">
                            {m.PLAN_COSTOMENSUAL != null && m.PLAN_COSTOMENSUAL !== ""
                              ? `Mensual: ${dinero(m.PLAN_COSTOMENSUAL)}`
                              : "Sin costo mensual"}
                          </span>
                        </div>
                        <div className="pago-mensualidad-resumen-der">
                          <span className="pago-mensualidad-fechas">
                            {dbToView(String(m.FECHAINICIO || ""))} —{" "}
                            {dbToView(String(m.FECHAFIN || ""))}
                          </span>
                          <span>Total: {dinero(m.MONTOTOTAL)}</span>
                        </div>
                      </div>
                      <div className="pago-mensualidad-montos">
                        <span>Pagado: {dinero(m.PAGADO)}</span>
                        <span className={deuda > 0 ? "deuda" : "ok"}>
                          {deuda > 0 ? `Deuda exigible: ${dinero(deuda)}` : "Sin deuda exigible"}
                        </span>
                      </div>
                      {m.TIENE_CUOTAS && (
                        <div className="pago-mensualidad-cuotas-hint">
                          {(m.CUOTAS || []).filter((c) => Number(c.DEUDA) > 0 && c.EXIGIBLE).length}{" "}
                          cuota(s) con saldo · {(m.CUOTAS || []).length} periodos
                        </div>
                      )}
                      {deuda > 0 && (
                        <span className="pago-mensualidad-cta">Clic para abonar</span>
                      )}
                    </>
                  );

                  if (deuda > 0) {
                    return (
                      <button
                        key={m.IDMENSUALIDAD}
                        type="button"
                        className={`pago-mensualidad-card has-deuda ${activa ? "is-selected" : ""}`}
                        onClick={() => clickMensualidad(m)}
                      >
                        {contenido}
                      </button>
                    );
                  }

                  return (
                    <div
                      key={m.IDMENSUALIDAD}
                      className="pago-mensualidad-card sin-deuda"
                      aria-disabled="true"
                    >
                      {contenido}
                    </div>
                  );
                })}
              </div>
            </aside>
          </div>
        </div>
        {toast && (
          <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
        )}
      </>
    );
  }

  return (
    <div className="mantenedor-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} onNuevo={abrirNuevo} />

      <div className="mantenedor-card">
        <Toolbar
          buscar={crud.buscar}
          onBuscarChange={crud.onBuscarChange}
          placeholder="Buscar estudiante, DNI, plan..."
        />

        <DataTable
          columnas={cfg.columnas}
          items={crud.items}
          pk={cfg.pk}
          orden={crud.orden}
          loading={crud.loading}
          error={crud.error}
          onOrden={crud.toggleOrden}
          onVer={abrirVer}
          onVerPagos={abrirDetalleGrupo}
          onReintentar={crud.listar}
          pagina={crud.pagina}
          tamanio={crud.tamanio}
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>

      <PagoDetalleModal
        abierto={detalleAbierto}
        titulo="Pagos del estudiante"
        estudianteNombre={grupoSel?.ESTUDIANTE_NOMBRE}
        planNombre={grupoSel?.PLAN_NOMBRE}
        resumen={
          grupoSel
            ? {
                montoTotal: grupoSel.TOTAL,
                pagado: grupoSel.PAGADO,
                deuda: grupoSel.DEUDA,
              }
            : null
        }
        pagos={pagosDetalle}
        columnas={cfg.columnasDetalle}
        pk="IDPAGOMENSUALIDAD"
        loading={cargandoDetalle}
        onClose={cerrarDetalleGrupo}
        onVer={abrirVer}
        onEditar={abrirEditar}
        onEliminar={abrirEliminar}
      />

      <FormModal
        abierto={modalAbierto}
        modo={modoDetalle}
        titulo={
          modoDetalle === "editar" ? "Editar pago" : "Ver pago"
        }
        campos={cfg.camposEdicion}
        registro={crud.registro}
        catalogos={catalogos}
        onClose={() => setModalAbierto(false)}
        onSubmit={handleGuardarDetalle}
      />

      <ConfirmDialog
        abierto={Boolean(confirm)}
        titulo="Confirmar eliminación"
        mensaje={confirm?.mensaje}
        confirmando={confirmando}
        onCancel={() => setConfirm(null)}
        onConfirm={handleConfirmEliminar}
      />

      {toast && (
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

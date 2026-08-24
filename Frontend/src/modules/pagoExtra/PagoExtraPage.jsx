import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner } from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { pagoExtraConfig } from "./pagoExtra.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormModal from "../../components/mantenedor/FormModal";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import EstudianteSearchField from "../mensualidad/EstudianteSearchField";
import PagoExtraDetalleModal from "./PagoExtraDetalleModal";
import { dbToView, hoyInput, inputToDb } from "../../utils/fecha";
import "../../styles/mantenedor.css";
import "../pago/pago.css";
import "./pagoExtra.css";

function dinero(n) {
  const v = Number(n);
  if (Number.isNaN(v)) return "—";
  return `S/ ${v.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

const emptyNuevo = () => ({
  IDCONCEPTO: "",
  MONTO: "",
  FECHAPAGO: hoyInput(),
  OBSERVACIONES: "",
});

const emptyAbono = () => ({
  MONTO: "",
  FECHAPAGO: hoyInput(),
  OBSERVACIONES: "",
});

export default function PagoExtraPage() {
  const cfg = pagoExtraConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "DEUDA", direccion: "DESC" },
    filtrosIniciales: { idConcepto: "" },
  });

  const [grupoSel, setGrupoSel] = useState(null);
  const [detalleAbierto, setDetalleAbierto] = useState(false);
  const [pagosDetalle, setPagosDetalle] = useState([]);
  const [cargandoDetalle, setCargandoDetalle] = useState(false);

  const [vista, setVista] = useState("lista");
  const [toast, setToast] = useState(null);
  const [confirm, setConfirm] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [modalAbierto, setModalAbierto] = useState(false);
  const [modoDetalle, setModoDetalle] = useState("ver");
  const [conceptos, setConceptos] = useState([]);
  const [conceptosFiltro, setConceptosFiltro] = useState([]);
  const [estudiante, setEstudiante] = useState(null);
  const [conceptosEst, setConceptosEst] = useState([]);
  const [cargandoConceptos, setCargandoConceptos] = useState(false);
  const [seleccionado, setSeleccionado] = useState(null);
  const [modo, setModo] = useState("nuevo"); // nuevo | abono
  const [nuevo, setNuevo] = useState(emptyNuevo());
  const [abono, setAbono] = useState(emptyAbono());
  const [errors, setErrors] = useState({});
  const [enviando, setEnviando] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/pagos-extraordinarios/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setConceptos(
            (data.data?.conceptos || []).map((c) => ({
              value: c.IDCONCEPTO,
              label: `${c.NOMBRE} — S/ ${Number(c.COSTO).toLocaleString("es-PE", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}`,
              costo: Number(c.COSTO) || 0,
              nombre: c.NOMBRE,
            })),
          );
          setConceptosFiltro(
            (data.data?.conceptosFiltro || data.data?.conceptos || []).map((c) => ({
              value: c.IDCONCEPTO,
              label: c.NOMBRE,
            })),
          );
        }
      } catch {
        /* opcional */
      }
    })();
  }, []);

  const cargarConceptosEstudiante = async (idUsuario) => {
    if (!idUsuario) {
      setConceptosEst([]);
      return;
    }
    setCargandoConceptos(true);
    try {
      const res = await fetch(
        `/api/pagos-extraordinarios/estudiante/${encodeURIComponent(idUsuario)}/conceptos/`,
      );
      const data = await parseJsonResponse(res);
      if (res.ok) {
        const list = data.data || [];
        setConceptosEst(list);
        const conDeuda = list.find((c) => Number(c.DEUDA) > 0);
        if (conDeuda) {
          setSeleccionado(conDeuda);
          setModo("abono");
          setAbono(emptyAbono());
        } else {
          setSeleccionado(null);
          setModo("nuevo");
          setNuevo(emptyNuevo());
        }
      }
    } catch {
      setConceptosEst([]);
    } finally {
      setCargandoConceptos(false);
    }
  };

  const onEstudianteChange = (_id, est) => {
    setEstudiante(est);
    setErrors({});
    setSeleccionado(null);
    setModo("nuevo");
    setNuevo(emptyNuevo());
    setAbono(emptyAbono());
    cargarConceptosEstudiante(est?.IDUSUARIO);
  };

  const clickConcepto = (c) => {
    if (Number(c.DEUDA) <= 0) return;
    setSeleccionado(c);
    setModo("abono");
    setAbono(emptyAbono());
    setErrors({});
  };

  const iniciarNuevoConcepto = () => {
    setSeleccionado(null);
    setModo("nuevo");
    setNuevo(emptyNuevo());
    setErrors({});
  };

  const volverLista = () => {
    setVista("lista");
    setEstudiante(null);
    setConceptosEst([]);
    setSeleccionado(null);
    setModo("nuevo");
    setNuevo(emptyNuevo());
    setAbono(emptyAbono());
    setErrors({});
  };

  const abrirNuevo = () => {
    volverLista();
    setVista("nuevo");
  };

  const onConceptoChange = (id) => {
    const c = conceptos.find((x) => x.value === id);
    setNuevo((prev) => ({
      ...prev,
      IDCONCEPTO: id,
      MONTO: c ? String(c.costo) : prev.MONTO,
    }));
  };

  const validate = () => {
    const next = {};
    if (!estudiante?.IDUSUARIO) next.estudiante = "Selecciona un estudiante.";
    if (modo === "abono") {
      if (!seleccionado?.IDCONCEPTO) next.concepto = "Selecciona un concepto con deuda.";
      if (!abono.MONTO || Number(abono.MONTO) <= 0) next.MONTO = "Ingresa el monto a abonar.";
      if (!abono.FECHAPAGO) next.FECHAPAGO = "Ingresa la fecha del pago.";
    } else {
      if (!nuevo.IDCONCEPTO) next.IDCONCEPTO = "Selecciona un concepto.";
      if (!nuevo.MONTO || Number(nuevo.MONTO) <= 0) next.MONTO = "Ingresa un monto válido.";
      if (!nuevo.FECHAPAGO) next.FECHAPAGO = "Ingresa la fecha del pago.";
    }
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  const handleGuardar = async (e) => {
    e.preventDefault();
    if (!validate()) return;
    setEnviando(true);
    try {
      const body =
        modo === "abono"
          ? {
              IDUSUARIO: estudiante.IDUSUARIO,
              IDCONCEPTO: seleccionado.IDCONCEPTO,
              MONTO: Number(abono.MONTO),
              FECHAPAGO: inputToDb(abono.FECHAPAGO),
              OBSERVACIONES: abono.OBSERVACIONES || null,
              IDREGISTRADOR: localStorage.getItem("idusuario") || null,
            }
          : {
              IDUSUARIO: estudiante.IDUSUARIO,
              IDCONCEPTO: nuevo.IDCONCEPTO,
              MONTO: Number(nuevo.MONTO),
              FECHAPAGO: inputToDb(nuevo.FECHAPAGO),
              OBSERVACIONES: nuevo.OBSERVACIONES || null,
              IDREGISTRADOR: localStorage.getItem("idusuario") || null,
            };

      const res = await fetch("/api/pagos-extraordinarios/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await parseJsonResponse(res);
      if (!res.ok || !data.ok) {
        throw new Error(data.mensaje || data.error || "Error al guardar");
      }
      setToast({
        mensaje: data.mensaje || (modo === "abono" ? "Abono registrado" : "Registrado"),
        tipo: "success",
      });
      volverLista();
      await crud.listar();
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setEnviando(false);
    }
  };

  const cargarDetalleGrupo = async (grupo) => {
    if (!grupo?.IDUSUARIO || !grupo?.IDCONCEPTO) return;
    setCargandoDetalle(true);
    try {
      const params = new URLSearchParams({
        idUsuario: grupo.IDUSUARIO,
        idConcepto: grupo.IDCONCEPTO,
      });
      const res = await fetch(`/api/pagos-extraordinarios/detalle/?${params}`);
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

  const abrirVer = async (row) => {
    try {
      const data = await crud.obtener(row.IDPAGOEXTRA);
      crud.setRegistro(data);
      setModoDetalle("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row.IDPAGOEXTRA);
      crud.setRegistro(data);
      setModoDetalle("editar");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    setConfirm({
      id: row.IDPAGOEXTRA,
      mensaje: `¿Eliminar el pago de ${dinero(row.MONTO)} del ${dbToView(String(row.FECHAPAGO || ""))}?`,
      grupo: grupoSel,
    });
  };

  const handleGuardarDetalle = async (payload) => {
    const body = {
      IDCONCEPTO: payload.IDCONCEPTO,
      MONTO: Number(payload.MONTO),
      FECHAPAGO: payload.FECHAPAGO,
      OBSERVACIONES: payload.OBSERVACIONES || null,
    };
    const mensaje = await crud.actualizar(crud.registro.IDPAGOEXTRA, body);
    setToast({ mensaje, tipo: "success" });
    setModalAbierto(false);
    await crud.listar();
    if (grupoSel) await cargarDetalleGrupo(grupoSel);
  };

  const handleConfirmEliminar = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      const res = await fetch(
        `/api/pagos-extraordinarios/${encodeURIComponent(confirm.id)}/`,
        { method: "DELETE" },
      );
      const data = await parseJsonResponse(res);
      if (!res.ok || !data.ok) {
        throw new Error(data.mensaje || data.error || "Error al eliminar");
      }
      setToast({ mensaje: data.mensaje, tipo: "success" });
      setConfirm(null);
      await crud.listar();
      if (confirm.grupo) await cargarDetalleGrupo(confirm.grupo);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setConfirmando(false);
    }
  };

  const camposDetalle = [
    { campo: "ESTUDIANTE_NOMBRE", etiqueta: "Estudiante", control: "text", bloqueado: true },
    {
      campo: "IDCONCEPTO",
      etiqueta: "Concepto",
      control: "select",
      catalogo: "conceptos",
      obligatorio: true,
    },
    { campo: "MONTO", etiqueta: "Monto", control: "number", obligatorio: true },
    { campo: "FECHAPAGO", etiqueta: "Fecha de pago", control: "date", obligatorio: true },
    { campo: "OBSERVACIONES", etiqueta: "Observaciones", control: "textarea", full: true },
  ];

  if (vista === "nuevo") {
    return (
      <>
        <div className="mantenedor-page form-page">
          <PageHeader
            modulo={cfg.modulo}
            listado={cfg.titulo}
            vista="Nuevo pago extraordinario"
            titulo="Nuevo pago extraordinario"
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

              {modo === "abono" && seleccionado && (
                <>
                  <h3 className="pago-section-title">Abono a concepto</h3>
                  <div className="pago-abono-info">
                    <div>
                      <strong>{seleccionado.CONCEPTO_NOMBRE}</strong>
                      <span>
                        {dbToView(String(seleccionado.FECHAINICIO || ""))} —{" "}
                        {dbToView(String(seleccionado.FECHAFIN || ""))}
                      </span>
                    </div>
                    <div className="pago-abono-deuda">
                      Deuda: <strong>{dinero(seleccionado.DEUDA)}</strong>
                    </div>
                  </div>
                  {errors.concepto && <span className="field-error">{errors.concepto}</span>}

                  <div className="form-grid form-grid--half">
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
                    <div className={`form-field ${errors.FECHAPAGO ? "has-error" : ""}`}>
                      <label>Fecha de pago</label>
                      <input
                        type="date"
                        value={abono.FECHAPAGO}
                        onChange={(e) => setAbono((p) => ({ ...p, FECHAPAGO: e.target.value }))}
                      />
                      {errors.FECHAPAGO && <span className="field-error">{errors.FECHAPAGO}</span>}
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

              {modo === "nuevo" && (
                <>
                  <h3 className="pago-section-title">Datos del pago</h3>
                  <div className="form-grid form-grid--half">
                    <div className={`form-field ${errors.IDCONCEPTO ? "has-error" : ""}`}>
                      <label>Concepto</label>
                      <select
                        value={nuevo.IDCONCEPTO}
                        onChange={(e) => onConceptoChange(e.target.value)}
                      >
                        <option value="">Selecciona...</option>
                        {conceptos.map((c) => (
                          <option key={c.value} value={c.value}>
                            {c.label}
                          </option>
                        ))}
                      </select>
                      {errors.IDCONCEPTO && (
                        <span className="field-error">{errors.IDCONCEPTO}</span>
                      )}
                      {conceptos.length === 0 && (
                        <span className="field-hint">
                          No hay conceptos vigentes. Créalos en Mantenedores → Conceptos.
                        </span>
                      )}
                    </div>

                    <div className={`form-field ${errors.MONTO ? "has-error" : ""}`}>
                      <label>Monto</label>
                      <input
                        type="number"
                        step="0.01"
                        min="0"
                        value={nuevo.MONTO}
                        onChange={(e) => setNuevo((p) => ({ ...p, MONTO: e.target.value }))}
                      />
                      {errors.MONTO && <span className="field-error">{errors.MONTO}</span>}
                    </div>

                    <div className={`form-field ${errors.FECHAPAGO ? "has-error" : ""}`}>
                      <label>Fecha de pago (abono)</label>
                      <input
                        type="date"
                        value={nuevo.FECHAPAGO}
                        onChange={(e) => setNuevo((p) => ({ ...p, FECHAPAGO: e.target.value }))}
                      />
                      {errors.FECHAPAGO && (
                        <span className="field-error">{errors.FECHAPAGO}</span>
                      )}
                    </div>

                    <div className="form-field full">
                      <label>Observaciones</label>
                      <textarea
                        rows={2}
                        value={nuevo.OBSERVACIONES}
                        onChange={(e) =>
                          setNuevo((p) => ({ ...p, OBSERVACIONES: e.target.value }))
                        }
                      />
                    </div>
                  </div>
                </>
              )}

              <div className="pago-form-actions">
                {modo === "abono" && (
                  <button type="button" className="btn-secondary" onClick={iniciarNuevoConcepto}>
                    Nuevo concepto
                  </button>
                )}
                <button type="button" className="btn-secondary" onClick={volverLista}>
                  Cancelar
                </button>
                <button type="submit" className="btn-primary" disabled={enviando || !estudiante}>
                  {enviando && <FontAwesomeIcon icon={faSpinner} spin />}
                  {modo === "abono" ? "Registrar abono" : "Registrar pago"}
                </button>
              </div>
            </form>

            <aside className="pago-mensualidads-panel mantenedor-card">
              <h3 className="pago-section-title">Últimos conceptos</h3>
              {!estudiante && (
                <p className="pago-hint">Busca un estudiante para ver sus últimos conceptos.</p>
              )}
              {estudiante && cargandoConceptos && <p className="pago-hint">Cargando...</p>}
              {estudiante && !cargandoConceptos && conceptosEst.length === 0 && (
                <p className="pago-hint">Sin pagos previos. Registra un nuevo concepto.</p>
              )}
              <div className="pago-mensualidads-list">
                {conceptosEst.map((c) => {
                  const deuda = Number(c.DEUDA) || 0;
                  const activa = seleccionado?.IDCONCEPTO === c.IDCONCEPTO;
                  const contenido = (
                    <>
                      <div className="pago-mensualidad-top">
                        <strong>{c.CONCEPTO_NOMBRE}</strong>
                      </div>
                      <div className="pago-mensualidad-fechas">
                        {dbToView(String(c.FECHAINICIO || ""))} —{" "}
                        {dbToView(String(c.FECHAFIN || ""))}
                      </div>
                      <div className="pago-mensualidad-montos">
                        <span>Costo: {dinero(c.COSTO)}</span>
                        <span>Pagado: {dinero(c.PAGADO)}</span>
                        <span className={deuda > 0 ? "deuda" : "ok"}>
                          {deuda > 0 ? `Deuda: ${dinero(deuda)}` : "Sin deuda"}
                        </span>
                      </div>
                      {deuda > 0 && (
                        <span className="pago-mensualidad-cta">Clic para abonar</span>
                      )}
                    </>
                  );

                  if (deuda > 0) {
                    return (
                      <button
                        key={c.IDCONCEPTO}
                        type="button"
                        className={`pago-mensualidad-card has-deuda ${activa ? "is-selected" : ""}`}
                        onClick={() => clickConcepto(c)}
                      >
                        {contenido}
                      </button>
                    );
                  }

                  return (
                    <div
                      key={c.IDCONCEPTO}
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
          placeholder="Buscar estudiante, DNI, concepto..."
          filtros={[
            {
              key: "idConcepto",
              etiqueta: "Concepto",
              value: crud.filtros.idConcepto || "",
              opciones: conceptosFiltro,
              onChange: (v) => crud.setFiltro("idConcepto", v),
            },
          ]}
        />

        <DataTable
          columnas={cfg.columnas}
          items={crud.items}
          pk={cfg.pk}
          orden={crud.orden}
          loading={crud.loading}
          error={crud.error}
          onOrden={crud.toggleOrden}
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

      <PagoExtraDetalleModal
        abierto={detalleAbierto}
        titulo="Pagos del concepto"
        estudianteNombre={grupoSel?.ESTUDIANTE_NOMBRE}
        conceptoNombre={grupoSel?.CONCEPTO_NOMBRE}
        resumen={
          grupoSel
            ? {
                montoTotal: grupoSel.MONTO_TOTAL,
                pagado: grupoSel.PAGADO,
                deuda: grupoSel.DEUDA,
              }
            : null
        }
        pagos={pagosDetalle}
        columnas={cfg.columnasDetalle}
        pk="IDPAGOEXTRA"
        loading={cargandoDetalle}
        onClose={cerrarDetalleGrupo}
        onVer={abrirVer}
        onEditar={abrirEditar}
        onEliminar={abrirEliminar}
      />

      <FormModal
        abierto={modalAbierto}
        modo={modoDetalle}
        titulo={modoDetalle === "ver" ? "Ver pago extraordinario" : "Editar pago extraordinario"}
        campos={camposDetalle}
        registro={crud.registro}
        catalogos={{
          conceptos: conceptos.map((c) => ({ value: c.value, label: c.nombre || c.label })),
        }}
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
        <Toast
          mensaje={toast.mensaje}
          tipo={toast.tipo}
          onClose={() => setToast(null)}
        />
      )}
    </div>
  );
}

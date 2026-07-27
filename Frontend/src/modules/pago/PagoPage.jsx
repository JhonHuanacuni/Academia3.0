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
  MONTO: "",
  IDMETODOPAGO: "MPG001",
  OBSERVACIONES: "",
});

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
    ordenInicial: { campo: "FECHAPAGO", direccion: "DESC" },
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
          setAbono({
            ...emptyAbono(),
            MONTO: String(conDeuda.DEUDA),
          });
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
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModoDetalle("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModoDetalle("editar");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    const nombre = row.ESTUDIANTE_NOMBRE || row[cfg.pk];
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar el pago de «${nombre}» por ${dinero(row.MONTO)}? Esta acción no se puede deshacer.`,
    });
  };

  const handleGuardarDetalle = async (payload) => {
    const mensaje = await crud.actualizar(crud.registro[cfg.pk], {
      MONTO: payload.MONTO === "" ? null : Number(payload.MONTO),
      IDMETODOPAGO: payload.IDMETODOPAGO,
      FECHAPAGO: payload.FECHAPAGO,
      OBSERVACIONES: payload.OBSERVACIONES || null,
    });
    setToast({ mensaje, tipo: "success" });
    await crud.listar();
  };

  const handleConfirmEliminar = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      const mensaje = await crud.eliminar(confirm.id);
      setToast({ mensaje, tipo: "success" });
      setConfirm(null);
      await crud.listar();
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
    setAbono({
      ...emptyAbono(),
      MONTO: String(deuda),
    });
    setErrors({});
  };

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
      if (!abono.MONTO || Number(abono.MONTO) <= 0) e.MONTO = "Ingresa el monto del abono.";
      if (!abono.IDMETODOPAGO) e.IDMETODOPAGO = "Selecciona el método de pago.";
      const deuda = Number(seleccionada?.DEUDA) || 0;
      if (Number(abono.MONTO) > deuda) e.MONTO = `No puede superar la deuda (${dinero(deuda)}).`;
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
          MONTO: Number(abono.MONTO),
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
                      Deuda: <strong>{dinero(seleccionada.DEUDA)}</strong>
                    </div>
                  </div>
                  {errors.mensualidad && <span className="field-error">{errors.mensualidad}</span>}

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
          onEditar={abrirEditar}
          onEliminar={abrirEliminar}
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

import { useEffect, useMemo, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faChartPie,
  faChevronDown,
  faGear,
  faListOl,
  faSearch,
  faSpinner,
} from "@fortawesome/free-solid-svg-icons";
import PageHeader from "../../components/mantenedor/PageHeader";
import ExamenDistribucion from "./ExamenDistribucion";
import ExamenPreguntaEditor from "./ExamenPreguntaEditor";
import { parseJsonResponse } from "../../utils/api";
import { dbToInput, inputToDb, hoyInput } from "../../utils/fecha";
import "./examen.css";
import "../../styles/mantenedor.css";

const TABS = [
  { id: "config", label: "Configuración", icon: faGear },
  { id: "distribucion", label: "Distribución", icon: faChartPie },
  { id: "preguntas", label: "Preguntas", icon: faListOl },
];

function horaToInput(h) {
  if (!h) return "";
  const s = String(h);
  return s.length >= 5 ? s.slice(0, 5) : s;
}

function horaToDb(h) {
  if (!h) return null;
  const s = String(h).trim();
  if (!s) return null;
  return s.length === 5 ? `${s}:00` : s;
}

function emptyForm() {
  return {
    TITULO: "",
    DESCRIPCION: "",
    TIPO: 40,
    DURACIONMIN: 120,
    FECHAINICIO: hoyInput(),
    FECHAFIN: hoyInput(),
    HORAINICIO: "08:00",
    HORAFIN: "10:00",
    VISIBLE: true,
    TODASLASULA: true,
    AULAS: [],
  };
}

function fromRegistro(reg) {
  return {
    TITULO: reg.TITULO || "",
    DESCRIPCION: reg.DESCRIPCION || "",
    TIPO: Number(reg.TIPO) || 40,
    DURACIONMIN: Number(reg.DURACIONMIN) || 120,
    FECHAINICIO: dbToInput(String(reg.FECHAINICIO || "")) || hoyInput(),
    FECHAFIN: dbToInput(String(reg.FECHAFIN || "")) || hoyInput(),
    HORAINICIO: horaToInput(reg.HORAINICIO) || "08:00",
    HORAFIN: horaToInput(reg.HORAFIN) || "10:00",
    VISIBLE: Boolean(reg.VISIBLE),
    TODASLASULA: reg.TODASLASULA !== false && reg.TODASLASULA !== 0,
    AULAS: Array.isArray(reg.AULAS) ? [...reg.AULAS] : [],
  };
}

export default function ExamenFormPage({
  modo,
  registro,
  aulas = [],
  onCancel,
  onSaved,
  onToast,
}) {
  const soloLectura = modo === "ver";
  const [tab, setTab] = useState("config");
  const [values, setValues] = useState(emptyForm());
  const [errors, setErrors] = useState({});
  const [enviando, setEnviando] = useState(false);
  const [dist, setDist] = useState({ categorias: [], materias: [] });
  const [preguntas, setPreguntas] = useState([]);
  const [preguntaSel, setPreguntaSel] = useState(null);
  const [detallePreg, setDetallePreg] = useState(null);
  const [idExamen, setIdExamen] = useState(null);
  const [filtroPreg, setFiltroPreg] = useState("");
  const [catsAbiertas, setCatsAbiertas] = useState(() => new Set());

  const titulo =
    modo === "crear" ? "Nuevo examen" : modo === "editar" ? "Editar examen" : "Ver examen";

  useEffect(() => {
    if (modo === "crear") {
      setValues(emptyForm());
      setIdExamen(null);
      setPreguntas([]);
      setPreguntaSel(null);
      setDetallePreg(null);
      setTab("config");
    } else if (registro) {
      setValues(fromRegistro(registro));
      setIdExamen(registro.IDEXAMEN);
      setPreguntas(registro.PREGUNTAS || []);
      const first = (registro.PREGUNTAS || [])[0];
      setPreguntaSel(first?.IDPREGUNTA || null);
      setTab("config");
    }
    setErrors({});
  }, [modo, registro]);

  useEffect(() => {
    (async () => {
      try {
        const params = idExamen
          ? `idExamen=${encodeURIComponent(idExamen)}`
          : `tipo=${encodeURIComponent(values.TIPO || 40)}`;
        const res = await fetch(`/api/examenes/distribucion/?${params}`);
        const data = await parseJsonResponse(res);
        if (res.ok) setDist(data.data || { categorias: [], materias: [] });
      } catch {
        setDist({ categorias: [], materias: [] });
      }
    })();
  }, [values.TIPO, idExamen]);

  useEffect(() => {
    if (!idExamen || !preguntaSel || tab !== "preguntas") {
      if (!preguntaSel) setDetallePreg(null);
      return;
    }
    (async () => {
      try {
        const res = await fetch(
          `/api/examenes/${encodeURIComponent(idExamen)}/preguntas/${encodeURIComponent(preguntaSel)}/`,
        );
        const data = await parseJsonResponse(res);
        if (res.ok) setDetallePreg(data.data);
      } catch {
        setDetallePreg(null);
      }
    })();
  }, [idExamen, preguntaSel, tab]);

  const setField = (campo, val) => setValues((prev) => ({ ...prev, [campo]: val }));

  const minutosSugeridos = useMemo(() => {
    try {
      const di = values.FECHAINICIO;
      const df = values.FECHAFIN;
      const hi = values.HORAINICIO || "00:00";
      const hf = values.HORAFIN || "00:00";
      if (!di || !df) return null;
      const start = new Date(`${di}T${hi.length === 5 ? hi : hi.slice(0, 5)}:00`);
      const end = new Date(`${df}T${hf.length === 5 ? hf : hf.slice(0, 5)}:00`);
      if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) return null;
      const mins = Math.round((end - start) / 60000);
      return mins > 0 ? mins : null;
    } catch {
      return null;
    }
  }, [values.FECHAINICIO, values.FECHAFIN, values.HORAINICIO, values.HORAFIN]);

  const toggleAula = (id) => {
    if (soloLectura) return;
    setValues((prev) => {
      const set = new Set(prev.AULAS || []);
      if (set.has(id)) set.delete(id);
      else set.add(id);
      return { ...prev, AULAS: [...set] };
    });
  };

  const validateConfig = () => {
    const next = {};
    if (!String(values.TITULO || "").trim()) next.TITULO = "Ingresa el título.";
    if (!values.FECHAINICIO) next.FECHAINICIO = "Ingresa fecha de inicio.";
    if (!values.FECHAFIN) next.FECHAFIN = "Ingresa fecha de cierre.";
    if (!values.TODASLASULA && !(values.AULAS || []).length) {
      next.AULAS = "Selecciona al menos un salón.";
    }
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  const payloadConfig = () => ({
    TITULO: values.TITULO.trim(),
    DESCRIPCION: values.DESCRIPCION,
    TIPO: Number(values.TIPO) || 40,
    DURACIONMIN: Number(values.DURACIONMIN) || minutosSugeridos || 120,
    FECHAINICIO: inputToDb(values.FECHAINICIO),
    FECHAFIN: inputToDb(values.FECHAFIN),
    HORAINICIO: horaToDb(values.HORAINICIO),
    HORAFIN: horaToDb(values.HORAFIN),
    VISIBLE: Boolean(values.VISIBLE),
    TODASLASULA: Boolean(values.TODASLASULA),
    AULAS: values.TODASLASULA ? [] : values.AULAS,
    IDUSUARIO: localStorage.getItem("idusuario") || "",
  });

  const crearExamen = async () => {
    if (!validateConfig()) return;
    try {
      setEnviando(true);
      const res = await fetch("/api/examenes/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payloadConfig()),
      });
      const data = await parseJsonResponse(res);
      if (!res.ok || !data.ok) throw new Error(data.mensaje || data.error || "Error al crear");
      onToast?.({ mensaje: data.mensaje, tipo: "success" });
      const id = data.id;
      setIdExamen(id);
      const det = await fetch(`/api/examenes/${encodeURIComponent(id)}/`);
      const detData = await parseJsonResponse(det);
      if (det.ok) {
        setPreguntas(detData.data?.PREGUNTAS || []);
        setPreguntaSel(detData.data?.PREGUNTAS?.[0]?.IDPREGUNTA || null);
      }
      setTab("preguntas");
      onSaved?.(id, "editar");
    } catch (err) {
      onToast?.({ mensaje: err.message, tipo: "error" });
    } finally {
      setEnviando(false);
    }
  };

  const guardarConfig = async () => {
    if (!idExamen) return crearExamen();
    if (!validateConfig()) return;
    try {
      setEnviando(true);
      const res = await fetch(`/api/examenes/${encodeURIComponent(idExamen)}/`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payloadConfig()),
      });
      const data = await parseJsonResponse(res);
      if (!res.ok || !data.ok) throw new Error(data.mensaje || data.error || "Error al guardar");
      onToast?.({ mensaje: data.mensaje, tipo: "success" });
    } catch (err) {
      onToast?.({ mensaje: err.message, tipo: "error" });
    } finally {
      setEnviando(false);
    }
  };

  const guardarPregunta = async (payload) => {
    if (!idExamen || !preguntaSel) return;
    const fd = new FormData();
    fd.append("DESCRIPCION", payload.DESCRIPCION ?? "");
    fd.append("ALT1", payload.ALT1 ?? "");
    fd.append("ALT2", payload.ALT2 ?? "");
    fd.append("ALT3", payload.ALT3 ?? "");
    fd.append("ALT4", payload.ALT4 ?? "");
    fd.append("ALT5", payload.ALT5 ?? "");
    fd.append("CORRECTA_ORDEN", String(payload.CORRECTA_ORDEN || 1));
    fd.append("QUITAR_IMAGEN", payload.QUITAR_IMAGEN ? "1" : "0");
    if (payload.imagen) fd.append("imagen", payload.imagen);
    (payload.imagenesAlt || []).forEach((file, i) => {
      if (file) fd.append(`imagen_alt${i + 1}`, file);
    });
    (payload.quitarImagenesAlt || []).forEach((q, i) => {
      fd.append(`QUITAR_IMG_ALT${i + 1}`, q ? "1" : "0");
    });

    // POST: Django sí parsea multipart; PUT no.
    const res = await fetch(
      `/api/examenes/${encodeURIComponent(idExamen)}/preguntas/${encodeURIComponent(preguntaSel)}/`,
      { method: "POST", body: fd },
    );
    const data = await parseJsonResponse(res);
    if (!res.ok || !data.ok) throw new Error(data.mensaje || data.error || "Error al guardar");
    setDetallePreg(data.data);
    setPreguntas((prev) =>
      prev.map((p) =>
        p.IDPREGUNTA === preguntaSel
          ? {
              ...p,
              DESCRIPCION: data.data?.DESCRIPCION,
              IMAGEURL: data.data?.IMAGEURL,
              URLPREVIEW: data.data?.URLPREVIEW,
            }
          : p,
      ),
    );
    onToast?.({ mensaje: data.mensaje, tipo: "success" });
  };

  const preguntaCompleta = (p) => Boolean(String(p.DESCRIPCION || "").trim());

  const preguntasFiltradas = useMemo(() => {
    const q = filtroPreg.trim().toLowerCase();
    if (!q) return preguntas;
    return preguntas.filter(
      (p) =>
        String(p.ORDEN).includes(q) ||
        (p.MATERIA_NOMBRE || "").toLowerCase().includes(q) ||
        (p.MATERIA_CODIGO || "").toLowerCase().includes(q) ||
        (p.CATEGORIA_NOMBRE || "").toLowerCase().includes(q),
    );
  }, [preguntas, filtroPreg]);

  const gruposCategoria = useMemo(() => {
    const map = new Map();
    for (const p of preguntasFiltradas) {
      const id = p.IDCATEGORIA || "_sin";
      const nombre = p.CATEGORIA_NOMBRE || "Sin categoría";
      if (!map.has(id)) {
        map.set(id, { id, nombre, preguntas: [] });
      }
      map.get(id).preguntas.push(p);
    }
    return [...map.values()];
  }, [preguntasFiltradas]);

  // Abrir categoría de la pregunta seleccionada / todas al filtrar
  useEffect(() => {
    if (filtroPreg.trim()) {
      setCatsAbiertas((prev) => {
        const ids = [...new Set(preguntasFiltradas.map((p) => p.IDCATEGORIA || "_sin"))];
        if (ids.length === prev.size && ids.every((id) => prev.has(id))) return prev;
        return new Set(ids);
      });
      return;
    }
    if (!preguntaSel) return;
    const p = preguntas.find((x) => x.IDPREGUNTA === preguntaSel);
    if (!p) return;
    const id = p.IDCATEGORIA || "_sin";
    setCatsAbiertas((prev) => {
      if (prev.has(id)) return prev;
      const next = new Set(prev);
      next.add(id);
      return next;
    });
  }, [preguntaSel, preguntas, filtroPreg, preguntasFiltradas]);

  const toggleCategoria = (id) => {
    setCatsAbiertas((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const incompletas = preguntas.filter((p) => !preguntaCompleta(p)).length;

  const irTab = (id) => {
    if (id === "preguntas" && !idExamen) {
      onToast?.({
        mensaje: "Primero crea el examen en Configuración para generar las preguntas.",
        tipo: "error",
      });
      return;
    }
    setTab(id);
  };

  return (
    <div className="mantenedor-page examen-form">
      <PageHeader
        modulo="Académico"
        listado="Exámenes"
        vista={titulo}
        onListadoClick={onCancel}
        mostrarNuevo={false}
      />

      <div className="ui-tabs-panel examen-tabs-panel">
        <div className="ui-tabs" role="tablist" aria-label="Secciones del examen">
          {TABS.map((t) => (
            <button
              key={t.id}
              type="button"
              role="tab"
              aria-selected={tab === t.id}
              className={`ui-tab${tab === t.id ? " ui-tab--activa" : ""}`}
              onClick={() => irTab(t.id)}
            >
              <FontAwesomeIcon icon={t.icon} />
              {t.label}
              {t.id === "preguntas" && idExamen ? (
                <span className="examen-tab-count">
                  {preguntas.length - incompletas}/{preguntas.length}
                </span>
              ) : null}
            </button>
          ))}
        </div>

        <div className="ui-tabs-panel-body" role="tabpanel">
      {tab === "config" && (
        <div className="examen-config form-page">
          <div className="examen-config-body">
            <div className="form-section-row">
              <section className="form-section form-section--card">
                <h3 className="form-section-title">Datos generales</h3>
                <div className="form-grid form-grid--half">
                  <div className={`form-field full ${errors.TITULO ? "has-error" : ""}`}>
                    <label>Título del examen</label>
                    <input
                      value={values.TITULO}
                      disabled={soloLectura}
                      onChange={(e) => setField("TITULO", e.target.value)}
                      placeholder="Ej: Examen de Admisión 2026"
                    />
                    {errors.TITULO && <span className="field-error">{errors.TITULO}</span>}
                  </div>
                  <div className="form-field">
                    <label>Tipo de examen</label>
                    <select
                      value={values.TIPO}
                      disabled={soloLectura || Boolean(idExamen)}
                      onChange={(e) => setField("TIPO", Number(e.target.value))}
                    >
                      <option value={40}>40 preguntas</option>
                      <option value={100}>100 preguntas</option>
                    </select>
                    {idExamen && (
                      <span className="field-hint">
                        El tipo no se puede cambiar después de crear el examen.
                      </span>
                    )}
                  </div>
                  <div className="form-field full">
                    <label>Descripción</label>
                    <textarea
                      value={values.DESCRIPCION}
                      disabled={soloLectura}
                      rows={4}
                      placeholder="Descripción general del examen..."
                      onChange={(e) => setField("DESCRIPCION", e.target.value)}
                    />
                  </div>
                </div>
              </section>

              <section className="form-section form-section--card">
                <h3 className="form-section-title">Fechas y duración</h3>
                <div className="form-grid form-grid--half">
                  <div className={`form-field ${errors.FECHAINICIO ? "has-error" : ""}`}>
                    <label>Fecha de inicio</label>
                    <input
                      type="date"
                      value={values.FECHAINICIO}
                      disabled={soloLectura}
                      onChange={(e) => setField("FECHAINICIO", e.target.value)}
                    />
                    {errors.FECHAINICIO && <span className="field-error">{errors.FECHAINICIO}</span>}
                  </div>
                  <div className="form-field">
                    <label>Hora de inicio</label>
                    <input
                      type="time"
                      value={values.HORAINICIO}
                      disabled={soloLectura}
                      onChange={(e) => setField("HORAINICIO", e.target.value)}
                    />
                  </div>
                  <div className={`form-field ${errors.FECHAFIN ? "has-error" : ""}`}>
                    <label>Fecha de cierre</label>
                    <input
                      type="date"
                      value={values.FECHAFIN}
                      disabled={soloLectura}
                      onChange={(e) => setField("FECHAFIN", e.target.value)}
                    />
                    {errors.FECHAFIN && <span className="field-error">{errors.FECHAFIN}</span>}
                  </div>
                  <div className="form-field">
                    <label>Hora de cierre</label>
                    <input
                      type="time"
                      value={values.HORAFIN}
                      disabled={soloLectura}
                      onChange={(e) => setField("HORAFIN", e.target.value)}
                    />
                  </div>
                  <div className="form-field full">
                    <label>Tiempo límite (minutos)</label>
                    <input
                      type="number"
                      min={1}
                      value={values.DURACIONMIN}
                      disabled={soloLectura}
                      onChange={(e) => setField("DURACIONMIN", e.target.value)}
                    />
                    {minutosSugeridos != null && (
                      <span className="field-hint">
                        Sugerido según fechas: {minutosSugeridos} min
                        {!soloLectura && (
                          <>
                            {" · "}
                            <button
                              type="button"
                              className="btn-link"
                              onClick={() => setField("DURACIONMIN", minutosSugeridos)}
                            >
                              Usar
                            </button>
                          </>
                        )}
                      </span>
                    )}
                  </div>
                </div>
              </section>
            </div>

            <section className="form-section form-section--card examen-config-visibilidad">
              <h3 className="form-section-title">Visibilidad</h3>
              <div className="form-field">
                <label>Alcance por salón</label>
                <div className="examen-radios">
                  <label>
                    <input
                      type="radio"
                      checked={values.TODASLASULA}
                      disabled={soloLectura}
                      onChange={() => setField("TODASLASULA", true)}
                    />
                    Visible para todos los salones
                  </label>
                  <label>
                    <input
                      type="radio"
                      checked={!values.TODASLASULA}
                      disabled={soloLectura}
                      onChange={() => setField("TODASLASULA", false)}
                    />
                    Visible solo para salones específicos
                  </label>
                </div>
              </div>

              {!values.TODASLASULA && (
                <div className={`examen-config-aulas ${errors.AULAS ? "has-error" : ""}`}>
                  {aulas.map((a) => (
                    <label key={a.value} className="examen-config-aula-check">
                      <input
                        type="checkbox"
                        checked={(values.AULAS || []).includes(a.value)}
                        disabled={soloLectura}
                        onChange={() => toggleAula(a.value)}
                      />
                      {a.label}
                    </label>
                  ))}
                  {errors.AULAS && <span className="field-error">{errors.AULAS}</span>}
                </div>
              )}

              <label className="examen-config-visible">
                <input
                  type="checkbox"
                  checked={values.VISIBLE}
                  disabled={soloLectura}
                  onChange={(e) => setField("VISIBLE", e.target.checked)}
                />
                Examen visible para estudiantes
              </label>
            </section>
          </div>

          {!soloLectura && (
            <div className="form-page-footer examen-config-footer">
              <button type="button" className="btn-secondary" onClick={onCancel}>
                Cancelar
              </button>
              <button type="button" className="btn-primary" disabled={enviando} onClick={guardarConfig}>
                {enviando ? <FontAwesomeIcon icon={faSpinner} spin /> : null}{" "}
                {idExamen ? "Guardar configuración" : "Crear examen y generar preguntas"}
              </button>
            </div>
          )}
        </div>
      )}

      {tab === "distribucion" && (
        <div className="examen-section">
          <h3 className="examen-section-title">Distribución de preguntas</h3>
          <p className="examen-muted" style={{ marginBottom: "0.85rem" }}>
            {idExamen
              ? "Resumen real del examen según las materias asignadas a cada pregunta."
              : `Vista previa según el tipo seleccionado (${values.TIPO} preguntas). Se confirma al crear el examen.`}
          </p>
          <ExamenDistribucion categorias={dist.categorias} materias={dist.materias} />
        </div>
      )}

      {tab === "preguntas" && idExamen && (
        <>
          <div className="examen-preguntas-layout">
            <aside className="examen-preg-sidebar mantenedor-card">
              <div className="examen-preg-sidebar-head">
                <div className="mantenedor-search examen-preg-sidebar-search">
                  <FontAwesomeIcon icon={faSearch} className="mantenedor-search-icon" />
                  <input
                    type="text"
                    placeholder="Filtrar por N°, materia o código..."
                    value={filtroPreg}
                    onChange={(e) => setFiltroPreg(e.target.value)}
                  />
                </div>
                <span
                  className={`examen-preg-stat-pill${incompletas > 0 ? " is-warn" : " is-ok"}`}
                >
                  {incompletas > 0
                    ? `${incompletas} sin enunciado`
                    : "Todas con enunciado"}
                </span>
              </div>
              <div className="examen-preg-list">
                {gruposCategoria.map((g) => {
                  const abierta = catsAbiertas.has(g.id);
                  const hechas = g.preguntas.filter((p) => preguntaCompleta(p)).length;
                  return (
                    <div key={g.id} className="examen-preg-acc">
                      <button
                        type="button"
                        className={`examen-preg-acc-head${abierta ? " is-open" : ""}`}
                        onClick={() => toggleCategoria(g.id)}
                        aria-expanded={abierta}
                      >
                        <FontAwesomeIcon icon={faChevronDown} className="examen-preg-acc-chevron" />
                        <span className="examen-preg-acc-title">{g.nombre}</span>
                        <span className="examen-preg-acc-count">
                          {hechas}/{g.preguntas.length}
                        </span>
                      </button>
                      {abierta && (
                        <div className="examen-preg-acc-body">
                          {g.preguntas.map((p) => {
                            const completa = preguntaCompleta(p);
                            return (
                              <button
                                key={p.IDPREGUNTA}
                                type="button"
                                className={`examen-preg-item ${preguntaSel === p.IDPREGUNTA ? "is-active" : ""} ${
                                  completa ? "is-complete" : "is-incomplete"
                                }`}
                                onClick={() => setPreguntaSel(p.IDPREGUNTA)}
                              >
                                <span className="examen-preg-item-row">
                                  <span className="examen-preg-item-num">#{p.ORDEN}</span>
                                  <span className="examen-preg-code">{p.MATERIA_CODIGO}</span>
                                  <span
                                    className="examen-preg-item-state"
                                    title={completa ? "Con enunciado" : "Sin enunciado"}
                                    aria-hidden
                                  />
                                </span>
                                <span className="examen-preg-item-name">
                                  {p.MATERIA_NOMBRE || "—"}
                                </span>
                              </button>
                            );
                          })}
                        </div>
                      )}
                    </div>
                  );
                })}
                {!gruposCategoria.length && (
                  <p className="examen-preg-empty-msg">Sin coincidencias.</p>
                )}
              </div>
            </aside>
            <ExamenPreguntaEditor
              pregunta={detallePreg}
              soloLectura={soloLectura}
              onGuardar={guardarPregunta}
            />
          </div>
          <div className="examen-form-actions">
            <button type="button" className="btn-secondary" onClick={onCancel}>
              Volver al listado
            </button>
          </div>
        </>
      )}
        </div>
      </div>
    </div>
  );
}

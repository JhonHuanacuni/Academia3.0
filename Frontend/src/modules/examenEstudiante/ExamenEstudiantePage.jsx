import { useCallback, useEffect, useRef, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowLeft,
  faCheckCircle,
  faClock,
  faEye,
  faForward,
  faPaperPlane,
  faPlay,
  faSpinner,
  faTimes,
} from "@fortawesome/free-solid-svg-icons";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toast from "../../components/mantenedor/feedback/Toast";
import { parseJsonResponse } from "../../utils/api";
import { dbToView } from "../../utils/fecha";
import "../../styles/mantenedor.css";
import "./examenEstudiante.css";

const idUsuario = () => localStorage.getItem("idusuario") || "";

function formatTimer(seg) {
  if (seg == null || Number.isNaN(seg)) return "--:--";
  const s = Math.max(0, Math.floor(seg));
  const m = Math.floor(s / 60);
  const r = s % 60;
  return `${String(m).padStart(2, "0")}:${String(r).padStart(2, "0")}`;
}

function accionLabel(accion) {
  switch (accion) {
    case "continuar":
      return "Continuar";
    case "desarrollar":
      return "Desarrollar";
    case "agotado":
      return "Sin intentos";
    case "cerrado":
      return "Cerrado";
    case "proximamente":
      return "Próximamente";
    default:
      return accion || "—";
  }
}

export default function ExamenEstudiantePage() {
  const [vista, setVista] = useState("lista"); // lista | rendir | resultado
  const [examenes, setExamenes] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [toast, setToast] = useState(null);
  const [enviando, setEnviando] = useState(false);

  const [idIntento, setIdIntento] = useState(null);
  const [intento, setIntento] = useState(null);
  const [pregunta, setPregunta] = useState(null);
  const [respondidas, setRespondidas] = useState([]);
  const [altSel, setAltSel] = useState(null);
  const [segundos, setSegundos] = useState(null);
  const [resultado, setResultado] = useState(null);
  const [imagenModal, setImagenModal] = useState(null);
  const finalizandoRef = useRef(false);

  const cargarLista = useCallback(async () => {
    setCargando(true);
    try {
      const uid = idUsuario();
      const res = await fetch(`/api/examenes/estudiante/?idusuario=${encodeURIComponent(uid)}`);
      const data = await parseJsonResponse(res);
      if (!res.ok || data.ok === false) {
        throw new Error(data.mensaje || "No se pudo cargar el listado");
      }
      setExamenes(data.data || []);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => {
    cargarLista();
  }, [cargarLista]);

  const cargarEstado = useCallback(async (intentoId) => {
    const uid = idUsuario();
    const res = await fetch(
      `/api/examenes/estudiante/intento/${encodeURIComponent(intentoId)}/?idusuario=${encodeURIComponent(uid)}`,
    );
    const data = await parseJsonResponse(res);
    if (!res.ok || !data.ok) {
      throw new Error(data.mensaje || "No se pudo cargar el intento");
    }
    setIntento(data.intento);
    setRespondidas(data.respondidas || []);
    setPregunta(data.pregunta || null);
    setAltSel(null);
    setImagenModal(null);
    const seg = data.intento?.SEGUNDOSRESTANTES;
    setSegundos(seg == null ? null : Number(seg));

    if (Number(data.intento?.ESTADO) === 1) {
      setResultado({
        IDINTENTOEXAMEN: data.intento.IDINTENTOEXAMEN,
        IDEXAMEN: data.intento.IDEXAMEN,
        TITULO: data.intento.TITULO,
        PUNTAJEOBTENIDO: data.intento.PUNTAJEOBTENIDO,
        CANTCORRECTAS: data.intento.CANTCORRECTAS,
        CANTINCORRECTAS: data.intento.CANTINCORRECTAS,
        CANTSINRESPONDER: data.intento.CANTSINRESPONDER,
        APROBADO: data.intento.APROBADO,
        CANTPREGUNTAS: data.intento.CANTPREGUNTAS,
      });
      setVista("resultado");
      return;
    }

    // Todas respondidas → listo para enviar
    const total = Number(data.intento?.CANTPREGUNTAS || 0);
    const resp = Number(data.intento?.CANTRESPONDIDAS || 0);
    if (!data.pregunta && resp >= total && total > 0) {
      setPregunta(null);
    }
    setVista("rendir");
  }, []);

  const finalizar = useCallback(
    async (intentoId) => {
      if (finalizandoRef.current) return;
      finalizandoRef.current = true;
      setEnviando(true);
      try {
        const uid = idUsuario();
        const res = await fetch(
          `/api/examenes/estudiante/intento/${encodeURIComponent(intentoId)}/finalizar/`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ IDUSUARIO: uid }),
          },
        );
        const data = await parseJsonResponse(res);
        if (!res.ok || !data.ok) {
          throw new Error(data.mensaje || "No se pudo enviar el examen");
        }
        setResultado(data.resultado);
        setVista("resultado");
        setToast({ mensaje: data.mensaje || "Examen enviado", tipo: "success" });
      } catch (err) {
        setToast({ mensaje: err.message, tipo: "error" });
      } finally {
        setEnviando(false);
        finalizandoRef.current = false;
      }
    },
    [],
  );

  // Timer countdown
  useEffect(() => {
    if (vista !== "rendir" || segundos == null || segundos < 0) return undefined;
    if (segundos === 0) {
      if (idIntento) finalizar(idIntento);
      return undefined;
    }
    const t = setInterval(() => {
      setSegundos((prev) => (prev == null || prev <= 0 ? 0 : prev - 1));
    }, 1000);
    return () => clearInterval(t);
  }, [vista, segundos, idIntento, finalizar]);

  const iniciar = async (examen) => {
    setEnviando(true);
    try {
      const uid = idUsuario();
      if (examen.ACCION === "continuar" && examen.IDINTENTOENCURSO) {
        setIdIntento(examen.IDINTENTOENCURSO);
        await cargarEstado(examen.IDINTENTOENCURSO);
        return;
      }
      const res = await fetch(
        `/api/examenes/estudiante/${encodeURIComponent(examen.IDEXAMEN)}/iniciar/`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ IDUSUARIO: uid }),
        },
      );
      const data = await parseJsonResponse(res);
      if (!res.ok || !data.ok) {
        throw new Error(data.mensaje || "No se pudo iniciar");
      }
      setIdIntento(data.idIntento);
      await cargarEstado(data.idIntento);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setEnviando(false);
    }
  };

  const enviarRespuesta = async () => {
    if (!pregunta || !altSel || !idIntento) return;
    setEnviando(true);
    try {
      const uid = idUsuario();
      const res = await fetch(
        `/api/examenes/estudiante/intento/${encodeURIComponent(idIntento)}/responder/`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            IDUSUARIO: uid,
            IDPREGUNTA: pregunta.IDPREGUNTA,
            IDALTERNATIVA: altSel,
          }),
        },
      );
      const data = await parseJsonResponse(res);
      if (data.tiempoAgotado) {
        await finalizar(idIntento);
        return;
      }
      if (!res.ok || !data.ok) {
        throw new Error(data.mensaje || "No se pudo guardar la respuesta");
      }
      if (data.esUltima) {
        await finalizar(idIntento);
      } else {
        await cargarEstado(idIntento);
      }
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setEnviando(false);
    }
  };

  const volverLista = () => {
    setVista("lista");
    setIdIntento(null);
    setIntento(null);
    setPregunta(null);
    setResultado(null);
    setRespondidas([]);
    setImagenModal(null);
    cargarLista();
  };

  const total = Number(intento?.CANTPREGUNTAS || 0);
  const ordenActual = Number(intento?.ORDENACTUAL || 1);
  const ordenesHechos = new Set((respondidas || []).map((r) => Number(r.ORDEN)));

  const modalImagen = imagenModal ? (
    <div
      className="modal-overlay exam-est-img-modal-overlay"
      onClick={() => setImagenModal(null)}
      role="presentation"
    >
      <div
        className="modal-panel exam-est-img-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-label={imagenModal.titulo}
      >
        <div className="modal-header exam-est-img-modal-header">
          <h3>{imagenModal.titulo}</h3>
          <button
            type="button"
            className="btn-secondary exam-est-img-modal-close"
            onClick={() => setImagenModal(null)}
            aria-label="Cerrar"
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>
        <div className="exam-est-img-modal-body">
          <img src={imagenModal.src} alt="" />
        </div>
      </div>
    </div>
  ) : null;

  if (vista === "resultado" && resultado) {
    const nota = resultado.PUNTAJEOBTENIDO;
    const correctas = resultado.CANTCORRECTAS;
    const totalP = resultado.CANTPREGUNTAS;
    return (
      <div className="mantenedor-page exam-est">
        <PageHeader
          modulo="Académico"
          listado="Exámenes"
          vista="Resultado"
          onListadoClick={volverLista}
          mostrarNuevo={false}
        />
        <div className="exam-est-resultado">
          <FontAwesomeIcon icon={faCheckCircle} className="exam-est-resultado-icon" />
          <h2>Examen enviado</h2>
          <p className="exam-est-resultado-titulo">{resultado.TITULO}</p>
          <div className="exam-est-nota">{nota != null ? Number(nota).toFixed(1) : "—"}</div>
          <p className="exam-est-nota-label">Tu nota</p>
          <div className="exam-est-stats">
            <div>
              <strong>{correctas ?? "—"}</strong>
              <span>Correctas</span>
            </div>
            <div>
              <strong>{resultado.CANTINCORRECTAS ?? "—"}</strong>
              <span>Incorrectas</span>
            </div>
            <div>
              <strong>{resultado.CANTSINRESPONDER ?? "—"}</strong>
              <span>Sin responder</span>
            </div>
            <div>
              <strong>{totalP ?? "—"}</strong>
              <span>Total</span>
            </div>
          </div>
          {resultado.APROBADO != null && (
            <p className={`exam-est-aprobado ${resultado.APROBADO ? "ok" : "no"}`}>
              {resultado.APROBADO ? "Aprobado" : "No aprobado"}
            </p>
          )}
          <button type="button" className="btn-primary" onClick={volverLista}>
            <FontAwesomeIcon icon={faArrowLeft} /> Volver al listado
          </button>
        </div>
        {toast && (
          <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
        )}
        {modalImagen}
      </div>
    );
  }

  if (vista === "rendir") {
    const esUltimaVisible =
      pregunta && Number(pregunta.ORDEN) === total && ordenesHechos.size === total - 1;
    const listoParaEnviar = !pregunta && ordenesHechos.size >= total && total > 0;

    return (
      <div className="mantenedor-page exam-est">
        <PageHeader
          modulo="Académico"
          listado="Exámenes"
          vista={intento?.TITULO || "Rendir"}
          onListadoClick={volverLista}
          mostrarNuevo={false}
        />

        <div className="exam-est-rendir-bar">
          <div className="exam-est-timer" data-urgent={segundos != null && segundos < 60}>
            <FontAwesomeIcon icon={faClock} />
            <span>{formatTimer(segundos)}</span>
          </div>
          <span className="exam-est-progress-label">
            Pregunta {Math.min(ordenActual, total)} / {total}
          </span>
        </div>

        <div className="exam-est-squares" aria-label="Progreso de preguntas">
          {Array.from({ length: total }, (_, i) => {
            const n = i + 1;
            const done = ordenesHechos.has(n);
            const current = n === ordenActual && !done;
            return (
              <span
                key={n}
                className={`exam-est-square${done ? " is-done" : ""}${current ? " is-current" : ""}`}
                title={`Pregunta ${n}`}
              >
                {n}
              </span>
            );
          })}
        </div>

        {listoParaEnviar ? (
          <div className="exam-est-card">
            <p>Ya respondiste todas las preguntas.</p>
            <button
              type="button"
              className="btn-primary"
              disabled={enviando}
              onClick={() => finalizar(idIntento)}
            >
              {enviando ? <FontAwesomeIcon icon={faSpinner} spin /> : <FontAwesomeIcon icon={faPaperPlane} />}{" "}
              Enviar examen
            </button>
          </div>
        ) : pregunta ? (
          <div className="exam-est-card exam-est-card--split">
            <div className="exam-est-col exam-est-col--enunciado">
              <div className="exam-est-preg-meta">
                <span>#{pregunta.ORDEN}</span>
                {pregunta.MATERIA_CODIGO && <span>{pregunta.MATERIA_CODIGO}</span>}
              </div>
              <h3 className="exam-est-preg-title">
                {pregunta.TITULO || `Pregunta ${pregunta.ORDEN}`}
              </h3>
              {pregunta.DESCRIPCION && (
                <p className="exam-est-preg-desc">{pregunta.DESCRIPCION}</p>
              )}
              {pregunta.URLPREVIEW && (
                <div className="exam-est-img-wrap">
                  <img src={pregunta.URLPREVIEW} alt="" className="exam-est-img" />
                  <button
                    type="button"
                    className="btn-secondary exam-est-ver-btn exam-est-ver-btn--overlay"
                    onClick={() =>
                      setImagenModal({
                        src: pregunta.URLPREVIEW,
                        titulo: "Imagen del enunciado",
                      })
                    }
                  >
                    <FontAwesomeIcon icon={faEye} /> Ampliar
                  </button>
                </div>
              )}
            </div>

            <div className="exam-est-col exam-est-col--alts">
              <p className="exam-est-alts-label">Alternativas</p>
              <div className="exam-est-alts" role="radiogroup">
                {(pregunta.ALTERNATIVAS || []).map((a, idx) => {
                  const letra = String.fromCharCode(65 + idx);
                  const selected = altSel === a.IDALTERNATIVA;
                  return (
                    <label
                      key={a.IDALTERNATIVA}
                      className={`exam-est-alt${selected ? " is-selected" : ""}`}
                    >
                      <input
                        type="radio"
                        name="alt"
                        checked={selected}
                        onChange={() => setAltSel(a.IDALTERNATIVA)}
                      />
                      <span className="exam-est-alt-letra">{letra}</span>
                      <span className="exam-est-alt-body">
                        {a.DESCRIPCION}
                        {a.URLPREVIEW && (
                          <div className="exam-est-alt-img-wrap">
                            <img src={a.URLPREVIEW} alt="" className="exam-est-img-sm" />
                            <button
                              type="button"
                              className="btn-secondary exam-est-ver-btn exam-est-ver-btn--alt"
                              onClick={(e) => {
                                e.preventDefault();
                                e.stopPropagation();
                                setImagenModal({
                                  src: a.URLPREVIEW,
                                  titulo: `Imagen alternativa ${letra}`,
                                });
                              }}
                            >
                              <FontAwesomeIcon icon={faEye} /> Ampliar
                            </button>
                          </div>
                        )}
                      </span>
                    </label>
                  );
                })}
              </div>

              <div className="exam-est-actions">
                <button
                  type="button"
                  className="btn-primary"
                  disabled={!altSel || enviando}
                  onClick={enviarRespuesta}
                >
                  {enviando ? (
                    <FontAwesomeIcon icon={faSpinner} spin />
                  ) : esUltimaVisible ? (
                    <FontAwesomeIcon icon={faPaperPlane} />
                  ) : (
                    <FontAwesomeIcon icon={faForward} />
                  )}{" "}
                  {esUltimaVisible ? "Enviar examen" : "Siguiente"}
                </button>
              </div>
            </div>
          </div>
        ) : (
          <div className="exam-est-card">
            <p>Cargando pregunta…</p>
          </div>
        )}

        {toast && (
          <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
        )}
        {modalImagen}
      </div>
    );
  }

  return (
    <div className="mantenedor-page exam-est">
      <PageHeader
        modulo="Académico"
        listado="Exámenes"
        vista="Mis exámenes"
        mostrarNuevo={false}
      />

      {cargando ? (
        <div className="exam-est-loading">
          <FontAwesomeIcon icon={faSpinner} spin /> Cargando…
        </div>
      ) : examenes.length === 0 ? (
        <div className="exam-est-empty mantenedor-card">
          <p>No hay exámenes disponibles por ahora.</p>
        </div>
      ) : (
        <div className="exam-est-list">
          {examenes.map((ex) => {
            const puede =
              ex.ACCION === "desarrollar" || ex.ACCION === "continuar";
            return (
              <article key={ex.IDEXAMEN} className="exam-est-item">
                <div className="exam-est-item-main">
                  <h3>{ex.TITULO}</h3>
                  <p className="exam-est-item-meta">
                    {ex.TIPO} preguntas · {ex.DURACIONMIN || "—"} min ·{" "}
                    {dbToView(ex.FECHAINICIO)} {ex.HORAINICIO?.slice(0, 5) || ""}
                    {" — "}
                    {dbToView(ex.FECHAFIN)} {ex.HORAFIN?.slice(0, 5) || ""}
                  </p>
                  {ex.ULTIMOPUNTAJE != null && (
                    <p className="exam-est-item-nota">
                      Última nota: <strong>{Number(ex.ULTIMOPUNTAJE).toFixed(1)}</strong>
                    </p>
                  )}
                </div>
                <button
                  type="button"
                  className={`btn-primary exam-est-btn${puede ? "" : " is-disabled"}`}
                  disabled={!puede || enviando}
                  onClick={() => iniciar(ex)}
                >
                  {enviando ? (
                    <FontAwesomeIcon icon={faSpinner} spin />
                  ) : (
                    <FontAwesomeIcon icon={faPlay} />
                  )}{" "}
                  {accionLabel(ex.ACCION)}
                </button>
              </article>
            );
          })}
        </div>
      )}

      {toast && (
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

import { useCallback, useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCheck,
  faMinus,
  faSpinner,
  faTimes,
} from "@fortawesome/free-solid-svg-icons";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import Toast from "../../components/mantenedor/feedback/Toast";
import { parseJsonResponse } from "../../utils/api";
import { dbToView } from "../../utils/fecha";
import { resultadosColumnasEstudiante, resultadosColumnasStaff } from "./resultados.config";
import "../../styles/mantenedor.css";
import "./resultados.css";

function formatNota(val) {
  if (val == null || val === "") return "—";
  const n = Number(val);
  if (Number.isNaN(n)) return String(val);
  return n.toFixed(1);
}

function etiquetaTipoExamen(row) {
  const origen = String(row?.ORIGEN || row?.TIPO_EXAMEN || "").toLowerCase();
  if (origen === "importado" || origen === "presencial") {
    const n = row?.TIPO_IMPORTACION;
    return n ? `Presencial (${n})` : "Presencial";
  }
  return "Virtual";
}

function DetalleModal({ abierto, detalle, loading, esDocente, onClose }) {
  if (!abierto) return null;
  const intento = detalle?.intento;
  const preguntas = detalle?.preguntas || [];
  const areas = detalle?.areas || [];
  const esImportado = String(intento?.ORIGEN || "").toLowerCase() === "importado";

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel resultados-detalle-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
      >
        <div className="modal-header">
          <h2>Detalle del resultado</h2>
          <button type="button" className="btn-icon" onClick={onClose} aria-label="Cerrar">
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>
        <div className="modal-body">
          {loading ? (
            <div className="mantenedor-state">
              <FontAwesomeIcon icon={faSpinner} spin /> Cargando detalle...
            </div>
          ) : !intento ? (
            <div className="mantenedor-state">No se encontró el resultado.</div>
          ) : (
            <>
              <dl className="resultados-meta">
                {esDocente && (
                  <div className="resultados-meta-item">
                    <dt>Estudiante</dt>
                    <dd>
                      {intento.ESTUDIANTE}
                      {intento.DNI ? ` · DNI ${intento.DNI}` : ""}
                    </dd>
                  </div>
                )}
                <div className="resultados-meta-item">
                  <dt>Examen</dt>
                  <dd>
                    {intento.EXAMEN}
                    <span className="resultados-tipo">{etiquetaTipoExamen(intento)}</span>
                  </dd>
                </div>
                <div className="resultados-meta-item">
                  <dt>Fecha</dt>
                  <dd>
                    {dbToView(intento.FECHAFIN || intento.FECHAINICIO) || "—"}
                    {intento.HORAFIN || intento.HORAINICIO
                      ? ` ${String(intento.HORAFIN || intento.HORAINICIO).slice(0, 5)}`
                      : ""}
                  </dd>
                </div>
                <div className="resultados-meta-item">
                  <dt>Puntaje</dt>
                  <dd>
                    {formatNota(intento.PUNTAJEOBTENIDO)}
                    {intento.PUNTAJETOTAL != null ? ` / ${formatNota(intento.PUNTAJETOTAL)}` : ""}
                    {intento.PORCENTAJE != null ? ` · ${formatNota(intento.PORCENTAJE)}%` : ""}
                    {intento.APROBADO != null && (
                      <span className={`resultados-badge ${intento.APROBADO ? "ok" : "no"}`}>
                        {intento.APROBADO ? "Aprobado" : "No aprobado"}
                      </span>
                    )}
                  </dd>
                </div>
                <div className="resultados-meta-item">
                  <dt>Resumen</dt>
                  <dd>
                    {intento.CANTCORRECTAS ?? 0} correctas · {intento.CANTINCORRECTAS ?? 0} incorrectas
                    · {intento.CANTSINRESPONDER ?? 0} en blanco
                  </dd>
                </div>
              </dl>

              {esImportado && areas.length > 0 && (
                <div className="resultados-areas">
                  <h3>Resultado por áreas</h3>
                  <ul>
                    {areas.map((a) => (
                      <li key={a.clave}>
                        <span>{a.etiqueta}</span>
                        <strong>{a.correctas}</strong>
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              {esImportado && preguntas.length === 0 && areas.length === 0 && (
                <p className="resultados-importado-nota">
                  Este resultado proviene de un examen presencial importado. No hay detalle pregunta por pregunta.
                </p>
              )}

              {!esImportado && (
              <div className="resultados-preguntas">
                {preguntas.map((p) => (
                  <article
                    key={p.IDPREGUNTA}
                    className={`resultados-pregunta resultados-pregunta--${p.estado}`}
                  >
                    <header>
                      <span className="resultados-pregunta-num">Pregunta {p.numero}</span>
                      <span className={`resultados-estado-pill ${p.estado}`}>
                        {p.estado === "correcta" && (
                          <>
                            <FontAwesomeIcon icon={faCheck} /> Correcta
                          </>
                        )}
                        {p.estado === "incorrecta" && (
                          <>
                            <FontAwesomeIcon icon={faTimes} /> Incorrecta
                          </>
                        )}
                        {p.estado === "blanco" && (
                          <>
                            <FontAwesomeIcon icon={faMinus} /> Sin respuesta
                          </>
                        )}
                      </span>
                    </header>
                    <h3>{p.TITULO}</h3>
                    {p.DESCRIPCION && <p className="resultados-pregunta-desc">{p.DESCRIPCION}</p>}
                    {p.IMAGEURL && (
                      <img src={p.IMAGEURL} alt="" className="resultados-pregunta-img" />
                    )}
                    <div className="resultados-respuesta-block">
                      <div>
                        <span className="resultados-label">Tu respuesta</span>
                        <p>
                          {p.respuestaElegida || (
                            <em className="muted">No respondió</em>
                          )}
                        </p>
                        {p.respuestaElegidaImg && (
                          <img src={p.respuestaElegidaImg} alt="" className="resultados-alt-img" />
                        )}
                      </div>
                      {p.mostrarCorrecta && p.respuestaCorrecta && (
                        <div>
                          <span className="resultados-label">Respuesta correcta</span>
                          <p>{p.respuestaCorrecta}</p>
                          {p.respuestaCorrectaImg && (
                            <img
                              src={p.respuestaCorrectaImg}
                              alt=""
                              className="resultados-alt-img"
                            />
                          )}
                        </div>
                      )}
                    </div>
                  </article>
                ))}
              </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default function ResultadosPage({ role, idusuario }) {
  const esEstudiante = role === "estudiante";
  const [filas, setFilas] = useState([]);
  const [total, setTotal] = useState(0);
  const [pagina, setPagina] = useState(1);
  const [tamanio] = useState(10);
  const [buscar, setBuscar] = useState("");
  const [buscarAplicado, setBuscarAplicado] = useState("");
  const [idExamen, setIdExamen] = useState("");
  const [idAula, setIdAula] = useState("");
  const [idExamenAplicado, setIdExamenAplicado] = useState("");
  const [idAulaAplicado, setIdAulaAplicado] = useState("");
  const [examenes, setExamenes] = useState([]);
  const [aulas, setAulas] = useState([]);
  const [filtroInicialListo, setFiltroInicialListo] = useState(false);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");
  const [orden, setOrden] = useState({ campo: "PUNTAJEOBTENIDO", direccion: "DESC" });
  const [toast, setToast] = useState(null);
  const [detalleAbierto, setDetalleAbierto] = useState(false);
  const [detalleLoading, setDetalleLoading] = useState(false);
  const [detalle, setDetalle] = useState(null);

  const uid = idusuario || localStorage.getItem("idusuario") || "";

  const cargarCatalogos = useCallback(async () => {
    if (!uid) return;
    setFiltroInicialListo(false);
    setCargando(true);
    try {
      const res = await fetch(
        `/api/examenes/resultados/catalogos/?idusuario=${encodeURIComponent(uid)}`,
      );
      const data = await parseJsonResponse(res);
      if (!res.ok || data.ok === false) {
        throw new Error(data.mensaje || "No se pudieron cargar los catálogos");
      }
      const payload = data.data || {};
      const listaExamenes = (payload.examenes || []).map((ex) => ({
        IDEXAMEN: ex.IDEXAMEN || ex.idexamen || "",
        TITULO: ex.TITULO || ex.titulo || "",
      }));
      setExamenes(listaExamenes);
      setAulas(payload.aulas || []);
      const ultimoId =
        payload.ultimoExamen?.IDEXAMEN ||
        payload.ultimoExamen?.idexamen ||
        listaExamenes[0]?.IDEXAMEN ||
        "";
      setIdExamen(ultimoId);
      setIdExamenAplicado(ultimoId);
      setPagina(1);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
      setExamenes([]);
      setAulas([]);
      setIdExamen("");
      setIdExamenAplicado("");
    } finally {
      setFiltroInicialListo(true);
    }
  }, [uid]);

  const cargar = useCallback(async () => {
    if (!uid || !filtroInicialListo) return;
    if (!idExamenAplicado && !buscarAplicado && examenes.length === 0) {
      setFilas([]);
      setTotal(0);
      setCargando(false);
      return;
    }
    setCargando(true);
    setError("");
    try {
      const params = new URLSearchParams({
        idusuario: uid,
        pagina: String(pagina),
        tamanio: String(tamanio),
        ordenarPor: orden.campo,
        direccion: orden.direccion,
      });
      if (buscarAplicado.trim()) params.set("buscar", buscarAplicado.trim());
      if (idExamenAplicado) params.set("idExamen", idExamenAplicado);
      if (idAulaAplicado) params.set("idAula", idAulaAplicado);

      const res = await fetch(`/api/examenes/resultados/?${params}`);
      const data = await parseJsonResponse(res);
      if (!res.ok || data.ok === false) {
        throw new Error(data.mensaje || "No se pudo cargar el listado");
      }
      setFilas(data.data || []);
      setTotal(data.total || 0);
    } catch (err) {
      setError(err.message);
      setToast({ mensaje: err.message, tipo: "error" });
      setFilas([]);
      setTotal(0);
    } finally {
      setCargando(false);
    }
  }, [
    uid,
    filtroInicialListo,
    pagina,
    tamanio,
    buscarAplicado,
    idExamenAplicado,
    idAulaAplicado,
    orden,
    examenes.length,
  ]);

  useEffect(() => {
    cargarCatalogos();
  }, [cargarCatalogos]);

  useEffect(() => {
    cargar();
  }, [cargar]);

  const aplicarBusqueda = () => {
    setBuscarAplicado(buscar.trim());
    setIdExamenAplicado(idExamen);
    setIdAulaAplicado(idAula);
    setPagina(1);
  };

  const toggleOrden = (campo) => {
    setOrden((prev) => ({
      campo,
      direccion: prev.campo === campo && prev.direccion === "ASC" ? "DESC" : "ASC",
    }));
    setPagina(1);
  };

  const abrirDetalle = async (row) => {
    setDetalleAbierto(true);
    setDetalle(null);
    setDetalleLoading(true);
    try {
      const res = await fetch(
        `/api/examenes/resultados/${encodeURIComponent(row.IDINTENTOEXAMEN)}/?idusuario=${encodeURIComponent(uid)}`,
      );
      const data = await parseJsonResponse(res);
      if (!res.ok || data.ok === false) {
        throw new Error(data.mensaje || "No se pudo cargar el detalle");
      }
      setDetalle(data);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
      setDetalleAbierto(false);
    } finally {
      setDetalleLoading(false);
    }
  };

  return (
    <div className="mantenedor-page resultados-page">
      <div className="mantenedor-card resultados-filtros">
        <div className="resultados-filtros-grid">
          {!esEstudiante && (
            <label>
              Salón
              <select value={idAula} onChange={(e) => setIdAula(e.target.value)}>
                <option value="">TODOS</option>
                {aulas.map((a) => (
                  <option key={a.IDAULA} value={a.IDAULA}>
                    {a.NOMBRE}
                  </option>
                ))}
              </select>
            </label>
          )}
          <label>
            Examen
            <select value={idExamen} onChange={(e) => setIdExamen(e.target.value)}>
              <option value="">TODOS</option>
              {examenes.map((ex) => (
                <option key={ex.IDEXAMEN} value={ex.IDEXAMEN}>
                  {ex.TITULO}
                </option>
              ))}
            </select>
          </label>
          <label className="resultados-filtro-buscar">
            Buscar
            <input
              type="text"
              placeholder={esEstudiante ? "BUSCAR EXAMEN" : "BUSCAR DNI, ESTUDIANTE O EXAMEN"}
              value={buscar}
              onChange={(e) => setBuscar(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") aplicarBusqueda();
              }}
            />
          </label>
          <button
            type="button"
            className="btn-primary"
            onClick={aplicarBusqueda}
            disabled={cargando}
          >
            {cargando ? <FontAwesomeIcon icon={faSpinner} spin /> : "Buscar"}
          </button>
        </div>
      </div>

      <div className="mantenedor-card">
        <DataTable
          columnas={esEstudiante ? resultadosColumnasEstudiante : resultadosColumnasStaff}
          items={filas}
          pk="IDINTENTOEXAMEN"
          orden={orden}
          loading={cargando || !filtroInicialListo}
          error={error}
          onOrden={toggleOrden}
          onVer={abrirDetalle}
          onReintentar={cargar}
          pagina={pagina}
          tamanio={tamanio}
          emptyMessage="No hay resultados para mostrar."
        />
        <Pagination
          pagina={pagina}
          tamanio={tamanio}
          total={total}
          onChange={setPagina}
        />
      </div>

      <DetalleModal
        abierto={detalleAbierto}
        detalle={detalle}
        loading={detalleLoading}
        esDocente={!esEstudiante}
        onClose={() => setDetalleAbierto(false)}
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

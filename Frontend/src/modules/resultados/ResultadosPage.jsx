import { useCallback, useEffect, useMemo, useState } from "react";
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

function ExamenResumen({ examen, mostrarAula }) {
  if (!examen) return null;
  return (
    <div className="resultados-examen-resumen">
      <div>
        <span>Examen</span>
        <strong>{examen.TITULO || "—"}</strong>
      </div>
      <div>
        <span>Tipo</span>
        <strong>{etiquetaTipoExamen(examen)}</strong>
      </div>
      {mostrarAula ? (
        <div>
          <span>Aula</span>
          <strong>{examen.AULA || "—"}</strong>
        </div>
      ) : null}
      <div>
        <span>Fecha</span>
        <strong>{dbToView(examen.FECHA) || "—"}</strong>
      </div>
    </div>
  );
}

function Kpi({ etiqueta, valor, tono }) {
  return (
    <div className={`resultados-kpi${tono ? ` resultados-kpi--${tono}` : ""}`}>
      <span>{etiqueta}</span>
      <strong>{valor}</strong>
    </div>
  );
}

function DetalleModal({ abierto, detalle, loading, esDocente, onClose }) {
  if (!abierto) return null;
  const intento = detalle?.intento;
  const preguntas = detalle?.preguntas || [];
  const areas = detalle?.areas || [];
  const esImportado = String(intento?.ORIGEN || "").toLowerCase() === "importado";
  const porcentaje =
    intento?.PORCENTAJE != null
      ? intento.PORCENTAJE
      : intento?.PUNTAJETOTAL
        ? (Number(intento.PUNTAJEOBTENIDO || 0) * 100) / Number(intento.PUNTAJETOTAL)
        : null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel resultados-detalle-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
      >
        <div className="modal-header resultados-detalle-header">
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
              <div className="resultados-detalle-top">
                <div className="resultados-detalle-titulo">
                  <h3>{intento.EXAMEN}</h3>
                  <span className="resultados-tipo">{etiquetaTipoExamen(intento)}</span>
                </div>
                {esDocente ? (
                  <p className="resultados-detalle-alumno">
                    {intento.ESTUDIANTE}
                    {intento.DNI ? ` · DNI ${intento.DNI}` : ""}
                  </p>
                ) : null}
                <div className="resultados-detalle-kpis">
                  <Kpi
                    etiqueta="Fecha"
                    valor={
                      `${dbToView(intento.FECHAFIN || intento.FECHAINICIO) || "—"}` +
                      (intento.HORAFIN || intento.HORAINICIO
                        ? ` ${String(intento.HORAFIN || intento.HORAINICIO).slice(0, 5)}`
                        : "")
                    }
                  />
                  <Kpi
                    etiqueta="Puntaje"
                    valor={
                      intento.PUNTAJETOTAL != null
                        ? `${formatNota(intento.PUNTAJEOBTENIDO)} / ${formatNota(intento.PUNTAJETOTAL)}`
                        : formatNota(intento.PUNTAJEOBTENIDO)
                    }
                  />
                  <Kpi
                    etiqueta="Porcentaje"
                    valor={porcentaje == null ? "—" : `${formatNota(porcentaje)}%`}
                  />
                  <Kpi etiqueta="Correctas" valor={intento.CANTCORRECTAS ?? 0} tono="ok" />
                  <Kpi etiqueta="Incorrectas" valor={intento.CANTINCORRECTAS ?? 0} tono="no" />
                  <Kpi etiqueta="En blanco" valor={intento.CANTSINRESPONDER ?? 0} tono="muted" />
                </div>
              </div>

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

function mapExamenCatalogo(ex) {
  return {
    IDEXAMEN: ex.IDEXAMEN || ex.idexamen || "",
    TITULO: ex.TITULO || ex.titulo || "",
    ORIGEN: ex.ORIGEN || ex.origen || "",
    FECHA: ex.FECHA || ex.fecha || "",
    AULA: ex.AULA || ex.aula || "",
    TIPO_IMPORTACION: ex.TIPO_IMPORTACION ?? ex.tipo_importacion ?? null,
  };
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
  const [idExamenAplicado, setIdExamenAplicado] = useState("");
  const [examenes, setExamenes] = useState([]);
  const [filtroInicialListo, setFiltroInicialListo] = useState(esEstudiante);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");
  const [orden, setOrden] = useState({
    campo: esEstudiante ? "FECHAFIN" : "PUNTAJEOBTENIDO",
    direccion: "DESC",
  });
  const [toast, setToast] = useState(null);
  const [detalleAbierto, setDetalleAbierto] = useState(false);
  const [detalleLoading, setDetalleLoading] = useState(false);
  const [detalle, setDetalle] = useState(null);

  const uid = idusuario || localStorage.getItem("idusuario") || "";

  const examenSeleccionado = useMemo(
    () => examenes.find((ex) => String(ex.IDEXAMEN) === String(idExamenAplicado)) || null,
    [examenes, idExamenAplicado],
  );

  const cargarCatalogos = useCallback(async () => {
    if (!uid || esEstudiante) return;
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
      const listaExamenes = (payload.examenes || []).map(mapExamenCatalogo);
      setExamenes(listaExamenes);
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
      setIdExamen("");
      setIdExamenAplicado("");
    } finally {
      setFiltroInicialListo(true);
    }
  }, [uid, esEstudiante]);

  const cargar = useCallback(async () => {
    if (!uid || !filtroInicialListo) return;
    if (!esEstudiante && !idExamenAplicado) {
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
      if (!esEstudiante && idExamenAplicado) params.set("idExamen", idExamenAplicado);
      if (!esEstudiante && buscarAplicado.trim()) params.set("buscar", buscarAplicado.trim());

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
    orden,
    esEstudiante,
  ]);

  useEffect(() => {
    if (esEstudiante) {
      setFiltroInicialListo(true);
      return;
    }
    cargarCatalogos();
  }, [esEstudiante, cargarCatalogos]);

  useEffect(() => {
    cargar();
  }, [cargar]);

  const aplicarBusqueda = () => {
    setBuscarAplicado(buscar.trim());
    setPagina(1);
  };

  const cambiarExamen = (valor) => {
    setIdExamen(valor);
    setIdExamenAplicado(valor);
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
      {!esEstudiante && (
        <div className="mantenedor-card resultados-filtros">
          <div className="resultados-filtros-grid resultados-filtros-grid--staff">
            <label>
              Examen
              <select value={idExamen} onChange={(e) => cambiarExamen(e.target.value)}>
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
                placeholder="BUSCAR DNI O ESTUDIANTE"
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
      )}

      <div className="mantenedor-card">
        {!esEstudiante && (
          <ExamenResumen examen={examenSeleccionado} mostrarAula />
        )}
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

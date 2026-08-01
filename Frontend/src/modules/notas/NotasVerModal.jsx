import { useEffect, useMemo, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner, faTimes } from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import { dbToView } from "../../utils/fecha";
import "../../styles/mantenedor.css";
import "../horario/horario.css";
import "./notas.css";

function formatModo(value) {
  const v = String(value || "").toLowerCase();
  if (v === "virtual") return "Virtual";
  if (v === "presencial") return "Presencial";
  return value || "—";
}

function formatPuntaje(value) {
  const n = Number(value);
  if (Number.isNaN(n)) return "—";
  return n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export default function NotasVerModal({ abierto, id, onClose }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [detalle, setDetalle] = useState(null);

  useEffect(() => {
    if (!abierto || !id) {
      setDetalle(null);
      setError("");
      return;
    }
    (async () => {
      setLoading(true);
      setError("");
      try {
        const res = await fetch(`/api/notas-importacion/${encodeURIComponent(id)}/`);
        const data = await parseJsonResponse(res);
        if (!res.ok) throw new Error(data.error || "No se pudo cargar la importación");
        setDetalle(data.data);
      } catch (err) {
        setError(err.message);
        setDetalle(null);
      } finally {
        setLoading(false);
      }
    })();
  }, [abierto, id]);

  const imp = detalle?.importacion;
  const notas = detalle?.notas || [];

  const subtitulo = useMemo(() => {
    if (!imp) return "";
    const partes = [
      imp.NOMBRE_ARCHIVO,
      imp.TIPO_IMPORTACION ? `${imp.TIPO_IMPORTACION} preguntas` : null,
      imp.AULA_NOMBRE,
    ].filter(Boolean);
    return partes.join(" · ");
  }, [imp]);

  if (!abierto) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel modal-panel--wide notas-ver-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="notas-ver-title"
      >
        <div className="modal-header hor-modal-header notas-ver-header">
          <div>
            <h2 id="notas-ver-title">Detalle de importación</h2>
            {subtitulo && <p className="notas-ver-subtitulo">{subtitulo}</p>}
          </div>
          <button type="button" className="btn-icon notas-ver-close" onClick={onClose} aria-label="Cerrar">
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="modal-body notas-ver-body">
          {loading && (
            <div className="mantenedor-state">
              <FontAwesomeIcon icon={faSpinner} spin /> Cargando...
            </div>
          )}

          {!loading && error && <p className="field-error">{error}</p>}

          {!loading && !error && imp && (
            <>
              <div className="notas-ver-resumen">
                <div className="notas-ver-resumen-main">
                  <strong>{imp.NOMBRE_ARCHIVO}</strong>
                  <span>
                    Examen: {dbToView(String(imp.FECHA_EXAMEN || ""))} · {formatModo(imp.TIPO_EXAMEN)}
                    {imp.TIPO_AREA_ACADEMICA ? ` · Área ${imp.TIPO_AREA_ACADEMICA}` : ""}
                  </span>
                </div>
                <div className="notas-ver-meta">
                  <span className="notas-ver-meta-count">{notas.length} estudiantes</span>
                  <span>{imp.IMPORTADO_POR || "—"}</span>
                </div>
              </div>

              {!notas.length ? (
                <div className="mantenedor-state">No hay notas en esta importación.</div>
              ) : (
                <>
                  <h3 className="form-section-title">Resultados por estudiante</h3>
                  <div className="mantenedor-card notas-ver-tabla">
                  <div className="data-table-wrap">
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Estudiante</th>
                          <th>DNI</th>
                          <th>Puntaje</th>
                          <th>%</th>
                          <th>Correctas</th>
                          <th>Incorrectas</th>
                          <th>Sin respuesta</th>
                        </tr>
                      </thead>
                      <tbody>
                        {notas.map((n) => (
                          <tr key={n.IDNOTA}>
                            <td>{n.ESTUDIANTE_NOMBRE || "—"}</td>
                            <td>{n.ESTUDIANTE_DNI || "—"}</td>
                            <td>{formatPuntaje(n.PUNTAJE)}</td>
                            <td>{formatPuntaje(n.PORCENTAJE)}%</td>
                            <td>{n.CORRECTAS ?? "—"}</td>
                            <td>{n.INCORRECTAS ?? "—"}</td>
                            <td>{n.NO_RESPUESTA ?? "—"}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
                </>
              )}
            </>
          )}
        </div>

        <div className="modal-footer">
          <button type="button" className="btn-secondary" onClick={onClose}>
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}

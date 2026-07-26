import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTimes } from "@fortawesome/free-solid-svg-icons";
import { resumenDiasAsistencia } from "../../utils/diasPlan";

export default function HorarioVerModal({ abierto, titulo, url, planes = [], onClose }) {
  if (!abierto) return null;

  const planesActivos = (planes || []).filter((p) => String(p.ESTADO || "").toLowerCase() === "activo");

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel modal-panel--wide hor-ver-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="hor-ver-modal-title"
      >
        <div className="modal-header hor-modal-header">
          <h2 id="hor-ver-modal-title">{titulo || "Horario"}</h2>
          <button type="button" className="btn-icon" onClick={onClose} aria-label="Cerrar">
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="modal-body hor-ver-modal-body">
          {url ? (
            <div className="hor-ver-modal-img">
              <img src={url} alt={titulo || "Horario"} />
            </div>
          ) : (
            <p className="hor-ver-state error">Este horario no tiene imagen asociada.</p>
          )}

          {planesActivos.length > 0 && (
            <div className="hor-plan-dias-panel">
              <h3>Días de asistencia por plan</h3>
              <p className="hor-plan-dias-hint">
                El porcentaje de asistencia en el informe solo considera los días habilitados en el plan del estudiante.
              </p>
              <ul className="hor-plan-dias-list">
                {planesActivos.map((p) => (
                  <li key={p.IDPLAN}>
                    <strong>{p.NOMBRE}</strong>
                    <span>{resumenDiasAsistencia(p.DIASASISTENCIA)}</span>
                  </li>
                ))}
              </ul>
            </div>
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

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTimes } from "@fortawesome/free-solid-svg-icons";

export default function HorarioVerModal({ abierto, titulo, url, onClose }) {
  if (!abierto) return null;

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

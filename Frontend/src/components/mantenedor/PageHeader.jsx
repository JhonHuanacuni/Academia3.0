import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlus } from "@fortawesome/free-solid-svg-icons";

export default function PageHeader({ titulo, onNuevo, mostrarNuevo = true }) {
  return (
    <div className="mantenedor-page-header">
      <h1>{titulo}</h1>
      {mostrarNuevo && (
        <button type="button" className="btn-primary" onClick={onNuevo}>
          <FontAwesomeIcon icon={faPlus} />
          Nuevo
        </button>
      )}
    </div>
  );
}

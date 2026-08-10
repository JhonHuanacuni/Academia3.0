import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faLink,
  faPencil,
  faTrash,
  faSort,
  faSortUp,
  faSortDown,
} from "@fortawesome/free-solid-svg-icons";
import { fmtFechaHora } from "./MateriaChipBar";
import { dbToView } from "../../utils/fecha";

function SortIcon({ col, orden }) {
  if (!col.ordenable) return null;
  if (orden.campo !== col.campo) return <FontAwesomeIcon icon={faSort} />;
  return <FontAwesomeIcon icon={orden.direccion === "ASC" ? faSortUp : faSortDown} />;
}

function renderCell(col, row) {
  const value = row[col.campo];

  if (col.tipo === "siNo") {
    return row.ENLACE ? <span className="cg-badge-si">SI</span> : "—";
  }
  if (col.tipo === "fechaHora") {
    return fmtFechaHora(row.FECHASUBIDA, row.HORASUBIDA);
  }
  if (col.tipo === "fechaHoraAudit") {
    return fmtFechaHora(value, row[col.origenHora]);
  }
  if (col.tipo === "estado") {
    const activo = String(value || "").toLowerCase() === "activo";
    return (
      <span className={`badge-estado ${activo ? "activo" : "inactivo"}`}>{value || "—"}</span>
    );
  }
  if (col.tipo === "fecha") return dbToView(String(value || ""));
  return value ?? "—";
}

export default function ClaseGrabadaTabla({
  columnas,
  items,
  pk,
  orden,
  loading,
  modo = "admin",
  onOrden,
  onEditar,
  onEliminar,
  onAbrirEnlace,
}) {
  const mostrarAcciones = modo === "admin" || modo === "estudiante";

  if (loading) {
    return <div className="mantenedor-state">Cargando...</div>;
  }
  if (!items.length) {
    return (
      <div className="mantenedor-state">
        <p>No hay grabaciones para mostrar.</p>
      </div>
    );
  }

  return (
    <div className="data-table-wrap cg-tabla-wrap">
      <table className="data-table">
        <thead>
          <tr>
            {columnas.map((col) => (
              <th
                key={col.campo}
                className={col.ordenable ? "sortable" : ""}
                onClick={() => col.ordenable && onOrden?.(col.campo)}
              >
                {col.etiqueta} <SortIcon col={col} orden={orden} />
              </th>
            ))}
            {mostrarAcciones && <th className="col-actions">Acciones</th>}
          </tr>
        </thead>
        <tbody>
          {items.map((row) => (
            <tr key={row[pk]}>
              {columnas.map((col) => (
                <td key={col.campo}>{renderCell(col, row)}</td>
              ))}
              {mostrarAcciones && (
                <td className="col-actions">
                  {modo === "admin" && (
                    <>
                      <button
                        type="button"
                        className="btn-icon"
                        title="Abrir enlace"
                        onClick={() => onAbrirEnlace?.(row)}
                      >
                        <FontAwesomeIcon icon={faLink} />
                      </button>
                      <button
                        type="button"
                        className="btn-icon"
                        title="Editar"
                        onClick={() => onEditar?.(row)}
                      >
                        <FontAwesomeIcon icon={faPencil} />
                      </button>
                      <button
                        type="button"
                        className="btn-icon danger"
                        title="Eliminar"
                        onClick={() => onEliminar?.(row)}
                      >
                        <FontAwesomeIcon icon={faTrash} />
                      </button>
                    </>
                  )}
                  {modo === "estudiante" && (
                    <button
                      type="button"
                      className="cg-btn-link"
                      onClick={() => onAbrirEnlace?.(row)}
                    >
                      <FontAwesomeIcon icon={faLink} /> Ver grabación
                    </button>
                  )}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

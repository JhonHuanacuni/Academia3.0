import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faPencil,
  faTrash,
  faDownload,
  faSort,
  faSortUp,
  faSortDown,
} from "@fortawesome/free-solid-svg-icons";
import { dbToView } from "../../utils/fecha";

function renderCell(col, row) {
  const value = row[col.campo];
  if (value == null || value === "") return "—";

  if (col.tipo === "estado") {
    const activo = String(value).toLowerCase() === "activo";
    return (
      <span className={`badge-estado ${activo ? "activo" : "inactivo"}`}>
        {value}
      </span>
    );
  }
  if (col.tipo === "fecha") return dbToView(String(value));
  if (col.tipo === "decimal") {
    const n = Number(value);
    if (Number.isNaN(n)) return String(value);
    return `S/ ${n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  }
  return String(value);
}

function SortIcon({ col, orden }) {
  if (!col.ordenable) return null;
  if (orden.campo !== col.campo) return <FontAwesomeIcon icon={faSort} />;
  return (
    <FontAwesomeIcon icon={orden.direccion === "ASC" ? faSortUp : faSortDown} />
  );
}

export default function DataTable({
  columnas,
  items,
  pk,
  orden,
  loading,
  error,
  onOrden,
  onVer,
  onEditar,
  onEliminar,
  onCarnet,
  onReintentar,
}) {
  if (loading) {
    return (
      <div className="data-table-wrap">
        <table className="data-table">
          <thead>
            <tr>
              {columnas.map((c) => (
                <th key={c.campo}>{c.etiqueta}</th>
              ))}
              <th className="col-actions">Acciones</th>
            </tr>
          </thead>
          <tbody>
            {Array.from({ length: 5 }).map((_, i) => (
              <tr key={i} className="skeleton-row">
                {columnas.map((c) => (
                  <td key={c.campo}>
                    <div className="skeleton-bar" />
                  </td>
                ))}
                <td>
                  <div className="skeleton-bar" />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  }

  if (error) {
    return (
      <div className="mantenedor-state error">
        <p>{error}</p>
        <button type="button" className="btn-secondary" onClick={onReintentar}>
          Reintentar
        </button>
      </div>
    );
  }

  if (!items.length) {
    return (
      <div className="mantenedor-state">
        <p>No hay registros. Crea el primero.</p>
      </div>
    );
  }

  return (
    <div className="data-table-wrap">
      <table className="data-table">
        <thead>
          <tr>
            {columnas.map((col) => (
              <th
                key={col.campo}
                className={col.ordenable ? "sortable" : ""}
                onClick={() => col.ordenable && onOrden(col.campo)}
              >
                {col.etiqueta} <SortIcon col={col} orden={orden} />
              </th>
            ))}
            <th className="col-actions">Acciones</th>
          </tr>
        </thead>
        <tbody>
          {items.map((row) => (
            <tr key={row[pk]}>
              {columnas.map((col) => (
                <td key={col.campo}>{renderCell(col, row)}</td>
              ))}
              <td className="col-actions">
                <button
                  type="button"
                  className="btn-icon"
                  title="Ver"
                  onClick={() => onVer(row)}
                >
                  <FontAwesomeIcon icon={faEye} />
                </button>
                <button
                  type="button"
                  className="btn-icon"
                  title="Editar"
                  onClick={() => onEditar(row)}
                >
                  <FontAwesomeIcon icon={faPencil} />
                </button>
                {onCarnet && (
                  <button
                    type="button"
                    className="btn-icon"
                    title="Descargar carnet"
                    onClick={() => onCarnet(row)}
                  >
                    <FontAwesomeIcon icon={faDownload} />
                  </button>
                )}
                <button
                  type="button"
                  className="btn-icon danger"
                  title="Eliminar"
                  onClick={() => onEliminar(row)}
                >
                  <FontAwesomeIcon icon={faTrash} />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faEye,
  faPencil,
  faTrash,
  faDownload,
  faKey,
  faCommentDots,
  faSort,
  faSortUp,
  faSortDown,
  faImage,
  faListUl,
} from "@fortawesome/free-solid-svg-icons";
import { dbToView, diasRestantesDesdeDb, textoDiasRestantes, claseDiasRestantes } from "../../utils/fecha";
import { resumenDiasAsistencia } from "../../utils/diasPlan";

function renderCell(col, row, index = 0, offset = 0) {
  if (col.tipo === "numero") {
    return offset + index + 1;
  }

  const value = row[col.campo];

  if (col.tipo === "diasRestantes") {
    const dias = diasRestantesDesdeDb(row[col.origen || "FECHAFIN"]);
    return (
      <span className={`dias-vence ${claseDiasRestantes(dias)}`}>
        {textoDiasRestantes(dias)}
      </span>
    );
  }

  if (col.tipo === "estadoMensualidad") {
    if (value == null || value === "") return "—";
    const v = String(value).toLowerCase();
    const clase = v === "activo" ? "activo" : v === "vencido" ? "vencido" : "inactivo";
    return <span className={`badge-estado ${clase}`}>{value}</span>;
  }

  if (col.tipo === "diasAsistencia") {
    return <span className="dias-asistencia-resumen">{resumenDiasAsistencia(value)}</span>;
  }

  if (col.tipo === "hora") {
    const s = String(value || "");
    return s.length >= 5 ? s.slice(0, 5) : "—";
  }

  if (col.tipo === "minutos") {
    const n = Number(value);
    if (Number.isNaN(n)) return "—";
    return `${n} min`;
  }

  if (value == null || value === "") return "—";

  if (col.tipo === "estado") {
    const activo = String(value).toLowerCase() === "activo";
    return (
      <span className={`badge-estado ${activo ? "activo" : "inactivo"}`}>
        {value}
      </span>
    );
  }
  if (col.tipo === "asistenciaEstado") {
    const v = String(value || "").toLowerCase();
    const clase =
      v === "presente" ? "activo" : v === "tarde" ? "inactivo" : v === "justificado" ? "activo" : "vencido";
    return <span className={`badge-estado ${clase}`}>{value || "—"}</span>;
  }
  if (col.tipo === "visibleExamen") {
    const on = value === true || value === 1 || value === "1" || String(value).toLowerCase() === "true";
    return (
      <span className={`badge-estado ${on ? "activo" : "inactivo"}`}>
        {on ? "Visible" : "Oculto"}
      </span>
    );
  }
  if (col.tipo === "tipoExamen") {
    const n = Number(value);
    if (Number.isNaN(n)) return String(value ?? "—");
    return `${n} preguntas`;
  }
  if (col.tipo === "fecha") return dbToView(String(value));
  if (col.tipo === "deuda") {
    const n = Number(value);
    if (value == null || value === "" || Number.isNaN(n) || n <= 0) {
      return <span className="badge-estado activo">Sin deuda</span>;
    }
    return (
      <span className="badge-estado vencido">
        Con deuda (S/{" "}
        {n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })})
      </span>
    );
  }
  if (col.tipo === "decimal") {
    const n = Number(value);
    if (Number.isNaN(n)) return String(value);
    return `S/ ${n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  }
  if (col.tipo === "saldoDeuda") {
    const n = Number(value);
    if (value == null || value === "" || Number.isNaN(n) || n <= 0) {
      return <span className="pex-saldo pex-saldo--ok">Sin deuda</span>;
    }
    return (
      <span className="pex-saldo pex-saldo--deuda">
        S/ {n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
      </span>
    );
  }
  if (col.tipo === "porcentaje") {
    const n = Number(value);
    if (Number.isNaN(n)) return String(value);
    return `${n.toLocaleString("es-PE", { minimumFractionDigits: 1, maximumFractionDigits: 1 })}%`;
  }
  if (col.tipo === "accionAuditoria") {
    const accion = String(value || "").toUpperCase();
    const clase =
      accion === "INSERT" ? "insert" : accion === "UPDATE" ? "update" : accion === "DELETE" ? "delete" : "";
    const label =
      accion === "INSERT" ? "Alta" : accion === "UPDATE" ? "Modificación" : accion === "DELETE" ? "Eliminación" : accion;
    return <span className={`auditoria-accion auditoria-accion--${clase}`}>{label}</span>;
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
  onResetContra,
  onWhatsapp,
  onVerPagos,
  onVerMensualidades,
  onReintentar,
  pagina = 1,
  tamanio = 10,
  verIcono = "eye",
}) {
  const mostrarAcciones = Boolean(
    onVer || onEditar || onEliminar || onCarnet || onResetContra || onWhatsapp || onVerPagos || onVerMensualidades,
  );
  const offset = Math.max(0, (pagina - 1) * tamanio);
  if (loading) {
    return (
      <div className="data-table-wrap">
        <table className="data-table">
          <thead>
            <tr>
              {columnas.map((c) => (
                <th key={c.campo}>{c.etiqueta}</th>
              ))}
              {mostrarAcciones && <th className="col-actions">Acciones</th>}
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
                {mostrarAcciones && (
                  <td>
                    <div className="skeleton-bar" />
                  </td>
                )}
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
            {mostrarAcciones && <th className="col-actions">Acciones</th>}
          </tr>
        </thead>
        <tbody>
          {items.map((row, index) => (
            <tr key={row[pk]}>
              {columnas.map((col) => (
                <td key={col.campo}>{renderCell(col, row, index, offset)}</td>
              ))}
              {mostrarAcciones && (
                <td className="col-actions">
                  {onVer && (
                    <button
                      type="button"
                      className="btn-icon"
                      title="Ver"
                      onClick={() => onVer(row)}
                    >
                      <FontAwesomeIcon icon={verIcono === "image" ? faImage : faEye} />
                    </button>
                  )}
                  {onEditar && (
                    <button
                      type="button"
                      className="btn-icon"
                      title="Editar"
                      onClick={() => onEditar(row)}
                    >
                      <FontAwesomeIcon icon={faPencil} />
                    </button>
                  )}
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
                  {onResetContra && (
                    <button
                      type="button"
                      className="btn-icon"
                      title="Restablecer contraseña al DNI"
                      onClick={() => onResetContra(row)}
                    >
                      <FontAwesomeIcon icon={faKey} />
                    </button>
                  )}
                  {onWhatsapp && (
                    <button
                      type="button"
                      className="btn-icon btn-icon--whatsapp"
                      title="WhatsApp"
                      onClick={() => onWhatsapp(row)}
                    >
                      <FontAwesomeIcon icon={faCommentDots} />
                    </button>
                  )}
                  {onVerMensualidades && (
                    <button
                      type="button"
                      className="btn-icon"
                      title="Ver mensualidades"
                      onClick={() => onVerMensualidades(row)}
                    >
                      <FontAwesomeIcon icon={faListUl} />
                    </button>
                  )}
                  {onVerPagos && (
                    <button
                      type="button"
                      className="btn-icon"
                      title="Ver listado de pagos"
                      onClick={() => onVerPagos(row)}
                    >
                      <FontAwesomeIcon icon={faListUl} />
                    </button>
                  )}
                  {onEliminar && (
                    <button
                      type="button"
                      className="btn-icon danger"
                      title="Eliminar"
                      onClick={() => onEliminar(row)}
                    >
                      <FontAwesomeIcon icon={faTrash} />
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

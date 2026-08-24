import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner, faTimes } from "@fortawesome/free-solid-svg-icons";
import DataTable from "../../components/mantenedor/DataTable";
import "../../styles/mantenedor.css";
import "../horario/horario.css";
import "./pago.css";

function dinero(value) {
  const n = Number(value);
  if (Number.isNaN(n)) return "—";
  return `S/ ${n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

export default function PagoDetalleModal({
  abierto,
  titulo,
  estudianteNombre,
  planNombre,
  resumen,
  pagos,
  columnas,
  pk,
  loading,
  onClose,
  onVer,
  onEditar,
  onEliminar,
}) {
  if (!abierto) return null;

  const deuda = Number(resumen?.deuda);
  const tieneDeuda = !Number.isNaN(deuda) && deuda > 0;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel modal-panel--wide pex-detalle-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="pago-detalle-title"
      >
        <div className="modal-header hor-modal-header">
          <h2 id="pago-detalle-title">{titulo || "Pagos del estudiante"}</h2>
          <button type="button" className="btn-icon" onClick={onClose} aria-label="Cerrar">
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="modal-body mens-est-body">
          {(estudianteNombre || planNombre) && (
            <div className="pago-abono-info mens-pagos-contexto">
              <div>
                {estudianteNombre && <strong>{estudianteNombre}</strong>}
                {planNombre && <span>{planNombre}</span>}
              </div>
              {resumen && (
                <div className="pago-mensualidad-montos mens-pagos-montos">
                  <span>Total: {dinero(resumen.montoTotal)}</span>
                  <span>Pagado: {dinero(resumen.pagado)}</span>
                  <span className={tieneDeuda ? "deuda" : "ok"}>
                    {tieneDeuda ? `Deuda: ${dinero(deuda)}` : "Completado"}
                  </span>
                </div>
              )}
            </div>
          )}

          <h3 className="form-section-title">Pagos registrados</h3>

          {loading ? (
            <div className="mantenedor-state">
              <FontAwesomeIcon icon={faSpinner} spin /> Cargando pagos...
            </div>
          ) : !pagos?.length ? (
            <div className="mantenedor-state">No hay pagos registrados para este estudiante.</div>
          ) : (
            <div className="mantenedor-card pex-detalle-tabla">
              <DataTable
                columnas={columnas}
                items={pagos}
                pk={pk}
                orden={{ campo: pk, direccion: "DESC" }}
                onVer={onVer}
                onEditar={onEditar}
                onEliminar={onEliminar}
              />
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

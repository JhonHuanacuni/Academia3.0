import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner, faTimes } from "@fortawesome/free-solid-svg-icons";
import { dbToView } from "../../utils/fecha";
import "../../styles/mantenedor.css";
import "../horario/horario.css";
import "../pago/pago.css";
import "./mensualidad.css";

function dinero(value) {
  const n = Number(value);
  if (Number.isNaN(n)) return "—";
  return `S/ ${n.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function formatHora(value) {
  const s = String(value || "");
  return s.length >= 5 ? s.slice(0, 5) : "—";
}

export default function MensualidadPagosModal({
  abierto,
  titulo,
  estudianteNombre,
  planNombre,
  resumen,
  pagos,
  loading,
  onClose,
}) {
  if (!abierto) return null;

  const retirado =
    String(resumen?.estudianteEstado || "").trim().toLowerCase() === "retirado";
  const deuda = Number(resumen?.deuda);
  const tieneDeuda = !retirado && !Number.isNaN(deuda) && deuda > 0;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel modal-panel--wide mens-pagos-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="mens-pagos-title"
      >
        <div className="modal-header hor-modal-header">
          <h2 id="mens-pagos-title">{titulo || "Pagos de la mensualidad"}</h2>
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
                  <span className={retirado ? "" : tieneDeuda ? "deuda" : "ok"}>
                    {retirado
                      ? "Retirado"
                      : tieneDeuda
                        ? `Deuda exigible: ${dinero(deuda)}`
                        : "Sin deuda exigible"}
                  </span>
                </div>
              )}
            </div>
          )}

          {resumen?.tieneCuotas && Array.isArray(resumen.cuotas) && resumen.cuotas.length > 0 && (
            <>
              <h3 className="form-section-title">Cuotas del periodo</h3>
              <div className="mantenedor-card mens-pagos-tabla" style={{ marginBottom: "1rem" }}>
                <div className="data-table-wrap">
                  <table className="data-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Periodo</th>
                        <th>Monto</th>
                        <th>Pagado</th>
                        <th>Saldo</th>
                        <th>Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      {resumen.cuotas.map((c) => (
                        <tr key={c.IDCUOTA}>
                          <td>{c.NUMERO}</td>
                          <td>
                            {dbToView(String(c.FECHAINICIO || ""))} —{" "}
                            {dbToView(String(c.FECHAFIN || ""))}
                          </td>
                          <td>{dinero(c.MONTO)}</td>
                          <td>{dinero(c.PAGADO)}</td>
                          <td>{dinero(c.DEUDA)}</td>
                          <td>
                            <span
                              className={`pago-cuota-estado estado-${String(c.ESTADO_CALC || c.ESTADO || "").toLowerCase()}`}
                            >
                              {c.ESTADO_CALC || c.ESTADO || "—"}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </>
          )}

          <h3 className="form-section-title">Pagos registrados</h3>

          {loading ? (
            <div className="mantenedor-state">
              <FontAwesomeIcon icon={faSpinner} spin /> Cargando pagos...
            </div>
          ) : !pagos?.length ? (
            <div className="mantenedor-state">No hay pagos registrados para esta mensualidad.</div>
          ) : (
            <div className="mantenedor-card mens-pagos-tabla">
              <div className="data-table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Fecha</th>
                      <th>Hora</th>
                      <th>Cuota</th>
                      <th>Mora</th>
                      <th>Total cobrado</th>
                      <th>N.º cuota</th>
                      <th>Método</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pagos.map((pago) => (
                      <tr key={pago.IDPAGOMENSUALIDAD}>
                        <td>{dbToView(String(pago.FECHAPAGO || "")) || "—"}</td>
                        <td>{formatHora(pago.HORAPAGO)}</td>
                        <td>{dinero(pago.MONTO)}</td>
                        <td>{dinero(pago.MORA || 0)}</td>
                        <td>{dinero(pago.TOTAL_COBRADO ?? Number(pago.MONTO || 0) + Number(pago.MORA || 0))}</td>
                        <td>{pago.CUOTA_NUMERO || "—"}</td>
                        <td>{pago.METODOPAGO_TITULO || "—"}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
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

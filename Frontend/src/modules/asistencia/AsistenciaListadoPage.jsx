import { useCallback, useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faDownload, faSpinner } from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import "../../styles/mantenedor.css";
import "./asistencia.css";

export default function AsistenciaListadoPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  const [buscar, setBuscar] = useState("");
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  const cargar = useCallback(async () => {
    try {
      setCargando(true);
      setError("");
      const params = new URLSearchParams({ tamanio: "100" });
      if (buscar) params.set("buscar", buscar);
      const res = await fetch(`/api/asistencias/?${params}`);
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "Error al cargar");
      setItems(data.data || []);
      setTotal(data.total || 0);
    } catch (err) {
      setError(err.message);
      setItems([]);
    } finally {
      setCargando(false);
    }
  }, [buscar]);

  useEffect(() => {
    cargar();
  }, [cargar]);

  const descargarCarnet = (idusuario, dni) => {
    window.open(`/api/usuarios/${encodeURIComponent(idusuario)}/carnet/`, "_blank");
  };

  return (
    <div className="asistencia-page">
      <div className="asistencia-header">
        <h1>Asistencias de hoy</h1>
        <p>{total} registro{total !== 1 ? "s" : ""}</p>
      </div>

      <div className="mantenedor-card">
        <div className="mantenedor-toolbar">
          <div className="mantenedor-search">
            <input
              type="text"
              placeholder="Buscar por DNI o nombre..."
              value={buscar}
              onChange={(e) => setBuscar(e.target.value)}
            />
          </div>
          <button type="button" className="btn-secondary" onClick={cargar}>
            Actualizar
          </button>
        </div>

        {cargando ? (
          <div className="mantenedor-state">
            <FontAwesomeIcon icon={faSpinner} spin /> Cargando...
          </div>
        ) : error ? (
          <div className="mantenedor-state error">{error}</div>
        ) : items.length === 0 ? (
          <div className="mantenedor-state">Sin asistencias registradas hoy.</div>
        ) : (
          <div className="data-table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Hora</th>
                  <th>DNI</th>
                  <th>Nombre</th>
                  <th>Estado</th>
                  <th className="col-actions">Carnet</th>
                </tr>
              </thead>
              <tbody>
                {items.map((row) => (
                  <tr key={row.IDASISTENCIA}>
                    <td>{(row.HORAINICIO || "").slice(0, 5)}</td>
                    <td>{row.DNI}</td>
                    <td>{row.NOMBRE} {row.APELLIDO}</td>
                    <td>
                      <span className={`badge-estado ${row.ESTADO === "Tarde" ? "inactivo" : "activo"}`}>
                        {row.ESTADO}
                      </span>
                    </td>
                    <td className="col-actions">
                      <button
                        type="button"
                        className="btn-icon"
                        title="Descargar carnet"
                        onClick={() => descargarCarnet(row.IDUSUARIO, row.DNI)}
                      >
                        <FontAwesomeIcon icon={faDownload} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

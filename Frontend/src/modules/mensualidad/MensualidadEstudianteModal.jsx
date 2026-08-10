import { useEffect, useMemo, useRef, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner, faTimes } from "@fortawesome/free-solid-svg-icons";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import Toolbar from "../../components/mantenedor/Toolbar";
import { mensualidadEstudianteColumnas } from "./mensualidadEstudiante.config";
import { dbToSortKey } from "../../utils/fecha";
import "../../styles/mantenedor.css";
import "../horario/horario.css";
import "./mensualidad.css";

const PK = "IDMENSUALIDAD";
const TAMANIO = 5;

function valorOrden(row, campo) {
  if (campo === "FECHAINICIO" || campo === "FECHAFIN" || campo === "FECHAREGISTRO") {
    return dbToSortKey(row[campo]) || "";
  }
  const n = Number(row[campo]);
  if (!Number.isNaN(n) && row[campo] !== "" && row[campo] != null) return n;
  return String(row[campo] ?? "").toLowerCase();
}

function compararFilas(a, b, campo, direccion) {
  const va = valorOrden(a, campo);
  const vb = valorOrden(b, campo);
  let cmp = 0;
  if (typeof va === "number" && typeof vb === "number") {
    cmp = va - vb;
  } else {
    cmp = String(va).localeCompare(String(vb), "es");
  }
  if (cmp === 0) {
    cmp = String(a[PK]).localeCompare(String(b[PK]));
  }
  return direccion === "ASC" ? cmp : -cmp;
}

export default function MensualidadEstudianteModal({
  abierto,
  estudianteNombre,
  estudianteDni,
  items,
  loading,
  onClose,
  onVerPagos,
}) {
  const [pagina, setPagina] = useState(1);
  const [buscar, setBuscar] = useState("");
  const [buscarInput, setBuscarInput] = useState("");
  const [orden, setOrden] = useState({ campo: "FECHAREGISTRO", direccion: "DESC" });
  const debounceRef = useRef(null);

  useEffect(() => {
    if (!abierto) {
      setPagina(1);
      setBuscar("");
      setBuscarInput("");
      setOrden({ campo: "FECHAREGISTRO", direccion: "DESC" });
    }
  }, [abierto]);

  const filtradas = useMemo(() => {
    const q = buscar.trim().toLowerCase();
    if (!q) return items || [];
    return (items || []).filter((row) =>
      ["PLAN_NOMBRE", "AULA_NOMBRE", PK].some((campo) =>
        String(row[campo] ?? "").toLowerCase().includes(q),
      ),
    );
  }, [items, buscar]);

  const ordenadas = useMemo(() => {
    const list = [...filtradas];
    list.sort((a, b) => compararFilas(a, b, orden.campo, orden.direccion));
    return list;
  }, [filtradas, orden]);

  const total = ordenadas.length;
  const paginaItems = useMemo(() => {
    const start = (pagina - 1) * TAMANIO;
    return ordenadas.slice(start, start + TAMANIO);
  }, [ordenadas, pagina]);

  const onBuscarChange = (value) => {
    setBuscarInput(value);
    clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      setBuscar(value);
      setPagina(1);
    }, 400);
  };

  const toggleOrden = (campo) => {
    setOrden((prev) => ({
      campo,
      direccion: prev.campo === campo && prev.direccion === "ASC" ? "DESC" : "ASC",
    }));
    setPagina(1);
  };

  if (!abierto) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel mens-est-modal"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="mens-est-title"
      >
        <div className="modal-header hor-modal-header mens-est-header">
          <div>
            <h2 id="mens-est-title">Mensualidades del estudiante</h2>
            {(estudianteNombre || estudianteDni) && (
              <p className="mens-est-subtitulo">
                {[estudianteNombre, estudianteDni ? `DNI ${estudianteDni}` : null]
                  .filter(Boolean)
                  .join(" · ")}
              </p>
            )}
          </div>
          <button type="button" className="btn-icon mens-est-close" onClick={onClose} aria-label="Cerrar">
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="modal-body mens-est-body">
          {loading ? (
            <div className="mantenedor-state">
              <FontAwesomeIcon icon={faSpinner} spin /> Cargando mensualidades...
            </div>
          ) : (
            <div className="mantenedor-card mens-est-listado">
              <Toolbar
                buscar={buscarInput}
                onBuscarChange={onBuscarChange}
                placeholder="Buscar plan o código..."
              />

              <DataTable
                columnas={mensualidadEstudianteColumnas}
                items={paginaItems}
                pk={PK}
                orden={orden}
                loading={false}
                error=""
                onOrden={toggleOrden}
                onVerPagos={onVerPagos}
                onReintentar={() => {}}
                pagina={pagina}
                tamanio={TAMANIO}
              />

              {total > 0 && (
                <Pagination
                  pagina={pagina}
                  tamanio={TAMANIO}
                  total={total}
                  onChange={setPagina}
                />
              )}
            </div>
          )}
        </div>

        <div className="modal-footer mens-est-footer">
          <button type="button" className="btn-secondary" onClick={onClose}>
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}

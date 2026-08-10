import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTimes } from "@fortawesome/free-solid-svg-icons";
import "../../styles/mantenedor.css";
import "./claseGrabada.css";

const emptyForm = () => ({
  IDAULA: "",
  IDMATERIA: "",
  DETALLES: "",
  ENLACE: "",
  ESTADO: "Activo",
});

export default function ClaseGrabadaFormModal({
  abierto,
  titulo,
  registro,
  aulas,
  materias,
  materiaPreseleccionada,
  onClose,
  onSubmit,
}) {
  const [values, setValues] = useState(emptyForm());
  const [enviando, setEnviando] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!abierto) return;
    setError("");
    if (registro) {
      setValues({
        IDAULA: registro.IDAULA || "",
        IDMATERIA: registro.IDMATERIA || "",
        DETALLES: registro.DETALLES || "",
        ENLACE: registro.ENLACE || "",
        ESTADO: registro.ESTADO || "Activo",
      });
    } else {
      setValues({
        ...emptyForm(),
        IDMATERIA: materiaPreseleccionada || "",
      });
    }
  }, [abierto, registro, materiaPreseleccionada]);

  if (!abierto) return null;

  const set = (campo, val) => setValues((prev) => ({ ...prev, [campo]: val }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    if (!values.IDAULA || !values.IDMATERIA || !values.DETALLES.trim() || !values.ENLACE.trim()) {
      setError("Completa salón, materia, detalles y enlace.");
      return;
    }
    try {
      setEnviando(true);
      await onSubmit(values);
      onClose();
    } catch (err) {
      setError(err.message || "No se pudo guardar");
    } finally {
      setEnviando(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-panel" onClick={(e) => e.stopPropagation()} role="dialog" aria-modal="true">
        <div className="modal-header">
          <h2>{titulo}</h2>
          <button type="button" className="btn-icon" onClick={onClose} aria-label="Cerrar">
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            {error && <p className="form-error">{error}</p>}
            <div className="cg-form-grid">
              <div className="form-field">
                <label htmlFor="cg-aula">Salón *</label>
                <select
                  id="cg-aula"
                  value={values.IDAULA}
                  onChange={(e) => set("IDAULA", e.target.value)}
                  required
                >
                  <option value="">Seleccione un salón</option>
                  {aulas.map((a) => (
                    <option key={a.value} value={a.value}>
                      {a.label}
                    </option>
                  ))}
                </select>
              </div>
              <div className="form-field">
                <label htmlFor="cg-materia">Materia *</label>
                <select
                  id="cg-materia"
                  value={values.IDMATERIA}
                  onChange={(e) => set("IDMATERIA", e.target.value)}
                  required
                >
                  <option value="">Seleccione materia</option>
                  {materias.map((m) => (
                    <option key={m.value} value={m.value}>
                      {m.label}
                    </option>
                  ))}
                </select>
              </div>
              <div className="form-field full">
                <label htmlFor="cg-detalles">Detalles *</label>
                <input
                  id="cg-detalles"
                  type="text"
                  value={values.DETALLES}
                  onChange={(e) => set("DETALLES", e.target.value)}
                  placeholder="Ej. SEMANA 13, FEEDBACK 1..."
                  required
                />
              </div>
              <div className="form-field full">
                <label htmlFor="cg-enlace">Enlace de grabación *</label>
                <input
                  id="cg-enlace"
                  type="url"
                  value={values.ENLACE}
                  onChange={(e) => set("ENLACE", e.target.value)}
                  placeholder="https://..."
                  required
                />
              </div>
              <div className="form-field">
                <label htmlFor="cg-estado">Estado</label>
                <select id="cg-estado" value={values.ESTADO} onChange={(e) => set("ESTADO", e.target.value)}>
                  <option value="Activo">Activo</option>
                  <option value="Inactivo">Inactivo</option>
                </select>
              </div>
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn-secondary" onClick={onClose} disabled={enviando}>
              Cancelar
            </button>
            <button type="submit" className="btn-primary" disabled={enviando}>
              {enviando ? "Guardando..." : "Guardar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

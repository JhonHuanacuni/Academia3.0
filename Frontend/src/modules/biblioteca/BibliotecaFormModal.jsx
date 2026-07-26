import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faSpinner, faTimes } from "@fortawesome/free-solid-svg-icons";

const emptyForm = () => ({
  TITULO: "",
  DESCRIPCION: "",
  ESTADO: "Activo",
  AULAS: [],
});

export default function BibliotecaFormModal({
  abierto,
  modo,
  titulo,
  registro,
  aulas = [],
  onClose,
  onSubmit,
}) {
  const [values, setValues] = useState(emptyForm());
  const [archivo, setArchivo] = useState(null);
  const [portada, setPortada] = useState(null);
  const [errors, setErrors] = useState({});
  const [enviando, setEnviando] = useState(false);
  const soloLectura = modo === "ver";

  useEffect(() => {
    if (!abierto) return;
    if (modo === "crear") {
      setValues(emptyForm());
      setArchivo(null);
      setPortada(null);
    } else if (registro) {
      setValues({
        TITULO: registro.TITULO || "",
        DESCRIPCION: registro.DESCRIPCION || "",
        ESTADO: registro.ESTADO || "Activo",
        AULAS: Array.isArray(registro.AULAS) ? [...registro.AULAS] : [],
      });
      setArchivo(null);
      setPortada(null);
    }
    setErrors({});
  }, [abierto, modo, registro]);

  if (!abierto) return null;

  const toggleAula = (id) => {
    if (soloLectura) return;
    setValues((prev) => {
      const set = new Set(prev.AULAS);
      if (set.has(id)) set.delete(id);
      else set.add(id);
      return { ...prev, AULAS: [...set] };
    });
  };

  const validate = () => {
    const next = {};
    if (!String(values.TITULO || "").trim()) next.TITULO = "Ingresa el título.";
    if (modo === "crear" && !archivo) next.archivo = "Selecciona un archivo PDF.";
    if (archivo && !archivo.name.toLowerCase().endsWith(".pdf")) {
      next.archivo = "El archivo debe ser PDF.";
    }
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (soloLectura) return;
    if (!validate()) return;
    setEnviando(true);
    try {
      await onSubmit({ ...values, archivo, portada });
      onClose();
    } catch (err) {
      setErrors({ form: err.message || "Error al guardar" });
    } finally {
      setEnviando(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-panel modal-panel--form modal-panel--wide"
        onClick={(ev) => ev.stopPropagation()}
        role="dialog"
        aria-modal="true"
      >
        <form className="modal-form" onSubmit={handleSubmit}>
          <div className="modal-header bib-modal-header">
            <h2>{titulo}</h2>
            <button type="button" className="btn-icon" onClick={onClose} aria-label="Cerrar">
              <FontAwesomeIcon icon={faTimes} />
            </button>
          </div>

          <div className="modal-body">
            {errors.form && <p className="field-error form-error-banner">{errors.form}</p>}

            <section className="form-section">
              <div className="form-grid">
                <div className={`form-field full ${errors.TITULO ? "has-error" : ""}`}>
                  <label htmlFor="bib-titulo">
                    Título <span className="req">*</span>
                  </label>
                  <input
                    id="bib-titulo"
                    type="text"
                    value={values.TITULO}
                    disabled={soloLectura}
                    onChange={(e) => setValues((v) => ({ ...v, TITULO: e.target.value }))}
                  />
                  {errors.TITULO && <span className="field-error">{errors.TITULO}</span>}
                </div>

                <div className="form-field full">
                  <label htmlFor="bib-desc">Descripción</label>
                  <textarea
                    id="bib-desc"
                    rows={3}
                    value={values.DESCRIPCION}
                    disabled={soloLectura}
                    onChange={(e) => setValues((v) => ({ ...v, DESCRIPCION: e.target.value }))}
                  />
                </div>

                <div className="form-field full">
                  <label>Salones</label>
                  <div className="bib-aulas-grid">
                    {aulas.length === 0 && (
                      <p className="field-hint">No hay salones activos registrados.</p>
                    )}
                    {aulas.map((a) => (
                      <label key={a.value} className="bib-aula-check">
                        <input
                          type="checkbox"
                          checked={values.AULAS.includes(a.value)}
                          disabled={soloLectura}
                          onChange={() => toggleAula(a.value)}
                        />
                        <span>{a.label}</span>
                      </label>
                    ))}
                  </div>
                </div>

                <div className={`form-field full ${errors.archivo ? "has-error" : ""}`}>
                  <label htmlFor="bib-pdf">
                    Archivo PDF {modo === "crear" && <span className="req">*</span>}
                  </label>
                  <input
                    id="bib-pdf"
                    type="file"
                    accept="application/pdf,.pdf"
                    disabled={soloLectura}
                    onChange={(e) => setArchivo(e.target.files?.[0] || null)}
                  />
                  {modo !== "crear" && registro?.URLPDF && !archivo && (
                    <span className="field-hint">
                      PDF actual:{" "}
                      <a href={registro.URLPDF} target="_blank" rel="noreferrer">
                        ver archivo
                      </a>
                    </span>
                  )}
                  {errors.archivo && <span className="field-error">{errors.archivo}</span>}
                </div>

                <div className="form-field full">
                  <label htmlFor="bib-portada">Portada (opcional)</label>
                  <input
                    id="bib-portada"
                    type="file"
                    accept="image/*"
                    disabled={soloLectura}
                    onChange={(e) => setPortada(e.target.files?.[0] || null)}
                  />
                  {registro?.URLPORTADA && !portada && (
                    <span className="field-hint">Portada actual disponible.</span>
                  )}
                </div>

                <div className="form-field">
                  <label className="bib-toggle" htmlFor="bib-activo">
                    <span>Activo</span>
                    <input
                      id="bib-activo"
                      type="checkbox"
                      checked={values.ESTADO === "Activo"}
                      disabled={soloLectura}
                      onChange={(e) =>
                        setValues((v) => ({
                          ...v,
                          ESTADO: e.target.checked ? "Activo" : "Inactivo",
                        }))
                      }
                    />
                    <span className="bib-toggle-track" aria-hidden="true" />
                  </label>
                </div>
              </div>
            </section>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn-secondary" onClick={onClose}>
              {soloLectura ? "Cerrar" : "Cancelar"}
            </button>
            {!soloLectura && (
              <button type="submit" className="btn-primary" disabled={enviando}>
                {enviando && <FontAwesomeIcon icon={faSpinner} spin />}
                Guardar
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
}

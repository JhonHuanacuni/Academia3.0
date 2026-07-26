import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faEye, faSpinner, faTimes, faTrash, faImage } from "@fortawesome/free-solid-svg-icons";

const LETRAS = ["A", "B", "C", "D", "E"];

function emptyAlts() {
  return LETRAS.map(() => ({
    texto: "",
    file: null,
    preview: null,
    quitar: false,
    urlServer: null,
  }));
}

export default function ExamenPreguntaEditor({ pregunta, soloLectura, onGuardar }) {
  const [descripcion, setDescripcion] = useState("");
  const [correcta, setCorrecta] = useState(1);
  const [imagen, setImagen] = useState(null);
  const [quitarImagen, setQuitarImagen] = useState(false);
  const [previewLocal, setPreviewLocal] = useState(null);
  const [alts, setAlts] = useState(emptyAlts);
  const [enviando, setEnviando] = useState(false);
  const [error, setError] = useState("");
  const [imagenModal, setImagenModal] = useState(null);

  useEffect(() => {
    if (!pregunta) return;
    setDescripcion(pregunta.DESCRIPCION || "");
    const ordered = [...(pregunta.ALTERNATIVAS || [])].sort(
      (a, b) => (a.ORDEN || 0) - (b.ORDEN || 0),
    );
    const next = emptyAlts();
    let corr = 1;
    ordered.forEach((a, i) => {
      if (i >= 5) return;
      next[i] = {
        texto: a.DESCRIPCION || "",
        file: null,
        preview: null,
        quitar: false,
        urlServer: a.URLPREVIEW || null,
      };
      if (a.ESCORRECTA) corr = a.ORDEN || i + 1;
    });
    setAlts(next);
    setCorrecta(corr);
    setImagen(null);
    setQuitarImagen(false);
    setPreviewLocal(null);
    setError("");
    setImagenModal(null);
  }, [pregunta]);

  if (!pregunta) {
    return (
      <div className="examen-preg-empty">
        <p>Selecciona una pregunta de la lista para editar el enunciado, imagen y alternativas.</p>
      </div>
    );
  }

  const previewSrc =
    previewLocal || (!quitarImagen && pregunta.URLPREVIEW ? pregunta.URLPREVIEW : null);

  const setAlt = (idx, patch) => {
    setAlts((prev) => prev.map((a, i) => (i === idx ? { ...a, ...patch } : a)));
  };

  const handleFilePregunta = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 2 * 1024 * 1024) {
      setError("La imagen no debe superar 2 MB.");
      e.target.value = "";
      return;
    }
    setImagen(file);
    setQuitarImagen(false);
    setPreviewLocal(URL.createObjectURL(file));
    setError("");
  };

  const handleFileAlt = (idx, e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 2 * 1024 * 1024) {
      setError("La imagen de la alternativa no debe superar 2 MB.");
      e.target.value = "";
      return;
    }
    setAlt(idx, {
      file,
      preview: URL.createObjectURL(file),
      quitar: false,
    });
    setError("");
  };

  const handleGuardar = async () => {
    if (!String(descripcion || "").trim()) {
      setError("Ingresa el enunciado de la pregunta.");
      return;
    }
    if (!alts.some((a) => String(a.texto || "").trim())) {
      setError("Completa al menos una alternativa.");
      return;
    }
    try {
      setEnviando(true);
      setError("");
      await onGuardar({
        DESCRIPCION: descripcion,
        ALT1: alts[0].texto,
        ALT2: alts[1].texto,
        ALT3: alts[2].texto,
        ALT4: alts[3].texto,
        ALT5: alts[4].texto,
        CORRECTA_ORDEN: correcta,
        imagen,
        QUITAR_IMAGEN: quitarImagen,
        imagenesAlt: alts.map((a) => a.file),
        quitarImagenesAlt: alts.map((a) => a.quitar),
      });
    } catch (err) {
      setError(err.message || "No se pudo guardar la pregunta.");
    } finally {
      setEnviando(false);
    }
  };

  return (
    <div className="examen-preg-editor examen-preg-editor--compact mantenedor-card">
      <div className="examen-preg-editor-head">
        <h4>Pregunta {pregunta.ORDEN}</h4>
        <span className="examen-preg-badge">{pregunta.MATERIA_CODIGO || "—"}</span>
        <span className="examen-muted">{pregunta.MATERIA_NOMBRE}</span>
      </div>

      <div className="examen-preg-editor-grid">
        <div className="examen-preg-col-enunciado">
          <div className="examen-field examen-field--tight">
            <div className="examen-field-label-row">
              <label>Enunciado</label>
              <div className="examen-image-actions examen-image-actions--inline">
                {previewSrc && (
                  <button
                    type="button"
                    className="btn-secondary examen-file-btn examen-file-btn--sm"
                    onClick={() =>
                      setImagenModal({ src: previewSrc, titulo: "Imagen del enunciado" })
                    }
                  >
                    <FontAwesomeIcon icon={faEye} /> Ver
                  </button>
                )}
                {!soloLectura && (
                  <>
                    <label className="btn-secondary examen-file-btn examen-file-btn--sm">
                      <FontAwesomeIcon icon={faImage} /> Imagen
                      <input
                        type="file"
                        accept="image/jpeg,image/png,image/webp,image/gif"
                        hidden
                        onChange={handleFilePregunta}
                      />
                    </label>
                    {(previewSrc || pregunta.IMAGEURL) && !quitarImagen && (
                      <button
                        type="button"
                        className="btn-secondary examen-file-btn--sm"
                        onClick={() => {
                          setImagen(null);
                          setPreviewLocal(null);
                          setQuitarImagen(true);
                        }}
                      >
                        <FontAwesomeIcon icon={faTrash} />
                      </button>
                    )}
                  </>
                )}
              </div>
            </div>
            {soloLectura ? (
              <div className="examen-pre-wrap examen-readonly-box examen-enunciado-box">{descripcion || "—"}</div>
            ) : (
              <textarea
                className="examen-enunciado-box"
                value={descripcion}
                onChange={(e) => setDescripcion(e.target.value)}
                placeholder="Escribe el enunciado. Los saltos de línea se conservan."
              />
            )}
          </div>
        </div>

        <div className="examen-preg-col-alts">
          <label className="examen-alts-heading">Alternativas — marca la correcta</label>
          <div className="examen-alts examen-alts--compact">
            {LETRAS.map((letra, idx) => {
              const alt = alts[idx];
              const altPreview =
                alt.preview || (!alt.quitar && alt.urlServer ? alt.urlServer : null);
              return (
                <div
                  key={letra}
                  className={`examen-alt-row${correcta === idx + 1 ? " is-correct" : ""}`}
                >
                  <label className="examen-alt-radio" title="Marcar como correcta">
                    <input
                      type="radio"
                      name={`correcta-${pregunta.IDPREGUNTA}`}
                      checked={correcta === idx + 1}
                      disabled={soloLectura}
                      onChange={() => setCorrecta(idx + 1)}
                    />
                    <span>{letra}</span>
                  </label>
                  <input
                    type="text"
                    className="examen-alt-input"
                    value={alt.texto}
                    disabled={soloLectura}
                    placeholder={`Texto ${letra}`}
                    onChange={(e) => setAlt(idx, { texto: e.target.value })}
                  />
                  {altPreview && (
                    <button
                      type="button"
                      className="btn-secondary examen-file-btn examen-file-btn--icon"
                      title={`Ver imagen ${letra}`}
                      onClick={() =>
                        setImagenModal({ src: altPreview, titulo: `Imagen alternativa ${letra}` })
                      }
                    >
                      <FontAwesomeIcon icon={faEye} />
                    </button>
                  )}
                  {!soloLectura && (
                    <div className="examen-alt-img-btns">
                      <label className="btn-secondary examen-file-btn examen-file-btn--icon" title={`Imagen ${letra}`}>
                        <FontAwesomeIcon icon={faImage} />
                        <input
                          type="file"
                          accept="image/jpeg,image/png,image/webp,image/gif"
                          hidden
                          onChange={(e) => handleFileAlt(idx, e)}
                        />
                      </label>
                      {(altPreview || alt.urlServer) && (
                        <button
                          type="button"
                          className="btn-secondary examen-file-btn--icon"
                          title="Quitar imagen"
                          onClick={() =>
                            setAlt(idx, { file: null, preview: null, quitar: true })
                          }
                        >
                          <FontAwesomeIcon icon={faTrash} />
                        </button>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {error && <p className="error">{error}</p>}

      {!soloLectura && (
        <div className="examen-form-actions examen-form-actions--tight">
          <button type="button" className="btn-primary" disabled={enviando} onClick={handleGuardar}>
            {enviando ? <FontAwesomeIcon icon={faSpinner} spin /> : null} Guardar pregunta
          </button>
        </div>
      )}

      {imagenModal && (
        <div
          className="modal-overlay examen-img-modal-overlay"
          onClick={() => setImagenModal(null)}
          role="presentation"
        >
          <div
            className="modal-panel examen-img-modal"
            onClick={(e) => e.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-label={imagenModal.titulo}
          >
            <div className="modal-header examen-img-modal-header">
              <h3>{imagenModal.titulo}</h3>
              <button
                type="button"
                className="btn-secondary examen-img-modal-close"
                onClick={() => setImagenModal(null)}
                aria-label="Cerrar"
              >
                <FontAwesomeIcon icon={faTimes} />
              </button>
            </div>
            <div className="examen-img-modal-body">
              <img src={imagenModal.src} alt="" />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

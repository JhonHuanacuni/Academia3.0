export default function FieldRenderer({
  campo,
  value,
  error,
  disabled,
  catalogo = [],
  onChange,
}) {
  const className = `form-field ${campo.full ? "full" : ""} ${error ? "has-error" : ""}`;

  const renderControl = () => {
    if (campo.control === "select" && campo.catalogo) {
      return (
        <select value={value} disabled={disabled} onChange={(e) => onChange(e.target.value)}>
          <option value="">Selecciona...</option>
          {catalogo.map((op) => (
            <option key={op.value} value={op.value}>
              {op.label}
            </option>
          ))}
        </select>
      );
    }
    if (campo.control === "select") {
      return (
        <select value={value} disabled={disabled} onChange={(e) => onChange(e.target.value)}>
          {(campo.opciones || []).map((op) => (
            <option key={op} value={op}>
              {op}
            </option>
          ))}
        </select>
      );
    }
    if (campo.control === "textarea") {
      return (
        <textarea
          rows={3}
          value={value}
          disabled={disabled}
          onChange={(e) => onChange(e.target.value)}
        />
      );
    }
    if (campo.control === "image") {
      const previewSrc = value
        ? value.startsWith("data:")
          ? value
          : `data:image/jpeg;base64,${value}`
        : null;

      const handleFile = (e) => {
        const file = e.target.files?.[0];
        if (!file) return;
        if (file.size > 500 * 1024) {
          onChange("");
          alert("La imagen no debe superar 500 KB. Usa JPG comprimido.");
          e.target.value = "";
          return;
        }
        const reader = new FileReader();
        reader.onload = () => {
          const result = String(reader.result || "");
          const base64 = result.includes(",") ? result.split(",")[1] : result;
          onChange(base64);
        };
        reader.readAsDataURL(file);
      };

      return (
        <div className="image-field">
          {previewSrc && (
            <img src={previewSrc} alt="Vista previa" className="image-field-preview" />
          )}
          <input
            type="file"
            accept="image/jpeg,image/png,image/webp"
            disabled={disabled}
            onChange={handleFile}
          />
          {value && !disabled && (
            <button type="button" className="btn-link" onClick={() => onChange("")}>
              Quitar foto
            </button>
          )}
        </div>
      );
    }
    return (
      <input
        type={
          campo.control === "password"
            ? "password"
            : campo.control === "date"
              ? "date"
              : campo.control === "time"
                ? "time"
                : campo.control === "number"
                  ? "number"
                  : "text"
        }
        step={campo.control === "number" ? (campo.step ?? "0.01") : undefined}
        min={campo.control === "number" ? (campo.min ?? "0") : undefined}
        max={campo.control === "number" ? campo.max : undefined}
        value={value}
        disabled={disabled}
        onChange={(e) => onChange(e.target.value)}
      />
    );
  };

  return (
    <div className={className}>
      <label htmlFor={campo.campo}>{campo.etiqueta}</label>
      {renderControl()}
      {error && <span className="field-error">{error}</span>}
      {campo.ayuda && <span className="field-hint">{campo.ayuda}</span>}
    </div>
  );
}

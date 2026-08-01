import { useEffect, useMemo, useRef, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faSpinner,
  faFileExcel,
  faUpload,
  faClipboardList,
} from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import { hoyInput, inputToDb } from "../../utils/fecha";
import { parseExcelFile } from "../../utils/parseExcel";
import "../../styles/mantenedor.css";
import "./notas.css";

const AREAS_ACADEMICAS = [
  { value: "A", label: "CIENCIAS DE LA SALUD" },
  { value: "B", label: "CIENCIAS BÁSICAS" },
  { value: "C", label: "INGENIERÍA" },
  { value: "D", label: "CIENCIAS ECONÓMICAS Y DE LA GESTIÓN" },
  { value: "E", label: "HUMANIDADES Y CIENCIAS JURÍDICAS Y SOCIALES" },
];

const MAX_FILE_SIZE = 10 * 1024 * 1024;

function SelectField({ label, value, onChange, disabled, children }) {
  return (
    <div className="form-field">
      <label>{label}</label>
      <select value={value} onChange={onChange} disabled={disabled}>
        {children}
      </select>
    </div>
  );
}

export default function NotasImportForm({ onCancel, onSuccess }) {
  const fileRef = useRef(null);
  const [modo, setModo] = useState("presencial");
  const [tipoImportacion, setTipoImportacion] = useState(40);
  const [tipoArea, setTipoArea] = useState("A");
  const [idAula, setIdAula] = useState("");
  const [nombreArchivo, setNombreArchivo] = useState("");
  const [fechaExamen, setFechaExamen] = useState(hoyInput());
  const [filas, setFilas] = useState([]);
  const [aulas, setAulas] = useState([]);
  const [loading, setLoading] = useState(false);
  const [cargandoCat, setCargandoCat] = useState(true);
  const [error, setError] = useState("");
  const [importadoPor, setImportadoPor] = useState("");
  const [archivoSeleccionado, setArchivoSeleccionado] = useState("");

  useEffect(() => {
    (async () => {
      const id = localStorage.getItem("idusuario") || "";
      if (!id) return;
      try {
        const res = await fetch(`/api/usuarios/${encodeURIComponent(id)}/`);
        const data = await parseJsonResponse(res);
        if (res.ok && data.data) {
          const u = data.data;
          setImportadoPor(
            `${u.APELLIDO || ""} ${u.NOMBRE || ""}`.trim().toUpperCase() || id,
          );
        } else {
          setImportadoPor(id);
        }
      } catch {
        setImportadoPor(id);
      }
    })();
  }, []);

  useEffect(() => {
    (async () => {
      try {
        setCargandoCat(true);
        const res = await fetch("/api/notas-importacion/catalogos/");
        const data = await parseJsonResponse(res);
        if (!res.ok) throw new Error(data.error || "No se pudieron cargar los catálogos");
        setAulas(data.data?.aulas || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setCargandoCat(false);
      }
    })();
  }, []);

  useEffect(() => {
    if (!filas.length) return;
    setFilas((prev) => prev.map((row) => ({ ...row, Modo: modo })));
  }, [modo]);

  const procesarArchivo = async (file) => {
    if (!file) return;
    setError("");

    const ext = file.name.toLowerCase().slice(file.name.lastIndexOf("."));
    if (![".xlsx", ".xls"].includes(ext)) {
      setError("Solo se permiten archivos .xlsx o .xls");
      return;
    }
    if (file.size > MAX_FILE_SIZE) {
      setError("El archivo supera el tamaño máximo de 10 MB");
      return;
    }

    try {
      const rows = await parseExcelFile(file);
      setFilas(rows.map((row) => ({ ...row, Modo: modo })));
      setArchivoSeleccionado(file.name);
      if (!nombreArchivo) setNombreArchivo(file.name);
    } catch {
      setError("No se pudo leer el archivo Excel");
      setFilas([]);
      setArchivoSeleccionado("");
    }
  };

  const handleFileChange = (e) => {
    procesarArchivo(e.target.files?.[0]);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!filas.length) {
      setError("Primero selecciona y carga un archivo Excel");
      return;
    }
    if (!nombreArchivo.trim()) {
      setError("Indica el nombre del archivo");
      return;
    }
    if (!idAula) {
      setError("Selecciona el salón del examen");
      return;
    }

    setLoading(true);
    setError("");
    try {
      const idusuario = localStorage.getItem("idusuario") || "";
      const res = await fetch(
        `/api/notas-importacion/importar/${idusuario ? `?idusuario=${encodeURIComponent(idusuario)}` : ""}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            nombre_archivo: nombreArchivo.trim(),
            data: filas.map((row) => ({ ...row, Modo: modo })),
            tipo_importacion: tipoImportacion,
            id_aula: idAula,
            fecha_examen: inputToDb(fechaExamen),
            tipo_area_academica: tipoImportacion === 100 ? tipoArea : undefined,
            modo,
          }),
        },
      );
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "Error al importar notas");

      const extra = [];
      if (data.estudiantes_no_encontrados) extra.push(`${data.estudiantes_no_encontrados} DNI no encontrados`);
      if (data.filas_sin_dni) extra.push(`${data.filas_sin_dni} sin DNI`);
      const detalle = extra.length ? ` (${extra.join(", ")})` : "";

      onSuccess?.(`${data.message || "Importación completada"}${detalle}`);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const limpiarArchivo = () => {
    setFilas([]);
    setArchivoSeleccionado("");
    setNombreArchivo("");
    if (fileRef.current) fileRef.current.value = "";
  };

  const previewCols = useMemo(() => {
    if (!filas.length) return [];
    return Object.keys(filas[0]).slice(0, 6);
  }, [filas]);

  const salonOptions = (
    <>
      <option value="">Seleccionar salón...</option>
      {aulas.map((a) => (
        <option key={a.IDAULA} value={a.IDAULA}>
          {a.NOMBRE}
          {a.CAPACIDAD != null ? ` (Cap. ${a.CAPACIDAD})` : ""}
        </option>
      ))}
    </>
  );

  return (
    <form className="form-page-card notas-import-card" onSubmit={handleSubmit}>
      <div className="form-page-body">
        {error && <p className="field-error form-error-banner">{error}</p>}

        <div className="notas-import-layout">
          <div className="notas-import-top">
            <div className="notas-import-left">
              <div className="form-section-row">
                <section className="form-section form-section--card">
                  <h3 className="form-section-title">Configuración del examen</h3>
                  <div className="form-grid form-grid--half">
                    <SelectField label="Modo del examen" value={modo} onChange={(e) => setModo(e.target.value)}>
                      <option value="presencial">Presencial</option>
                      <option value="virtual">Virtual</option>
                    </SelectField>
                    <SelectField
                      label="Tipo de importación"
                      value={tipoImportacion}
                      onChange={(e) => setTipoImportacion(Number(e.target.value))}
                    >
                      <option value={40}>40 preguntas</option>
                      <option value={100}>100 preguntas</option>
                    </SelectField>
                    {tipoImportacion === 100 && (
                      <SelectField
                        label="Área académico profesional"
                        value={tipoArea}
                        onChange={(e) => setTipoArea(e.target.value)}
                      >
                        {AREAS_ACADEMICAS.map((a) => (
                          <option key={a.value} value={a.value}>
                            {a.label}
                          </option>
                        ))}
                      </SelectField>
                    )}
                    <SelectField
                      label="Salón del examen"
                      value={idAula}
                      onChange={(e) => setIdAula(e.target.value)}
                      disabled={cargandoCat}
                    >
                      {salonOptions}
                    </SelectField>
                  </div>
                </section>

                <section className="form-section form-section--card">
                  <h3 className="form-section-title">Datos del archivo</h3>
                  <div className="form-grid form-grid--half">
                    <div className="form-field full">
                      <label>Nombre del archivo</label>
                      <input
                        type="text"
                        value={nombreArchivo}
                        onChange={(e) => setNombreArchivo(e.target.value)}
                        placeholder="Ejemplo: simulacro_abril.xlsx"
                        required
                      />
                    </div>
                    <div className="form-field">
                      <label>Fecha del examen</label>
                      <input
                        type="date"
                        value={fechaExamen}
                        onChange={(e) => setFechaExamen(e.target.value)}
                        required
                      />
                    </div>
                    <div className="form-field">
                      <label>Importado por</label>
                      <input type="text" value={importadoPor || "—"} readOnly disabled />
                    </div>
                  </div>
                </section>
              </div>
            </div>

            <section className="form-section form-section--card notas-import-file">
              <h3 className="form-section-title">Archivo Excel</h3>
              <div
                className={`notas-file-drop${archivoSeleccionado ? " notas-file-drop--loaded" : ""}`}
                onClick={() => fileRef.current?.click()}
                onKeyDown={(e) => e.key === "Enter" && fileRef.current?.click()}
                role="button"
                tabIndex={0}
              >
                <input
                  ref={fileRef}
                  type="file"
                  accept=".xlsx,.xls"
                  onChange={handleFileChange}
                  className="notas-file-input"
                />
                <FontAwesomeIcon
                  icon={archivoSeleccionado ? faFileExcel : faUpload}
                  className="notas-file-drop-icon"
                />
                {archivoSeleccionado ? (
                  <>
                    <strong>{archivoSeleccionado}</strong>
                    <span>{filas.length} filas detectadas · Clic para cambiar archivo</span>
                  </>
                ) : (
                  <>
                    <strong>Seleccionar archivo Excel</strong>
                    <span>Formatos .xlsx o .xls · Máximo 10 MB</span>
                  </>
                )}
              </div>
              {archivoSeleccionado && (
                <button type="button" className="btn-link notas-file-clear" onClick={limpiarArchivo}>
                  Quitar archivo
                </button>
              )}
            </section>
          </div>

          <section className="notas-import-preview notas-import-preview--bottom">
            <div className="notas-import-preview-inner">
              <h3 className="form-section-title">
                <FontAwesomeIcon icon={faClipboardList} />
                Vista previa
              </h3>

              {!filas.length ? (
                <div className="notas-preview-empty">
                  <FontAwesomeIcon icon={faFileExcel} />
                  <p>Carga un Excel para ver las primeras filas antes de importar.</p>
                </div>
              ) : (
                <>
                  <div className="notas-preview-badge">
                    <strong>{filas.length}</strong>
                    <span>{filas.length === 1 ? "fila cargada" : "filas cargadas"}</span>
                  </div>
                  <div className="notas-preview-table">
                    <div className="data-table-wrap">
                      <table className="data-table">
                        <thead>
                          <tr>
                            <th>#</th>
                            {previewCols.map((col) => (
                              <th key={col}>{col}</th>
                            ))}
                          </tr>
                        </thead>
                        <tbody>
                          {filas.slice(0, 8).map((row, idx) => (
                            <tr key={idx}>
                              <td>{idx + 1}</td>
                              {previewCols.map((col) => (
                                <td key={col}>{String(row[col] ?? "—")}</td>
                              ))}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                  {filas.length > 8 && (
                    <p className="field-hint notas-preview-more">
                      Mostrando 8 de {filas.length} filas.
                    </p>
                  )}
                </>
              )}
            </div>
          </section>
        </div>
      </div>

      <div className="form-page-footer">
        <button type="button" className="btn-secondary" onClick={onCancel} disabled={loading}>
          Cancelar
        </button>
        <button type="submit" className="btn-primary" disabled={loading || !filas.length}>
          {loading && <FontAwesomeIcon icon={faSpinner} spin />}
          Guardar importación
        </button>
      </div>
    </form>
  );
}

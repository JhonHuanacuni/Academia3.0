import { useEffect, useRef, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowLeft,
  faChevronLeft,
  faChevronRight,
  faHouse,
  faSpinner,
} from "@fortawesome/free-solid-svg-icons";
import * as pdfjs from "pdfjs-dist";
import pdfWorker from "pdfjs-dist/build/pdf.worker.min.mjs?url";

pdfjs.GlobalWorkerOptions.workerSrc = pdfWorker;

export default function BibliotecaVerPage({ titulo, url, onVolver }) {
  const canvasRef = useRef(null);
  const [doc, setDoc] = useState(null);
  const [pagina, setPagina] = useState(1);
  const [total, setTotal] = useState(0);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");
  const [renderizando, setRenderizando] = useState(false);

  useEffect(() => {
    let cancelled = false;
    let loadingTask = null;

    (async () => {
      setCargando(true);
      setError("");
      setDoc(null);
      setPagina(1);
      setTotal(0);
      try {
        loadingTask = pdfjs.getDocument(url);
        const pdf = await loadingTask.promise;
        if (cancelled) return;
        setDoc(pdf);
        setTotal(pdf.numPages);
      } catch (err) {
        if (!cancelled) setError(err.message || "No se pudo abrir el PDF.");
      } finally {
        if (!cancelled) setCargando(false);
      }
    })();

    return () => {
      cancelled = true;
      if (loadingTask) {
        try {
          loadingTask.destroy();
        } catch {
          /* ignore */
        }
      }
    };
  }, [url]);

  useEffect(() => {
    if (!doc || !canvasRef.current) return;
    let cancelled = false;

    (async () => {
      setRenderizando(true);
      try {
        const page = await doc.getPage(pagina);
        if (cancelled) return;
        const canvas = canvasRef.current;
        const base = page.getViewport({ scale: 1 });
        const maxW = Math.min(window.innerWidth - 120, 780);
        const scale = Math.min(1.35, maxW / base.width);
        const viewport = page.getViewport({ scale });
        const ctx = canvas.getContext("2d");
        canvas.height = viewport.height;
        canvas.width = viewport.width;
        await page.render({ canvasContext: ctx, viewport }).promise;
      } catch (err) {
        if (!cancelled) setError(err.message || "Error al renderizar la página.");
      } finally {
        if (!cancelled) setRenderizando(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [doc, pagina]);

  const irInicio = () => setPagina(1);
  const irAnt = () => setPagina((p) => Math.max(1, p - 1));
  const irSig = () => setPagina((p) => Math.min(total, p + 1));

  return (
    <div className="bib-ver-page">
      <header className="bib-ver-header">
        <h1>{titulo || "Documento"}</h1>
        <button type="button" className="bib-ver-volver" onClick={onVolver}>
          <FontAwesomeIcon icon={faArrowLeft} />
          Volver
        </button>
      </header>

      <div className="bib-ver-stage">
        {cargando && (
          <div className="bib-ver-state">
            <FontAwesomeIcon icon={faSpinner} spin />
            <span>Cargando documento…</span>
          </div>
        )}

        {error && !cargando && (
          <div className="bib-ver-state error">
            <p>{error}</p>
            <a href={url} target="_blank" rel="noreferrer">
              Abrir PDF en otra pestaña
            </a>
          </div>
        )}

        {!cargando && !error && (
          <div className={`bib-ver-doc ${renderizando ? "is-rendering" : ""}`}>
            <canvas ref={canvasRef} />
          </div>
        )}
      </div>

      {total > 0 && (
        <div className="bib-ver-nav" aria-label="Navegación de páginas">
          <button type="button" className="bib-nav-btn" onClick={irInicio} title="Inicio">
            <FontAwesomeIcon icon={faHouse} />
          </button>
          <button
            type="button"
            className="bib-nav-btn"
            onClick={irAnt}
            disabled={pagina <= 1}
            title="Anterior"
          >
            <FontAwesomeIcon icon={faChevronLeft} />
          </button>
          <select
            className="bib-nav-select"
            value={pagina}
            onChange={(e) => setPagina(Number(e.target.value))}
            aria-label="Página"
          >
            {Array.from({ length: total }, (_, i) => i + 1).map((n) => (
              <option key={n} value={n}>
                Página {n}
              </option>
            ))}
          </select>
          <button
            type="button"
            className="bib-nav-btn"
            onClick={irSig}
            disabled={pagina >= total}
            title="Siguiente"
          >
            <FontAwesomeIcon icon={faChevronRight} />
          </button>
        </div>
      )}
    </div>
  );
}

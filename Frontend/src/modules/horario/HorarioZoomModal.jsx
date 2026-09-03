import { useCallback, useEffect, useRef, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faMinus,
  faPlus,
  faTimes,
  faSearchMinus,
} from "@fortawesome/free-solid-svg-icons";

const ZOOM_MIN = 1;
const ZOOM_MAX = 4;
const ZOOM_STEP = 0.25;

export default function HorarioZoomModal({ abierto, titulo, url, onClose }) {
  const [zoom, setZoom] = useState(1);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const dragRef = useRef(null);
  const stageRef = useRef(null);

  useEffect(() => {
    if (!abierto) return;
    setZoom(1);
    setOffset({ x: 0, y: 0 });
  }, [abierto, url]);

  useEffect(() => {
    if (!abierto) return undefined;
    const onKey = (e) => {
      if (e.key === "Escape") onClose?.();
      if (e.key === "+" || e.key === "=") setZoom((z) => Math.min(ZOOM_MAX, z + ZOOM_STEP));
      if (e.key === "-") setZoom((z) => Math.max(ZOOM_MIN, z - ZOOM_STEP));
      if (e.key === "0") {
        setZoom(1);
        setOffset({ x: 0, y: 0 });
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [abierto, onClose]);

  const ajustarZoom = useCallback((next) => {
    const clamped = Math.min(ZOOM_MAX, Math.max(ZOOM_MIN, next));
    setZoom(clamped);
    if (clamped <= 1) setOffset({ x: 0, y: 0 });
  }, []);

  useEffect(() => {
    if (!abierto) return undefined;
    const el = stageRef.current;
    if (!el) return undefined;
    const onWheelNative = (e) => {
      e.preventDefault();
      const delta = e.deltaY < 0 ? ZOOM_STEP : -ZOOM_STEP;
      setZoom((z) => {
        const next = Math.min(ZOOM_MAX, Math.max(ZOOM_MIN, z + delta));
        if (next <= 1) setOffset({ x: 0, y: 0 });
        return next;
      });
    };
    el.addEventListener("wheel", onWheelNative, { passive: false });
    return () => el.removeEventListener("wheel", onWheelNative);
  }, [abierto]);

  const onPointerDown = (e) => {
    if (zoom <= 1) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    dragRef.current = {
      startX: e.clientX,
      startY: e.clientY,
      origX: offset.x,
      origY: offset.y,
    };
  };

  const onPointerMove = (e) => {
    if (!dragRef.current) return;
    const dx = e.clientX - dragRef.current.startX;
    const dy = e.clientY - dragRef.current.startY;
    setOffset({
      x: dragRef.current.origX + dx,
      y: dragRef.current.origY + dy,
    });
  };

  const onPointerUp = (e) => {
    if (dragRef.current) {
      try {
        e.currentTarget.releasePointerCapture(e.pointerId);
      } catch {
        /* ignore */
      }
    }
    dragRef.current = null;
  };

  if (!abierto) return null;

  const pct = Math.round(zoom * 100);

  return (
    <div className="horario-zoom-overlay" onClick={onClose} role="presentation">
      <div
        className="horario-zoom-panel"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="horario-zoom-title"
      >
        <div className="horario-zoom-toolbar">
          <h2 id="horario-zoom-title" className="horario-zoom-title">
            {titulo || "Horario"}
          </h2>
          <div className="horario-zoom-actions">
            <button
              type="button"
              className="horario-zoom-btn"
              onClick={() => ajustarZoom(zoom - ZOOM_STEP)}
              disabled={zoom <= ZOOM_MIN}
              aria-label="Alejar"
              title="Alejar"
            >
              <FontAwesomeIcon icon={faMinus} />
            </button>
            <span className="horario-zoom-pct">{pct}%</span>
            <button
              type="button"
              className="horario-zoom-btn"
              onClick={() => ajustarZoom(zoom + ZOOM_STEP)}
              disabled={zoom >= ZOOM_MAX}
              aria-label="Acercar"
              title="Acercar"
            >
              <FontAwesomeIcon icon={faPlus} />
            </button>
            <button
              type="button"
              className="horario-zoom-btn"
              onClick={() => {
                setZoom(1);
                setOffset({ x: 0, y: 0 });
              }}
              disabled={zoom === 1 && offset.x === 0 && offset.y === 0}
              aria-label="Restablecer zoom"
              title="Restablecer"
            >
              <FontAwesomeIcon icon={faSearchMinus} />
            </button>
            <button
              type="button"
              className="horario-zoom-btn horario-zoom-btn--close"
              onClick={onClose}
              aria-label="Cerrar"
            >
              <FontAwesomeIcon icon={faTimes} />
            </button>
          </div>
        </div>

        <div
          ref={stageRef}
          className={`horario-zoom-stage${zoom > 1 ? " is-zoomed" : ""}`}
          onPointerDown={onPointerDown}
          onPointerMove={onPointerMove}
          onPointerUp={onPointerUp}
          onPointerCancel={onPointerUp}
        >
          {url ? (
            <img
              src={url}
              alt={titulo || "Horario"}
              className="horario-zoom-img"
              style={{
                transform: `translate(${offset.x}px, ${offset.y}px) scale(${zoom})`,
              }}
              draggable={false}
            />
          ) : (
            <p className="horario-estudiante-state horario-estudiante-state--error">
              Este horario no tiene imagen asociada.
            </p>
          )}
        </div>

        <p className="horario-zoom-hint">
          Usa + / − o la rueda del mouse para acercar. Arrastra para mover cuando esté ampliado.
        </p>
      </div>
    </div>
  );
}

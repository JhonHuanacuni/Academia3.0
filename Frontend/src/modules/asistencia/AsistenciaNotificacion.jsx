import { useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCheckCircle,
  faExclamationTriangle,
  faTimesCircle,
} from "@fortawesome/free-solid-svg-icons";

const GIFS = {
  success: "/good-gif.webp",
  warning: "/bad-gif.webp",
};

const TITULOS = {
  success: "Asistencia registrada",
  warning: "Asistencia ya registrada",
  error: "Error",
  invalid: "DNI inválido",
};

const ICONOS = {
  error: faTimesCircle,
  invalid: faExclamationTriangle,
};

const TIMERS = {
  success: 3000,
  warning: 3000,
  invalid: 2000,
  error: 4000,
};

export default function AsistenciaNotificacion({ notif, onClose }) {
  useEffect(() => {
    if (!notif) return undefined;
    const ms = TIMERS[notif.tipo] || 3500;
    const t = window.setTimeout(onClose, ms);
    return () => window.clearTimeout(t);
  }, [notif, onClose]);

  if (!notif) return null;

  const { tipo, nombre, dni, estado, hora, mensaje } = notif;
  const gifUrl = GIFS[tipo];
  const etiquetaEstado =
    estado === "tarde" || estado === "Tarde"
      ? "Tarde"
      : estado === "presente" || estado === "Presente"
        ? "Presente"
        : null;

  return (
    <div className="asistencia-notif-backdrop" onClick={onClose} role="presentation">
      <div
        className={`asistencia-notif-card asistencia-notif-card--${tipo}`}
        onClick={(e) => e.stopPropagation()}
        role="alertdialog"
        aria-live="assertive"
        aria-labelledby="asistencia-notif-title"
      >
        <button type="button" className="asistencia-notif-close" onClick={onClose} aria-label="Cerrar">
          ×
        </button>

        {gifUrl ? (
          <img
            src={gifUrl}
            alt=""
            className="asistencia-notif-gif"
            width={200}
            height={200}
          />
        ) : (
          <div className={`asistencia-notif-icon asistencia-notif-icon--${tipo}`}>
            <FontAwesomeIcon icon={ICONOS[tipo] || faTimesCircle} />
          </div>
        )}

        <h2 id="asistencia-notif-title" className="asistencia-notif-titulo">
          {TITULOS[tipo] || "Aviso"}
        </h2>

        {tipo === "success" && (nombre || dni) && (
          <div className="asistencia-notif-detalle">
            {nombre && (
              <p>
                <strong>Nombre:</strong> {nombre}
              </p>
            )}
            {dni && (
              <p>
                <strong>DNI:</strong> {dni}
              </p>
            )}
          </div>
        )}

        {tipo === "warning" && (
          <div className="asistencia-notif-detalle asistencia-notif-detalle--warning">
            <p>Este estudiante ya tiene su asistencia registrada para hoy.</p>
            <p>
              <strong>No se puede marcar la asistencia dos veces en el mismo día.</strong>
            </p>
            {nombre && (
              <p className="asistencia-notif-extra">
                {nombre}
                {dni ? ` · DNI ${dni}` : ""}
              </p>
            )}
          </div>
        )}

        {(tipo === "error" || tipo === "invalid") && mensaje && (
          <p className="asistencia-notif-mensaje">{mensaje}</p>
        )}

        {tipo === "success" && etiquetaEstado && (
          <span className={`asistencia-notif-estado asistencia-notif-estado--${etiquetaEstado.toLowerCase()}`}>
            <FontAwesomeIcon icon={faCheckCircle} />
            {etiquetaEstado}
            {hora ? ` · ${String(hora).slice(0, 5)}` : ""}
          </span>
        )}

        {tipo === "success" && !etiquetaEstado && mensaje && (
          <p className="asistencia-notif-mensaje">{mensaje}</p>
        )}
      </div>
    </div>
  );
}

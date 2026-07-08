import { useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCheckCircle,
  faExclamationTriangle,
  faTimesCircle,
  faUser,
} from "@fortawesome/free-solid-svg-icons";

const ICONOS = {
  success: faCheckCircle,
  warning: faExclamationTriangle,
  error: faTimesCircle,
};

const TITULOS = {
  success: "Asistencia registrada",
  warning: "Ya registrado",
  error: "No registrado",
};

function iniciales(nombre) {
  const partes = String(nombre || "").trim().split(/\s+/).filter(Boolean);
  if (!partes.length) return "?";
  if (partes.length === 1) return partes[0].slice(0, 2).toUpperCase();
  return (partes[0][0] + partes[partes.length - 1][0]).toUpperCase();
}

export default function AsistenciaNotificacion({ notif, onClose }) {
  useEffect(() => {
    if (!notif) return undefined;
    const t = window.setTimeout(onClose, notif.tipo === "success" ? 4000 : 4500);
    return () => window.clearTimeout(t);
  }, [notif, onClose]);

  if (!notif) return null;

  const { tipo, nombre, dni, estado, hora, mensaje, fotoUrl } = notif;
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
      >
        <button type="button" className="asistencia-notif-close" onClick={onClose} aria-label="Cerrar">
          ×
        </button>

        <div className="asistencia-notif-avatar">
          {fotoUrl ? (
            <img src={fotoUrl} alt="" />
          ) : (
            <span className="asistencia-notif-iniciales">
              {nombre ? iniciales(nombre) : <FontAwesomeIcon icon={faUser} />}
            </span>
          )}
        </div>

        {nombre && <h2 className="asistencia-notif-nombre">{nombre}</h2>}
        {dni && <p className="asistencia-notif-dni">DNI {dni}</p>}

        {etiquetaEstado && (
          <span className={`asistencia-notif-estado asistencia-notif-estado--${etiquetaEstado.toLowerCase()}`}>
            <FontAwesomeIcon icon={ICONOS[tipo]} />
            {etiquetaEstado}
          </span>
        )}

        <p className="asistencia-notif-mensaje">
          {mensaje || TITULOS[tipo]}
          {hora ? ` — ${String(hora).slice(0, 5)}` : ""}
        </p>
      </div>
    </div>
  );
}

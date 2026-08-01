import { useCallback, useEffect, useRef, useState } from "react";
import { Html5Qrcode, Html5QrcodeScannerState } from "html5-qrcode";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCamera,
  faCheckCircle,
  faExclamationTriangle,
  faSpinner,
  faStop,
} from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import AsistenciaNotificacion from "./AsistenciaNotificacion";
import "../../styles/mantenedor.css";
import "./asistencia.css";

const SCANNER_ID = "asistencia-qr-reader";
const COOLDOWN_MS = 2000;
const DEBOUNCE_MS = 500;
const DNI_LENGTH = 8;

async function detenerScanner(scanner) {
  if (!scanner) return;
  try {
    const state = scanner.getState();
    if (
      state === Html5QrcodeScannerState.SCANNING ||
      state === Html5QrcodeScannerState.PAUSED
    ) {
      await scanner.stop();
    }
  } catch {
    // ignore
  }
  try {
    await scanner.clear();
  } catch {
    // ignore
  }
}

function isValidDni(value) {
  const clean = String(value || "").trim();
  return clean.length === DNI_LENGTH && /^\d+$/.test(clean);
}

function hasDuplicatePattern(value) {
  if (value.length !== DNI_LENGTH * 2) return false;
  return value.slice(0, DNI_LENGTH) === value.slice(DNI_LENGTH);
}

function extractValidDni(raw) {
  const clean = String(raw || "").trim().replace(/\D/g, "");
  if (clean.length === DNI_LENGTH) return clean;
  if (clean.length === DNI_LENGTH * 2 && hasDuplicatePattern(clean)) {
    return clean.slice(0, DNI_LENGTH);
  }
  if (clean.length > DNI_LENGTH) {
    const first = clean.slice(0, DNI_LENGTH);
    const next = clean.slice(DNI_LENGTH, DNI_LENGTH * 2);
    if (first === next) return first;
    return first;
  }
  return null;
}

export default function AsistenciaMarcarPage() {
  const [dniManual, setDniManual] = useState("");
  const [camaraActiva, setCamaraActiva] = useState(false);
  const [camaraLista, setCamaraLista] = useState(false);
  const [procesando, setProcesando] = useState(false);
  const [notif, setNotif] = useState(null);
  const [mensajeExito, setMensajeExito] = useState("");
  const scannerRef = useRef(null);
  const pendingScannerRef = useRef(null);
  const cooldownRef = useRef({});
  const lastProcessedDniRef = useRef("");
  const lastScanTimeRef = useRef(0);
  const debounceRef = useRef(null);
  const inputRef = useRef(null);
  const idRegistrador = localStorage.getItem("idusuario") || "";

  const cerrarNotif = useCallback(() => {
    setNotif(null);
    window.setTimeout(() => inputRef.current?.focus(), 150);
  }, []);

  const mostrarNotif = useCallback((payload) => {
    setNotif(payload);
  }, []);

  const procesandoRef = useRef(false);

  const registrar = useCallback(async (dniRaw) => {
    if (procesandoRef.current) return;

    const now = Date.now();
    const validDni = extractValidDni(dniRaw);

    if (!validDni || !isValidDni(validDni)) {
      mostrarNotif({
        tipo: "invalid",
        mensaje: `El DNI debe tener exactamente ${DNI_LENGTH} dígitos numéricos.`,
      });
      setDniManual("");
      return;
    }

    if (
      validDni === lastProcessedDniRef.current &&
      now - lastScanTimeRef.current < COOLDOWN_MS
    ) {
      return;
    }

    const last = cooldownRef.current[validDni] || 0;
    if (now - last < COOLDOWN_MS) return;

    cooldownRef.current[validDni] = now;
    lastProcessedDniRef.current = validDni;
    lastScanTimeRef.current = now;

    procesandoRef.current = true;
    setProcesando(true);

    try {
      const res = await fetch("/api/asistencias/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ dni: validDni, idRegistrador }),
      });
      const data = await parseJsonResponse(res);
      const nombre = `${data.nombres || data.NOMBRE || ""} ${data.apellidos || data.APELLIDO || ""}`.trim();

      if (!res.ok) {
        const detail = data.detail || data.error || "";
        const esDuplicado =
          data.type === "duplicate_attendance" ||
          detail.includes("Ya existe una asistencia registrada") ||
          detail.includes("asistencia registrada para este estudiante") ||
          detail.includes("No se puede marcar la asistencia dos veces");

        if (esDuplicado) {
          mostrarNotif({
            tipo: "warning",
            nombre: nombre || undefined,
            dni: data.dni || validDni,
          });
        } else {
          mostrarNotif({
            tipo: "error",
            nombre: nombre || undefined,
            dni: validDni,
            mensaje: detail || "Error al registrar la asistencia",
          });
        }
        setDniManual("");
        return;
      }

      const nombreOk = `${data.nombres || ""} ${data.apellidos || ""}`.trim();
      mostrarNotif({
        tipo: "success",
        nombre: nombreOk || validDni,
        dni: data.dni || validDni,
        estado: data.estado,
        hora: data.hora,
        mensaje: "Registrado correctamente",
      });
      setMensajeExito(
        `Asistencia registrada: ${nombreOk || "Estudiante"} - DNI: ${data.dni || validDni}`,
      );
      window.setTimeout(() => setMensajeExito(""), 3000);
      setDniManual("");
    } catch (err) {
      mostrarNotif({
        tipo: "error",
        dni: validDni,
        mensaje: err.message || "No se pudo conectar con el servidor.",
      });
      setDniManual("");
    } finally {
      procesandoRef.current = false;
      setProcesando(false);
      window.setTimeout(() => {
        lastProcessedDniRef.current = "";
      }, COOLDOWN_MS);
    }
  }, [idRegistrador, mostrarNotif]);

  const iniciarCamara = useCallback(async (signal) => {
    if (scannerRef.current || pendingScannerRef.current) return;
    const scanner = new Html5Qrcode(SCANNER_ID);
    pendingScannerRef.current = scanner;
    try {
      await scanner.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 260, height: 260 }, aspectRatio: 1 },
        (decoded) => registrar(decoded),
        () => {},
      );
      pendingScannerRef.current = null;
      if (signal?.aborted) {
        await detenerScanner(scanner);
        return;
      }
      scannerRef.current = scanner;
      setCamaraLista(true);
    } catch {
      pendingScannerRef.current = null;
      await detenerScanner(scanner);
      if (signal?.aborted) return;
      setCamaraActiva(false);
      setCamaraLista(false);
      mostrarNotif({
        tipo: "error",
        mensaje: "No se pudo activar la cámara. Verifica los permisos del navegador.",
      });
    }
  }, [registrar, mostrarNotif]);

  const detenerCamara = useCallback(async () => {
    const scanner = scannerRef.current || pendingScannerRef.current;
    scannerRef.current = null;
    pendingScannerRef.current = null;
    setCamaraLista(false);
    await detenerScanner(scanner);
  }, []);

  useEffect(() => {
    if (!camaraActiva) return undefined;
    const ac = new AbortController();
    void iniciarCamara(ac.signal);
    return () => {
      ac.abort();
      void detenerCamara();
    };
  }, [camaraActiva, iniciarCamara, detenerCamara]);

  useEffect(() => () => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
  }, []);

  const handleDniChange = (e) => {
    const numeric = e.target.value.replace(/\D/g, "");
    setDniManual(numeric);
    if (debounceRef.current) clearTimeout(debounceRef.current);

    if (isValidDni(numeric)) {
      debounceRef.current = setTimeout(() => registrar(numeric), DEBOUNCE_MS);
    } else if (numeric.length > DNI_LENGTH) {
      debounceRef.current = setTimeout(() => registrar(numeric), 100);
    }
  };

  const toggleCamara = () => {
    setCamaraActiva((prev) => !prev);
  };

  const handleManual = (e) => {
    e.preventDefault();
    registrar(dniManual);
  };

  return (
    <div className="asistencia-page asistencia-page--marcar">
      <div className="asistencia-layout">
        <div className="asistencia-panel mantenedor-card asistencia-marcar-card">
          <form className="dni-form" onSubmit={handleManual}>
            <label htmlFor="dni-input">Número de DNI</label>
            <input
              ref={inputRef}
              id="dni-input"
              type="text"
              inputMode="numeric"
              maxLength={DNI_LENGTH * 2}
              placeholder={`Ingrese DNI (${DNI_LENGTH} dígitos)`}
              value={dniManual}
              onChange={handleDniChange}
              disabled={procesando}
              autoFocus
            />
            <button
              type="submit"
              className="btn-primary asistencia-submit-btn"
              disabled={procesando || !isValidDni(dniManual)}
            >
              {procesando ? (
                <>
                  <FontAwesomeIcon icon={faSpinner} spin />
                  Procesando...
                </>
              ) : (
                "Registrar asistencia"
              )}
            </button>
          </form>

          {dniManual && (
            <div className="asistencia-dni-hint">
              {isValidDni(dniManual) ? (
                <span className="asistencia-dni-hint--ok">
                  <FontAwesomeIcon icon={faCheckCircle} />
                  DNI válido ({dniManual.length} dígitos) — se enviará automáticamente
                </span>
              ) : dniManual.length > DNI_LENGTH ? (
                <span className="asistencia-dni-hint--warn">
                  <FontAwesomeIcon icon={faExclamationTriangle} />
                  DNI con duplicado detectado — extrayendo DNI válido...
                </span>
              ) : (
                <span className="asistencia-dni-hint--muted">
                  Ingresando... ({dniManual.length}/{DNI_LENGTH} dígitos)
                </span>
              )}
            </div>
          )}

          {mensajeExito && (
            <div className="asistencia-exito-banner" role="status">
              <FontAwesomeIcon icon={faCheckCircle} />
              {mensajeExito}
            </div>
          )}

          <div className="asistencia-camara-actions">
            <button
              type="button"
              className={camaraActiva ? "btn-secondary" : "btn-primary"}
              onClick={toggleCamara}
              disabled={procesando}
            >
              <FontAwesomeIcon icon={camaraActiva ? faStop : faCamera} />
              {camaraActiva ? "Desactivar cámara" : "Activar cámara"}
            </button>
          </div>

          {camaraActiva && (
            <div className="asistencia-scanner-wrap">
              <div id={SCANNER_ID} className="qr-reader" />
              <p className="scanner-hint">
                {camaraLista
                  ? "Apunta al QR del carnet. La cámara permanece activa tras cada registro."
                  : "Iniciando cámara..."}
              </p>
            </div>
          )}

          <div className="asistencia-scanner-info">
            <h4>Información del scanner</h4>
            <ul>
              <li>El DNI se envía automáticamente al completar {DNI_LENGTH} dígitos</li>
              <li>Se detectan y corrigen duplicados del scanner</li>
              <li>Se previenen registros duplicados en menos de {COOLDOWN_MS / 1000} segundos</li>
              <li>Solo se aceptan DNI con exactamente {DNI_LENGTH} dígitos numéricos</li>
            </ul>
          </div>
        </div>
      </div>

      <AsistenciaNotificacion notif={notif} onClose={cerrarNotif} />
    </div>
  );
}

import { useCallback, useEffect, useRef, useState } from "react";
import { Html5Qrcode, Html5QrcodeScannerState } from "html5-qrcode";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCamera, faStop } from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import AsistenciaNotificacion from "./AsistenciaNotificacion";
import "../../styles/mantenedor.css";
import "./asistencia.css";

const SCANNER_ID = "asistencia-qr-reader";
const COOLDOWN_MS = 2500;

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

function normalizeDni(raw) {
  return String(raw || "").trim().replace(/\D/g, "");
}

export default function AsistenciaMarcarPage() {
  const [dniManual, setDniManual] = useState("");
  const [camaraActiva, setCamaraActiva] = useState(false);
  const [camaraLista, setCamaraLista] = useState(false);
  const [procesando, setProcesando] = useState(false);
  const [notif, setNotif] = useState(null);
  const scannerRef = useRef(null);
  const pendingScannerRef = useRef(null);
  const cooldownRef = useRef({});
  const idRegistrador = localStorage.getItem("idusuario") || "";

  const cerrarNotif = useCallback(() => setNotif(null), []);

  const mostrarNotif = useCallback((payload) => {
    setNotif(payload);
  }, []);

  const procesandoRef = useRef(false);

  const registrar = useCallback(async (dniRaw) => {
    const dni = normalizeDni(dniRaw);
    if (!dni || dni.length < 8) return;

    const now = Date.now();
    const last = cooldownRef.current[dni] || 0;
    if (now - last < COOLDOWN_MS) return;
    cooldownRef.current[dni] = now;

    if (procesandoRef.current) return;
    procesandoRef.current = true;
    setProcesando(true);

    try {
      const res = await fetch("/api/asistencias/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ dni, idRegistrador }),
      });
      const data = await parseJsonResponse(res);

      if (!res.ok) {
        const nombre = `${data.nombres || data.NOMBRE || ""} ${data.apellidos || data.APELLIDO || ""}`.trim();
        if (data.type === "duplicate_attendance") {
          mostrarNotif({
            tipo: "warning",
            nombre: nombre || undefined,
            dni: data.dni || dni,
            mensaje: data.detail || "Este estudiante ya marcó asistencia hoy.",
            fotoUrl: data.fotoUrl || null,
          });
        } else {
          mostrarNotif({
            tipo: "error",
            nombre: nombre || undefined,
            dni,
            mensaje: data.detail || data.error || "Error al marcar asistencia.",
          });
        }
        return;
      }

      const nombre = `${data.nombres || ""} ${data.apellidos || ""}`.trim();
      mostrarNotif({
        tipo: "success",
        nombre: nombre || dni,
        dni: data.dni,
        estado: data.estado,
        hora: data.hora,
        mensaje: "Registrado correctamente",
        fotoUrl: data.fotoUrl || null,
      });
    } catch (err) {
      mostrarNotif({
        tipo: "error",
        dni,
        mensaje: err.message || "No se pudo conectar con el servidor.",
      });
    } finally {
      procesandoRef.current = false;
      setProcesando(false);
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
        () => {}
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

  const toggleCamara = () => {
    if (camaraActiva) {
      setCamaraActiva(false);
    } else {
      setCamaraActiva(true);
    }
  };

  const handleManual = (e) => {
    e.preventDefault();
    registrar(dniManual);
    setDniManual("");
  };

  return (
    <div className="asistencia-page">
      <div className="asistencia-header">
        <h1>Marcar asistencia</h1>
        <p>Ingresa el DNI o activa la cámara para escanear el QR del carnet.</p>
      </div>

      <div className="asistencia-layout">
        <div className="asistencia-panel mantenedor-card asistencia-marcar-card">
          <form className="dni-form" onSubmit={handleManual}>
            <label htmlFor="dni-input">Número de DNI</label>
            <input
              id="dni-input"
              type="text"
              inputMode="numeric"
              maxLength={8}
              placeholder="Ingrese su DNI"
              value={dniManual}
              onChange={(e) => setDniManual(e.target.value.replace(/\D/g, ""))}
              autoFocus
            />
            <button
              type="submit"
              className="btn-primary"
              disabled={procesando || dniManual.length < 8}
            >
              Registrar asistencia
            </button>
          </form>

          <div className="asistencia-camara-actions">
            <button
              type="button"
              className={camaraActiva ? "btn-secondary" : "btn-primary"}
              onClick={toggleCamara}
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
        </div>
      </div>

      <AsistenciaNotificacion notif={notif} onClose={cerrarNotif} />
    </div>
  );
}

export function estadoVencimientoDesdeFila(fila) {
  if (fila.venceVencida) return "vencida";
  if (fila.venceEn3Dias) return "proxima";

  const s = String(fila.vence || "").trim();
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(s);
  if (!m) return "";

  const fin = new Date(Number(m[3]), Number(m[2]) - 1, Number(m[1]));
  const hoy = new Date();
  hoy.setHours(0, 0, 0, 0);
  fin.setHours(0, 0, 0, 0);
  const dias = Math.round((fin - hoy) / 86400000);
  if (dias < 0) return "vencida";
  if (dias <= 3) return "proxima";
  return "";
}

export function claseMarca(codigo) {
  if (codigo === "A") return "marca-a";
  if (codigo === "T") return "marca-t";
  if (codigo === "F") return "marca-f";
  if (codigo === "R") return "marca-r";
  return "marca-vacio";
}

export function claseVence(fila) {
  const estado = estadoVencimientoDesdeFila(fila);
  if (estado === "proxima") return "col-vence--proxima";
  if (estado === "vencida") return "col-vence--vencida";
  return "";
}

export function esDiaNoLectivo(fila, fecha) {
  if (!fecha) return false;
  const set = new Set(fila?.diasNoLectivos || []);
  return set.has(fecha);
}

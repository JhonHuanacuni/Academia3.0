export function estadoVencimientoDesdeFila(fila) {
  if (fila.venceVencida) return "vencida";
  if (fila.venceEn3Dias) return "proxima";
  if (fila.venceVencida === false || fila.venceEn3Dias === false) return "";

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
  if (codigo === "J" || codigo === "R") return "marca-j";
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

export function esDiaFueraMensualidad(fila, fecha) {
  if (!fecha) return false;
  const set = new Set(fila?.diasFueraMensualidad || []);
  return set.has(fecha);
}

export const TIPOS_MARCA_INFORME = [
  { value: "", label: "Todas" },
  { value: "A", label: "Asistencias" },
  { value: "T", label: "Tardanzas" },
  { value: "F", label: "Faltas" },
  { value: "J", label: "Justificaciones" },
];

const CAMPO_TOTAL_POR_MARCA = {
  A: "totalAsist",
  T: "totalTard",
  F: "totalFaltas",
  J: "totalJust",
};

export function filtrarFilasPorMarca(filas, tipoMarca) {
  if (!tipoMarca) return filas;
  const campo = CAMPO_TOTAL_POR_MARCA[tipoMarca];
  if (!campo) return filas;
  return filas.filter((fila) => (fila[campo] || 0) > 0);
}

export function renumerarFilasInforme(filas) {
  return filas.map((fila, index) => ({ ...fila, numero: index + 1 }));
}

export function calcularResumenInforme(filas) {
  let asist = 0;
  let tard = 0;
  let faltas = 0;

  for (const fila of filas) {
    asist += fila.totalAsist || 0;
    tard += fila.totalTard || 0;
    faltas += fila.totalFaltas || 0;
  }

  const total = asist + tard + faltas;
  if (total === 0) {
    return {
      asistAcum: 0,
      tardanzaAcum: 0,
      faltasAcum: 0,
      totalAsistentes: 0,
      asistPct: 0,
      tardanzaPct: 0,
      faltasPct: 0,
      totalMarcas: 0,
    };
  }

  return {
    asistAcum: asist,
    tardanzaAcum: tard,
    faltasAcum: faltas,
    totalAsistentes: asist + tard,
    asistPct: Math.round((asist / total) * 100),
    tardanzaPct: Math.round((tard / total) * 100),
    faltasPct: Math.round((faltas / total) * 100),
    totalMarcas: total,
  };
}

export const MESES_ES = [
  { value: "1", label: "Enero" },
  { value: "2", label: "Febrero" },
  { value: "3", label: "Marzo" },
  { value: "4", label: "Abril" },
  { value: "5", label: "Mayo" },
  { value: "6", label: "Junio" },
  { value: "7", label: "Julio" },
  { value: "8", label: "Agosto" },
  { value: "9", label: "Septiembre" },
  { value: "10", label: "Octubre" },
  { value: "11", label: "Noviembre" },
  { value: "12", label: "Diciembre" },
];

export function aniosInforme() {
  const y = new Date().getFullYear();
  return [y - 1, y, y + 1].map((n) => ({ value: String(n), label: String(n) }));
}

export function periodoInicial() {
  const hoy = new Date();
  return { anio: String(hoy.getFullYear()), mes: String(hoy.getMonth() + 1) };
}

export function formatSoles(n) {
  const v = Number(n || 0);
  return `S/ ${v.toLocaleString("es-PE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

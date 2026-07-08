export const dbToInput = (s) =>
  s && s.length === 8 ? `${s.slice(4)}-${s.slice(2, 4)}-${s.slice(0, 2)}` : "";

export const inputToDb = (s) => (s ? s.split("-").reverse().join("") : null);

export const dbToView = (s) =>
  s && s.length === 8 ? `${s.slice(0, 2)}/${s.slice(2, 4)}/${s.slice(4)}` : "";

/** Primer y último día del mes de una fecha input (YYYY-MM-DD). */
export const rangoMesCompletoInput = (fechaInput) => {
  if (!fechaInput) return { desde: "", hasta: "" };
  const [y, m] = fechaInput.split("-").map(Number);
  const ultimo = new Date(y, m, 0).getDate();
  const mm = String(m).padStart(2, "0");
  return {
    desde: `${y}-${mm}-01`,
    hasta: `${y}-${mm}-${String(ultimo).padStart(2, "0")}`,
  };
};

export const primerDiaMesInput = () => {
  const hoy = new Date();
  const y = hoy.getFullYear();
  const m = String(hoy.getMonth() + 1).padStart(2, "0");
  return `${y}-${m}-01`;
};

export const ultimoDiaMesInput = (fechaRef) => {
  const ref = fechaRef || primerDiaMesInput();
  return rangoMesCompletoInput(ref).hasta;
};

/** Hoy en formato input date (YYYY-MM-DD). */
export const hoyInput = () => {
  const hoy = new Date();
  const y = hoy.getFullYear();
  const m = String(hoy.getMonth() + 1).padStart(2, "0");
  const d = String(hoy.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
};

/** Suma días a una fecha input (YYYY-MM-DD). */
export const sumarDiasInput = (fechaInput, dias) => {
  if (!fechaInput || !dias) return "";
  const base = new Date(`${fechaInput}T12:00:00`);
  if (Number.isNaN(base.getTime())) return "";
  base.setDate(base.getDate() + Number(dias));
  const y = base.getFullYear();
  const m = String(base.getMonth() + 1).padStart(2, "0");
  const d = String(base.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
};

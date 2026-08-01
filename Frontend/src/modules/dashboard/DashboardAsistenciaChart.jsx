export default function DashboardAsistenciaChart({ resumen }) {
  if (!resumen) return null;

  const items = [
    { key: "asist", etiqueta: "Asistencias", pct: resumen.asistPct ?? 0, tono: "asist" },
    { key: "tard", etiqueta: "Tardanzas", pct: resumen.tardanzaPct ?? 0, tono: "tard" },
    { key: "faltas", etiqueta: "Faltas", pct: resumen.faltasPct ?? 0, tono: "falta" },
  ];

  return (
    <div className="dash-asist">
      {items.map((item) => (
        <div key={item.key} className={`dash-asist-row dash-asist-row--${item.tono}`}>
          <div className="dash-asist-meta">
            <span className="dash-asist-pct">{item.pct}%</span>
            <span className="dash-asist-name">{item.etiqueta}</span>
          </div>
          <div className="dash-asist-track">
            <div className="dash-asist-fill" style={{ width: `${item.pct}%` }} />
          </div>
        </div>
      ))}
    </div>
  );
}

const COLORES = {
  primary: "#6a42e5",
  asist: "#1e9e5a",
  warn: "#c7891b",
  muted: "#cbd5e1",
  danger: "#d23b3b",
};

export default function DashboardDonutChart({ segments, centerValue, centerLabel }) {
  const total = segments.reduce((s, seg) => s + (Number(seg.valor) || 0), 0);
  if (total <= 0) {
    return <p className="dash-chart-empty">Sin datos</p>;
  }

  const r = 54;
  const stroke = 16;
  const c = 2 * Math.PI * r;
  let acum = 0;

  return (
    <div className="dash-donut-wrap">
      <div className="dash-donut-ring">
        <svg viewBox="0 0 160 160" className="dash-donut-svg" aria-hidden="true">
          <circle cx="80" cy="80" r={r} fill="none" stroke="#eef1f8" strokeWidth={stroke} />
          {segments.map((seg) => {
            const val = Number(seg.valor) || 0;
            if (val <= 0) return null;
            const pct = val / total;
            const dash = pct * c;
            const gap = c - dash;
            const rot = (acum / total) * 360 - 90;
            acum += val;
            return (
              <circle
                key={seg.key}
                cx="80"
                cy="80"
                r={r}
                fill="none"
                stroke={COLORES[seg.tono] || COLORES.primary}
                strokeWidth={stroke}
                strokeDasharray={`${dash} ${gap}`}
                strokeDashoffset="0"
                transform={`rotate(${rot} 80 80)`}
                strokeLinecap="round"
              />
            );
          })}
        </svg>
        <div className="dash-donut-center">
          <strong>{centerValue ?? total}</strong>
          <span>{centerLabel || "Total"}</span>
        </div>
      </div>
      <ul className="dash-donut-legend">
        {segments.map((seg) => (
          <li key={seg.key}>
            <span className={`dash-donut-dot dash-donut-dot--${seg.tono}`} />
            <span className="dash-donut-leg-label">{seg.etiqueta}</span>
            <span className="dash-donut-leg-val">{seg.valor}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

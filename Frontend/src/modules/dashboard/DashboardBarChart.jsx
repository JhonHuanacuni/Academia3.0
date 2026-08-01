function formatMoneyShort(value) {
  const n = Number(value || 0);
  if (n >= 1000) return `S/ ${(n / 1000).toFixed(1)}k`;
  return new Intl.NumberFormat("es-PE", {
    style: "currency",
    currency: "PEN",
    maximumFractionDigits: 0,
  }).format(n);
}

function maxValor(items) {
  return Math.max(...items.map((i) => Number(i.valor) || 0), 1);
}

export default function DashboardBarChart({ items, format = "money", emptyLabel = "Sin datos" }) {
  if (!items?.length) {
    return <p className="dash-chart-empty">{emptyLabel}</p>;
  }

  const max = maxValor(items);
  const fmt = format === "money"
    ? (v) => formatMoneyShort(v)
    : (v) => String(v);
  const many = items.length > 15;

  return (
    <div className={`dash-chart${many ? " dash-chart--dense" : ""}`}>
      <div className="dash-chart-bars">
        {items.map((item, idx) => {
          const val = Number(item.valor) || 0;
          const pct = max > 0 ? Math.round((val / max) * 100) : 0;
          const h = val > 0 ? Math.max(pct, 8) : 0;
          const showLbl = !many || idx % 5 === 0 || idx === items.length - 1;
          return (
            <div key={item.key} className="dash-chart-col" title={`${item.etiqueta}: ${fmt(val)}`}>
              <span className="dash-chart-val">{val > 0 && !many ? fmt(val) : ""}</span>
              <div className="dash-chart-track">
                <div className="dash-chart-fill" style={{ height: `${h}%` }} />
              </div>
              <span className="dash-chart-lbl">{showLbl ? item.etiqueta : ""}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

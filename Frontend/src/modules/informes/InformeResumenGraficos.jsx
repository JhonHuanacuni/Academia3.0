export default function InformeResumenGraficos({ resumen, totalEstudiantes }) {
  if (!resumen) return null;

  const { asistPct, tardanzaPct, faltasPct, asistAcum, tardanzaAcum, faltasAcum } = resumen;

  const kpis = [
    { key: "est", valor: totalEstudiantes, etiqueta: "Estudiantes", tono: "primary" },
    { key: "asist", valor: asistAcum, etiqueta: "Asistencias", tono: "asist" },
    { key: "tard", valor: tardanzaAcum, etiqueta: "Tardanzas", tono: "tard" },
    {
      key: "totalAsist",
      valor: resumen.totalAsistentes ?? (asistAcum || 0) + (tardanzaAcum || 0),
      etiqueta: "Total de asistentes",
      tono: "total",
    },
    { key: "faltas", valor: faltasAcum, etiqueta: "Faltas", tono: "falta" },
  ];

  const distribucion = [
    { key: "asist", etiqueta: "Asistencias", pct: asistPct, tono: "asist" },
    { key: "tard", etiqueta: "Tardanzas", pct: tardanzaPct, tono: "tard" },
    { key: "faltas", etiqueta: "Faltas", pct: faltasPct, tono: "falta" },
  ];

  return (
    <div className="informes-dashboard">
      <div className="informes-kpi-row">
        {kpis.map((k) => (
          <div key={k.key} className={`informes-kpi informes-kpi--${k.tono}`}>
            <span className="informes-kpi-valor">{k.valor}</span>
            <span className="informes-kpi-etiqueta">{k.etiqueta}</span>
          </div>
        ))}
      </div>

      <div className="informes-resumen-panel">
        <div className="informes-resumen-grid">
          <section className="informes-dist-side">
            <div className="informes-panel-header">
              <h2>Distribución acumulada</h2>
              <p>% sobre el total de marcas del período</p>
            </div>
            <div className="informes-distribucion">
              {distribucion.map((item) => (
                <div key={item.key} className={`informes-dist-item informes-dist-item--${item.tono}`}>
                  <div className="informes-dist-row">
                    <span className="informes-dist-pct">{item.pct}%</span>
                    <span className="informes-dist-label">{item.etiqueta}</span>
                  </div>
                  <div className="informes-dist-track">
                    <div className="informes-dist-fill" style={{ width: `${item.pct}%` }} />
                  </div>
                </div>
              ))}
            </div>
          </section>

          <section className="informes-chart-side">
            <div className="informes-panel-header">
              <h2>Comparativo visual</h2>
              <p>Proporción por categoría</p>
            </div>
            <div className="informes-chart-bars">
              {distribucion.map((item) => (
                <div key={item.key} className="informes-chart-col">
                  <div className="informes-chart-bar-wrap">
                    <div
                      className={`informes-chart-bar informes-chart-bar--${item.tono}`}
                      style={{ height: `${Math.max(item.pct, item.pct > 0 ? 6 : 0)}%` }}
                    >
                      {item.pct > 12 && <span>{item.pct}%</span>}
                    </div>
                  </div>
                  <span className="informes-chart-label">{item.etiqueta}</span>
                  {item.pct <= 12 && item.pct > 0 && (
                    <span className="informes-chart-pct-small">{item.pct}%</span>
                  )}
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}

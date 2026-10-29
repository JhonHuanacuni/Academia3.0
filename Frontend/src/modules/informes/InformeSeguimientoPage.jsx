import { useCallback, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faChartColumn,
  faFileExcel,
  faSpinner,
  faUsers,
} from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import "../../styles/mantenedor.css";
import "./informes.css";
import { exportarInformeSeguimientoExcel } from "./exportarSeguimientoExcel";
import { MESES_ES, aniosInforme, periodoInicial } from "./informePeriodoUtils";

const TABS = [
  { id: "indicadores", label: "Indicadores", icon: faChartColumn },
  { id: "listado", label: "Consultas", icon: faUsers },
];

const PIE_COLORS = ["#6b7280", "#6a42e5", "#c7891b", "#1e9e5a", "#2563eb", "#d23b3b"];

function DistList({ titulo, items, total }) {
  if (!items?.length) {
    return (
      <section className="informes-dist-side">
        <div className="informes-panel-header">
          <h2>{titulo}</h2>
          <p>Sin datos</p>
        </div>
      </section>
    );
  }
  return (
    <section className="informes-dist-side">
      <div className="informes-panel-header">
        <h2>{titulo}</h2>
        <p>Distribución del periodo</p>
      </div>
      <div className="informes-distribucion">
        {items.map((item) => {
          const pct = total > 0 ? Math.round((item.cantidad / total) * 100) : 0;
          return (
            <div key={item.etiqueta} className="informes-dist-item informes-dist-item--asist">
              <div className="informes-dist-row">
                <span className="informes-dist-pct">{pct}%</span>
                <span className="informes-dist-label">
                  {item.etiqueta} · {item.cantidad}
                </span>
              </div>
              <div className="informes-dist-track">
                <div className="informes-dist-fill" style={{ width: `${pct}%` }} />
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}

function DistCircular({ titulo, items, total }) {
  if (!items?.length) {
    return (
      <section className="informes-dist-side">
        <div className="informes-panel-header">
          <h2>{titulo}</h2>
          <p>Sin datos</p>
        </div>
      </section>
    );
  }
  let acumulado = 0;
  const segmentos = items.map((item, i) => {
    const pctRaw = total > 0 ? (item.cantidad / total) * 100 : 0;
    const inicio = acumulado;
    acumulado += pctRaw;
    return {
      ...item,
      color: PIE_COLORS[i % PIE_COLORS.length],
      pct: Math.round(pctRaw),
      inicio,
      fin: acumulado,
    };
  });
  const gradient =
    segmentos.length === 1
      ? segmentos[0].color
      : segmentos.map((s) => `${s.color} ${s.inicio}% ${s.fin}%`).join(", ");

  return (
    <section className="informes-dist-side">
      <div className="informes-panel-header">
        <h2>{titulo}</h2>
        <p>Distribución circular</p>
      </div>
      <div className="informes-pie-wrap">
        <div className="informes-pie" style={{ background: `conic-gradient(${gradient})` }}>
          <div className="informes-pie-hole">
            <strong>{total}</strong>
            <span>total</span>
          </div>
        </div>
        <ul className="informes-pie-legend">
          {segmentos.map((s) => (
            <li key={s.etiqueta}>
              <span className="informes-pie-dot" style={{ background: s.color }} />
              <span className="informes-pie-legend-text">
                {s.etiqueta} · {s.cantidad} ({s.pct}%)
              </span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}

function IndicadoresSeguimiento({ resumen }) {
  if (!resumen) return null;
  const kpis = [
    { key: "tot", valor: resumen.total, etiqueta: "Consultas", tono: "primary" },
    {
      key: "na",
      valor: resumen.noAplica,
      extra: `${resumen.noAplicaPct}%`,
      etiqueta: "No aplica",
      tono: "total",
    },
    {
      key: "int",
      valor: resumen.interesados,
      extra: `${resumen.interesadosPct}%`,
      etiqueta: "Interesados",
      tono: "tard",
    },
    { key: "seg", valor: resumen.seguimiento, etiqueta: "En seguimiento", tono: "primary" },
    {
      key: "mat",
      valor: resumen.matriculados,
      extra: `${resumen.matriculadosPct}% del total`,
      etiqueta: "Matriculados",
      tono: "asist",
    },
    {
      key: "conv",
      valor: resumen.conversion != null ? `${resumen.conversion}%` : "—",
      extra: "matriculados / interesados",
      etiqueta: "Conversión",
      tono: "asist",
    },
  ];

  const maxDia = Math.max(...(resumen.chartDiario || []).map((d) => d.valor), 1);

  return (
    <div className="informes-dashboard">
      <div className="informes-kpi-row informes-kpi-row--6">
        {kpis.map((k) => (
          <div key={k.key} className={`informes-kpi informes-kpi--${k.tono}`}>
            <span className="informes-kpi-valor">{k.valor}</span>
            {k.extra && <span className="informes-kpi-extra">{k.extra}</span>}
            <span className="informes-kpi-etiqueta">{k.etiqueta}</span>
          </div>
        ))}
      </div>
      <div className="informes-resumen-panel">
        <div className="informes-resumen-grid">
          <DistCircular titulo="Por resultado" items={resumen.porResultado} total={resumen.total} />
          <DistList titulo="Cómo llegó" items={resumen.porCanal} total={resumen.total} />
        </div>
        <div className="informes-resumen-grid">
          <DistList titulo="Ciclo de interés" items={resumen.porCiclo} total={resumen.total} />
          <section className="informes-chart-side">
            <div className="informes-panel-header">
              <h2>Consultas por día</h2>
              <p>Volumen diario del mes</p>
            </div>
            <div className="informes-chart-bars informes-chart-bars--distrito">
              {(resumen.chartDiario || []).map((d) => {
                const altura = Math.max(Math.round((d.valor / maxDia) * 100), d.valor > 0 ? 8 : 0);
                return (
                  <div key={d.etiqueta} className="informes-chart-col" title={`Día ${d.etiqueta}: ${d.valor}`}>
                    <div className="informes-chart-bar-wrap">
                      <div className="informes-chart-bar" style={{ height: `${altura}%`, background: "#6a42e5" }} />
                    </div>
                    <span className="informes-chart-label">{d.etiqueta}</span>
                  </div>
                );
              })}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}

function TablaSeguimiento({ filas }) {
  if (!filas?.length) {
    return <div className="mantenedor-state">No hay consultas en el periodo.</div>;
  }
  return (
    <div className="informe-tabla-outer">
      <table className="informe-asistencias-table">
        <thead>
          <tr>
            <th>FECHA</th>
            <th>NOMBRE</th>
            <th>TELÉFONO</th>
            <th>CICLO</th>
            <th>CÓMO LLEGÓ</th>
            <th>RESULTADO</th>
            <th>SE ENTERÓ</th>
            <th>OBSERVACIÓN</th>
          </tr>
        </thead>
        <tbody>
          {filas.map((f) => (
            <tr key={f.id} className={f.enAlumnos ? "informe-fila--alumno" : undefined}>
              <td>{f.fecha}</td>
              <td>
                {f.nombre}
                {f.enAlumnos && <span className="informe-badge-alumno"> En alumnos</span>}
              </td>
              <td>{f.telefono || "—"}</td>
              <td>{f.ciclo || "—"}</td>
              <td>{f.canal}</td>
              <td>{f.resultado}</td>
              <td>{f.seEntero || "—"}</td>
              <td>{f.observacion || "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function InformeSeguimientoPage() {
  const ini = periodoInicial();
  const [anio, setAnio] = useState(ini.anio);
  const [mes, setMes] = useState(ini.mes);
  const [tabActiva, setTabActiva] = useState("indicadores");
  const [data, setData] = useState(null);
  const [cargando, setCargando] = useState(false);
  const [exportando, setExportando] = useState(false);
  const [error, setError] = useState("");
  const [consultado, setConsultado] = useState(false);

  const cargar = useCallback(async () => {
    try {
      setCargando(true);
      setError("");
      const params = new URLSearchParams({ anio, mes });
      const res = await fetch(`/api/informes/seguimiento/?${params}`);
      const json = await parseJsonResponse(res);
      if (!res.ok) throw new Error(json.error || "Error al generar el informe");
      setData(json);
      setConsultado(true);
    } catch (err) {
      setError(err.message);
      setData(null);
    } finally {
      setCargando(false);
    }
  }, [anio, mes]);

  const exportarExcel = useCallback(async () => {
    if (!data?.filas?.length) {
      setError("No hay datos para exportar.");
      return;
    }
    try {
      setExportando(true);
      await exportarInformeSeguimientoExcel({
        filas: data.filas,
        meta: {
          periodo: data.periodo,
          conversion: data.resumen?.conversion,
        },
      });
    } catch (err) {
      setError(err.message || "No se pudo exportar");
    } finally {
      setExportando(false);
    }
  }, [data]);

  const hayDatos = consultado && data?.total > 0;

  return (
    <div className="informes-page">
      <div className="mantenedor-card informes-filtros">
        <div className="informes-filtros-grid informes-filtros-grid--periodo">
          <label>
            Año
            <select value={anio} onChange={(e) => setAnio(e.target.value)}>
              {aniosInforme().map((a) => (
                <option key={a.value} value={a.value}>
                  {a.label}
                </option>
              ))}
            </select>
          </label>
          <label>
            Mes
            <select value={mes} onChange={(e) => setMes(e.target.value)}>
              {MESES_ES.map((m) => (
                <option key={m.value} value={m.value}>
                  {m.label}
                </option>
              ))}
            </select>
          </label>
          <div className="informes-filtros-acciones">
            <button type="button" className="btn-primary informes-btn-generar" onClick={cargar} disabled={cargando}>
              {cargando ? (
                <>
                  <FontAwesomeIcon icon={faSpinner} spin /> Generando...
                </>
              ) : (
                "Generar informe"
              )}
            </button>
            {hayDatos && (
              <button type="button" className="btn-secondary" onClick={exportarExcel} disabled={exportando}>
                <FontAwesomeIcon icon={faFileExcel} spin={exportando} />
                {exportando ? "Exportando..." : "Exportar Excel"}
              </button>
            )}
          </div>
        </div>
        <p className="informes-filtro-nota">
          Conversión = matriculados ÷ interesados. Quien queda en seguimiento o se matricula sigue contando como
          interesado. Si el teléfono ya está en alumnos del mes, la fila lo marca. Los registros se cargan en
          Académico → Informes.
        </p>
      </div>

      {error && <div className="mantenedor-state error">{error}</div>}

      {cargando ? (
        <div className="mantenedor-state">
          <FontAwesomeIcon icon={faSpinner} spin /> Generando informe...
        </div>
      ) : consultado && !hayDatos ? (
        <div className="mantenedor-state">
          No hay consultas registradas en el periodo. Anótalas en Académico → Informes.
        </div>
      ) : hayDatos ? (
        <div className="ui-tabs-panel">
          <div className="ui-tabs" role="tablist" aria-label="Vista del informe de seguimiento">
            {TABS.map((tab) => (
              <button
                key={tab.id}
                type="button"
                role="tab"
                aria-selected={tabActiva === tab.id}
                className={`ui-tab${tabActiva === tab.id ? " ui-tab--activa" : ""}`}
                onClick={() => setTabActiva(tab.id)}
              >
                <FontAwesomeIcon icon={tab.icon} />
                {tab.label}
              </button>
            ))}
          </div>
          <div className="ui-tabs-panel-body" role="tabpanel">
            {tabActiva === "indicadores" ? (
              <IndicadoresSeguimiento resumen={data.resumen} />
            ) : (
              <TablaSeguimiento filas={data.filas} />
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

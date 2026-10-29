import { useCallback, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faChartColumn,
  faFileExcel,
  faList,
  faMoneyBillWave,
  faSpinner,
} from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import "../../styles/mantenedor.css";
import "./informes.css";
import { exportarInformeCajaExcel } from "./exportarCajaExcel";
import { MESES_ES, aniosInforme, formatSoles, periodoInicial } from "./informePeriodoUtils";

const TABS = [
  { id: "indicadores", label: "Indicadores", icon: faChartColumn },
  { id: "medios", label: "Por medio", icon: faMoneyBillWave },
  { id: "detalle", label: "Detalle", icon: faList },
];

const PIE_COLORS = ["#1e9e5a", "#6a42e5", "#2563eb", "#c7891b", "#d23b3b", "#0891b2", "#7c3aed", "#db2777"];

function IndicadoresCaja({ resumen, chartDiario }) {
  if (!resumen) return null;
  const kpis = [
    { key: "ing", valor: formatSoles(resumen.totalIngresos), etiqueta: "Ingresos del mes", tono: "asist" },
    { key: "cant", valor: resumen.cantidadPagos, etiqueta: "Pagos registrados", tono: "primary" },
    { key: "med", valor: resumen.cantidadMedios, etiqueta: "Medios usados", tono: "tard" },
    { key: "prom", valor: formatSoles(resumen.promedioDiario), etiqueta: "Promedio diario", tono: "primary" },
  ];
  const maxVal = Math.max(...(chartDiario || []).map((d) => d.valor), 1);

  return (
    <div className="informes-dashboard">
      <div className="informes-kpi-row informes-kpi-row--4">
        {kpis.map((k) => (
          <div key={k.key} className={`informes-kpi informes-kpi--${k.tono}`}>
            <span className="informes-kpi-valor informes-kpi-valor--sm">{k.valor}</span>
            <span className="informes-kpi-etiqueta">{k.etiqueta}</span>
          </div>
        ))}
      </div>
      <div className="informes-resumen-panel">
        <section className="informes-chart-side informes-chart-side--full">
          <div className="informes-panel-header">
            <h2>Ingresos por día</h2>
            <p>Pagos mensuales y extraordinarios del mes</p>
          </div>
          <div className="informes-chart-bars informes-chart-bars--distrito">
            {(chartDiario || []).map((d) => {
              const altura = Math.max(Math.round((d.valor / maxVal) * 100), d.valor > 0 ? 8 : 0);
              return (
                <div key={d.etiqueta} className="informes-chart-col" title={`${d.etiqueta}: ${formatSoles(d.valor)}`}>
                  <div className="informes-chart-bar-wrap">
                    <div className="informes-chart-bar informes-chart-bar--asist" style={{ height: `${altura}%` }} />
                  </div>
                  <span className="informes-chart-label">{d.etiqueta}</span>
                </div>
              );
            })}
          </div>
        </section>
      </div>
    </div>
  );
}

function PorMedio({ medios, totalIngresos }) {
  if (!medios?.length) {
    return <div className="mantenedor-state">Sin ingresos por medio.</div>;
  }
  let acumulado = 0;
  const segmentos = medios.map((m, i) => {
    const pctRaw = totalIngresos > 0 ? (m.monto / totalIngresos) * 100 : 0;
    const inicio = acumulado;
    acumulado += pctRaw;
    return { ...m, color: PIE_COLORS[i % PIE_COLORS.length], inicio, fin: acumulado, pct: Math.round(pctRaw) };
  });
  const gradient =
    segmentos.length === 1
      ? segmentos[0].color
      : segmentos.map((s) => `${s.color} ${s.inicio}% ${s.fin}%`).join(", ");

  return (
    <div className="informes-resumen-grid">
      <section className="informes-dist-side">
        <div className="informes-panel-header">
          <h2>Distribución por medio</h2>
          <p>Participación del total ingresado</p>
        </div>
        <div className="informes-pie-wrap">
          <div className="informes-pie" style={{ background: `conic-gradient(${gradient})` }}>
            <div className="informes-pie-hole">
              <strong>{formatSoles(totalIngresos)}</strong>
              <span>total</span>
            </div>
          </div>
          <ul className="informes-pie-legend">
            {segmentos.map((s) => (
              <li key={s.etiqueta}>
                <span className="informes-pie-dot" style={{ background: s.color }} />
                <span className="informes-pie-legend-text">
                  {s.etiqueta} · {formatSoles(s.monto)} ({s.pct}%)
                </span>
              </li>
            ))}
          </ul>
        </div>
      </section>
      <section className="informes-dist-side">
        <div className="informes-panel-header">
          <h2>Detalle por medio</h2>
          <p>Monto y cantidad de pagos</p>
        </div>
        <div className="informe-tabla-outer">
          <table className="informe-asistencias-table">
            <thead>
              <tr>
                <th>MEDIO</th>
                <th>CANTIDAD</th>
                <th>MONTO</th>
                <th>%</th>
              </tr>
            </thead>
            <tbody>
              {medios.map((m) => (
                <tr key={m.etiqueta}>
                  <td>{m.etiqueta}</td>
                  <td>{m.cantidad}</td>
                  <td>{formatSoles(m.monto)}</td>
                  <td>{m.pct}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function DetalleCaja({ gruposFecha }) {
  if (!gruposFecha?.length) {
    return <div className="mantenedor-state">No hay ingresos en el periodo.</div>;
  }
  return (
    <div className="informe-caja-detalle">
      {gruposFecha.map((g) => (
        <div key={g.fecha} className="informe-caja-dia">
          <div className="informe-tabla-outer">
            <table className="informe-asistencias-table">
              <thead>
                <tr>
                  <th>FECHA</th>
                  <th>RECIBO</th>
                  <th>NOMBRE</th>
                  <th>CICLO / CONCEPTO</th>
                  <th>MEDIO</th>
                  <th>MONTO</th>
                </tr>
              </thead>
              <tbody>
                {g.items.map((item) => (
                  <tr key={`${item.tipo}-${item.id}`}>
                    <td>{item.fecha}</td>
                    <td>{item.recibo}</td>
                    <td>{item.nombre}</td>
                    <td>{item.ciclo || "—"}</td>
                    <td>{item.medio}</td>
                    <td>{formatSoles(item.monto)}</td>
                  </tr>
                ))}
                <tr className="informe-caja-subtotal">
                  <td colSpan={5}>
                    <strong>Total {g.fecha}</strong>
                  </td>
                  <td>
                    <strong>{formatSoles(g.monto)}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      ))}
    </div>
  );
}

export default function InformeCajaPage() {
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
      const res = await fetch(`/api/informes/caja/?${params}`);
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
      await exportarInformeCajaExcel({ filas: data.filas, meta: { periodo: data.periodo } });
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
          Solo ingresos reales del mes (pagos de mensualidad + pagos extraordinarios). No hay egresos ni cuadre en
          Vita; este informe no calcula disponible.
        </p>
      </div>

      {error && <div className="mantenedor-state error">{error}</div>}

      {cargando ? (
        <div className="mantenedor-state">
          <FontAwesomeIcon icon={faSpinner} spin /> Generando informe...
        </div>
      ) : consultado && !hayDatos ? (
        <div className="mantenedor-state">No hay ingresos para el periodo seleccionado.</div>
      ) : hayDatos ? (
        <div className="ui-tabs-panel">
          <div className="ui-tabs" role="tablist" aria-label="Vista del informe de caja">
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
            {tabActiva === "indicadores" && (
              <IndicadoresCaja resumen={data.resumen} chartDiario={data.chartDiario} />
            )}
            {tabActiva === "medios" && (
              <PorMedio medios={data.medios} totalIngresos={data.resumen?.totalIngresos || 0} />
            )}
            {tabActiva === "detalle" && <DetalleCaja gruposFecha={data.gruposFecha} />}
          </div>
        </div>
      ) : null}
    </div>
  );
}

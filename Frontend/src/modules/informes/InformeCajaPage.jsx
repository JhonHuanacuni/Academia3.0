import { Fragment, useCallback, useEffect, useState } from "react";
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
    { key: "ing", valor: formatSoles(resumen.totalIngresos), etiqueta: "Ingresos del periodo", tono: "asist" },
    { key: "cant", valor: resumen.cantidadPagos, etiqueta: "Pagos registrados", tono: "primary" },
    { key: "med", valor: resumen.cantidadMedios, etiqueta: "Medios usados", tono: "tard" },
    { key: "prom", valor: formatSoles(resumen.promedioDiario), etiqueta: "Promedio diario", tono: "primary" },
  ];
  const puntosChart = chartDiario || [];
  const puntosRank = [...puntosChart].sort((a, b) => b.valor - a.valor);
  const maxVal = Math.max(...puntosChart.map((d) => d.valor), 1);
  const esMes = Number(resumen.mes) > 0;

  return (
    <div className="informes-dashboard informe-caja-indicadores">
      <div className="informes-kpi-row informes-kpi-row--4">
        {kpis.map((k) => (
          <div key={k.key} className={`informes-kpi informes-kpi--${k.tono}`}>
            <span className="informes-kpi-valor informes-kpi-valor--sm">{k.valor}</span>
            <span className="informes-kpi-etiqueta">{k.etiqueta}</span>
          </div>
        ))}
      </div>

      <div className="informe-caja-ind-grid">
        <section className="informe-caja-panel">
          <div className="informes-panel-header">
            <h2>{resumen.chartTitulo || "Ingresos por día"}</h2>
            <p>{resumen.periodo} · solo fechas con movimiento</p>
          </div>
          {puntosChart.length === 0 ? (
            <div className="mantenedor-state">Sin movimientos en el periodo.</div>
          ) : (
            <div className="informe-caja-bars">
              {puntosChart.map((d) => {
                const altura = Math.max(Math.round((d.valor / maxVal) * 100), 8);
                return (
                  <div key={d.etiqueta} className="informe-caja-bar-col" title={`${d.etiqueta}: ${formatSoles(d.valor)}`}>
                    <span className="informe-caja-bar-monto">{formatSoles(d.valor)}</span>
                    <div className="informe-caja-bar-track">
                      <div className="informe-caja-bar-fill" style={{ height: `${altura}%` }} />
                    </div>
                    <span className="informe-caja-bar-label">
                      {esMes ? `Día ${d.etiqueta}` : d.etiqueta}
                    </span>
                  </div>
                );
              })}
            </div>
          )}
        </section>

        <section className="informe-caja-panel">
          <div className="informes-panel-header">
            <h2>Ranking del periodo</h2>
            <p>De mayor a menor ingreso</p>
          </div>
          <div className="informe-tabla-outer">
            <table className="informe-asistencias-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>{esMes ? "DÍA" : "MES"}</th>
                  <th>MONTO</th>
                  <th>%</th>
                </tr>
              </thead>
              <tbody>
                {puntosRank.map((d, i) => {
                  const pct = resumen.totalIngresos > 0 ? Math.round((d.valor / resumen.totalIngresos) * 100) : 0;
                  return (
                    <tr key={d.etiqueta}>
                      <td>{i + 1}</td>
                      <td>{esMes ? `Día ${d.etiqueta}` : d.etiqueta}</td>
                      <td className="informes-num--ok">{formatSoles(d.valor)}</td>
                      <td>{pct}%</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
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
    return {
      ...m,
      color: PIE_COLORS[i % PIE_COLORS.length],
      inicio,
      fin: acumulado,
      pct: Math.round(pctRaw),
    };
  });
  const gradient =
    segmentos.length === 1
      ? segmentos[0].color
      : segmentos.map((s) => `${s.color} ${s.inicio}% ${s.fin}%`).join(", ");

  return (
    <div className="informe-caja-medios">
      <section className="informe-caja-panel informe-caja-medios-top">
        <div className="informes-panel-header">
          <h2>Distribución por medio</h2>
          <p>Participación del total ingresado en el periodo</p>
        </div>
        <div className="informe-caja-medios-top-body">
          <div className="informe-caja-pie-block">
            <div
              className="informes-pie informe-caja-pie-lg"
              style={{ background: `conic-gradient(${gradient})` }}
            >
              <div className="informes-pie-hole informe-caja-pie-hole">
                <strong>{formatSoles(totalIngresos)}</strong>
                <span>total</span>
              </div>
            </div>
          </div>
          <div className="informe-caja-medios-cards">
            {segmentos.map((s) => (
              <article key={s.etiqueta} className="informe-caja-medio-card">
                <header>
                  <span className="informes-pie-dot" style={{ background: s.color }} />
                  <strong>{s.etiqueta}</strong>
                  <em>{s.pct}%</em>
                </header>
                <div className="informe-caja-medio-card-monto">{formatSoles(s.monto)}</div>
                <div className="informes-dist-track">
                  <div
                    className="informes-dist-fill"
                    style={{ width: `${Math.max(s.pct, 2)}%`, background: s.color }}
                  />
                </div>
                <footer>
                  {s.cantidad} pago{s.cantidad === 1 ? "" : "s"}
                </footer>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="informe-caja-panel">
        <div className="informes-panel-header">
          <h2>Resumen tabular</h2>
          <p>Montos consolidados por medio de pago</p>
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
              {segmentos.map((m) => (
                <tr key={m.etiqueta}>
                  <td>
                    <span className="informes-pie-dot" style={{ background: m.color, marginRight: 8 }} />
                    {m.etiqueta}
                  </td>
                  <td>{m.cantidad}</td>
                  <td className="informes-num--ok">{formatSoles(m.monto)}</td>
                  <td>{m.pct}%</td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr className="informe-caja-total-row">
                <td>
                  <strong>TOTAL</strong>
                </td>
                <td>
                  <strong>{medios.reduce((a, m) => a + m.cantidad, 0)}</strong>
                </td>
                <td>
                  <strong>{formatSoles(totalIngresos)}</strong>
                </td>
                <td>
                  <strong>100%</strong>
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </section>
    </div>
  );
}

function DetalleCaja({ gruposFecha, totalIngresos, periodo }) {
  if (!gruposFecha?.length) {
    return <div className="mantenedor-state">No hay ingresos en el periodo.</div>;
  }
  const totalPagos = gruposFecha.reduce((a, g) => a + (g.cantidad || g.items?.length || 0), 0);

  return (
    <div className="informe-caja-detalle">
      <div className="informe-caja-detalle-meta">
        <div>
          <strong>{periodo}</strong>
          <span>
            {totalPagos} pago{totalPagos === 1 ? "" : "s"} · {gruposFecha.length} día
            {gruposFecha.length === 1 ? "" : "s"} con movimiento
          </span>
        </div>
        <div className="informe-caja-detalle-total">
          Total periodo: <strong>{formatSoles(totalIngresos)}</strong>
        </div>
      </div>

      <div className="informe-tabla-outer">
        <table className="informe-asistencias-table informe-caja-detalle-table">
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
            {gruposFecha.map((g) => (
              <Fragment key={g.fecha}>
                {g.items.map((item) => (
                  <tr key={`${item.tipo}-${item.id}`}>
                    <td>{item.fecha}</td>
                    <td>{item.recibo}</td>
                    <td title={item.nombre}>{item.nombre}</td>
                    <td>{item.ciclo || "—"}</td>
                    <td>
                      <span className="informe-caja-chip">{item.medio}</span>
                    </td>
                    <td className="informes-num--ok">{formatSoles(item.monto)}</td>
                  </tr>
                ))}
                <tr className="informe-caja-subtotal">
                  <td colSpan={5}>
                    <strong>Total {g.fecha}</strong>
                    <span className="informe-caja-subtotal-count">
                      {" "}
                      · {g.cantidad || g.items.length} pago{(g.cantidad || g.items.length) === 1 ? "" : "s"}
                    </span>
                  </td>
                  <td>
                    <strong>{formatSoles(g.monto)}</strong>
                  </td>
                </tr>
              </Fragment>
            ))}
          </tbody>
          <tfoot>
            <tr className="informe-caja-total-row">
              <td colSpan={5}>
                <strong>TOTAL {periodo?.toUpperCase() || "PERIODO"}</strong>
              </td>
              <td>
                <strong>{formatSoles(totalIngresos)}</strong>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
}

export default function InformeCajaPage() {
  const ini = periodoInicial();
  const [anio, setAnio] = useState(ini.anio);
  const [mes, setMes] = useState(ini.mes);
  const [tabActiva, setTabActiva] = useState("detalle");
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
      if (!res.ok) throw new Error(json.error || "Error al cargar el informe");
      setData(json);
      setConsultado(true);
    } catch (err) {
      setError(err.message);
      setData(null);
    } finally {
      setCargando(false);
    }
  }, [anio, mes]);

  useEffect(() => {
    cargar();
  }, [cargar]);

  const exportarExcel = useCallback(async () => {
    if (!data?.filas?.length) {
      setError("No hay datos para exportar.");
      return;
    }
    try {
      setExportando(true);
      setError("");
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
      <div className="mantenedor-card informes-filtros informe-caja-toolbar">
        <div className="informe-caja-toolbar-row">
          <div className="informe-caja-toolbar-filtros">
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
              Periodo
              <select value={mes} onChange={(e) => setMes(e.target.value)}>
                <option value="0">Todo el año</option>
                {MESES_ES.map((m) => (
                  <option key={m.value} value={m.value}>
                    {m.label}
                  </option>
                ))}
              </select>
            </label>
            {data?.periodo && (
              <span className="informe-caja-periodo-pill">{data.periodo}</span>
            )}
          </div>
          <button
            type="button"
            className="btn-primary"
            onClick={exportarExcel}
            disabled={exportando || !hayDatos || cargando}
            title={!hayDatos ? "No hay datos para exportar" : "Descargar Excel del periodo"}
          >
            <FontAwesomeIcon icon={faFileExcel} spin={exportando} />
            {exportando ? "Exportando..." : "Descargar Excel"}
          </button>
        </div>
        <p className="informes-filtro-nota">
          Elige mes o “Todo el año”. La descarga Excel incluye todos los pagos del periodo seleccionado (mensualidades
          + extraordinarios).
        </p>
      </div>

      {error && <div className="mantenedor-state error">{error}</div>}

      {cargando ? (
        <div className="mantenedor-state">
          <FontAwesomeIcon icon={faSpinner} spin /> Cargando caja...
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
            {tabActiva === "detalle" && (
              <DetalleCaja
                gruposFecha={data.gruposFecha}
                totalIngresos={data.resumen?.totalIngresos || 0}
                periodo={data.periodo}
              />
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

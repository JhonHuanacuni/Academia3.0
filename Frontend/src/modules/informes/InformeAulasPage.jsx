import { useCallback, useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faChartColumn,
  faChalkboard,
  faFileExcel,
  faSpinner,
  faTableCells,
} from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import "../../styles/mantenedor.css";
import "./informes.css";
import { exportarInformeAulasExcel } from "./exportarAulasExcel";
import { MESES_ES, aniosInforme, formatSoles, periodoInicial } from "./informePeriodoUtils";

const TABS = [
  { id: "indicadores", label: "Indicadores", icon: faChartColumn },
  { id: "aulas", label: "Por aula", icon: faChalkboard },
  { id: "ciclos", label: "Ciclos por aula", icon: faTableCells },
];

function BarraOcupacion({ pct }) {
  if (pct == null) return <span className="informes-muted">—</span>;
  const tono = pct > 100 ? "falta" : pct >= 80 ? "tard" : "asist";
  return (
    <div className="informes-ocupacion" title={`${pct}%`}>
      <div className="informes-ocupacion-track">
        <div
          className={`informes-ocupacion-fill informes-ocupacion-fill--${tono}`}
          style={{ width: `${Math.min(pct, 100)}%` }}
        />
      </div>
      <span>{pct}%</span>
    </div>
  );
}

function IndicadoresAulas({ resumen, filas }) {
  if (!resumen) return null;

  const pctCobrado = Math.min(Number(resumen.pctCobrado) || 0, 100);
  const pctPendiente = Math.max(0, 100 - pctCobrado);
  const ocupacion = resumen.ocupacion != null ? Number(resumen.ocupacion) : null;

  const ranking = [...(filas || [])]
    .filter((f) => (f.ingresoMes || 0) > 0 || (f.alumnos || 0) > 0)
    .sort((a, b) => (b.porCobrar || 0) - (a.porCobrar || 0) || (b.alumnos || 0) - (a.alumnos || 0))
    .slice(0, 8);

  const maxPorCobrar = Math.max(...ranking.map((f) => f.porCobrar || 0), 1);

  return (
    <div className="informes-dashboard informe-aulas-indicadores">
      <div className="informe-aulas-kpi-grid">
        <article className="informe-aulas-kpi informe-aulas-kpi--primary">
          <span className="informe-aulas-kpi-label">Aulas</span>
          <strong>{resumen.totalAulas}</strong>
        </article>
        <article className="informe-aulas-kpi informe-aulas-kpi--asist">
          <span className="informe-aulas-kpi-label">Alumnos</span>
          <strong>{resumen.alumnos}</strong>
        </article>
        <article className="informe-aulas-kpi informe-aulas-kpi--tard">
          <span className="informe-aulas-kpi-label">Ocupación</span>
          <strong>{ocupacion != null ? `${ocupacion}%` : "—"}</strong>
        </article>
        <article className="informe-aulas-kpi informe-aulas-kpi--primary">
          <span className="informe-aulas-kpi-label">Ingreso mes</span>
          <strong className="informe-aulas-kpi-money">{formatSoles(resumen.ingresoMes)}</strong>
        </article>
        <article className="informe-aulas-kpi informe-aulas-kpi--asist">
          <span className="informe-aulas-kpi-label">Cobrado</span>
          <strong className="informe-aulas-kpi-money">{formatSoles(resumen.cobrado)}</strong>
        </article>
        <article className="informe-aulas-kpi informe-aulas-kpi--falta">
          <span className="informe-aulas-kpi-label">Por cobrar</span>
          <strong className="informe-aulas-kpi-money">{formatSoles(resumen.porCobrar)}</strong>
        </article>
      </div>

      <div className="informe-aulas-ind-grid">
        <section className="informe-caja-panel">
          <div className="informes-panel-header">
            <h2>Cobranza del mes</h2>
            <p>
              {resumen.periodo || "Periodo"} · {pctCobrado}% del ingreso esperado ya cobrado
            </p>
          </div>

          <div className="informe-aulas-cobranza">
            <div
              className="informe-aulas-cobranza-pct"
              style={{ background: `conic-gradient(#1e9e5a 0 ${pctCobrado}%, #eef1f8 ${pctCobrado}% 100%)` }}
            >
              <strong>{pctCobrado}%</strong>
              <span>cobrado</span>
            </div>
            <div className="informe-aulas-cobranza-bars">
              <div className="informe-aulas-stack">
                <div className="informe-aulas-stack-fill informe-aulas-stack-fill--ok" style={{ width: `${pctCobrado}%` }} />
                <div className="informe-aulas-stack-fill informe-aulas-stack-fill--warn" style={{ width: `${pctPendiente}%` }} />
              </div>
              <div className="informe-aulas-cobranza-legend">
                <span>
                  <i className="informe-aulas-dot informe-aulas-dot--ok" /> Cobrado · {formatSoles(resumen.cobrado)}
                </span>
                <span>
                  <i className="informe-aulas-dot informe-aulas-dot--warn" /> Por cobrar · {formatSoles(resumen.porCobrar)}
                </span>
              </div>
            </div>
          </div>

          <div className="informe-aulas-mini-grid">
            <div className="informe-aulas-mini">
              <span>Ingreso esperado</span>
              <strong>{formatSoles(resumen.ingresoMes)}</strong>
            </div>
            <div className="informe-aulas-mini">
              <span>Ocupación global</span>
              <strong>{ocupacion != null ? `${ocupacion}%` : "—"}</strong>
              {ocupacion != null && (
                <div className="informes-ocupacion-track" style={{ marginTop: "0.45rem" }}>
                  <div
                    className={`informes-ocupacion-fill ${
                      ocupacion > 100
                        ? "informes-ocupacion-fill--falta"
                        : ocupacion >= 80
                          ? "informes-ocupacion-fill--tard"
                          : "informes-ocupacion-fill--asist"
                    }`}
                    style={{ width: `${Math.min(ocupacion, 100)}%` }}
                  />
                </div>
              )}
            </div>
          </div>
        </section>

        <section className="informe-caja-panel">
          <div className="informes-panel-header">
            <h2>Aulas con mayor pendiente</h2>
            <p>Top por monto por cobrar</p>
          </div>
          {ranking.length === 0 ? (
            <div className="mantenedor-state">Sin aulas con movimiento.</div>
          ) : (
            <div className="informe-aulas-rank">
              {ranking.map((f, idx) => {
                const ancho = Math.max(((f.porCobrar || 0) / maxPorCobrar) * 100, f.porCobrar > 0 ? 4 : 0);
                return (
                  <div key={f.idAula} className="informe-aulas-rank-row">
                    <div className="informe-aulas-rank-meta">
                      <span className="informe-aulas-rank-pos">{idx + 1}</span>
                      <div className="informe-aulas-rank-text">
                        <strong title={f.aula}>{f.aula}</strong>
                        <em>
                          {f.alumnos} alum. · ocup. {f.ocupacion != null ? `${f.ocupacion}%` : "—"}
                        </em>
                      </div>
                      <span className="informe-aulas-rank-monto">{formatSoles(f.porCobrar)}</span>
                    </div>
                    <div className="informes-dist-track">
                      <div className="informes-dist-fill informes-ocupacion-fill--falta" style={{ width: `${ancho}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

function TablaAulas({ filas, totales }) {
  if (!filas?.length) {
    return <div className="mantenedor-state">No hay aulas para mostrar.</div>;
  }
  return (
    <div className="informe-tabla-outer">
      <table className="informe-asistencias-table">
        <thead>
          <tr>
            <th>AULA</th>
            <th>AFORO</th>
            <th>ALUMNOS</th>
            <th>OCUPACIÓN</th>
            <th>CANCELARON</th>
            <th>DEBEN</th>
            <th>INGRESO MES</th>
            <th>COBRADO</th>
            <th>POR COBRAR</th>
          </tr>
        </thead>
        <tbody>
          {filas.map((f) => (
            <tr key={f.idAula}>
              <td>{f.aula}</td>
              <td>{f.aforo}</td>
              <td>{f.alumnos}</td>
              <td>
                <BarraOcupacion pct={f.ocupacion} />
              </td>
              <td>{f.cancelaron}</td>
              <td>{f.deben}</td>
              <td>{formatSoles(f.ingresoMes)}</td>
              <td className="informes-num--ok">{formatSoles(f.cobrado)}</td>
              <td className="informes-num--warn">{formatSoles(f.porCobrar)}</td>
            </tr>
          ))}
        </tbody>
        {totales && (
          <tfoot>
            <tr>
              <td>
                <strong>TOTALES</strong>
              </td>
              <td>{totales.aforo}</td>
              <td>{totales.alumnos}</td>
              <td>
                <BarraOcupacion pct={totales.ocupacion} />
              </td>
              <td>{totales.cancelaron}</td>
              <td>{totales.deben}</td>
              <td>
                <strong>{formatSoles(totales.ingresoMes)}</strong>
              </td>
              <td>
                <strong>{formatSoles(totales.cobrado)}</strong>
              </td>
              <td>
                <strong>{formatSoles(totales.porCobrar)}</strong>
              </td>
            </tr>
          </tfoot>
        )}
      </table>
    </div>
  );
}

function MatrizCiclos({ matriz }) {
  const planes = matriz?.planes || [];
  const filas = matriz?.filas || [];
  if (!filas.length || !planes.length) {
    return <div className="mantenedor-state">Sin desglose de ciclos para el periodo.</div>;
  }
  return (
    <div className="informe-tabla-outer">
      <table className="informe-asistencias-table informe-matriz-ciclos">
        <thead>
          <tr>
            <th className="sticky-izq">AULA</th>
            {planes.map((p) => (
              <th key={p}>{p}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {filas.map((f) => (
            <tr key={f.idAula}>
              <td className="sticky-izq">{f.aula}</td>
              {planes.map((p) => (
                <td key={p}>{f.porPlan?.[p] || ""}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function InformeAulasPage() {
  const ini = periodoInicial();
  const [anio, setAnio] = useState(ini.anio);
  const [mes, setMes] = useState(ini.mes);
  const [idAula, setIdAula] = useState("");
  const [aulas, setAulas] = useState([]);
  const [tabActiva, setTabActiva] = useState("aulas");
  const [data, setData] = useState(null);
  const [cargando, setCargando] = useState(false);
  const [exportando, setExportando] = useState(false);
  const [error, setError] = useState("");
  const [consultado, setConsultado] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/mensualidades/catalogos/");
        const json = await parseJsonResponse(res);
        if (res.ok) setAulas(json.data?.aulas || []);
      } catch {
        setAulas([]);
      }
    })();
  }, []);

  const cargar = useCallback(async () => {
    try {
      setCargando(true);
      setError("");
      const params = new URLSearchParams({ anio, mes });
      if (idAula) params.set("idAula", idAula);
      const res = await fetch(`/api/informes/aulas/?${params}`);
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
  }, [anio, mes, idAula]);

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
      await exportarInformeAulasExcel({
        filas: data.filas,
        totales: data.totales,
        meta: {
          periodo: data.periodo,
          aula: aulas.find((a) => String(a.IDAULA) === String(idAula))?.NOMBRE || "",
        },
      });
    } catch (err) {
      setError(err.message || "No se pudo exportar");
    } finally {
      setExportando(false);
    }
  }, [data, aulas, idAula]);

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
          <label>
            Aula
            <select value={idAula} onChange={(e) => setIdAula(e.target.value)}>
              <option value="">TODAS LAS AULAS</option>
              {aulas.map((a) => (
                <option key={a.IDAULA} value={a.IDAULA}>
                  {a.NOMBRE}
                </option>
              ))}
            </select>
          </label>
          <div className="informes-filtros-acciones">
            {hayDatos && (
              <button type="button" className="btn-secondary" onClick={exportarExcel} disabled={exportando}>
                <FontAwesomeIcon icon={faFileExcel} spin={exportando} />
                {exportando ? "Exportando..." : "Exportar Excel"}
              </button>
            )}
          </div>
        </div>
        <p className="informes-filtro-nota">
          Ingreso del mes = suma de mensualidades de alumnos activos del aula. Cobrado = mensualidades ya canceladas
          (pagado ≥ monto). Sin utilidad docente: en Vita no hay pago por aula.
        </p>
      </div>

      {error && <div className="mantenedor-state error">{error}</div>}

      {cargando ? (
        <div className="mantenedor-state">
          <FontAwesomeIcon icon={faSpinner} spin /> Generando informe...
        </div>
      ) : consultado && !hayDatos ? (
        <div className="mantenedor-state">No hay datos para los filtros seleccionados.</div>
      ) : hayDatos ? (
        <div className="ui-tabs-panel">
          <div className="ui-tabs" role="tablist" aria-label="Vista del informe de aulas">
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
              <IndicadoresAulas resumen={data.resumen} filas={data.filas} />
            )}
            {tabActiva === "aulas" && <TablaAulas filas={data.filas} totales={data.totales} />}
            {tabActiva === "ciclos" && <MatrizCiclos matriz={data.matrizCiclos} />}
          </div>
        </div>
      ) : null}
    </div>
  );
}

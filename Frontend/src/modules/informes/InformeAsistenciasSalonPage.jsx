import { useCallback, useEffect, useMemo, useState } from "react";
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
import { exportarInformeEstudiantesExcel } from "./exportarEstudiantesExcel";

const TABS = [
  { id: "indicadores", label: "Indicadores", icon: faChartColumn },
  { id: "estudiantes", label: "Estudiantes", icon: faUsers },
];

const PIE_COLORS = ["#1e9e5a", "#6a42e5", "#2563eb", "#c7891b", "#d23b3b", "#0891b2", "#7c3aed", "#db2777"];

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
        <p>Distribución del listado filtrado</p>
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
        <p>Distribución circular del listado filtrado</p>
      </div>
      <div className="informes-pie-wrap">
        <div
          className="informes-pie"
          style={{ background: `conic-gradient(${gradient})` }}
          role="img"
          aria-label={titulo}
        >
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

function DistBarrasDistrito({ items, total }) {
  if (!items?.length) {
    return (
      <section className="informes-chart-side informes-chart-side--full">
        <div className="informes-panel-header">
          <h2>Por distrito</h2>
          <p>Sin datos</p>
        </div>
      </section>
    );
  }
  const maxCant = Math.max(...items.map((i) => i.cantidad), 1);
  return (
    <section className="informes-chart-side informes-chart-side--full">
      <div className="informes-panel-header">
        <h2>Por distrito</h2>
        <p>Comparativo en barras verticales</p>
      </div>
      <div className="informes-chart-bars informes-chart-bars--distrito">
        {items.map((item, idx) => {
          const pct = total > 0 ? Math.round((item.cantidad / total) * 100) : 0;
          const altura = Math.max(Math.round((item.cantidad / maxCant) * 100), item.cantidad > 0 ? 8 : 0);
          const color = PIE_COLORS[idx % PIE_COLORS.length];
          return (
            <div key={item.etiqueta} className="informes-chart-col" title={`${item.etiqueta}: ${item.cantidad}`}>
              <div className="informes-chart-bar-wrap">
                <div
                  className="informes-chart-bar"
                  style={{ height: `${altura}%`, background: color }}
                >
                  {altura > 18 && <span>{pct}%</span>}
                </div>
              </div>
              <span className="informes-chart-label">{item.etiqueta}</span>
              <span className="informes-chart-pct-small">{item.cantidad}</span>
            </div>
          );
        })}
      </div>
    </section>
  );
}

function IndicadoresEstudiantes({ resumen }) {
  if (!resumen) return null;
  const total = resumen.total || 0;
  const kpis = [
    { key: "total", valor: total, etiqueta: "Estudiantes", tono: "primary" },
    { key: "act", valor: resumen.activos || 0, etiqueta: "Activos", tono: "asist" },
    { key: "ret", valor: resumen.retirados || 0, etiqueta: "Retirados", tono: "falta" },
  ];

  return (
    <div className="informes-dashboard">
      <div className="informes-kpi-row informes-kpi-row--3">
        {kpis.map((k) => (
          <div key={k.key} className={`informes-kpi informes-kpi--${k.tono}`}>
            <span className="informes-kpi-valor">{k.valor}</span>
            <span className="informes-kpi-etiqueta">{k.etiqueta}</span>
          </div>
        ))}
      </div>
      <div className="informes-resumen-panel">
        <div className="informes-resumen-grid">
          <DistCircular titulo="¿De qué manera se enteraron?" items={resumen.porComoEntero} total={total} />
          <DistList titulo="Por plan / ciclo" items={resumen.porPlan} total={total} />
        </div>
        <div className="informes-resumen-grid informes-resumen-grid--distrito">
          <DistBarrasDistrito items={resumen.porDistrito} total={total} />
        </div>
      </div>
    </div>
  );
}

function TablaEstudiantes({ filas }) {
  if (!filas?.length) {
    return <div className="mantenedor-state">No hay estudiantes para mostrar.</div>;
  }
  return (
    <div className="informe-tabla-outer">
      <table className="informe-asistencias-table informe-estudiantes-table">
        <thead>
          <tr>
            <th className="col-num sticky-izq">N°</th>
            <th className="col-nombre sticky-izq sticky-izq--ultimo">NOMBRES Y APELLIDOS</th>
            <th>DNI</th>
            <th>TUTOR</th>
            <th>AULA</th>
            <th>PLAN / CICLO</th>
            <th>CÓMO SE ENTERÓ</th>
            <th>DISTRITO</th>
            <th>ESTADO</th>
          </tr>
        </thead>
        <tbody>
          {filas.map((fila) => (
            <tr key={fila.idusuario || fila.numero}>
              <td className="col-num sticky-izq">{fila.numero}</td>
              <td className="col-nombre sticky-izq sticky-izq--ultimo" title={fila.nombres}>
                {fila.nombres}
              </td>
              <td>{fila.dni || "—"}</td>
              <td>{fila.tutora || "—"}</td>
              <td>{fila.aula || "—"}</td>
              <td>{fila.ciclo || "—"}</td>
              <td>{fila.comoEntero || "—"}</td>
              <td>{fila.distrito || "—"}</td>
              <td>{fila.estado || "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function InformeAsistenciasSalonPage() {
  const [buscar, setBuscar] = useState("");
  const [idPlan, setIdPlan] = useState("");
  const [idAula, setIdAula] = useState("");
  const [idTutor, setIdTutor] = useState("");
  const [estado, setEstado] = useState("Activo");
  const [planes, setPlanes] = useState([]);
  const [aulas, setAulas] = useState([]);
  const [tutores, setTutores] = useState([]);
  const [tabActiva, setTabActiva] = useState("estudiantes");
  const [resumen, setResumen] = useState(null);
  const [filas, setFilas] = useState([]);
  const [total, setTotal] = useState(0);
  const [cargando, setCargando] = useState(false);
  const [exportando, setExportando] = useState(false);
  const [error, setError] = useState("");
  const [consultado, setConsultado] = useState(false);

  const aulasFiltradas = useMemo(() => {
    if (!idTutor) return aulas;
    return aulas.filter((a) => !a.IDTUTOR || String(a.IDTUTOR) === String(idTutor));
  }, [aulas, idTutor]);

  const cargar = useCallback(async () => {
    try {
      setCargando(true);
      setError("");
      const params = new URLSearchParams();
      if (idAula) params.set("idAula", idAula);
      if (buscar.trim()) params.set("buscar", buscar.trim());
      if (idPlan) params.set("idPlan", idPlan);
      if (idTutor) params.set("idTutor", idTutor);
      if (estado) params.set("estado", estado);

      const res = await fetch(`/api/informes/estudiantes/?${params}`);
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "Error al generar el informe");

      setResumen(data.resumen || null);
      setFilas(data.filas || []);
      setTotal(data.total || 0);
      setConsultado(true);
    } catch (err) {
      setError(err.message);
      setResumen(null);
      setFilas([]);
      setTotal(0);
    } finally {
      setCargando(false);
    }
  }, [buscar, idPlan, idAula, idTutor, estado]);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/mensualidades/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setPlanes(data.data?.planes || []);
          setAulas(data.data?.aulas || []);
          setTutores(data.data?.tutores || []);
        }
      } catch {
        setPlanes([]);
        setAulas([]);
        setTutores([]);
      }
    })();
  }, []);

  useEffect(() => {
    if (idAula && idTutor) {
      const aula = aulas.find((a) => String(a.IDAULA) === String(idAula));
      if (aula?.IDTUTOR && String(aula.IDTUTOR) !== String(idTutor)) {
        setIdAula("");
        setConsultado(false);
        setFilas([]);
      }
    }
  }, [idTutor, idAula, aulas]);

  const exportarExcel = useCallback(async () => {
    if (!filas.length) {
      setError("No hay datos para exportar.");
      return;
    }
    try {
      setExportando(true);
      const salon = aulas.find((a) => String(a.IDAULA) === String(idAula))?.NOMBRE || "";
      const tutor = tutores.find((t) => String(t.IDTUTOR) === String(idTutor))?.NOMBRE || "";
      const plan = planes.find((p) => String(p.IDPLAN) === String(idPlan))?.NOMBRE || "";
      const estadoLabel =
        estado === "Activo" ? "Activos" : estado === "Retirado" ? "Retirados" : "Todos";
      await exportarInformeEstudiantesExcel({
        filas,
        meta: {
          salon: salon || (idAula ? "Salón filtrado" : "Todos"),
          tutor: tutor || "Todos",
          plan: plan || "Todos",
          estado: estadoLabel,
          buscar: buscar.trim() || "",
        },
      });
    } catch (err) {
      setError(err.message || "No se pudo exportar");
    } finally {
      setExportando(false);
    }
  }, [filas, aulas, tutores, planes, idAula, idTutor, idPlan, estado, buscar]);

  const hayDatos = consultado && total > 0;

  return (
    <div className="informes-page">
      <div className="mantenedor-card informes-filtros">
        <div className="informes-filtros-grid informes-filtros-grid--estudiantes">
          <label>
            Salón
            <select value={idAula} onChange={(e) => setIdAula(e.target.value)}>
              <option value="">TODOS LOS SALONES</option>
              {aulasFiltradas.map((a) => (
                <option key={a.IDAULA} value={a.IDAULA}>
                  {a.NOMBRE}
                </option>
              ))}
            </select>
          </label>
          <label>
            Tutor
            <select value={idTutor} onChange={(e) => setIdTutor(e.target.value)}>
              <option value="">TODOS LOS TUTORES</option>
              {tutores.map((t) => (
                <option key={t.IDTUTOR} value={t.IDTUTOR}>
                  {t.NOMBRE}
                </option>
              ))}
            </select>
          </label>
          <label>
            Tipo de plan
            <select value={idPlan} onChange={(e) => setIdPlan(e.target.value)}>
              <option value="">TODOS LOS PLANES</option>
              {planes.map((p) => (
                <option key={p.IDPLAN} value={p.IDPLAN}>
                  {p.NOMBRE}
                </option>
              ))}
            </select>
          </label>
          <label>
            Estado
            <select value={estado} onChange={(e) => setEstado(e.target.value)}>
              <option value="">TODOS LOS ESTADOS</option>
              <option value="Activo">Activos</option>
              <option value="Retirado">Retirados</option>
            </select>
          </label>
          <label className="informes-filtro-buscar">
            Buscar
            <input
              type="text"
              placeholder="BUSCAR DNI O NOMBRE"
              value={buscar}
              onChange={(e) => setBuscar(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && cargar()}
            />
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
      </div>

      {error && <div className="mantenedor-state error">{error}</div>}

      {cargando ? (
        <div className="mantenedor-state">
          <FontAwesomeIcon icon={faSpinner} spin /> Generando informe...
        </div>
      ) : consultado && total === 0 ? (
        <div className="mantenedor-state">No hay estudiantes para los filtros seleccionados.</div>
      ) : hayDatos ? (
        <div className="ui-tabs-panel">
          <div className="ui-tabs" role="tablist" aria-label="Vista del informe de estudiantes">
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
              <IndicadoresEstudiantes resumen={resumen} />
            ) : (
              <TablaEstudiantes filas={filas} />
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

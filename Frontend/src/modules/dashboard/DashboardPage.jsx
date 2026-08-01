import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowRight,
  faSpinner,
} from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import DashboardKpi from "./DashboardKpi";
import DashboardDonutChart from "./DashboardDonutChart";
import DashboardBarChart from "./DashboardBarChart";
import DashboardAsistenciaChart from "./DashboardAsistenciaChart";
import DashboardEstudianteExamen from "./DashboardEstudianteExamen";
import "../../styles/mantenedor.css";
import "./dashboard.css";

function formatMoney(value) {
  return new Intl.NumberFormat("es-PE", {
    style: "currency",
    currency: "PEN",
    maximumFractionDigits: 0,
  }).format(Number(value || 0));
}

function Shortcuts({ acciones, onNavigate }) {
  if (!acciones?.length) return null;
  return (
    <div className="dash-shortcuts">
      {acciones.map((a) => (
        <button
          key={a.page}
          type="button"
          className="dash-shortcut"
          onClick={() => onNavigate(a.page)}
        >
          {a.label}
          <FontAwesomeIcon icon={faArrowRight} />
        </button>
      ))}
    </div>
  );
}

function PanelEstudiantes({ estudiantes, admin = false }) {
  if (!estudiantes) return null;

  const segments = admin
    ? [
        { key: "alDia", valor: estudiantes.alDia ?? 0, etiqueta: "Al día", tono: "asist" },
        { key: "deuda", valor: estudiantes.conDeuda ?? 0, etiqueta: "Con deuda", tono: "warn" },
        { key: "ret", valor: estudiantes.retirados ?? 0, etiqueta: "Retirados", tono: "muted" },
      ]
    : [
        { key: "act", valor: estudiantes.activos ?? 0, etiqueta: "Activos", tono: "primary" },
        { key: "ret", valor: estudiantes.retirados ?? 0, etiqueta: "Retirados", tono: "muted" },
      ];

  return (
    <div className="dash-panel">
      <div className="dash-panel-head">
        <h2>Estudiantes</h2>
      </div>
      <DashboardDonutChart
        segments={segments.filter((s) => s.valor > 0)}
        centerValue={estudiantes.activos ?? 0}
        centerLabel="Activos"
      />
    </div>
  );
}

function PanelPagosMensuales({ pagos }) {
  if (!pagos) return null;
  const items = pagos.mensuales || [];

  return (
    <div className="dash-panel">
      <div className="dash-panel-head">
        <h2>Pagos mensuales</h2>
        <span className="dash-panel-total">{formatMoney(pagos.totalPeriodo)}</span>
      </div>
      <DashboardBarChart items={items} format="money" emptyLabel="Sin pagos en el periodo" />
    </div>
  );
}

function PanelAsistencia({ resumen, hoy }) {
  return (
    <div className="dash-panel">
      <div className="dash-panel-head">
        <h2>Asistencia del mes</h2>
      </div>
      <DashboardAsistenciaChart resumen={resumen} />
      <div className="dash-asist-stats">
        <div className="dash-asist-stat">
          <strong>{hoy?.presente ?? 0}</strong>
          <span>Presentes hoy</span>
        </div>
        <div className="dash-asist-stat">
          <strong>{hoy?.tarde ?? 0}</strong>
          <span>Tardanzas hoy</span>
        </div>
        <div className="dash-asist-stat">
          <strong>{resumen?.totalEstudiantes ?? 0}</strong>
          <span>Estudiantes</span>
        </div>
      </div>
    </div>
  );
}

function DashboardAdmin({ data }) {
  const k = data.kpis || {};

  const kpis = [
    { key: "est", valor: k.estudiantesActivos ?? 0, etiqueta: "Estudiantes", icon: "estudiantes", tono: "primary" },
    { key: "deuda", valor: formatMoney(k.deudaTotal), etiqueta: "Deuda total", icon: "deuda", tono: "danger" },
    { key: "cobrado", valor: formatMoney(k.pagosMes), etiqueta: "Cobrado", icon: "cobrado", tono: "money" },
    { key: "conDeuda", valor: k.mensualidadesConDeuda ?? 0, etiqueta: "Con deuda", icon: "conDeuda", tono: "warn" },
  ];

  return (
    <>
      <DashboardKpi items={kpis} />
      <div className="dash-layout dash-layout--charts">
        <PanelEstudiantes estudiantes={data.graficos?.estudiantes} admin />
        <PanelPagosMensuales pagos={data.graficos?.pagos} />
      </div>
      <PanelAsistencia resumen={data.asistenciaMes} hoy={data.asistenciasHoy} />
    </>
  );
}

function DashboardDocente({ data }) {
  const k = data.kpis || {};
  const hoy = data.asistenciasHoy || {};

  const kpis = [
    { key: "est", valor: k.estudiantesActivos ?? 0, etiqueta: "Estudiantes", icon: "estudiantes", tono: "primary" },
    { key: "hoy", valor: k.asistenciasHoy ?? 0, etiqueta: "Marcas hoy", icon: "asistencia", tono: "asist" },
    { key: "pct", valor: `${k.asistenciaPct ?? 0}%`, etiqueta: "Asistencia mes", icon: "presentes", tono: "asist" },
    { key: "faltas", valor: k.faltasMes ?? 0, etiqueta: "Faltas mes", icon: "deuda", tono: "falta" },
  ];

  return (
    <>
      <DashboardKpi items={kpis} />
      <div className="dash-layout">
        <PanelAsistencia resumen={data.asistenciaMes} hoy={hoy} />
        <div className="dash-panel">
          <div className="dash-panel-head">
            <h2>Asistencias de hoy</h2>
          </div>
          <DashboardBarChart
            items={[
              { key: "p", etiqueta: "Presente", valor: hoy.presente ?? 0 },
              { key: "t", etiqueta: "Tarde", valor: hoy.tarde ?? 0 },
              { key: "f", etiqueta: "Falta", valor: hoy.falta ?? 0 },
            ]}
            format="number"
            emptyLabel="Sin marcas registradas hoy"
          />
        </div>
      </div>
    </>
  );
}

export default function DashboardPage({ role, idusuario, onChangePage }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError("");
      try {
        const uid = idusuario || localStorage.getItem("idusuario");
        const res = await fetch(`/api/dashboard/?idusuario=${encodeURIComponent(uid || "")}`);
        const json = await parseJsonResponse(res);
        if (!res.ok) throw new Error(json.error || "No se pudo cargar el dashboard");
        if (!cancelled) setData(json.data);
      } catch (err) {
        if (!cancelled) setError(err.message || "Error al cargar");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, [idusuario]);

  const rol = data?.rol || role;
  const esAdmin = rol === "administrador" || rol === "admin";
  const esDocente = rol === "docente" || rol === "secretario";
  const esEstudiante = rol === "estudiante" || data?.idtipousuario === "1";

  if (loading) {
    return (
      <div className="dashboard-page mantenedor-page">
        <div className="dash-loading">
          <FontAwesomeIcon icon={faSpinner} spin />
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dashboard-page mantenedor-page">
        <div className="dash-error">{error}</div>
      </div>
    );
  }

  if (esEstudiante && !esAdmin && !esDocente) {
    return (
      <div className="dashboard-page mantenedor-page">
        <DashboardEstudianteExamen data={data} onNavigate={onChangePage} />
      </div>
    );
  }

  if (!esAdmin && !esDocente) {
    return null;
  }

  return (
    <div className="dashboard-page mantenedor-page">
      <header className="dash-head">
        <h1>Dashboard</h1>
        <Shortcuts acciones={data.acciones} onNavigate={onChangePage} />
      </header>

      {esAdmin && <DashboardAdmin data={data} />}
      {esDocente && !esAdmin && <DashboardDocente data={data} />}
    </div>
  );
}

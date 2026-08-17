import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faFilter,
  faRotateLeft,
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

function fechaLocalIso(fecha) {
  const offset = fecha.getTimezoneOffset() * 60000;
  return new Date(fecha.getTime() - offset).toISOString().slice(0, 10);
}

function rangoInicial() {
  const hoy = new Date();
  return {
    fechaDesde: fechaLocalIso(new Date(hoy.getFullYear(), hoy.getMonth(), 1)),
    fechaHasta: fechaLocalIso(hoy),
    estadoEstudiante: "Activo",
  };
}

function DashboardFiltros({ filtros, onChange, onSubmit, onReset, loading }) {
  return (
    <form className="dash-filtros" onSubmit={onSubmit}>
      <label className="dash-filtro-campo">
        <span>Fecha inicio</span>
        <input
          type="date"
          value={filtros.fechaDesde}
          max={filtros.fechaHasta || undefined}
          onChange={(event) => onChange({ ...filtros, fechaDesde: event.target.value })}
          required
        />
      </label>
      <label className="dash-filtro-campo">
        <span>Fecha final</span>
        <input
          type="date"
          value={filtros.fechaHasta}
          min={filtros.fechaDesde || undefined}
          onChange={(event) => onChange({ ...filtros, fechaHasta: event.target.value })}
          required
        />
      </label>
      <label className="dash-filtro-campo">
        <span>Estado del estudiante</span>
        <select
          value={filtros.estadoEstudiante}
          onChange={(event) => onChange({ ...filtros, estadoEstudiante: event.target.value })}
        >
          <option value="Activo">Activos</option>
          <option value="Retirado">Retirados</option>
          <option value="Todos">Todos</option>
        </select>
      </label>
      <div className="dash-filtro-acciones">
        <button className="dash-filtro-btn dash-filtro-btn--primary" type="submit" disabled={loading}>
          <FontAwesomeIcon icon={loading ? faSpinner : faFilter} spin={loading} />
          Filtrar
        </button>
        <button className="dash-filtro-btn" type="button" onClick={onReset} disabled={loading}>
          <FontAwesomeIcon icon={faRotateLeft} />
          Este mes
        </button>
      </div>
    </form>
  );
}

function PanelEstudiantes({ estudiantes, admin = false }) {
  if (!estudiantes) return null;

  const segments = admin
    ? [
        { key: "alDia", valor: estudiantes.alDia ?? 0, etiqueta: "Sin deuda", tono: "asist" },
        { key: "deuda", valor: estudiantes.conDeuda ?? 0, etiqueta: "Con deuda", tono: "warn" },
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
        centerValue={estudiantes.seleccionados ?? estudiantes.activos ?? 0}
        centerLabel={estudiantes.etiquetaSeleccion || "Estudiantes"}
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
        <h2>Pagos del periodo</h2>
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
        <h2>Asistencia del periodo</h2>
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
    { key: "deuda", valor: formatMoney(k.deudaTotal), etiqueta: "Deuda total actual", icon: "deuda", tono: "danger" },
    { key: "deudaPeriodo", valor: formatMoney(k.deudaPeriodo), etiqueta: "Deuda cuotas del rango", icon: "deuda", tono: "warn" },
    { key: "cobradoTotal", valor: formatMoney(k.cobradoTotal), etiqueta: "Cobrado histórico", icon: "cobrado", tono: "money" },
    { key: "cobrado", valor: formatMoney(k.pagosMes), etiqueta: "Cobrado en el rango", icon: "cobrado", tono: "primary" },
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
    { key: "pct", valor: `${k.asistenciaPct ?? 0}%`, etiqueta: "Asistencia periodo", icon: "presentes", tono: "asist" },
    { key: "faltas", valor: k.faltasMes ?? 0, etiqueta: "Faltas periodo", icon: "deuda", tono: "falta" },
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
  const [filtros, setFiltros] = useState(rangoInicial);
  const [filtrosAplicados, setFiltrosAplicados] = useState(rangoInicial);
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
        const params = new URLSearchParams({
          idusuario: uid || "",
          fecha_desde: filtrosAplicados.fechaDesde,
          fecha_hasta: filtrosAplicados.fechaHasta,
          estado_estudiante: filtrosAplicados.estadoEstudiante,
        });
        const res = await fetch(`/api/dashboard/?${params.toString()}`);
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
  }, [idusuario, filtrosAplicados]);

  const aplicarFiltros = (event) => {
    event.preventDefault();
    if (filtros.fechaDesde > filtros.fechaHasta) {
      setError("La fecha inicial no puede ser mayor que la fecha final.");
      return;
    }
    setFiltrosAplicados({ ...filtros });
  };

  const restablecerFiltros = () => {
    const inicial = rangoInicial();
    setFiltros(inicial);
    setFiltrosAplicados(inicial);
  };

  const rol = data?.rol || role;
  const esAdmin = rol === "administrador" || rol === "admin";
  const esDocente = rol === "docente" || rol === "trabajador" || rol === "secretario";
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
      <DashboardFiltros
        filtros={filtros}
        onChange={setFiltros}
        onSubmit={aplicarFiltros}
        onReset={restablecerFiltros}
        loading={loading}
      />

      {esAdmin && <DashboardAdmin data={data} />}
      {esDocente && !esAdmin && <DashboardDocente data={data} />}
    </div>
  );
}

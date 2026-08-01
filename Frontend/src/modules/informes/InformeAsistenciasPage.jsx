import { useCallback, useEffect, useMemo, useRef, useState } from "react";

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

import { faChartColumn, faFileExcel, faSpinner, faTable } from "@fortawesome/free-solid-svg-icons";

import { parseJsonResponse } from "../../utils/api";

import { inputToDb, dbToView, primerDiaMesInput, ultimoDiaMesInput } from "../../utils/fecha";

import { exportarInformeAsistenciasExcel } from "./exportarExcel";

import InformeResumenGraficos from "./InformeResumenGraficos";

import InformeAsistenciasTabla from "./InformeAsistenciasTabla";

import {
  TIPOS_MARCA_INFORME,
  calcularResumenInforme,
  filtrarFilasPorMarca,
  renumerarFilasInforme,
} from "./informeAsistenciasUtils";

import "../../styles/mantenedor.css";

import "./informes.css";



const TABS = [

  { id: "indicadores", label: "Indicadores", icon: faChartColumn },

  { id: "asistencias", label: "Asistencias", icon: faTable },

];



export default function InformeAsistenciasPage() {

  const [fechaDesde, setFechaDesde] = useState(primerDiaMesInput);

  const [fechaHasta, setFechaHasta] = useState(() => ultimoDiaMesInput());

  const [buscar, setBuscar] = useState("");

  const [idPlan, setIdPlan] = useState("");

  const [estado, setEstado] = useState("Activo");

  const [tipoMarca, setTipoMarca] = useState("");

  const [planes, setPlanes] = useState([]);

  const [tabActiva, setTabActiva] = useState("indicadores");

  const [resumen, setResumen] = useState(null);

  const [filas, setFilas] = useState([]);

  const [dias, setDias] = useState([]);

  const [total, setTotal] = useState(0);

  const [cargando, setCargando] = useState(false);

  const [exportando, setExportando] = useState(false);

  const [error, setError] = useState("");

  const [consultado, setConsultado] = useState(false);

  const [rangoConsultado, setRangoConsultado] = useState(null);

  const cargaInicialHecha = useRef(false);



  const cargar = useCallback(async () => {

    const desde = inputToDb(fechaDesde);

    const hasta = inputToDb(fechaHasta);

    if (!desde || !hasta) {

      setError("Selecciona un rango de fechas válido.");

      return;

    }

    if (desde > hasta) {

      setError("La fecha desde no puede ser mayor que la fecha hasta.");

      return;

    }



    try {

      setCargando(true);

      setError("");

      const params = new URLSearchParams({ fechaDesde: desde, fechaHasta: hasta });

      if (buscar.trim()) params.set("buscar", buscar.trim());

      if (idPlan) params.set("idPlan", idPlan);

      if (estado) params.set("estado", estado);

      const res = await fetch(`/api/informes/asistencias/?${params}`);

      const data = await parseJsonResponse(res);

      if (!res.ok) throw new Error(data.error || "Error al generar el informe");

      setResumen(data.resumen || null);

      setFilas(data.filas || []);

      setDias(data.dias || []);

      setTotal(data.total || 0);

      setRangoConsultado({ desde, hasta });

      setConsultado(true);

    } catch (err) {

      setError(err.message);

      setResumen(null);

      setFilas([]);

      setDias([]);

      setTotal(0);

      setRangoConsultado(null);

    } finally {

      setCargando(false);

    }

  }, [fechaDesde, fechaHasta, buscar, idPlan, estado]);



  useEffect(() => {

    (async () => {

      try {

        const res = await fetch("/api/mensualidades/catalogos/");

        const data = await parseJsonResponse(res);

        if (res.ok) setPlanes(data.data?.planes || []);

      } catch {

        setPlanes([]);

      }

    })();

  }, []);

  useEffect(() => {
    if (cargaInicialHecha.current) return;
    cargaInicialHecha.current = true;
    cargar();
  }, [cargar]);



  const filasVisibles = useMemo(
    () => renumerarFilasInforme(filtrarFilasPorMarca(filas, tipoMarca)),
    [filas, tipoMarca],
  );

  const resumenVisible = useMemo(
    () => (filasVisibles.length ? calcularResumenInforme(filasVisibles) : resumen),
    [filasVisibles, resumen],
  );

  const totalVisible = filasVisibles.length;

  const exportarExcel = useCallback(async () => {
    const desdeDb = inputToDb(fechaDesde);
    const hastaDb = inputToDb(fechaHasta);

    if (!desdeDb || !hastaDb) {
      setError("Selecciona un rango de fechas válido.");
      return;
    }

    if (desdeDb > hastaDb) {
      setError("La fecha desde no puede ser mayor que la fecha hasta.");
      return;
    }

    const fechasCoinciden =
      rangoConsultado &&
      desdeDb === rangoConsultado.desde &&
      hastaDb === rangoConsultado.hasta;

    try {
      setExportando(true);
      setError("");

      let filasExport = filasVisibles;
      let diasExport = dias;

      if (!consultado || !fechasCoinciden || !diasExport.length) {
        const params = new URLSearchParams({ fechaDesde: desdeDb, fechaHasta: hastaDb });
        if (buscar.trim()) params.set("buscar", buscar.trim());
        if (idPlan) params.set("idPlan", idPlan);
        if (estado) params.set("estado", estado);

        const res = await fetch(`/api/informes/asistencias/?${params}`);
        const data = await parseJsonResponse(res);
        if (!res.ok) throw new Error(data.error || "Error al exportar");

        filasExport = renumerarFilasInforme(filtrarFilasPorMarca(data.filas || [], tipoMarca));
        diasExport = data.dias || [];
      }

      await exportarInformeAsistenciasExcel({
        filas: filasExport,
        dias: diasExport,
        fechaDesde: desdeDb,
        fechaHasta: hastaDb,
      });
    } catch (err) {
      setError(err.message);
    } finally {
      setExportando(false);
    }
  }, [
    fechaDesde,
    fechaHasta,
    buscar,
    idPlan,
    estado,
    tipoMarca,
    consultado,
    rangoConsultado,
    filasVisibles,
    dias,
  ]);



  const rangoLabel = useMemo(() => {
    if (!consultado || !rangoConsultado) return "";
    const periodo =
      rangoConsultado.desde === rangoConsultado.hasta
        ? dbToView(rangoConsultado.desde)
        : `${dbToView(rangoConsultado.desde)} – ${dbToView(rangoConsultado.hasta)}`;
    const base = `${periodo} · ${totalVisible} estudiante${totalVisible !== 1 ? "s" : ""}`;
    if (tipoMarca && totalVisible !== total) {
      return `${base} (filtrado de ${total})`;
    }
    return base;
  }, [consultado, rangoConsultado, totalVisible, total, tipoMarca]);

  const hayDatos = consultado && total > 0;
  const hayFilasVisibles = consultado && totalVisible > 0;



  return (

    <div className="informes-page">

      <div className="informes-header">

        <div>

          <h1>Informe de asistencias</h1>

          <p>

            {rangoLabel || "Consulta el resumen y el detalle de asistencias por estudiante."}

          </p>

        </div>

        {hayDatos && (

          <button type="button" className="btn-secondary" onClick={exportarExcel} disabled={exportando}>

            <FontAwesomeIcon icon={faFileExcel} spin={exportando} />

            {exportando ? "Exportando..." : "Exportar Excel"}

          </button>

        )}

      </div>



      <div className="mantenedor-card informes-filtros">

        <div className="informes-filtros-grid">

          <label>

            Desde

            <input type="date" value={fechaDesde} onChange={(e) => {
              const value = e.target.value;
              setFechaDesde(value);
              if (value && fechaHasta && value > fechaHasta) setFechaHasta(value);
            }} />

          </label>

          <label>

            Hasta

            <input type="date" value={fechaHasta} onChange={(e) => setFechaHasta(e.target.value)} />

          </label>

          <label>

            Tipo de plan

            <select value={idPlan} onChange={(e) => setIdPlan(e.target.value)}>

              <option value="">Todos</option>

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
              <option value="Activo">Activos</option>
              <option value="Retirado">Retirados</option>
              <option value="">Todos</option>
            </select>
          </label>

          <label>
            Tipo de marca
            <select value={tipoMarca} onChange={(e) => setTipoMarca(e.target.value)}>
              {TIPOS_MARCA_INFORME.map((op) => (
                <option key={op.value || "todas"} value={op.value}>
                  {op.label}
                </option>
              ))}
            </select>
          </label>

          <label className="informes-filtro-buscar">

            Buscar

            <input

              type="text"

              placeholder="DNI, nombre o aula..."

              value={buscar}

              onChange={(e) => setBuscar(e.target.value)}

              onKeyDown={(e) => e.key === "Enter" && cargar()}

            />

          </label>

          <button type="button" className="btn-primary informes-btn-generar" onClick={cargar} disabled={cargando}>

            {cargando ? (

              <>

                <FontAwesomeIcon icon={faSpinner} spin /> Generando...

              </>

            ) : (

              "Generar informe"

            )}

          </button>

        </div>

      </div>



      {error && <div className="mantenedor-state error">{error}</div>}



      {cargando ? (

        <div className="mantenedor-state">

          <FontAwesomeIcon icon={faSpinner} spin /> Generando informe...

        </div>

      ) : consultado && total === 0 ? (

        <div className="mantenedor-state">No hay estudiantes para el rango seleccionado.</div>

      ) : hayDatos && !hayFilasVisibles ? (

        <div className="mantenedor-state">
          No hay estudiantes con{" "}
          {TIPOS_MARCA_INFORME.find((op) => op.value === tipoMarca)?.label?.toLowerCase() || "ese tipo de marca"}{" "}
          en el período.
        </div>

      ) : hayFilasVisibles ? (
        <div className="ui-tabs-panel">
          <div className="ui-tabs" role="tablist" aria-label="Vista del informe">
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
              <InformeResumenGraficos resumen={resumenVisible} totalEstudiantes={totalVisible} />
            ) : (
              <InformeAsistenciasTabla filas={filasVisibles} dias={dias} />
            )}
          </div>
        </div>

      ) : null}



      <div className="informes-nota mantenedor-card">

        <p>

          Las marcas usan: A = presente, T = tardanza, F = falta, J = justificado.
          Las faltas (F) solo se generan en los días lectivos del plan asignado al estudiante, dentro
          del período de su mensualidad. Los días justificados (J) no cuentan como falta ni reducen
          el porcentaje de asistencia: el % se calcula como presentes ÷ (días que debió asistir − justificados).
          Los días que no corresponden al plan quedan vacíos y no cuentan en totales ni en el porcentaje.
          Los días anteriores al inicio de la mensualidad tampoco se marcan ni afectan el porcentaje.
          Las fechas futuras no se marcan como falta.
          La celda <strong>VENCE</strong> se resalta en amarillo (3 días o menos) o rojo (vencida).

        </p>

      </div>

    </div>

  );

}


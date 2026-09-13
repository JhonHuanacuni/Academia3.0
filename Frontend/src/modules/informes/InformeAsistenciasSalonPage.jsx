import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faChartColumn, faFileExcel, faSpinner, faTable } from "@fortawesome/free-solid-svg-icons";
import { parseJsonResponse } from "../../utils/api";
import { inputToDb, primerDiaMesInput, ultimoDiaMesInput } from "../../utils/fecha";
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

export default function InformeAsistenciasSalonPage() {
  const [fechaDesde, setFechaDesde] = useState(primerDiaMesInput);
  const [fechaHasta, setFechaHasta] = useState(() => ultimoDiaMesInput());
  const [buscar, setBuscar] = useState("");
  const [idPlan, setIdPlan] = useState("");
  const [idAula, setIdAula] = useState("");
  const [idTutor, setIdTutor] = useState("");
  const [estado, setEstado] = useState("Activo");
  const [tipoMarca, setTipoMarca] = useState("");
  const [planes, setPlanes] = useState([]);
  const [aulas, setAulas] = useState([]);
  const [tutores, setTutores] = useState([]);
  const [tabActiva, setTabActiva] = useState("asistencias");
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

  const aulasFiltradas = useMemo(() => {
    if (!idTutor) return aulas;
    return aulas.filter((a) => !a.IDTUTOR || String(a.IDTUTOR) === String(idTutor));
  }, [aulas, idTutor]);

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
    if (!idAula) {
      setError("Selecciona un salón para generar el informe.");
      return;
    }

    try {
      setCargando(true);
      setError("");
      const params = new URLSearchParams({
        fechaDesde: desde,
        fechaHasta: hasta,
        idAula,
      });
      if (buscar.trim()) params.set("buscar", buscar.trim());
      if (idPlan) params.set("idPlan", idPlan);
      if (idTutor) params.set("idTutor", idTutor);
      if (estado) params.set("estado", estado);

      const res = await fetch(`/api/informes/asistencias/?${params}`);
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "Error al generar el informe");

      setResumen(data.resumen || null);
      setFilas(data.filas || []);
      setDias(data.dias || []);
      setTotal(data.total || 0);
      setRangoConsultado({ desde, hasta, idAula });
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
  }, [fechaDesde, fechaHasta, buscar, idPlan, idAula, idTutor, estado]);

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
    if (cargaInicialHecha.current) return;
    if (!idAula && aulas.length) {
      setIdAula(aulas[0].IDAULA);
      return;
    }
    if (!idAula) return;
    cargaInicialHecha.current = true;
    cargar();
  }, [cargar, idAula, aulas]);

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
    if (!idAula) {
      setError("Selecciona un salón para exportar.");
      return;
    }

    try {
      setExportando(true);
      setError("");
      let filasExport = filasVisibles;
      let diasExport = dias;

      const fechasCoinciden =
        rangoConsultado &&
        desdeDb === rangoConsultado.desde &&
        hastaDb === rangoConsultado.hasta &&
        idAula === rangoConsultado.idAula;

      if (!consultado || !fechasCoinciden || !diasExport.length) {
        const params = new URLSearchParams({
          fechaDesde: desdeDb,
          fechaHasta: hastaDb,
          idAula,
        });
        if (buscar.trim()) params.set("buscar", buscar.trim());
        if (idPlan) params.set("idPlan", idPlan);
        if (idTutor) params.set("idTutor", idTutor);
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
    idAula,
    idTutor,
    estado,
    tipoMarca,
    consultado,
    rangoConsultado,
    filasVisibles,
    dias,
  ]);

  const hayDatos = consultado && total > 0;
  const hayFilasVisibles = consultado && totalVisible > 0;

  return (
    <div className="informes-page">
      <div className="mantenedor-card informes-filtros">
        <div className="informes-filtros-grid informes-filtros-grid--salon">
          <label>
            Desde
            <input
              type="date"
              value={fechaDesde}
              onChange={(e) => {
                const value = e.target.value;
                setFechaDesde(value);
                if (value && fechaHasta && value > fechaHasta) setFechaHasta(value);
              }}
            />
          </label>
          <label>
            Hasta
            <input type="date" value={fechaHasta} onChange={(e) => setFechaHasta(e.target.value)} />
          </label>
          <label>
            Salón
            <select value={idAula} onChange={(e) => setIdAula(e.target.value)}>
              <option value="">Seleccionar...</option>
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
              <option value="">Todos</option>
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
              placeholder="DNI, nombre..."
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
        <div className="mantenedor-state">No hay estudiantes en el salón seleccionado para el rango.</div>
      ) : hayDatos && !hayFilasVisibles ? (
        <div className="mantenedor-state">
          No hay estudiantes con{" "}
          {TIPOS_MARCA_INFORME.find((op) => op.value === tipoMarca)?.label?.toLowerCase() || "ese tipo de marca"}{" "}
          en el período.
        </div>
      ) : hayFilasVisibles ? (
        <div className="ui-tabs-panel">
          <div className="ui-tabs" role="tablist" aria-label="Vista del informe por salón">
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
          Solo se listan estudiantes con mensualidad vinculada al salón seleccionado. Las marcas usan: A =
          presente, T = tardanza, F = falta, J = justificado.
        </p>
      </div>
    </div>
  );
}

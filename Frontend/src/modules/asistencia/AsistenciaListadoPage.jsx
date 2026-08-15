import { useMemo } from "react";
import { useCrud } from "../../hooks/useCrud";
import { asistenciaListadoConfig } from "./asistenciaListado.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import { dbToInput, hoyInput, inputToDb } from "../../utils/fecha";
import "../../styles/mantenedor.css";

export default function AsistenciaListadoPage() {
  const cfg = asistenciaListadoConfig;
  const hoy = hoyInput();
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "HORAINICIO", direccion: "DESC" },
    filtrosIniciales: {
      fechaInicio: inputToDb(hoy),
      fechaFin: inputToDb(hoy),
    },
  });

  const fechaInicioInput = useMemo(() => {
    const f = crud.filtros.fechaInicio;
    return f ? dbToInput(String(f)) : hoy;
  }, [crud.filtros.fechaInicio, hoy]);

  const fechaFinInput = useMemo(() => {
    const f = crud.filtros.fechaFin;
    return f ? dbToInput(String(f)) : hoy;
  }, [crud.filtros.fechaFin, hoy]);

  const items = useMemo(
    () =>
      (crud.items || []).map((row) => ({
        ...row,
        ESTUDIANTE_NOMBRE: `${row.NOMBRE || ""} ${row.APELLIDO || ""}`.trim(),
      })),
    [crud.items],
  );

  const setFechaInicio = (value) => {
    const db = inputToDb(value);
    crud.setFiltro("fechaInicio", db);
    if (fechaFinInput && value && value > fechaFinInput) {
      crud.setFiltro("fechaFin", db);
    }
  };

  const setFechaFin = (value) => {
    const db = inputToDb(value);
    crud.setFiltro("fechaFin", db);
    if (fechaInicioInput && value && value < fechaInicioInput) {
      crud.setFiltro("fechaInicio", db);
    }
  };

  return (
    <div className="mantenedor-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} mostrarNuevo={false} />

      <div className="mantenedor-card">
        <div className="mantenedor-toolbar">
          <Toolbar
            buscar={crud.buscar}
            onBuscarChange={crud.onBuscarChange}
            placeholder="Buscar por DNI o nombre..."
          />
          <label className="toolbar-date">
            <span>Fecha inicio</span>
            <input
              type="date"
              value={fechaInicioInput}
              onChange={(e) => setFechaInicio(e.target.value)}
            />
          </label>
          <label className="toolbar-date">
            <span>Fecha fin</span>
            <input
              type="date"
              value={fechaFinInput}
              onChange={(e) => setFechaFin(e.target.value)}
            />
          </label>
        </div>

        <DataTable
          columnas={cfg.columnas}
          items={items}
          pk={cfg.pk}
          orden={crud.orden}
          loading={crud.loading}
          error={crud.error}
          onReintentar={crud.listar}
          pagina={crud.pagina}
          tamanio={crud.tamanio}
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>
    </div>
  );
}

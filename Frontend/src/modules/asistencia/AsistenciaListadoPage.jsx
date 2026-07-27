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
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "HORAINICIO", direccion: "DESC" },
    filtrosIniciales: { fecha: inputToDb(hoyInput()) },
  });

  const fechaInput = useMemo(() => {
    const f = crud.filtros.fecha;
    return f ? dbToInput(String(f)) : hoyInput();
  }, [crud.filtros.fecha]);

  const items = useMemo(
    () =>
      (crud.items || []).map((row) => ({
        ...row,
        ESTUDIANTE_NOMBRE: `${row.NOMBRE || ""} ${row.APELLIDO || ""}`.trim(),
      })),
    [crud.items],
  );

  const columnas = cfg.columnas.map((col) =>
    col.campo === "ESTUDIANTE_NOMBRE"
      ? { ...col, campo: "ESTUDIANTE_NOMBRE" }
      : col,
  );

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
            <span>Fecha</span>
            <input
              type="date"
              value={fechaInput}
              onChange={(e) => crud.setFiltro("fecha", inputToDb(e.target.value))}
            />
          </label>
        </div>

        <DataTable
          columnas={columnas}
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

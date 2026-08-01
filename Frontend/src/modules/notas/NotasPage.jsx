import { useState } from "react";
import { useCrud } from "../../hooks/useCrud";
import { notasConfig } from "./notas.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import NotasImportForm from "./NotasImportForm";
import NotasVerModal from "./NotasVerModal";
import "../../styles/mantenedor.css";
import "./notas.css";

export default function NotasPage() {
  const cfg = notasConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHA_EXAMEN", direccion: "DESC" },
    filtrosIniciales: {},
  });

  const [vista, setVista] = useState("lista");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [verId, setVerId] = useState(null);

  const abrirImportar = () => setVista("importar");

  const volverLista = async () => {
    setVista("lista");
    await crud.listar();
  };

  const abrirVer = (row) => setVerId(row[cfg.pk]);

  const abrirEliminar = (row) => {
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar la importación «${row.NOMBRE_ARCHIVO}»? Se borrarán todas las notas asociadas.`,
    });
  };

  const handleConfirmEliminar = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      const mensaje = await crud.eliminar(confirm.id);
      setToast({ mensaje, tipo: "success" });
      setConfirm(null);
      await crud.listar();
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setConfirmando(false);
    }
  };

  if (vista === "importar") {
    return (
      <div className="mantenedor-page form-page">
        <PageHeader
          modulo={cfg.modulo}
          listado={cfg.titulo}
          vista="Importar notas"
          titulo="Importar notas"
          mostrarNuevo={false}
          onListadoClick={volverLista}
        />
        <NotasImportForm
          onCancel={volverLista}
          onSuccess={(mensaje) => {
            setToast({ mensaje, tipo: "success" });
            volverLista();
          }}
        />
        {toast && (
          <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
        )}
      </div>
    );
  }

  return (
    <div className="mantenedor-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} onNuevo={abrirImportar} nuevoEtiqueta="Importar" />

      <div className="mantenedor-card">
        <Toolbar
          buscar={crud.buscar}
          onBuscarChange={crud.onBuscarChange}
          placeholder="Buscar archivo, salón, importador..."
          filtros={[
            {
              key: "tipo",
              etiqueta: "Tipo",
              value: crud.filtros.tipo || "",
              opciones: [
                { value: "40", label: "40 preguntas" },
                { value: "100", label: "100 preguntas" },
              ],
              onChange: (v) => crud.setFiltro("tipo", v),
            },
          ]}
        />

        <DataTable
          columnas={cfg.columnas}
          items={crud.items}
          pk={cfg.pk}
          orden={crud.orden}
          loading={crud.loading}
          error={crud.error}
          onOrden={crud.toggleOrden}
          onVer={abrirVer}
          onEliminar={abrirEliminar}
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

      <NotasVerModal abierto={Boolean(verId)} id={verId} onClose={() => setVerId(null)} />

      <ConfirmDialog
        abierto={Boolean(confirm)}
        titulo="Confirmar eliminación"
        mensaje={confirm?.mensaje}
        confirmLabel="Eliminar"
        confirmando={confirmando}
        onCancel={() => setConfirm(null)}
        onConfirm={handleConfirmEliminar}
      />

      {toast && (
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

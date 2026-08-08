import { useEffect, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { aulaConfig } from "./aula.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormModal from "../../components/mantenedor/FormModal";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import "../../styles/mantenedor.css";

export default function AulaPage() {
  const cfg = aulaConfig;
  const crud = useCrud({ entidad: cfg.entidad, pk: cfg.pk });

  const [modalAbierto, setModalAbierto] = useState(false);
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [catalogos, setCatalogos] = useState({ tutores: [] });

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/mensualidades/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setCatalogos({
            tutores: (data.data?.tutores || []).map((t) => ({
              value: t.IDTUTOR,
              label: t.NOMBRE,
            })),
          });
        }
      } catch {
        /* catálogo opcional */
      }
    })();
  }, []);

  const abrirCrear = () => {
    crud.setRegistro(null);
    setModo("crear");
    setModalAbierto(true);
  };

  const abrirVer = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModo("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModo("editar");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar el aula «${row.NOMBRE || row[cfg.pk]}»? Esta acción no se puede deshacer.`,
    });
  };

  const handleGuardar = async (payload) => {
    let mensaje;
    if (modo === "crear") {
      mensaje = await crud.insertar(payload);
    } else {
      mensaje = await crud.actualizar(crud.registro[cfg.pk], payload);
    }
    setToast({ mensaje, tipo: "success" });
    await crud.listar();
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

  const tituloModal =
    modo === "crear" ? "Nueva aula" : modo === "editar" ? "Editar aula" : "Ver aula";

  return (
    <div className="mantenedor-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} onNuevo={abrirCrear} />

      <div className="mantenedor-card">
        <Toolbar
          buscar={crud.buscar}
          onBuscarChange={crud.onBuscarChange}
          filtros={[
            {
              key: "estado",
              etiqueta: "Estado",
              value: crud.filtros.estado || "",
              opciones: ["Activo", "Inactivo"],
              onChange: (v) => crud.setFiltro("estado", v),
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
          onEditar={abrirEditar}
          onEliminar={abrirEliminar}
          onReintentar={crud.listar}
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>

      <FormModal
        abierto={modalAbierto}
        modo={modo}
        titulo={tituloModal}
        campos={cfg.campos}
        secciones={cfg.secciones}
        registro={crud.registro}
        catalogos={catalogos}
        onClose={() => setModalAbierto(false)}
        onSubmit={handleGuardar}
      />

      <ConfirmDialog
        abierto={Boolean(confirm)}
        titulo="Confirmar eliminación"
        mensaje={confirm?.mensaje}
        confirmando={confirmando}
        onCancel={() => setConfirm(null)}
        onConfirm={handleConfirmEliminar}
      />

      {toast && (
        <Toast
          mensaje={toast.mensaje}
          tipo={toast.tipo}
          onClose={() => setToast(null)}
        />
      )}
    </div>
  );
}

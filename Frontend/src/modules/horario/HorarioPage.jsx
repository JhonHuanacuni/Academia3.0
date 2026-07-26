import { useEffect, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { horarioConfig } from "./horario.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import HorarioFormModal from "./HorarioFormModal";
import HorarioVerModal from "./HorarioVerModal";
import "../../styles/mantenedor.css";
import "./horario.css";

export default function HorarioPage() {
  const cfg = horarioConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHASUBIDA", direccion: "DESC" },
  });

  const [verModal, setVerModal] = useState(null);
  const [cargandoVer, setCargandoVer] = useState(false);
  const [modalAbierto, setModalAbierto] = useState(false);
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [aulas, setAulas] = useState([]);
  const [planes, setPlanes] = useState([]);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/horarios/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setAulas(
            (data.data?.aulas || []).map((a) => ({
              value: a.IDAULA,
              label: a.NOMBRE,
            })),
          );
        }
      } catch {
        /* catálogo opcional */
      }
    })();
  }, []);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/planes/?estado=Activo&tamanio=100");
        const data = await parseJsonResponse(res);
        if (res.ok) setPlanes(data.data || []);
      } catch {
        setPlanes([]);
      }
    })();
  }, []);

  const abrirCrear = () => {
    crud.setRegistro(null);
    setModo("crear");
    setModalAbierto(true);
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

  const abrirVer = async (row) => {
    try {
      setCargandoVer(true);
      const data = await crud.obtener(row[cfg.pk]);
      if (!data?.URLPREVIEW) {
        setToast({ mensaje: "Este horario no tiene imagen asociada.", tipo: "error" });
        return;
      }
      setVerModal({ url: data.URLPREVIEW, titulo: data.TITULO });
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setCargandoVer(false);
    }
  };

  const abrirEliminar = (row) => {
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar «${row.TITULO || row[cfg.pk]}»? Se borrará la imagen del servidor.`,
    });
  };

  const enviarForm = async ({ TITULO, DESCRIPCION, ESTADO, AULAS, imagen }) => {
    const fd = new FormData();
    fd.append("TITULO", TITULO);
    fd.append("DESCRIPCION", DESCRIPCION || "");
    fd.append("ESTADO", ESTADO || "Activo");
    fd.append("AULAS", JSON.stringify(AULAS || []));
    if (imagen) fd.append("imagen", imagen);

    const esCrear = modo === "crear";
    const url = esCrear
      ? `/api/${cfg.entidad}/`
      : `/api/${cfg.entidad}/${encodeURIComponent(crud.registro[cfg.pk])}/`;

    const res = await fetch(url, {
      method: esCrear ? "POST" : "PUT",
      body: fd,
    });
    const data = await parseJsonResponse(res);
    if (!res.ok || !data.ok) {
      throw new Error(data.mensaje || data.error || "Error al guardar");
    }
    setToast({ mensaje: data.mensaje || "Guardado", tipo: "success" });
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
    modo === "crear" ? "Agregar Horario" : modo === "editar" ? "Editar Horario" : "Ver Horario";

  return (
    <div className="mantenedor-page">
      <PageHeader
        modulo={cfg.modulo}
        vista={cfg.titulo}
        onNuevo={abrirCrear}
        nuevoEtiqueta="Agregar Horario"
        nuevoClase="btn-success"
      />

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
          loading={crud.loading || cargandoVer}
          error={crud.error}
          onOrden={crud.toggleOrden}
          onVer={abrirVer}
          onEditar={abrirEditar}
          onEliminar={abrirEliminar}
          onReintentar={crud.listar}
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          verIcono="image"
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>

      <HorarioFormModal
        abierto={modalAbierto}
        modo={modo}
        titulo={tituloModal}
        registro={crud.registro}
        aulas={aulas}
        onClose={() => setModalAbierto(false)}
        onSubmit={enviarForm}
      />

      <HorarioVerModal
        abierto={Boolean(verModal)}
        titulo={verModal?.titulo}
        url={verModal?.url}
        planes={planes}
        onClose={() => setVerModal(null)}
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

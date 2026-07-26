import { useEffect, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { usuarioConfig } from "./usuario.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormPage from "../../components/mantenedor/FormPage";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import "../../styles/mantenedor.css";

export default function UsuarioPage() {
  const cfg = usuarioConfig;
  const crud = useCrud({ entidad: cfg.entidad, pk: cfg.pk });

  const [vista, setVista] = useState("lista");
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [catalogos, setCatalogos] = useState({ tiposUsuario: [], mediosEntero: [] });
  const [confirmando, setConfirmando] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/tipos-usuario/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setCatalogos({
            tiposUsuario: (data.data || []).map((t) => ({
              value: t.IDTIPOUSUARIO,
              label: t.DESCRIPCION,
            })),
            mediosEntero: [
              { value: "Facebook", label: "Facebook" },
              { value: "Instagram", label: "Instagram" },
              { value: "TikTok", label: "TikTok" },
              { value: "WhatsApp", label: "WhatsApp" },
              { value: "Recomendación", label: "Recomendación de amigo/familiar" },
              { value: "Google", label: "Google / Internet" },
              { value: "Volante", label: "Volante / publicidad" },
              { value: "Otro", label: "Otro" },
            ],
          });
        }
      } catch {
        /* catálogo opcional en UI */
      }
    })();
  }, []);

  const volverLista = () => {
    setVista("lista");
    crud.setRegistro(null);
  };

  const abrirCrear = () => {
    crud.setRegistro(null);
    setModo("crear");
    setVista("form");
  };

  const abrirVer = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModo("ver");
      setVista("form");
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModo("editar");
      setVista("form");
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    const nombre = `${row.NOMBRE} ${row.APELLIDO}`.trim();
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar «${nombre || row[cfg.pk]}»? Esta acción se puede revertir reactivándolo.`,
    });
  };

  const descargarCarnet = (row) => {
    window.open(`/api/usuarios/${encodeURIComponent(row[cfg.pk])}/carnet/`, "_blank");
  };

  const handleGuardar = async (payload) => {
    let mensaje;
    if (modo === "crear") {
      mensaje = await crud.insertar(payload);
    } else {
      mensaje = await crud.actualizar(crud.registro[cfg.pk], payload);
    }
    setToast({ mensaje, tipo: "success" });
    volverLista();
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

  const tituloForm =
    modo === "crear" ? "Nuevo usuario" : modo === "editar" ? "Editar usuario" : "Ver usuario";

  if (vista === "form") {
    return (
      <>
        <FormPage
          modo={modo}
          modulo={cfg.modulo}
          listado={cfg.titulo}
          vista={tituloForm}
          titulo={tituloForm}
          campos={cfg.campos}
          secciones={cfg.secciones}
          registro={crud.registro}
          catalogos={catalogos}
          onCancel={volverLista}
          onSubmit={handleGuardar}
        />
        {toast && (
          <Toast
            mensaje={toast.mensaje}
            tipo={toast.tipo}
            onClose={() => setToast(null)}
          />
        )}
      </>
    );
  }

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
          onCarnet={descargarCarnet}
          onReintentar={crud.listar}
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>

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

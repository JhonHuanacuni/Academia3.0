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
import { telefonoContactoUsuario, whatsappUrl } from "../../utils/telefono";
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
              { value: "Promotoría", label: "Promotoría" },
              { value: "Buscando", label: "Buscando" },
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

  const abrirRetirar = (row) => {
    const nombre = `${row.NOMBRE} ${row.APELLIDO}`.trim();
    setConfirm({
      tipo: "retirar",
      id: row[cfg.pk],
      titulo: "Confirmar retiro",
      mensaje: `¿Retirar a «${nombre || row[cfg.pk]}»? El usuario quedará inactivo y podrá eliminarse permanentemente después.`,
      confirmLabel: "Retirar",
    });
  };

  const abrirEliminar = (row) => {
    const nombre = `${row.NOMBRE} ${row.APELLIDO}`.trim();
    setConfirm({
      tipo: "eliminar",
      id: row[cfg.pk],
      titulo: "Confirmar eliminación",
      mensaje: `¿Eliminar permanentemente a «${nombre || row[cfg.pk]}»? Esta acción no se puede deshacer.`,
      confirmLabel: "Eliminar",
    });
  };

  const abrirResetContra = (row) => {
    const nombre = `${row.NOMBRE} ${row.APELLIDO}`.trim();
    setConfirm({
      tipo: "resetContra",
      id: row[cfg.pk],
      titulo: "Restablecer contraseña",
      mensaje: `¿Restablecer la contraseña de «${nombre || row[cfg.pk]}» a su DNI (${row.DNI || "—"})?`,
      confirmLabel: "Restablecer",
    });
  };

  const descargarCarnet = (row) => {
    window.open(`/api/usuarios/${encodeURIComponent(row[cfg.pk])}/carnet/`, "_blank");
  };

  const abrirWhatsapp = (row) => {
    const tel = telefonoContactoUsuario(row);
    const url = whatsappUrl(tel);
    if (!url) {
      setToast({
        mensaje: "Este usuario no tiene celular registrado (personal ni apoderado).",
        tipo: "error",
      });
      return;
    }
    window.open(url, "_blank", "noopener,noreferrer");
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

  const handleConfirm = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      if (confirm.tipo === "resetContra") {
        const res = await fetch(
          `/api/usuarios/${encodeURIComponent(confirm.id)}/reset-contra/`,
          { method: "POST" },
        );
        const data = await parseJsonResponse(res);
        if (!res.ok || !data.ok) {
          throw new Error(data.mensaje || data.error || "No se pudo restablecer la contraseña");
        }
        setToast({ mensaje: data.mensaje, tipo: "success" });
      } else if (confirm.tipo === "retirar" || confirm.tipo === "eliminar") {
        const mensaje = await crud.eliminar(confirm.id);
        setToast({ mensaje, tipo: "success" });
        await crud.listar();
      }
      setConfirm(null);
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
              opciones: ["Activo", "Retirado"],
              onChange: (v) => crud.setFiltro("estado", v),
            },
          ]}
          placeholder="Buscar por nombre, DNI, email o usuario..."
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
          onRetirar={abrirRetirar}
          onEliminar={abrirEliminar}
          onCarnet={descargarCarnet}
          onResetContra={abrirResetContra}
          onWhatsapp={abrirWhatsapp}
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
        titulo={confirm?.titulo || "Confirmar"}
        mensaje={confirm?.mensaje}
        confirmando={confirmando}
        confirmLabel={confirm?.confirmLabel || "Confirmar"}
        onCancel={() => setConfirm(null)}
        onConfirm={handleConfirm}
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

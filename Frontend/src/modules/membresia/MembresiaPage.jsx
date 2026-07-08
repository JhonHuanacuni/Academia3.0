import { useEffect, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { sumarDiasInput } from "../../utils/fecha";
import { useCrud } from "../../hooks/useCrud";
import { membresiaConfig } from "./membresia.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormModal from "../../components/mantenedor/FormModal";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import "../../styles/mantenedor.css";

function mapCatalogos(data) {
  return {
    planes: [{ value: "", label: "Seleccione un plan" }].concat(
      (data.planes || []).map((p) => ({
        value: p.IDPLAN,
        label: p.NOMBRE,
        precio: p.PRECIO,
        duracionDias: p.DURACIONDIAS,
      })),
    ),
    turnos: [{ value: "", label: "Seleccione turno" }].concat(
      (data.turnos || []).map((t) => ({
        value: t.IDTURNO,
        label: t.DESCRIPCION,
      })),
    ),
    aulas: [{ value: "", label: "Seleccione un salón" }].concat(
      (data.aulas || []).map((a) => ({ value: a.IDAULA, label: a.NOMBRE })),
    ),
    metodosPago: (data.metodosPago || []).map((m) => ({
      value: m.IDMETODOPAGO,
      label: m.TITULO,
    })),
    estadosMiembro: data.estadosMiembro || [],
    tiposMembresia: data.tiposMembresia || [],
  };
}

export default function MembresiaPage() {
  const cfg = membresiaConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHAREGISTRO", direccion: "DESC" },
    filtrosIniciales: { estado: "Activo" },
  });

  const [modalAbierto, setModalAbierto] = useState(false);
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [catalogos, setCatalogos] = useState({
    planes: [],
    turnos: [],
    aulas: [],
    metodosPago: [],
    estadosMiembro: [],
    tiposMembresia: [],
  });
  const [estudianteSel, setEstudianteSel] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const esAdmin = (localStorage.getItem("role") || "") === "administrador";

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/membresias/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) setCatalogos(mapCatalogos(data.data || {}));
      } catch {
        /* catálogo opcional */
      }
    })();
  }, []);

  const abrirCrear = () => {
    crud.setRegistro(null);
    setEstudianteSel(null);
    setModo("crear");
    setModalAbierto(true);
  };

  const abrirVer = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setEstudianteSel({
        IDUSUARIO: data.IDUSUARIO,
        NOMBRE_COMPLETO: data.ESTUDIANTE_NOMBRE,
        DNI: data.ESTUDIANTE_DNI,
      });
      setModo("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro({
        ...data,
        ESTADOMIEMBRO: String(data.ESTADOMIEMBRO ?? "1"),
      });
      setEstudianteSel({
        IDUSUARIO: data.IDUSUARIO,
        NOMBRE_COMPLETO: data.ESTUDIANTE_NOMBRE,
        DNI: data.ESTUDIANTE_DNI,
      });
      setModo("editar");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    const nombre = row.ESTUDIANTE_NOMBRE || row[cfg.pk];
    setConfirm({
      id: row[cfg.pk],
      mensaje: esAdmin
        ? `¿Eliminar permanentemente la membresía de «${nombre}»? Esta acción no se puede deshacer.`
        : `¿Desactivar la membresía de «${nombre}»? Desaparecerá del listado; un administrador puede eliminarla después.`,
      confirmLabel: esAdmin ? "Eliminar" : "Desactivar",
    });
  };

  const handleGuardar = async (payload) => {
    const body = {
      IDUSUARIO: payload.IDUSUARIO,
      IDPLAN: payload.IDPLAN,
      IDTURNO: payload.IDTURNO || null,
      ESTADOMIEMBRO: Number(payload.ESTADOMIEMBRO || 1),
      FECHAINICIO: payload.FECHAINICIO,
      FECHAFIN: payload.FECHAFIN,
      MONTOTOTAL: payload.MONTOTOTAL === "" ? null : Number(payload.MONTOTOTAL),
      TIPOMEMBRESIA: payload.TIPOMEMBRESIA || null,
      IDAULA: payload.IDAULA || null,
      ASESOR: payload.ASESOR || null,
      OBSERVACIONES: payload.OBSERVACIONES || null,
    };
    if (modo === "crear") {
      body.PAGOINICIAL =
        payload.PAGOINICIAL === "" || payload.PAGOINICIAL == null
          ? null
          : Number(payload.PAGOINICIAL);
      body.IDMETODOPAGO = payload.IDMETODOPAGO || null;
    }
    let mensaje;
    if (modo === "crear") {
      mensaje = await crud.insertar(body);
    } else {
      mensaje = await crud.actualizar(crud.registro[cfg.pk], body);
    }
    setToast({ mensaje, tipo: "success" });
    await crud.listar();
  };

  const handleConfirmEliminar = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      const mensaje = await crud.eliminar(confirm.id, {
        idusuario: localStorage.getItem("idusuario") || "",
      });
      setToast({ mensaje, tipo: "success" });
      setConfirm(null);
      await crud.listar();
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setConfirmando(false);
    }
  };

  const handleFieldChange = (campo, val, setValues) => {
    if (campo === "IDPLAN" && modo === "crear") {
      const plan = catalogos.planes.find((p) => p.value === val);
      if (plan?.precio != null) {
        setValues((prev) => {
          const next = { ...prev, MONTOTOTAL: String(plan.precio) };
          if (plan.duracionDias && prev.FECHAINICIO) {
            next.FECHAFIN = sumarDiasInput(prev.FECHAINICIO, plan.duracionDias);
          }
          return next;
        });
      }
    }
    if (campo === "FECHAINICIO" && modo === "crear") {
      setValues((prev) => {
        const plan = catalogos.planes.find((p) => p.value === prev.IDPLAN);
        if (plan?.duracionDias && val) {
          return { ...prev, FECHAFIN: sumarDiasInput(val, plan.duracionDias) };
        }
        return prev;
      });
    }
  };

  const tituloModal =
    modo === "crear"
      ? "Registrar membresía"
      : modo === "editar"
        ? "Editar membresía"
        : "Ver membresía";

  return (
    <div className="mantenedor-page">
      <PageHeader titulo={cfg.titulo} onNuevo={abrirCrear} />

      <div className="mantenedor-card">
        <Toolbar
          buscar={crud.buscar}
          onBuscarChange={crud.onBuscarChange}
          placeholder="Buscar estudiante, DNI, plan..."
          filtros={[
            {
              key: "estado",
              etiqueta: "Estado",
              value: crud.filtros.estado || "Activo",
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
        estudianteSeleccionado={estudianteSel}
        onEstudianteChange={setEstudianteSel}
        onFieldChange={handleFieldChange}
        onClose={() => setModalAbierto(false)}
        onSubmit={handleGuardar}
      />

      <ConfirmDialog
        abierto={Boolean(confirm)}
        titulo={esAdmin ? "Confirmar eliminación" : "Confirmar desactivación"}
        mensaje={confirm?.mensaje}
        confirmLabel={confirm?.confirmLabel || "Eliminar"}
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

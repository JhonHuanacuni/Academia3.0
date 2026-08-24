import { useEffect, useMemo, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { mensualidadConfig } from "./mensualidad.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormPage from "../../components/mantenedor/FormPage";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import MensualidadEstudianteModal from "./MensualidadEstudianteModal";
import MensualidadPagosModal from "./MensualidadPagosModal";
import "../../styles/mantenedor.css";
import "./mensualidad.css";

function mapCatalogos(data) {
  return {
    planes: (data.planes || []).map((p) => ({
      value: p.IDPLAN,
      label: p.NOMBRE,
    })),
    aulas: (data.aulas || []).map((a) => ({
      value: a.IDAULA,
      label: a.NOMBRE,
      idTutor: a.IDTUTOR || "",
    })),
    tutores: (data.tutores || []).map((a) => ({ value: a.IDTUTOR, label: a.NOMBRE })),
    metodosPago: (data.metodosPago || []).map((m) => ({
      value: m.IDMETODOPAGO,
      label: m.TITULO,
    })),
  };
}

export default function MensualidadPage() {
  const cfg = mensualidadConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "ESTUDIANTE_NOMBRE", direccion: "ASC" },
    filtrosIniciales: {},
  });

  const [vista, setVista] = useState("lista");
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [catalogos, setCatalogos] = useState({
    planes: [],
    aulas: [],
    tutores: [],
    metodosPago: [],
  });
  const [estudianteSel, setEstudianteSel] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [registradorNombre, setRegistradorNombre] = useState("");
  const [estudianteModal, setEstudianteModal] = useState(null);
  const [estudianteModalLoading, setEstudianteModalLoading] = useState(false);
  const [pagosModal, setPagosModal] = useState(null);
  const [pagosLoading, setPagosLoading] = useState(false);
  const esAdmin = (localStorage.getItem("role") || "") === "administrador";

  useEffect(() => {
    (async () => {
      try {
        const idusuario = localStorage.getItem("idusuario") || "";
        const res = await fetch(
          `/api/mensualidades/catalogos/${idusuario ? `?idusuario=${encodeURIComponent(idusuario)}` : ""}`,
        );
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setCatalogos(mapCatalogos(data.data || {}));
          setRegistradorNombre(data.data?.registradorNombre || "");
        }
      } catch {
        /* catálogo opcional */
      }
    })();
  }, []);

  const volverLista = () => {
    setVista("lista");
    crud.setRegistro(null);
    setEstudianteSel(null);
  };

  const abrirCrear = () => {
    crud.setRegistro(null);
    setEstudianteSel(null);
    setModo("crear");
    setVista("form");
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
      setVista("form");
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setEstudianteSel({
        IDUSUARIO: data.IDUSUARIO,
        NOMBRE_COMPLETO: data.ESTUDIANTE_NOMBRE,
        DNI: data.ESTUDIANTE_DNI,
      });
      setModo("editar");
      setVista("form");
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEliminar = (row) => {
    const nombre = row.ESTUDIANTE_NOMBRE || row[cfg.pk];
    setConfirm({
      id: row[cfg.pk],
      mensaje: esAdmin
        ? `¿Eliminar permanentemente la mensualidad de «${nombre}»? Esta acción no se puede deshacer.`
        : `¿Desactivar la mensualidad de «${nombre}»? Desaparecerá del listado; un administrador puede eliminarla después.`,
      confirmLabel: esAdmin ? "Eliminar" : "Desactivar",
    });
  };

  const abrirMensualidadesEstudiante = async (row) => {
    const idUsuario = row.IDUSUARIO;
    if (!idUsuario) {
      setToast({ mensaje: "No se encontró el estudiante de esta fila.", tipo: "error" });
      return;
    }
    setEstudianteModal({
      estudianteNombre: row.ESTUDIANTE_NOMBRE || idUsuario,
      estudianteDni: row.ESTUDIANTE_DNI || "",
      idUsuario,
      items: [],
    });
    setEstudianteModalLoading(true);
    try {
      const res = await fetch(`/api/mensualidades/estudiante/${encodeURIComponent(idUsuario)}/`);
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "No se pudieron cargar las mensualidades");
      setEstudianteModal((prev) =>
        prev ? { ...prev, items: data.data || [] } : prev,
      );
    } catch (err) {
      setEstudianteModal(null);
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setEstudianteModalLoading(false);
    }
  };

  const abrirPagosDesdeEstudiante = async (mensualidad) => {
    const id = mensualidad.IDMENSUALIDAD;
    setPagosModal({
      titulo: "Pagos de la mensualidad",
      estudianteNombre: estudianteModal?.estudianteNombre || "",
      planNombre: mensualidad.PLAN_NOMBRE || "",
      resumen: {
        montoTotal: mensualidad.MONTOTOTAL,
        pagado: mensualidad.PAGADO,
        deuda: mensualidad.DEUDA,
        estudianteEstado: mensualidad.ESTUDIANTE_ESTADO,
        cuotas: mensualidad.CUOTAS || [],
        tieneCuotas: Boolean(mensualidad.TIENE_CUOTAS),
      },
      pagos: [],
    });
    setPagosLoading(true);
    try {
      const res = await fetch(`/api/mensualidades/${encodeURIComponent(id)}/pagos/`);
      const data = await parseJsonResponse(res);
      if (!res.ok) throw new Error(data.error || "No se pudieron cargar los pagos");
      setPagosModal((prev) => (prev ? { ...prev, pagos: data.data || [] } : prev));
    } catch (err) {
      setPagosModal(null);
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setPagosLoading(false);
    }
  };

  const handleGuardar = async (payload) => {
    const body = {
      IDUSUARIO: payload.IDUSUARIO,
      IDPLAN: payload.IDPLAN,
      ESTADOMIEMBRO: 2,
      FECHAINICIO: payload.FECHAINICIO,
      FECHAFIN: payload.FECHAFIN,
      MONTOTOTAL: payload.MONTOTOTAL === "" ? null : Number(payload.MONTOTOTAL),
      IDAULA: payload.IDAULA || null,
      IDTUTOR: payload.IDTUTOR || null,
      OBSERVACIONES: payload.OBSERVACIONES || null,
    };
    if (modo === "crear") {
      body.PAGOINICIAL =
        payload.PAGOINICIAL === "" || payload.PAGOINICIAL == null
          ? null
          : Number(payload.PAGOINICIAL);
      body.IDMETODOPAGO = payload.IDMETODOPAGO || null;
      body.REGISTRADOPOR = localStorage.getItem("idusuario") || null;
    }
    let mensaje;
    if (modo === "crear") {
      mensaje = await crud.insertar(body);
    } else {
      mensaje = await crud.actualizar(crud.registro[cfg.pk], body);
    }
    setToast({ mensaje, tipo: "success" });
    volverLista();
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

  const tituloForm =
    modo === "crear"
      ? "Nueva mensualidad"
      : modo === "editar"
        ? "Editar mensualidad"
        : "Ver mensualidad";

  const createDefaults = useMemo(
    () => (modo === "crear" ? { ASESOR_NOMBRE: registradorNombre } : undefined),
    [modo, registradorNombre],
  );

  const handleFieldChange = (campo, val, setValues) => {
    if (campo !== "IDAULA") return;
    const aula = catalogos.aulas.find((a) => a.value === val);
    if (aula?.idTutor) {
      setValues((prev) => ({ ...prev, IDTUTOR: aula.idTutor }));
    }
  };

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
          estudianteSeleccionado={estudianteSel}
          onEstudianteChange={setEstudianteSel}
          createDefaults={createDefaults}
          onFieldChange={handleFieldChange}
          onCancel={volverLista}
          onSubmit={handleGuardar}
        />
        {toast && (
          <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
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
          placeholder="Buscar estudiante, DNI, plan..."
          filtros={[
            {
              key: "deuda",
              etiqueta: "Deuda",
              value: crud.filtros.deuda || "",
              opciones: ["Con deuda", "Sin deuda"],
              onChange: (v) => crud.setFiltro("deuda", v),
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
          onVerMensualidades={abrirMensualidadesEstudiante}
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

      <ConfirmDialog
        abierto={Boolean(confirm)}
        titulo={esAdmin ? "Confirmar eliminación" : "Confirmar desactivación"}
        mensaje={confirm?.mensaje}
        confirmLabel={confirm?.confirmLabel || "Eliminar"}
        confirmando={confirmando}
        onCancel={() => setConfirm(null)}
        onConfirm={handleConfirmEliminar}
      />

      <MensualidadEstudianteModal
        abierto={Boolean(estudianteModal)}
        estudianteNombre={estudianteModal?.estudianteNombre}
        estudianteDni={estudianteModal?.estudianteDni}
        items={estudianteModal?.items}
        loading={estudianteModalLoading}
        onClose={() => setEstudianteModal(null)}
        onVerPagos={abrirPagosDesdeEstudiante}
      />

      <MensualidadPagosModal
        abierto={Boolean(pagosModal)}
        titulo={pagosModal?.titulo}
        estudianteNombre={pagosModal?.estudianteNombre}
        planNombre={pagosModal?.planNombre}
        resumen={pagosModal?.resumen}
        pagos={pagosModal?.pagos}
        loading={pagosLoading}
        onClose={() => setPagosModal(null)}
      />

      {toast && (
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

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
import "../../styles/mantenedor.css";

function normalizarEstadoMensualidad(val) {
  return Number(val) === 3 ? "3" : "2";
}

function mapCatalogos(data) {
  return {
    planes: (data.planes || []).map((p) => ({
      value: p.IDPLAN,
      label: p.NOMBRE,
    })),
    aulas: (data.aulas || []).map((a) => ({ value: a.IDAULA, label: a.NOMBRE })),
    tutores: (data.tutores || []).map((a) => ({ value: a.IDTUTOR, label: a.NOMBRE })),
    metodosPago: (data.metodosPago || []).map((m) => ({
      value: m.IDMETODOPAGO,
      label: m.TITULO,
    })),
    estadosMensualidad: data.estadosMensualidad || [],
  };
}

export default function MensualidadPage() {
  const cfg = mensualidadConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHAREGISTRO", direccion: "DESC" },
    filtrosIniciales: { estado: "Activo" },
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
    estadosMensualidad: [],
  });
  const [estudianteSel, setEstudianteSel] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [registradorNombre, setRegistradorNombre] = useState("");
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
      crud.setRegistro({
        ...data,
        ESTADOMIEMBRO: normalizarEstadoMensualidad(data.ESTADOMIEMBRO),
      });
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
      crud.setRegistro({
        ...data,
        ESTADOMIEMBRO: normalizarEstadoMensualidad(data.ESTADOMIEMBRO),
      });
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

  const handleGuardar = async (payload) => {
    const body = {
      IDUSUARIO: payload.IDUSUARIO,
      IDPLAN: payload.IDPLAN,
      ESTADOMIEMBRO: Number(payload.ESTADOMIEMBRO || 2),
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

      {toast && (
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

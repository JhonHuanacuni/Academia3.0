import { useEffect, useMemo, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import { justificacionConfig } from "./justificacion.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormModal from "../../components/mantenedor/FormModal";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import { dbToInput, inputToDb } from "../../utils/fecha";
import "../../styles/mantenedor.css";

export default function JustificacionPage() {
  const cfg = justificacionConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    filtrosIniciales: {
      idTutor: "",
      idPlan: "",
      idTurno: "",
      fechaDesde: "",
      fechaHasta: "",
    },
  });

  const [modalAbierto, setModalAbierto] = useState(false);
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [estudianteSel, setEstudianteSel] = useState(null);
  const [registradorNombre, setRegistradorNombre] = useState("");
  const [catalogos, setCatalogos] = useState({ tutores: [], planes: [], turnos: [] });

  useEffect(() => {
    (async () => {
      try {
        const [resMen, resPlan] = await Promise.all([
          fetch("/api/mensualidades/catalogos/"),
          fetch("/api/planes/catalogos/"),
        ]);
        const dataMen = await parseJsonResponse(resMen);
        const dataPlan = await parseJsonResponse(resPlan);
        if (resMen.ok) {
          setCatalogos((prev) => ({
            ...prev,
            tutores: (dataMen.data?.tutores || []).map((t) => ({
              value: t.IDTUTOR,
              label: t.NOMBRE,
            })),
            planes: (dataMen.data?.planes || []).map((p) => ({
              value: p.IDPLAN,
              label: p.NOMBRE,
            })),
          }));
        }
        if (resPlan.ok) {
          setCatalogos((prev) => ({
            ...prev,
            turnos: (dataPlan.data?.turnos || []).map((t) => ({
              value: t.IDTURNO,
              label: t.DESCRIPCION,
            })),
          }));
        }
      } catch {
        /* catálogos opcionales */
      }
    })();
  }, []);

  useEffect(() => {
    (async () => {
      const id = localStorage.getItem("idusuario") || "";
      if (!id) return;
      try {
        const res = await fetch(`/api/usuarios/${encodeURIComponent(id)}/`);
        const data = await parseJsonResponse(res);
        if (res.ok && data.data) {
          const u = data.data;
          setRegistradorNombre(`${u.NOMBRE || ""} ${u.APELLIDO || ""}`.trim() || id);
        }
      } catch {
        setRegistradorNombre(id);
      }
    })();
  }, []);

  const secciones = useMemo(
    () =>
      cfg.secciones.map((sec) => ({
        ...sec,
        campos: sec.campos.map((c) =>
          c.campo === "REGISTRADOR_NOMBRE"
            ? { ...c, defaultValue: registradorNombre }
            : c,
        ),
      })),
    [cfg.secciones, registradorNombre],
  );

  const fechaDesdeInput = useMemo(() => {
    const f = crud.filtros.fechaDesde;
    return f ? dbToInput(String(f)) : "";
  }, [crud.filtros.fechaDesde]);

  const fechaHastaInput = useMemo(() => {
    const f = crud.filtros.fechaHasta;
    return f ? dbToInput(String(f)) : "";
  }, [crud.filtros.fechaHasta]);

  const items = useMemo(
    () =>
      (crud.items || []).map((row) => ({
        ...row,
        ESTUDIANTE_NOMBRE: `${row.ESTUDIANTE_NOMBRE || ""} ${row.ESTUDIANTE_APELLIDO || ""}`.trim(),
      })),
    [crud.items],
  );

  const abrirCrear = () => {
    crud.setRegistro(null);
    setEstudianteSel(null);
    setModo("crear");
    setModalAbierto(true);
  };

  const abrirVer = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(prepararRegistro(data));
      setEstudianteSel(estudianteDesdeRegistro(data));
      setModo("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  const abrirEditar = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(prepararRegistro(data));
      setEstudianteSel(estudianteDesdeRegistro(data));
      setModo("editar");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
  };

  function prepararRegistro(data) {
    return {
      ...data,
      ESTUDIANTE_NOMBRE: `${data.ESTUDIANTE_NOMBRE || ""} ${data.ESTUDIANTE_APELLIDO || ""}`.trim(),
    };
  }

  function estudianteDesdeRegistro(data) {
    return {
      IDUSUARIO: data.IDUSUARIO,
      NOMBRE_COMPLETO: `${data.ESTUDIANTE_NOMBRE || ""} ${data.ESTUDIANTE_APELLIDO || ""}`.trim(),
      DNI: data.DNI,
    };
  }

  const abrirEliminar = (row) => {
    const nombre = row.ESTUDIANTE_NOMBRE || row.DNI || row[cfg.pk];
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar la justificación de «${nombre}»?`,
    });
  };

  const handleGuardar = async (payload) => {
    const body = {
      IDUSUARIO: payload.IDUSUARIO,
      FECHA: inputToDb(payload.FECHA),
      OBSERVACION: payload.OBSERVACION,
    };
    let mensaje;
    if (modo === "crear") {
      body.IDREGISTRADOR = localStorage.getItem("idusuario") || null;
      mensaje = await crud.insertar(body);
    } else {
      mensaje = await crud.actualizar(crud.registro[cfg.pk], body);
    }
    setToast({ mensaje, tipo: "success" });
    setModalAbierto(false);
    await crud.listar();
  };

  const tituloModal =
    modo === "crear"
      ? "Nueva justificación"
      : modo === "editar"
        ? "Editar justificación"
        : "Ver justificación";

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

  return (
    <div className="mantenedor-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} onNuevo={abrirCrear} />

      <div className="mantenedor-card">
        <div className="mantenedor-toolbar">
          <Toolbar
            buscar={crud.buscar}
            onBuscarChange={crud.onBuscarChange}
            placeholder="Buscar por estudiante, DNI u observación..."
            filtros={[
              {
                key: "idTutor",
                etiqueta: "Tutor",
                value: crud.filtros.idTutor || "",
                opciones: catalogos.tutores,
                onChange: (v) => crud.setFiltro("idTutor", v),
              },
              {
                key: "idPlan",
                etiqueta: "Ciclo",
                value: crud.filtros.idPlan || "",
                opciones: catalogos.planes,
                onChange: (v) => crud.setFiltro("idPlan", v),
              },
              {
                key: "idTurno",
                etiqueta: "Turno",
                value: crud.filtros.idTurno || "",
                opciones: catalogos.turnos,
                onChange: (v) => crud.setFiltro("idTurno", v),
              },
            ]}
          />
          <label className="toolbar-date">
            <span>Fecha inicio</span>
            <input
              type="date"
              value={fechaDesdeInput}
              onChange={(e) => {
                const value = e.target.value;
                crud.setFiltro("fechaDesde", value ? inputToDb(value) : "");
                if (value && fechaHastaInput && value > fechaHastaInput) {
                  crud.setFiltro("fechaHasta", inputToDb(value));
                }
              }}
            />
          </label>
          <label className="toolbar-date">
            <span>Fecha fin</span>
            <input
              type="date"
              value={fechaHastaInput}
              onChange={(e) => crud.setFiltro("fechaHasta", e.target.value ? inputToDb(e.target.value) : "")}
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

      <FormModal
        abierto={modalAbierto}
        modo={modo}
        titulo={tituloModal}
        secciones={secciones}
        registro={crud.registro}
        estudianteSeleccionado={estudianteSel}
        onEstudianteChange={setEstudianteSel}
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
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

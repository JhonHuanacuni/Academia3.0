import { useCallback, useEffect, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import {
  claseGrabadaConfig,
  claseGrabadaAdminColumnas,
} from "./claseGrabada.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import Pagination from "../../components/mantenedor/Pagination";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import MateriaChipBar from "./MateriaChipBar";
import ClaseGrabadaTabla from "./ClaseGrabadaTabla";
import ClaseGrabadaFormModal from "./ClaseGrabadaFormModal";
import "../../styles/mantenedor.css";
import "./claseGrabada.css";

export default function ClaseGrabadaAdminPage() {
  const cfg = claseGrabadaConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHASUBIDA", direccion: "DESC" },
    filtrosIniciales: { estado: "Activo" },
  });

  const [aulas, setAulas] = useState([]);
  const [materiasCat, setMateriasCat] = useState([]);
  const [materiasResumen, setMateriasResumen] = useState([]);
  const [totalEnlaces, setTotalEnlaces] = useState(0);
  const [materiaSel, setMateriaSel] = useState("");
  const [aulaSel, setAulaSel] = useState("");
  const [modalAbierto, setModalAbierto] = useState(false);
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/clases-grabadas/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setAulas(
            (data.data?.aulas || []).map((a) => ({ value: a.IDAULA, label: a.NOMBRE })),
          );
          setMateriasCat(
            (data.data?.materias || []).map((m) => ({ value: m.IDMATERIA, label: m.NOMBRE })),
          );
        }
      } catch {
        /* opcional */
      }
    })();
  }, []);

  const cargarMaterias = useCallback(async () => {
    try {
      const params = new URLSearchParams();
      if (aulaSel) params.set("idAula", aulaSel);
      const res = await fetch(`/api/clases-grabadas/materias/?${params}`);
      const data = await parseJsonResponse(res);
      if (res.ok) {
        setMateriasResumen(data.data || []);
        setTotalEnlaces(data.totalEnlaces || 0);
      }
    } catch {
      setMateriasResumen([]);
      setTotalEnlaces(0);
    }
  }, [aulaSel]);

  useEffect(() => {
    cargarMaterias();
  }, [cargarMaterias]);

  useEffect(() => {
    crud.setFiltro("idMateria", materiaSel);
  }, [materiaSel]);

  useEffect(() => {
    crud.setFiltro("idAula", aulaSel);
    setMateriaSel("");
  }, [aulaSel]);

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

  const abrirEliminar = (row) => {
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar «${row.DETALLES || row[cfg.pk]}»?`,
    });
  };

  const abrirEnlace = (row) => {
    const url = row.ENLACE;
    if (!url) {
      setToast({ mensaje: "Este registro no tiene enlace.", tipo: "error" });
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
    await crud.listar();
    await cargarMaterias();
  };

  const handleConfirmEliminar = async () => {
    if (!confirm) return;
    try {
      setConfirmando(true);
      const mensaje = await crud.eliminar(confirm.id);
      setToast({ mensaje, tipo: "success" });
      setConfirm(null);
      await crud.listar();
      await cargarMaterias();
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    } finally {
      setConfirmando(false);
    }
  };

  const tituloModal = modo === "crear" ? "Agregar enlace" : "Editar enlace";

  return (
    <div className="mantenedor-page">
      <PageHeader
        modulo={cfg.modulo}
        vista={cfg.titulo}
        onNuevo={abrirCrear}
        nuevoEtiqueta="Agregar enlace"
        nuevoClase="btn-success"
      />

      <div className="mantenedor-card">
        <div className="cg-toolbar-row">
          <label htmlFor="cg-filtro-aula">Seleccionar salón</label>
          <select
            id="cg-filtro-aula"
            value={aulaSel}
            onChange={(e) => setAulaSel(e.target.value)}
          >
            <option value="">Todos los salones</option>
            {aulas.map((a) => (
              <option key={a.value} value={a.value}>
                {a.label}
              </option>
            ))}
          </select>
        </div>

        <MateriaChipBar
          materias={materiasResumen}
          totalTodos={totalEnlaces}
          seleccionada={materiaSel}
          onSelect={(id) => {
            setMateriaSel(id);
            crud.setPagina(1);
          }}
        />

        <Toolbar
          buscar={crud.buscar}
          onBuscarChange={crud.onBuscarChange}
          placeholder="Buscar detalles, salón..."
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

        <ClaseGrabadaTabla
          columnas={claseGrabadaAdminColumnas}
          items={crud.items}
          pk={cfg.pk}
          orden={crud.orden}
          loading={crud.loading}
          modo="admin"
          onOrden={crud.toggleOrden}
          onEditar={abrirEditar}
          onEliminar={abrirEliminar}
          onAbrirEnlace={abrirEnlace}
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>

      <ClaseGrabadaFormModal
        abierto={modalAbierto}
        titulo={tituloModal}
        registro={crud.registro}
        aulas={aulas}
        materias={materiasCat}
        materiaPreseleccionada={materiaSel}
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

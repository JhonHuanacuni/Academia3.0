import { useEffect, useMemo, useState } from "react";
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
import HorarioZoomModal from "./HorarioZoomModal";
import "../../styles/mantenedor.css";
import "./horario.css";

function HorarioEstudianteVista({ idUsuario }) {
  const cfg = horarioConfig;
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selId, setSelId] = useState(null);
  const [zoomAbierto, setZoomAbierto] = useState(false);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError("");
      try {
        const params = new URLSearchParams({
          pagina: "1",
          tamanio: "50",
          ordenarPor: "FECHASUBIDA",
          direccion: "DESC",
          estado: "Activo",
          idusuario: idUsuario,
        });
        const res = await fetch(`/api/${cfg.entidad}/?${params}`);
        const data = await parseJsonResponse(res);
        if (!res.ok) throw new Error(data.error || "Error al cargar el horario");
        const rows = data.data || [];
        if (cancelled) return;
        setItems(rows);
        setSelId(rows[0]?.[cfg.pk] ?? null);
      } catch (err) {
        if (!cancelled) {
          setError(err.message || "Error al cargar el horario");
          setItems([]);
          setSelId(null);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [cfg.entidad, cfg.pk, idUsuario]);

  const seleccionado = useMemo(
    () => items.find((r) => r[cfg.pk] === selId) || null,
    [items, selId, cfg.pk],
  );

  const url = seleccionado?.URLPREVIEW || seleccionado?.URLIMAGEN || "";

  return (
    <div className="mantenedor-page horario-estudiante-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} mostrarNuevo={false} />

      <div className="horario-estudiante-card">
        {loading && (
          <p className="horario-estudiante-state">Cargando horario…</p>
        )}

        {!loading && error && (
          <p className="horario-estudiante-state horario-estudiante-state--error">
            {error}
          </p>
        )}

        {!loading && !error && items.length === 0 && (
          <p className="horario-estudiante-state">
            No hay un horario asignado a tu salón.
          </p>
        )}

        {!loading && !error && items.length > 1 && (
          <div className="horario-estudiante-tabs" role="tablist" aria-label="Horarios">
            {items.map((row) => {
              const activa = row[cfg.pk] === selId;
              return (
                <button
                  key={row[cfg.pk]}
                  type="button"
                  role="tab"
                  aria-selected={activa}
                  className={`horario-estudiante-tab${activa ? " is-active" : ""}`}
                  onClick={() => setSelId(row[cfg.pk])}
                >
                  {row.TITULO || `Horario ${row[cfg.pk]}`}
                </button>
              );
            })}
          </div>
        )}

        {!loading && !error && seleccionado && (
          <div className="horario-estudiante-viewer">
            {url ? (
              <button
                type="button"
                className="horario-estudiante-img-btn"
                onClick={() => setZoomAbierto(true)}
                title="Clic para ampliar"
                aria-label="Ver horario ampliado"
              >
                <img
                  src={url}
                  alt={seleccionado.TITULO || "Horario"}
                  className="horario-estudiante-img"
                />
                <span className="horario-estudiante-img-hint">
                  Clic para ampliar
                </span>
              </button>
            ) : (
              <p className="horario-estudiante-state horario-estudiante-state--error">
                Este horario no tiene imagen asociada.
              </p>
            )}
          </div>
        )}
      </div>

      <HorarioZoomModal
        abierto={zoomAbierto && Boolean(url)}
        titulo={seleccionado?.TITULO}
        url={url}
        onClose={() => setZoomAbierto(false)}
      />
    </div>
  );
}

function HorarioAdminPage() {
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

export default function HorarioPage({ role }) {
  if (role === "estudiante") {
    return (
      <HorarioEstudianteVista
        idUsuario={localStorage.getItem("idusuario") || ""}
      />
    );
  }
  return <HorarioAdminPage />;
}

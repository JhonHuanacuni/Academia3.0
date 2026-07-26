import { useEffect, useState } from "react";
import { useCrud } from "../../hooks/useCrud";
import { examenConfig } from "./examen.config";
import ExamenFormPage from "./ExamenFormPage";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import { parseJsonResponse } from "../../utils/api";
import "../../styles/mantenedor.css";

export default function ExamenPage() {
  const cfg = examenConfig;
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHAINICIO", direccion: "DESC" },
  });

  const [vista, setVista] = useState("lista");
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [aulas, setAulas] = useState([]);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/examenes/catalogos/");
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
        /* opcional */
      }
    })();
  }, []);

  const volverLista = async () => {
    setVista("lista");
    crud.setRegistro(null);
    await crud.listar();
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
    setConfirm({
      id: row[cfg.pk],
      mensaje: `¿Eliminar el examen «${row.TITULO || row[cfg.pk]}»? Se borrarán todas sus preguntas.`,
    });
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

  const onSaved = async (id, nextModo = "editar") => {
    try {
      const data = await crud.obtener(id);
      crud.setRegistro(data);
      setModo(nextModo);
      setVista("form");
      await crud.listar();
    } catch {
      /* keep form */
    }
  };

  if (vista === "form") {
    return (
      <>
        <ExamenFormPage
          modo={modo}
          registro={crud.registro}
          aulas={aulas}
          onCancel={volverLista}
          onSaved={onSaved}
          onToast={setToast}
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
        <Toolbar buscar={crud.buscar} onBuscarChange={crud.onBuscarChange} />

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

import { useEffect, useState } from "react";
import { useCrud } from "../../hooks/useCrud";
import { informeConsultaConfig } from "./informeConsulta.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Toolbar from "../../components/mantenedor/Toolbar";
import DataTable from "../../components/mantenedor/DataTable";
import Pagination from "../../components/mantenedor/Pagination";
import FormModal from "../../components/mantenedor/FormModal";
import ConfirmDialog from "../../components/mantenedor/ConfirmDialog";
import Toast from "../../components/mantenedor/feedback/Toast";
import { parseJsonResponse } from "../../utils/api";
import "../../styles/mantenedor.css";

const MESES = [
  { value: "1", label: "Enero" },
  { value: "2", label: "Febrero" },
  { value: "3", label: "Marzo" },
  { value: "4", label: "Abril" },
  { value: "5", label: "Mayo" },
  { value: "6", label: "Junio" },
  { value: "7", label: "Julio" },
  { value: "8", label: "Agosto" },
  { value: "9", label: "Septiembre" },
  { value: "10", label: "Octubre" },
  { value: "11", label: "Noviembre" },
  { value: "12", label: "Diciembre" },
];

function aniosOpciones() {
  const y = new Date().getFullYear();
  return [y - 1, y, y + 1].map((n) => ({ value: String(n), label: String(n) }));
}

export default function InformeConsultaPage() {
  const cfg = informeConsultaConfig;
  const hoy = new Date();
  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHA", direccion: "DESC" },
    filtrosIniciales: {
      anio: String(hoy.getFullYear()),
      mes: String(hoy.getMonth() + 1),
      resultado: "",
      canal: "",
    },
  });

  const [modalAbierto, setModalAbierto] = useState(false);
  const [modo, setModo] = useState("crear");
  const [confirm, setConfirm] = useState(null);
  const [toast, setToast] = useState(null);
  const [confirmando, setConfirmando] = useState(false);
  const [catalogos, setCatalogos] = useState({ resultados: [], canales: [] });

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/informes-consulta/catalogos/");
        const data = await parseJsonResponse(res);
        if (res.ok) {
          setCatalogos({
            resultados: data.data?.resultados || [],
            canales: data.data?.canales || [],
          });
        }
      } catch {
        setCatalogos({ resultados: [], canales: [] });
      }
    })();
  }, []);

  const abrirCrear = () => {
    crud.setRegistro(null);
    setModo("crear");
    setModalAbierto(true);
  };

  const abrirVer = async (row) => {
    try {
      const data = await crud.obtener(row[cfg.pk]);
      crud.setRegistro(data);
      setModo("ver");
      setModalAbierto(true);
    } catch (err) {
      setToast({ mensaje: err.message, tipo: "error" });
    }
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
      mensaje: `¿Dar de baja el registro de «${row.NOMBRE || row[cfg.pk]}»? No se borrará de la base; solo dejará de mostrarse.`,
    });
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
    modo === "crear"
      ? "Anotar consulta"
      : modo === "editar"
        ? "Editar consulta"
        : "Ver consulta";

  return (
    <div className="mantenedor-page">
      <PageHeader
        modulo={cfg.modulo}
        vista={cfg.titulo}
        onNuevo={abrirCrear}
        nuevoEtiqueta="Anotar"
      />

      <div className="mantenedor-card">
        <Toolbar
          buscar={crud.buscar}
          onBuscarChange={crud.onBuscarChange}
          filtros={[
            {
              key: "anio",
              etiqueta: "Año",
              value: crud.filtros.anio || "",
              opciones: aniosOpciones(),
              onChange: (v) => crud.setFiltro("anio", v),
            },
            {
              key: "mes",
              etiqueta: "Mes",
              value: crud.filtros.mes || "",
              opciones: MESES,
              onChange: (v) => crud.setFiltro("mes", v),
            },
            {
              key: "resultado",
              etiqueta: "Resultado",
              value: crud.filtros.resultado || "",
              opciones: catalogos.resultados,
              onChange: (v) => crud.setFiltro("resultado", v),
            },
            {
              key: "canal",
              etiqueta: "Canal",
              value: crud.filtros.canal || "",
              opciones: catalogos.canales,
              onChange: (v) => crud.setFiltro("canal", v),
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
        onClose={() => setModalAbierto(false)}
        onSubmit={handleGuardar}
      />

      <ConfirmDialog
        abierto={Boolean(confirm)}
        titulo="Dar de baja"
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

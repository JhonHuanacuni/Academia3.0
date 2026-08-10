import { useCallback, useEffect, useState } from "react";
import { parseJsonResponse } from "../../utils/api";
import { useCrud } from "../../hooks/useCrud";
import {
  claseGrabadaConfig,
  claseGrabadaEstudianteColumnas,
} from "./claseGrabada.config";
import PageHeader from "../../components/mantenedor/PageHeader";
import Pagination from "../../components/mantenedor/Pagination";
import Toast from "../../components/mantenedor/feedback/Toast";
import MateriaChipBar from "./MateriaChipBar";
import ClaseGrabadaTabla from "./ClaseGrabadaTabla";
import "../../styles/mantenedor.css";
import "./claseGrabada.css";

export default function ClaseGrabadaEstudiantePage() {
  const cfg = claseGrabadaConfig;
  const idUsuario = localStorage.getItem("idusuario") || "";

  const crud = useCrud({
    entidad: cfg.entidad,
    pk: cfg.pk,
    ordenInicial: { campo: "FECHASUBIDA", direccion: "DESC" },
    filtrosIniciales: { estado: "Activo", idusuario: idUsuario },
  });

  const [materiasResumen, setMateriasResumen] = useState([]);
  const [totalEnlaces, setTotalEnlaces] = useState(0);
  const [materiaSel, setMateriaSel] = useState("");
  const [toast, setToast] = useState(null);

  const cargarMaterias = useCallback(async () => {
    try {
      const params = new URLSearchParams({ idusuario: idUsuario });
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
  }, [idUsuario]);

  useEffect(() => {
    cargarMaterias();
  }, [cargarMaterias]);

  useEffect(() => {
    crud.setFiltro("idMateria", materiaSel);
  }, [materiaSel]);

  const abrirEnlace = (row) => {
    const url = row.ENLACE;
    if (!url) {
      setToast({ mensaje: "Esta grabación no tiene enlace disponible.", tipo: "error" });
      return;
    }
    window.open(url, "_blank", "noopener,noreferrer");
  };

  return (
    <div className="mantenedor-page">
      <PageHeader modulo={cfg.modulo} vista={cfg.titulo} />

      <div className="mantenedor-card">
        <MateriaChipBar
          materias={materiasResumen}
          totalTodos={totalEnlaces}
          seleccionada={materiaSel}
          onSelect={(id) => {
            setMateriaSel(id);
            crud.setPagina(1);
          }}
        />

        <ClaseGrabadaTabla
          columnas={claseGrabadaEstudianteColumnas}
          items={crud.items}
          pk={cfg.pk}
          orden={crud.orden}
          loading={crud.loading}
          modo="estudiante"
          onOrden={crud.toggleOrden}
          onAbrirEnlace={abrirEnlace}
        />

        <Pagination
          pagina={crud.pagina}
          tamanio={crud.tamanio}
          total={crud.total}
          onChange={crud.setPagina}
        />
      </div>

      {toast && (
        <Toast mensaje={toast.mensaje} tipo={toast.tipo} onClose={() => setToast(null)} />
      )}
    </div>
  );
}

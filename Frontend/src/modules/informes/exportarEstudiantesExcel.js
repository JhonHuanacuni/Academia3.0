import {
  aplicarAnchosColumnas,
  crearWorkbookInforme,
  descargarBufferExcel,
  escribirEncabezadoInforme,
  escribirFilaDatos,
  escribirFilaEncabezados,
} from "../../utils/excelInformeFormato";

const COLUMNAS = [
  { header: "N°", key: "numero", width: 6 },
  { header: "NOMBRES Y APELLIDOS", key: "nombres", width: 36 },
  { header: "DNI", key: "dni", width: 12 },
  { header: "TUTOR", key: "tutora", width: 18 },
  { header: "AULA", key: "aula", width: 28 },
  { header: "PLAN / CICLO", key: "ciclo", width: 28 },
  { header: "CÓMO SE ENTERÓ", key: "comoEntero", width: 22 },
  { header: "DISTRITO", key: "distrito", width: 18 },
  { header: "ESTADO", key: "estado", width: 12 },
];

/**
 * Exportación formal de listado de estudiantes (Informes → Estudiantes).
 */
export async function exportarInformeEstudiantesExcel({ filas, meta = {} }) {
  if (!filas?.length) return;

  const wb = await crearWorkbookInforme();
  const ws = wb.addWorksheet("Estudiantes");

  const metadatos = [
    meta.salon ? `Salón: ${meta.salon}` : null,
    meta.tutor ? `Tutor: ${meta.tutor}` : null,
    meta.plan ? `Plan: ${meta.plan}` : null,
    meta.estado ? `Estado: ${meta.estado}` : "Estado: Todos",
    meta.buscar ? `Búsqueda: ${meta.buscar}` : null,
  ].filter(Boolean);

  const filaHeader = await escribirEncabezadoInforme(wb, ws, {
    titulo: "Informe de estudiantes",
    subtitulo: "Listado consolidado para revisión gerencial",
    metadatos,
    totalColumnas: COLUMNAS.length,
    totalRegistros: filas.length,
  });

  escribirFilaEncabezados(
    ws,
    filaHeader,
    COLUMNAS.map((c) => c.header),
  );

  filas.forEach((fila, idx) => {
    escribirFilaDatos(
      ws,
      [
        fila.numero,
        fila.nombres,
        fila.dni || "",
        fila.tutora || "",
        fila.aula || "",
        fila.ciclo || "",
        fila.comoEntero || "",
        fila.distrito || "",
        fila.estado || "",
      ],
      idx,
    );
  });

  aplicarAnchosColumnas(ws, COLUMNAS.map((c) => c.width));

  const stamp = new Date().toISOString().slice(0, 10);
  const buffer = await wb.xlsx.writeBuffer();
  descargarBufferExcel(buffer, `informe_estudiantes_${stamp}.xlsx`);
}

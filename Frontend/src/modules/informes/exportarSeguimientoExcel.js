import {
  aplicarAnchosColumnas,
  crearWorkbookInforme,
  descargarBufferExcel,
  escribirEncabezadoInforme,
  escribirFilaDatos,
  escribirFilaEncabezados,
} from "../../utils/excelInformeFormato";

export async function exportarInformeSeguimientoExcel({ filas, meta = {} }) {
  if (!filas?.length) return;

  const columnas = [
    { header: "FECHA", width: 12 },
    { header: "NOMBRE", width: 28 },
    { header: "TELÉFONO", width: 14 },
    { header: "CICLO", width: 18 },
    { header: "CÓMO LLEGÓ", width: 16 },
    { header: "RESULTADO", width: 16 },
    { header: "SE ENTERÓ", width: 18 },
    { header: "OBSERVACIÓN", width: 28 },
    { header: "EN ALUMNOS", width: 12 },
  ];

  const wb = await crearWorkbookInforme();
  const ws = wb.addWorksheet("Seguimiento");
  const filaHeader = await escribirEncabezadoInforme(wb, ws, {
    titulo: "Informe de seguimiento",
    subtitulo: "Consultas de información y conversión a matrícula",
    metadatos: [
      meta.periodo ? `Periodo: ${meta.periodo}` : null,
      meta.conversion != null ? `Conversión: ${meta.conversion}%` : null,
    ].filter(Boolean),
    totalColumnas: columnas.length,
    totalRegistros: filas.length,
  });

  escribirFilaEncabezados(ws, filaHeader, columnas.map((c) => c.header));
  filas.forEach((f, i) => {
    escribirFilaDatos(
      ws,
      [
        f.fecha,
        f.nombre,
        f.telefono,
        f.ciclo,
        f.canal,
        f.resultado,
        f.seEntero,
        f.observacion,
        f.enAlumnos ? "Sí" : "",
      ],
      i,
    );
  });

  aplicarAnchosColumnas(ws, columnas.map((c) => c.width));
  const stamp = new Date().toISOString().slice(0, 10);
  descargarBufferExcel(await wb.xlsx.writeBuffer(), `informe_seguimiento_${stamp}.xlsx`);
}

import {
  aplicarAnchosColumnas,
  crearWorkbookInforme,
  descargarBufferExcel,
  escribirEncabezadoInforme,
  escribirFilaDatos,
  escribirFilaEncabezados,
} from "../../utils/excelInformeFormato";

export async function exportarInformeCajaExcel({ filas, meta = {} }) {
  if (!filas?.length) return;

  const columnas = [
    { header: "FECHA", width: 12 },
    { header: "RECIBO", width: 14 },
    { header: "NOMBRE", width: 32 },
    { header: "CICLO / CONCEPTO", width: 24 },
    { header: "MEDIO", width: 18 },
    { header: "MONTO", width: 12 },
    { header: "TIPO", width: 14 },
  ];

  const wb = await crearWorkbookInforme();
  const ws = wb.addWorksheet("Caja");
  const filaHeader = await escribirEncabezadoInforme(wb, ws, {
    titulo: "Informe de caja",
    subtitulo: "Ingresos del mes por medio de pago",
    metadatos: [meta.periodo ? `Periodo: ${meta.periodo}` : null].filter(Boolean),
    totalColumnas: columnas.length,
    totalRegistros: filas.length,
  });

  escribirFilaEncabezados(ws, filaHeader, columnas.map((c) => c.header));
  filas.forEach((f, i) => {
    escribirFilaDatos(
      ws,
      [f.fecha, f.recibo, f.nombre, f.ciclo, f.medio, f.monto, f.tipo],
      i,
    );
  });

  aplicarAnchosColumnas(ws, columnas.map((c) => c.width));
  const stamp = new Date().toISOString().slice(0, 10);
  descargarBufferExcel(await wb.xlsx.writeBuffer(), `informe_caja_${stamp}.xlsx`);
}

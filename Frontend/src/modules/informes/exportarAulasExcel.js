import {
  aplicarAnchosColumnas,
  crearWorkbookInforme,
  descargarBufferExcel,
  escribirEncabezadoInforme,
  escribirFilaDatos,
  escribirFilaEncabezados,
} from "../../utils/excelInformeFormato";

export async function exportarInformeAulasExcel({ filas, totales, meta = {} }) {
  if (!filas?.length) return;

  const columnas = [
    { header: "AULA", width: 28 },
    { header: "AFORO", width: 10 },
    { header: "ALUMNOS", width: 10 },
    { header: "OCUPACIÓN %", width: 12 },
    { header: "CANCELARON", width: 12 },
    { header: "DEBEN", width: 10 },
    { header: "INGRESO MES", width: 14 },
    { header: "COBRADO", width: 14 },
    { header: "POR COBRAR", width: 14 },
  ];

  const wb = await crearWorkbookInforme();
  const ws = wb.addWorksheet("Aulas");
  const filaHeader = await escribirEncabezadoInforme(wb, ws, {
    titulo: "Informe de aulas",
    subtitulo: "Ocupación y cobranza por salón",
    metadatos: [
      meta.periodo ? `Periodo: ${meta.periodo}` : null,
      meta.aula ? `Aula: ${meta.aula}` : "Aula: Todas",
    ].filter(Boolean),
    totalColumnas: columnas.length,
    totalRegistros: filas.length,
  });

  escribirFilaEncabezados(ws, filaHeader, columnas.map((c) => c.header));
  filas.forEach((f, i) => {
    escribirFilaDatos(
      ws,
      [
        f.aula,
        f.aforo,
        f.alumnos,
        f.ocupacion ?? "",
        f.cancelaron,
        f.deben,
        f.ingresoMes,
        f.cobrado,
        f.porCobrar,
      ],
      i,
    );
  });
  if (totales) {
    escribirFilaDatos(
      ws,
      [
        "TOTALES",
        totales.aforo,
        totales.alumnos,
        totales.ocupacion ?? "",
        totales.cancelaron,
        totales.deben,
        totales.ingresoMes,
        totales.cobrado,
        totales.porCobrar,
      ],
      filas.length,
    );
  }

  aplicarAnchosColumnas(ws, columnas.map((c) => c.width));
  const stamp = new Date().toISOString().slice(0, 10);
  descargarBufferExcel(await wb.xlsx.writeBuffer(), `informe_aulas_${stamp}.xlsx`);
}

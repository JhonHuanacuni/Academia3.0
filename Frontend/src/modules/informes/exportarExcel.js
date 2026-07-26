import ExcelJS from "exceljs";
import { estadoVencimientoDesdeFila } from "./informeAsistenciasUtils";

const C = {
  headerBlue: "FF5B9BD5",
  headerDateBlue: "FF2F75B5",
  headerFont: "FFFFFFFF",
  rowEven: "FFDCE6F1",
  rowOdd: "FFFFFFFF",
  sundayBg: "FFB4C6E7",
  noLectivoBg: "FFECEEF4",
  border: "FF8EA9DB",
  borderDark: "FF2F5597",
  greenA: "FF006100",
  redT: "FFC00000",
  redF: "FFFF0000",
  yellowTard: "FFFFFF00",
  cellVenceProxima: "FFFFFF66",
  cellVencida: "FFFF9999",
  black: "FF000000",
  white: "FFFFFFFF",
};

const FIJAS = 7;
const COL_VENCE = 2;

function aplicarEstilo(cell, { fill, font, alignment, border }) {
  if (fill) cell.fill = fill;
  if (font) cell.font = font;
  if (alignment) cell.alignment = alignment;
  if (border) cell.border = border;
}

function borde(estilo = "thin", color = C.border) {
  const b = { style: estilo, color: { argb: color } };
  return { top: b, left: b, bottom: b, right: b };
}

function bordeSemana() {
  const t = { style: "thin", color: { argb: C.border } };
  const r = { style: "medium", color: { argb: C.borderDark } };
  return { top: t, left: t, bottom: t, right: r };
}

function relleno(argb) {
  return { type: "pattern", pattern: "solid", fgColor: { argb } };
}

function fondoCeldaVence(estado, fondoBase) {
  if (estado === "vencida") return C.cellVencida;
  if (estado === "proxima") return C.cellVenceProxima;
  return fondoBase;
}

function estiloMarca(codigo, fondoFila, fueraPlan = false) {
  const base = {
    alignment: { vertical: "middle", horizontal: "center" },
    border: borde(),
    fill: relleno(fondoFila),
    font: { name: "Calibri", size: 9, bold: true, color: { argb: C.black } },
  };
  if (fueraPlan) {
    base.fill = relleno(C.noLectivoBg);
    base.font.color = { argb: "FF6B7280" };
    return base;
  }
  if (codigo === "A") {
    base.font.color = { argb: C.greenA };
  } else if (codigo === "T") {
    base.font.color = { argb: C.redT };
  } else if (codigo === "F") {
    base.fill = relleno(C.redF);
    base.font.color = { argb: C.white };
  } else if (codigo === "R") {
    base.font.color = { argb: C.black };
  }
  return base;
}

function descargarBuffer(buffer, nombre) {
  const blob = new Blob([buffer], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = nombre;
  a.click();
  URL.revokeObjectURL(url);
}

export async function exportarInformeAsistenciasExcel({ filas, dias, fechaDesde, fechaHasta }) {
  if (!filas?.length || !dias?.length) return;

  const wb = new ExcelJS.Workbook();
  const ws = wb.addWorksheet("Asistencias", {
    views: [{ state: "frozen", ySplit: 1, xSplit: 3 }],
  });

  const encabezadosFijos = [
    "N°",
    "NOMBRES Y APELLIDOS",
    "VENCE",
    "TUTORA",
    "AULA",
    "CICLO",
    "ESTADO",
  ];
  const encabezadosTotales = ["TOTAL\nASIST", "TOTAL\nTARD", "TOTAL\nFALTAS"];
  const encabezados = [...encabezadosFijos, ...dias.map((d) => d.etiqueta), ...encabezadosTotales];

  const headerRow = ws.addRow(encabezados);
  headerRow.height = 52;

  encabezados.forEach((_, colIdx) => {
    const cell = headerRow.getCell(colIdx + 1);
    const esDia = colIdx >= FIJAS && colIdx < FIJAS + dias.length;
    const esTotal = colIdx >= FIJAS + dias.length;
    const diaInfo = esDia ? dias[colIdx - FIJAS] : null;
    const esDomingo = diaInfo?.esDomingo || diaInfo?.etiqueta?.startsWith("dom");

    if (esDia && esDomingo) {
      cell.fill = relleno(C.white);
      cell.font = { name: "Calibri", size: 9, bold: true, color: { argb: C.headerDateBlue } };
    } else {
      cell.fill = relleno(esDia ? C.headerDateBlue : C.headerBlue);
      cell.font = { name: "Calibri", size: 9, bold: true, color: { argb: C.headerFont } };
    }
    cell.border = borde();
    cell.alignment = {
      vertical: esDia ? "bottom" : "middle",
      horizontal: "center",
      wrapText: esTotal,
      textRotation: esDia ? 45 : 0,
    };
  });

  filas.forEach((fila, rowIdx) => {
    const fondoFila = rowIdx % 2 === 1 ? C.rowEven : C.rowOdd;
    const estadoVence = estadoVencimientoDesdeFila(fila);
    const noLectivos = new Set(fila.diasNoLectivos || []);

    const valores = [
      fila.numero,
      fila.nombres,
      fila.vence || "",
      fila.tutora,
      fila.aula,
      fila.ciclo,
      fila.estado,
      ...dias.map((d) => fila.marcas[d.fecha] || ""),
      fila.totalAsist,
      fila.totalTard,
      fila.totalFaltas,
    ];

    const row = ws.addRow(valores);
    row.height = 15;

    valores.forEach((valor, colIdx) => {
      const cell = row.getCell(colIdx + 1);
      const esDia = colIdx >= FIJAS && colIdx < FIJAS + dias.length;
      const esTotal = colIdx >= FIJAS + dias.length;
      const diaInfo = esDia ? dias[colIdx - FIJAS] : null;
      const esDomingo = diaInfo?.esDomingo || diaInfo?.etiqueta?.startsWith("dom");
      const esNoLectivo = esDia && diaInfo && noLectivos.has(diaInfo.fecha);
      const codigo = esDia ? String(valor || "") : "";

      let fondo = fondoFila;
      if (esDia && esNoLectivo) fondo = C.noLectivoBg;
      else if (esDia && esDomingo && !codigo) fondo = C.sundayBg;

      if (esDia && codigo) {
        aplicarEstilo(cell, estiloMarca(codigo, fondo, esNoLectivo));
        cell.border = esDomingo ? bordeSemana() : borde();
      } else if (esDia) {
        cell.fill = relleno(fondo);
        cell.font = { name: "Calibri", size: 9 };
        cell.alignment = { vertical: "middle", horizontal: "center" };
        cell.border = esDomingo ? bordeSemana() : borde();
      } else if (colIdx === 1) {
        cell.fill = relleno(fondoFila);
        cell.font = { name: "Calibri", size: 9 };
        cell.alignment = { vertical: "middle", horizontal: "left" };
        cell.border = borde();
      } else if (colIdx === COL_VENCE) {
        cell.fill = relleno(fondoCeldaVence(estadoVence, fondoFila));
        cell.font = { name: "Calibri", size: 9, bold: estadoVence !== "" };
        cell.alignment = { vertical: "middle", horizontal: "center" };
        cell.border = borde();
      } else if (esTotal) {
        const esTard = colIdx === FIJAS + dias.length + 1;
        const esFaltas = colIdx === FIJAS + dias.length + 2;
        let bg = fondoFila;
        let fg = C.black;
        if (esTard && Number(valor) > 0) {
          bg = C.yellowTard;
        }
        if (esFaltas && Number(valor) > 0) {
          bg = C.redF;
          fg = C.white;
        }
        cell.fill = relleno(bg);
        cell.font = { name: "Calibri", size: 9, bold: esFaltas && Number(valor) > 0, color: { argb: fg } };
        cell.alignment = { vertical: "middle", horizontal: "center" };
        cell.border = borde();
      } else {
        cell.fill = relleno(fondoFila);
        cell.font = { name: "Calibri", size: 9 };
        cell.alignment = { vertical: "middle", horizontal: "center" };
        cell.border = borde();
      }
    });
  });

  ws.columns = [
    { width: 4 },
    { width: 36 },
    { width: 12 },
    { width: 12 },
    { width: 6 },
    { width: 18 },
    { width: 9 },
    ...dias.map(() => ({ width: 4.2 })),
    { width: 8 },
    { width: 8 },
    { width: 9 },
  ];

  const buffer = await wb.xlsx.writeBuffer();
  descargarBuffer(buffer, `informe_asistencias_${fechaDesde}_${fechaHasta}.xlsx`);
}

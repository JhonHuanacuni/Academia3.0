export const pagoExtraConfig = {
  modulo: "Mensualidades",
  titulo: "Pagos extraordinarios",
  entidad: "pagos-extraordinarios",
  pk: "GRUPO_KEY",
  columnas: [
    { campo: "ESTUDIANTE_NOMBRE", etiqueta: "Estudiante", ordenable: true },
    { campo: "ESTUDIANTE_DNI", etiqueta: "DNI", ordenable: false },
    { campo: "CONCEPTO_NOMBRE", etiqueta: "Concepto", ordenable: true },
    { campo: "MONTO_TOTAL", etiqueta: "Total a pagar", tipo: "decimal", ordenable: true },
    { campo: "PAGADO", etiqueta: "Pagado", tipo: "decimal", ordenable: true },
    { campo: "DEUDA", etiqueta: "Debe", tipo: "saldoDeuda", ordenable: true },
  ],
  columnasDetalle: [
    { campo: "FECHAPAGO", etiqueta: "Fecha pago", tipo: "fecha", ordenable: false },
    { campo: "MONTO", etiqueta: "Monto", tipo: "decimal", ordenable: false },
    { campo: "OBSERVACIONES", etiqueta: "Observaciones", ordenable: false },
  ],
};

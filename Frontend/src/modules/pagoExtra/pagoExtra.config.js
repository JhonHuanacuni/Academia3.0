export const pagoExtraConfig = {
  modulo: "Mensualidades",
  titulo: "Pagos extraordinarios",
  entidad: "pagos-extraordinarios",
  pk: "IDPAGOEXTRA",
  columnas: [
    { campo: "ESTUDIANTE_NOMBRE", etiqueta: "Estudiante", ordenable: true },
    { campo: "ESTUDIANTE_DNI", etiqueta: "DNI", ordenable: false },
    { campo: "CONCEPTO_NOMBRE", etiqueta: "Concepto", ordenable: true },
    { campo: "MONTO", etiqueta: "Monto", tipo: "decimal", ordenable: true },
    { campo: "FECHAPAGO", etiqueta: "Fecha pago", tipo: "fecha", ordenable: true },
  ],
};

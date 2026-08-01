export const mensualidadEstudianteColumnas = [
  { campo: "_NUMERO", etiqueta: "N°", tipo: "numero", ordenable: false },
  { campo: "PLAN_NOMBRE", etiqueta: "Plan", ordenable: true },
  { campo: "FECHAINICIO", etiqueta: "Inicio", tipo: "fecha", ordenable: true },
  { campo: "FECHAFIN", etiqueta: "Fin", tipo: "fecha", ordenable: true },
  {
    campo: "DIAS_RESTANTES",
    etiqueta: "Días restantes",
    tipo: "diasRestantes",
    origen: "FECHAFIN",
    ordenable: false,
  },
  { campo: "MONTOTOTAL", etiqueta: "Total", tipo: "decimal", ordenable: true },
  { campo: "PAGADO", etiqueta: "Pagado", tipo: "decimal", ordenable: true },
  { campo: "DEUDA", etiqueta: "Deuda", tipo: "deuda", ordenable: true },
];

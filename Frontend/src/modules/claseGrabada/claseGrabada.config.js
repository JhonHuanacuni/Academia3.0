export const claseGrabadaConfig = {
  modulo: "Académico",
  titulo: "Clases grabadas",
  entidad: "clases-grabadas",
  pk: "IDCLASEGRABADA",
};

export const claseGrabadaAdminColumnas = [
  { campo: "IDCLASEGRABADA", etiqueta: "ID", ordenable: true },
  { campo: "AULA_NOMBRE", etiqueta: "Salón", ordenable: true, soloSinFiltroAula: true },
  { campo: "DETALLES", etiqueta: "Detalles", ordenable: true },
  { campo: "TIENE_ENLACE", etiqueta: "Enlace", tipo: "siNo", ordenable: false },
  { campo: "FECHASUBIDA", etiqueta: "Fecha de subida", tipo: "fechaHora", ordenable: true },
  { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
];

export const claseGrabadaEstudianteColumnas = [
  { campo: "DETALLES", etiqueta: "Detalles", ordenable: true },
  { campo: "FECHASUBIDA", etiqueta: "Fecha de subida", tipo: "fechaHora", ordenable: true },
];

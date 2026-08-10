export const claseGrabadaConfig = {
  modulo: "Académico",
  titulo: "Clases grabadas",
  entidad: "clases-grabadas",
  pk: "IDCLASEGRABADA",
};

export const claseGrabadaAdminColumnas = [
  { campo: "IDCLASEGRABADA", etiqueta: "ID", ordenable: true },
  { campo: "AULA_NOMBRE", etiqueta: "Salón", ordenable: true },
  { campo: "DETALLES", etiqueta: "Detalles", ordenable: true },
  { campo: "TIENE_ENLACE", etiqueta: "Enlace", tipo: "siNo", ordenable: false },
  { campo: "FECHASUBIDA", etiqueta: "Fecha de subida", tipo: "fechaHora", ordenable: true },
  { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  { campo: "CREADO_POR_NOMBRE", etiqueta: "Creado por", ordenable: false },
  { campo: "FECHACREACION", etiqueta: "Fecha creación", tipo: "fechaHoraAudit", origenHora: "HORACREACION", ordenable: false },
  { campo: "MODIFICADO_POR_NOMBRE", etiqueta: "Modificado por", ordenable: false },
  { campo: "FECHAMODIFICACION", etiqueta: "Última modificación", tipo: "fechaHoraAudit", origenHora: "HORAMODIFICACION", ordenable: false },
];

export const claseGrabadaEstudianteColumnas = [
  { campo: "DETALLES", etiqueta: "Detalles", ordenable: true },
  { campo: "FECHASUBIDA", etiqueta: "Fecha de subida", tipo: "fechaHora", ordenable: true },
];

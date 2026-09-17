const columnasStaff = [
  { campo: "FECHAREGISTRO", etiqueta: "Fecha", tipo: "fecha", ordenable: true },
  { campo: "HORAINICIO", etiqueta: "Hora", tipo: "hora", ordenable: true },
  { campo: "DNI", etiqueta: "DNI", ordenable: true },
  {
    campo: "ESTUDIANTE_NOMBRE",
    etiqueta: "Nombre",
    ordenable: true,
  },
  { campo: "ESTADO", etiqueta: "Estado", tipo: "asistenciaEstado", ordenable: true },
];

const columnasEstudiante = [
  { campo: "FECHAREGISTRO", etiqueta: "Fecha", tipo: "fecha", ordenable: true },
  { campo: "HORAINICIO", etiqueta: "Hora", tipo: "hora", ordenable: true },
  { campo: "ESTADO", etiqueta: "Estado", tipo: "asistenciaEstado", ordenable: true },
];

export const asistenciaListadoConfig = {
  modulo: "Asistencias",
  titulo: "Ver asistencias",
  entidad: "asistencias",
  pk: "IDASISTENCIA",
  columnas: columnasStaff,
  columnasEstudiante,
};

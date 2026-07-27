export const asistenciaListadoConfig = {
  modulo: "Asistencias",
  titulo: "Asistencias de hoy",
  entidad: "asistencias",
  pk: "IDASISTENCIA",
  columnas: [
    { campo: "HORAINICIO", etiqueta: "Hora", tipo: "hora", ordenable: false },
    { campo: "DNI", etiqueta: "DNI", ordenable: false },
    {
      campo: "ESTUDIANTE_NOMBRE",
      etiqueta: "Nombre",
      ordenable: false,
    },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "asistenciaEstado", ordenable: false },
  ],
};

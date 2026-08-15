export const asistenciaListadoConfig = {
  modulo: "Asistencias",
  titulo: "Ver asistencias",
  entidad: "asistencias",
  pk: "IDASISTENCIA",
  columnas: [
    { campo: "FECHAREGISTRO", etiqueta: "Fecha", tipo: "fecha", ordenable: false },
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

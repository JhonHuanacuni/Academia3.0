export const justificacionConfig = {
  modulo: "Asistencias",
  titulo: "Justificación",
  entidad: "justificaciones",
  pk: "IDJUSTIFICACION",
  columnas: [
    { campo: "FECHA", etiqueta: "Fecha", tipo: "fecha", ordenable: false },
    { campo: "HORAREGISTRO", etiqueta: "Hora", tipo: "hora", ordenable: false },
    { campo: "ESTUDIANTE_NOMBRE", etiqueta: "Estudiante", ordenable: false },
    { campo: "DNI", etiqueta: "DNI", ordenable: false },
    { campo: "REGISTRADOR_NOMBRE", etiqueta: "Justificado por", ordenable: false },
    { campo: "OBSERVACION", etiqueta: "Observación", ordenable: false },
  ],
  secciones: [
    {
      titulo: "Datos de la justificación",
      campos: [
        {
          campo: "IDUSUARIO",
          etiqueta: "Estudiante",
          control: "estudiante",
          obligatorio: true,
          full: true,
          ayuda: "Busca y selecciona al estudiante.",
        },
        {
          campo: "FECHA",
          etiqueta: "Fecha a justificar",
          control: "date",
          obligatorio: true,
          defaultHoy: true,
        },
        {
          campo: "REGISTRADOR_NOMBRE",
          etiqueta: "Justificado por",
          control: "text",
          bloqueado: true,
          full: true,
        },
        {
          campo: "OBSERVACION",
          etiqueta: "Observación",
          control: "textarea",
          obligatorio: true,
          full: true,
          ayuda: "Motivo o detalle de la justificación.",
        },
      ],
    },
  ],
};

justificacionConfig.campos = justificacionConfig.secciones.flatMap((s) => s.campos);

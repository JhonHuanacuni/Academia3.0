export const mensajeConfig = {
  modulo: "Académico",
  titulo: "Mensajes",
  entidad: "mensajes",
  pk: "IDMENSAJE",
  columnas: [
    { campo: "TITULO", etiqueta: "Título", ordenable: true },
    { campo: "DESTINATARIO", etiqueta: "Dirigido a", ordenable: true },
    { campo: "FECHAINICIO", etiqueta: "Inicio", tipo: "fecha", ordenable: true },
    { campo: "FECHAFIN", etiqueta: "Fin", tipo: "fecha", ordenable: true },
    { campo: "AUTOR", etiqueta: "Autor", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Aviso",
      campos: [
        { campo: "TITULO", etiqueta: "Título", control: "text", obligatorio: true, full: true },
        {
          campo: "MENSAJE",
          etiqueta: "Mensaje",
          control: "textarea",
          obligatorio: true,
          full: true,
          rows: 5,
        },
        {
          campo: "DESTINATARIO",
          etiqueta: "Dirigido a",
          control: "select",
          opciones: ["Estudiantes", "Trabajadores", "Todos"],
          obligatorio: true,
          defaultValue: "Estudiantes",
        },
        {
          campo: "FECHAINICIO",
          etiqueta: "Fecha de inicio",
          control: "date",
          obligatorio: true,
          defaultHoy: true,
        },
        {
          campo: "FECHAFIN",
          etiqueta: "Fecha final",
          control: "date",
          obligatorio: true,
          defaultHoy: true,
        },
        {
          campo: "ESTADO",
          etiqueta: "Estado",
          control: "select",
          opciones: ["Activo", "Inactivo"],
          obligatorio: true,
          defaultValue: "Activo",
        },
      ],
    },
    {
      titulo: "Registro",
      campos: [
        { campo: "AUTOR", etiqueta: "Autor", control: "text", soloEditar: true, bloqueado: true },
        { campo: "FECHACREACION", etiqueta: "Fecha de creación", control: "date", soloEditar: true, bloqueado: true },
        { campo: "HORACREACION", etiqueta: "Hora de creación", control: "text", soloEditar: true, bloqueado: true },
        { campo: "FECHAMODIFICACION", etiqueta: "Fecha de modificación", control: "date", soloEditar: true, bloqueado: true },
        { campo: "HORAMODIFICACION", etiqueta: "Hora de modificación", control: "text", soloEditar: true, bloqueado: true },
      ],
    },
  ],
};

mensajeConfig.campos = mensajeConfig.secciones.flatMap((s) => s.campos);

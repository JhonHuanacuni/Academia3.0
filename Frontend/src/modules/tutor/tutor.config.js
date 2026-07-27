export const tutorConfig = {
  modulo: "Mantenedores",
  titulo: "Tutores",
  entidad: "tutores",
  pk: "IDTUTOR",
  columnas: [
    { campo: "IDTUTOR", etiqueta: "Código", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos del tutor",
      campos: [
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
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
  ],
};

tutorConfig.campos = tutorConfig.secciones.flatMap((s) => s.campos);

export const aulaConfig = {
  modulo: "Mantenedores",
  titulo: "Aulas",
  entidad: "aulas",
  pk: "IDAULA",
  columnas: [
    { campo: "IDAULA", etiqueta: "Código", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "TUTOR_NOMBRE", etiqueta: "Tutor", ordenable: true },
    { campo: "CAPACIDAD", etiqueta: "Capacidad", ordenable: true },
    { campo: "DESCRIPCION", etiqueta: "Descripción", ordenable: false },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos del aula",
      campos: [
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
        {
          campo: "CAPACIDAD",
          etiqueta: "Capacidad",
          control: "number",
          obligatorio: false,
          defaultValue: "20",
        },
        {
          campo: "ESTADO",
          etiqueta: "Estado",
          control: "select",
          opciones: ["Activo", "Inactivo"],
          obligatorio: true,
          defaultValue: "Activo",
        },
        { campo: "DESCRIPCION", etiqueta: "Descripción", control: "textarea", full: true },
      ],
    },
    {
      titulo: "Asignación",
      campos: [
        {
          campo: "IDTUTOR",
          etiqueta: "Tutor",
          control: "select",
          catalogo: "tutores",
          full: true,
          ayuda: "Tutor asignado al salón. Se usará al registrar mensualidades.",
        },
      ],
    },
    {
      titulo: "Enlaces (opcional)",
      campos: [
        { campo: "ENLACEVIRTUAL", etiqueta: "Enlace virtual (clase online)", control: "text", full: true },
        { campo: "ENLACECUESTIONARIO", etiqueta: "Enlace cuestionario", control: "text", full: true },
      ],
    },
  ],
};

aulaConfig.campos = aulaConfig.secciones.flatMap((s) => s.campos);

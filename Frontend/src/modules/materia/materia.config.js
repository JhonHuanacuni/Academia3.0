export const materiaConfig = {
  modulo: "Mantenedores",
  titulo: "Materias",
  entidad: "materias",
  pk: "IDMATERIA",
  columnas: [
    { campo: "IDMATERIA", etiqueta: "Código", ordenable: true },
    { campo: "CODIGO", etiqueta: "Abrev.", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "CATEGORIA_NOMBRE", etiqueta: "Categoría", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos de la materia",
      campos: [
        {
          campo: "CODIGO",
          etiqueta: "Abreviatura",
          control: "text",
          obligatorio: true,
          ayuda: "Ej. ARIT, HM, FIS",
        },
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
        {
          campo: "IDCATEGORIA",
          etiqueta: "Categoría",
          control: "select",
          catalogo: "categorias",
          obligatorio: true,
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
  ],
};

materiaConfig.campos = materiaConfig.secciones.flatMap((s) => s.campos);

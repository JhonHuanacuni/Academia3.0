export const categoriaConfig = {
  modulo: "Mantenedores",
  titulo: "Categorías",
  entidad: "categorias",
  pk: "IDCATEGORIA",
  columnas: [
    { campo: "IDCATEGORIA", etiqueta: "Código", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "PORCENTAJE", etiqueta: "Porcentaje", tipo: "porcentaje", ordenable: true },
    { campo: "ORDEN", etiqueta: "Orden", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos de la categoría",
      campos: [
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
        {
          campo: "PORCENTAJE",
          etiqueta: "Porcentaje",
          control: "number",
          obligatorio: true,
          defaultValue: "0",
        },
        {
          campo: "ORDEN",
          etiqueta: "Orden",
          control: "number",
          obligatorio: true,
          defaultValue: "0",
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

categoriaConfig.campos = categoriaConfig.secciones.flatMap((s) => s.campos);

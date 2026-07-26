export const conceptoConfig = {
  modulo: "Mantenedores",
  titulo: "Conceptos",
  entidad: "conceptos",
  pk: "IDCONCEPTO",
  columnas: [
    { campo: "IDCONCEPTO", etiqueta: "Código", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "COSTO", etiqueta: "Costo", tipo: "decimal", ordenable: true },
    { campo: "FECHAINICIO", etiqueta: "Inicio", tipo: "fecha", ordenable: true },
    { campo: "FECHAFIN", etiqueta: "Fin", tipo: "fecha", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos del concepto",
      campos: [
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
        { campo: "COSTO", etiqueta: "Costo", control: "number", obligatorio: true, defaultValue: "0" },
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

conceptoConfig.campos = conceptoConfig.secciones.flatMap((s) => s.campos);

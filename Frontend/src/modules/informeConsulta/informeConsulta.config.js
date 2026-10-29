export const informeConsultaConfig = {
  modulo: "Académico",
  titulo: "Informes",
  entidad: "informes-consulta",
  pk: "IDINFORMECONSULTA",
  columnas: [
    { campo: "FECHA", etiqueta: "Fecha", tipo: "fecha", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "TELEFONO", etiqueta: "Teléfono", ordenable: true },
    { campo: "CICLO_INTERES", etiqueta: "Ciclo de interés", ordenable: false },
    { campo: "CANAL_LABEL", etiqueta: "Cómo llegó", ordenable: false },
    { campo: "RESULTADO_LABEL", etiqueta: "Resultado", ordenable: false },
    { campo: "SE_ENTERO", etiqueta: "Se enteró por", ordenable: false },
    { campo: "OBSERVACION", etiqueta: "Observación", ordenable: false },
  ],
  secciones: [
    {
      titulo: "Datos de la consulta",
      campos: [
        {
          campo: "FECHA",
          etiqueta: "Fecha",
          control: "date",
          obligatorio: true,
          defaultHoy: true,
        },
        {
          campo: "NOMBRE",
          etiqueta: "Nombre",
          control: "text",
          obligatorio: true,
        },
        {
          campo: "TELEFONO",
          etiqueta: "Teléfono",
          control: "text",
          obligatorio: false,
        },
        {
          campo: "CICLO_INTERES",
          etiqueta: "Ciclo de interés",
          control: "text",
          obligatorio: false,
        },
        {
          campo: "CANAL",
          etiqueta: "Cómo llegó",
          control: "select",
          catalogo: "canales",
          obligatorio: true,
          defaultValue: "presencial",
        },
        {
          campo: "RESULTADO",
          etiqueta: "Resultado",
          control: "select",
          catalogo: "resultados",
          obligatorio: true,
          defaultValue: "interesado",
          ayuda: "Interesado = prospecto. En seguimiento = sigue preguntando. Matriculado = ya se inscribió.",
        },
        {
          campo: "SE_ENTERO",
          etiqueta: "Se enteró por",
          control: "text",
          obligatorio: false,
          placeholder: "Redes, referido…",
        },
        {
          campo: "OBSERVACION",
          etiqueta: "Observación",
          control: "textarea",
          full: true,
          obligatorio: false,
        },
      ],
    },
  ],
};

informeConsultaConfig.campos = informeConsultaConfig.secciones.flatMap((s) => s.campos);

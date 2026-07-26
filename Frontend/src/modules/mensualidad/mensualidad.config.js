export const mensualidadConfig = {
  modulo: "Mensualidades",
  titulo: "Listado de Mensualidades",
  entidad: "mensualidades",
  pk: "IDMENSUALIDAD",
  columnas: [
    { campo: "_NUMERO", etiqueta: "N°", tipo: "numero", ordenable: false },
    { campo: "ESTUDIANTE_NOMBRE", etiqueta: "Estudiante", ordenable: true },
    { campo: "PLAN_NOMBRE", etiqueta: "Plan", ordenable: false },
    { campo: "TURNO_DESCRIPCION", etiqueta: "Turno", ordenable: false },
    {
      campo: "ESTADOMIEMBRO_DESCRIPCION",
      etiqueta: "Estado",
      tipo: "estadoMensualidad",
      ordenable: false,
    },
    { campo: "FECHAINICIO", etiqueta: "Inicio", tipo: "fecha", ordenable: true },
    { campo: "FECHAFIN", etiqueta: "Fin", tipo: "fecha", ordenable: true },
    {
      campo: "DIAS_RESTANTES",
      etiqueta: "Días restantes",
      tipo: "diasRestantes",
      origen: "FECHAFIN",
      ordenable: false,
    },
    { campo: "DEUDA", etiqueta: "Deuda", tipo: "deuda", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Estudiante",
      campos: [
        {
          campo: "IDUSUARIO",
          etiqueta: "Buscar estudiante",
          control: "estudiante",
          obligatorio: true,
          full: true,
          ayuda: "Busca y selecciona un estudiante para asignar la mensualidad.",
        },
      ],
    },
    {
      titulo: "Plan y mensualidad",
      grupo: "plan-fechas",
      campos: [
        {
          campo: "IDPLAN",
          etiqueta: "Tipo de plan",
          control: "select",
          catalogo: "planes",
          obligatorio: true,
        },
        {
          campo: "IDTURNO",
          etiqueta: "Turno",
          control: "select",
          catalogo: "turnos",
        },
        {
          campo: "ESTADOMIEMBRO",
          etiqueta: "Estado mensualidad",
          control: "select",
          catalogo: "estadosMensualidad",
          obligatorio: true,
          defaultValue: "2",
        },
        {
          campo: "FECHAREGISTRO",
          etiqueta: "Fecha de registro",
          control: "date",
          defaultHoy: true,
          bloqueado: true,
          ayuda: "Se asigna automáticamente al crear la mensualidad.",
        },
      ],
    },
    {
      titulo: "Fechas y montos",
      grupo: "plan-fechas",
      campos: [
        { campo: "FECHAINICIO", etiqueta: "Fecha inicio", control: "date", obligatorio: true, defaultHoy: true },
        { campo: "FECHAFIN", etiqueta: "Fecha fin", control: "date", obligatorio: true },
        {
          campo: "MONTOTOTAL",
          etiqueta: "Monto total",
          control: "number",
          obligatorio: true,
          ayuda: "Valor total de la mensualidad",
          full: true,
        },
        {
          campo: "PAGOINICIAL",
          etiqueta: "Pago inicial",
          control: "number",
          soloCrear: true,
          ayuda: "Primer pago de la mensualidad",
        },
        {
          campo: "IDMETODOPAGO",
          etiqueta: "Método de pago",
          control: "select",
          catalogo: "metodosPago",
          soloCrear: true,
          defaultValue: "MPG001",
        },
      ],
    },
    {
      titulo: "Asignación",
      grupo: "asignacion-obs",
      campos: [
        {
          campo: "IDAULA",
          etiqueta: "Salón",
          control: "select",
          catalogo: "aulas",
        },
        {
          campo: "IDTUTOR",
          etiqueta: "Tutor",
          control: "select",
          catalogo: "tutores",
        },
      ],
    },
    {
      titulo: "Observaciones",
      grupo: "asignacion-obs",
      campos: [
        {
          campo: "OBSERVACIONES",
          etiqueta: "Observaciones adicionales",
          control: "textarea",
          full: true,
        },
      ],
    },
  ],
};

mensualidadConfig.campos = mensualidadConfig.secciones.flatMap((s) => s.campos);

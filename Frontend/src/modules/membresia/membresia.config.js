export const membresiaConfig = {
  titulo: "Membresías",
  entidad: "membresias",
  pk: "IDMEMBRESIA",
  columnas: [
    { campo: "ESTUDIANTE_NOMBRE", etiqueta: "Estudiante", ordenable: true },
    { campo: "ESTUDIANTE_DNI", etiqueta: "DNI", ordenable: false },
    { campo: "PLAN_NOMBRE", etiqueta: "Plan", ordenable: false },
    { campo: "TURNO_DESCRIPCION", etiqueta: "Turno", ordenable: false },
    { campo: "ESTADOMIEMBRO_DESCRIPCION", etiqueta: "Estado miembro", ordenable: false },
    { campo: "FECHAINICIO", etiqueta: "Inicio", tipo: "fecha", ordenable: true },
    { campo: "FECHAFIN", etiqueta: "Fin", tipo: "fecha", ordenable: true },
    { campo: "MONTOTOTAL", etiqueta: "Monto", tipo: "decimal", ordenable: true },
    { campo: "AULA_NOMBRE", etiqueta: "Salón", ordenable: false },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: false },
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
          ayuda: "Busca y selecciona un estudiante para asignar la membresía.",
        },
      ],
    },
    {
      titulo: "Plan y membresía",
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
          etiqueta: "Estado del miembro",
          control: "select",
          catalogo: "estadosMiembro",
          obligatorio: true,
          defaultValue: "1",
        },
        {
          campo: "TIPOMEMBRESIA",
          etiqueta: "Tipo de membresía",
          control: "select",
          catalogo: "tiposMembresia",
          defaultValue: "Individual",
        },
      ],
    },
    {
      titulo: "Fechas y montos",
      campos: [
        { campo: "FECHAINICIO", etiqueta: "Fecha inicio", control: "date", obligatorio: true, defaultHoy: true },
        { campo: "FECHAFIN", etiqueta: "Fecha fin", control: "date", obligatorio: true },
        {
          campo: "MONTOTOTAL",
          etiqueta: "Monto total",
          control: "number",
          obligatorio: true,
          ayuda: "Valor total de la membresía",
        },
        {
          campo: "PAGOINICIAL",
          etiqueta: "Pago inicial",
          control: "number",
          soloCrear: true,
          ayuda: "Primer pago de la membresía",
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
      campos: [
        {
          campo: "IDAULA",
          etiqueta: "Salón",
          control: "select",
          catalogo: "aulas",
        },
        { campo: "ASESOR", etiqueta: "Asesor", control: "text", ayuda: "Nombre del asesor" },
      ],
    },
    {
      titulo: "Observaciones",
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

membresiaConfig.campos = membresiaConfig.secciones.flatMap((s) => s.campos);

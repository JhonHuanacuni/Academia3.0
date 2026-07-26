export const planConfig = {
  modulo: "Mantenedores",
  titulo: "Planes",
  entidad: "planes",
  pk: "IDPLAN",
  columnas: [
    { campo: "IDPLAN", etiqueta: "Código", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "DESCRIPCION", etiqueta: "Descripción", ordenable: false },
    { campo: "COSTOMENSUAL", etiqueta: "Costo mensual", tipo: "decimal", ordenable: true },
    { campo: "DIASASISTENCIA", etiqueta: "Días asistencia", tipo: "diasAsistencia", ordenable: false },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos del plan",
      campos: [
        { campo: "IDPLAN", etiqueta: "Código", control: "text", obligatorio: true, soloCrear: true },
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
        {
          campo: "COSTOMENSUAL",
          etiqueta: "Costo mensual",
          control: "number",
          obligatorio: true,
          min: 0,
          step: 0.01,
        },
        {
          campo: "ESTADO",
          etiqueta: "Estado",
          control: "select",
          opciones: ["Activo", "Inactivo"],
          obligatorio: true,
          defaultValue: "Activo",
        },
        {
          campo: "DIASASISTENCIA",
          etiqueta: "Días de asistencia",
          control: "diasSemana",
          obligatorio: true,
          full: true,
          defaultValue: 63,
          ayuda: "Días de la semana en que los estudiantes de este plan pueden asistir. Afecta el informe de asistencias y la referencia en horarios.",
        },
        { campo: "DESCRIPCION", etiqueta: "Descripción", control: "textarea", full: true },
      ],
    },
  ],
};

planConfig.campos = planConfig.secciones.flatMap((s) => s.campos);

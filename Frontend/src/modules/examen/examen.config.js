export const examenConfig = {
  modulo: "Académico",
  titulo: "Exámenes",
  entidad: "examenes",
  pk: "IDEXAMEN",
  columnas: [
    { campo: "TITULO", etiqueta: "Título", ordenable: true },
    { campo: "TIPO", etiqueta: "Tipo", tipo: "tipoExamen", ordenable: true },
    { campo: "CANTPREGUNTAS", etiqueta: "Preguntas", ordenable: false },
    { campo: "FECHAINICIO", etiqueta: "Inicio", tipo: "fecha", ordenable: true },
    { campo: "FECHAFIN", etiqueta: "Cierre", tipo: "fecha", ordenable: true },
    { campo: "DURACIONMIN", etiqueta: "Minutos", ordenable: false },
    { campo: "VISIBLE", etiqueta: "Visible", tipo: "visibleExamen", ordenable: false },
  ],
};

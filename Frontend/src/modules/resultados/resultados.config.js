export const resultadosColumnasStaff = [
  { campo: "_NUMERO", etiqueta: "N°", tipo: "numero", ordenable: false },
  { campo: "ESTUDIANTE", etiqueta: "Estudiante", ordenable: true },
  { campo: "DNI", etiqueta: "DNI", ordenable: true },
  { campo: "PUNTAJEOBTENIDO", etiqueta: "Puntaje", tipo: "nota", ordenable: true },
  { campo: "CANTCORRECTAS", etiqueta: "Correctas", ordenable: true },
  { campo: "CANTINCORRECTAS", etiqueta: "Incorrectas", ordenable: true },
  { campo: "ESTADOINTENTO", etiqueta: "Intento", tipo: "intentoEstado", ordenable: true },
];

export const resultadosColumnasEstudiante = [
  { campo: "_NUMERO", etiqueta: "N°", tipo: "numero", ordenable: false },
  { campo: "EXAMEN", etiqueta: "Examen", ordenable: true },
  { campo: "FECHAFIN", etiqueta: "Fecha", tipo: "fecha", ordenable: true },
  { campo: "PUNTAJEOBTENIDO", etiqueta: "Puntaje", tipo: "nota", ordenable: true },
  { campo: "CANTCORRECTAS", etiqueta: "Correctas", ordenable: true },
  { campo: "CANTINCORRECTAS", etiqueta: "Incorrectas", ordenable: true },
  { campo: "ESTADOINTENTO", etiqueta: "Intento", tipo: "intentoEstado", ordenable: true },
];

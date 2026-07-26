export const horarioConfig = {
  modulo: "Académico",
  titulo: "Horario",
  entidad: "horarios",
  pk: "IDHORARIO",
  columnas: [
    { campo: "IDHORARIO", etiqueta: "ID", ordenable: true },
    { campo: "TITULO", etiqueta: "Título", ordenable: true },
    { campo: "DESCRIPCION", etiqueta: "Descripción", ordenable: false },
    { campo: "FECHASUBIDA", etiqueta: "Fecha de subida", tipo: "fecha", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
};

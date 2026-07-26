export const bibliotecaConfig = {
  modulo: "Académico",
  titulo: "Biblioteca",
  entidad: "libros",
  pk: "IDLIBRO",
  columnas: [
    { campo: "IDLIBRO", etiqueta: "ID", ordenable: true },
    { campo: "TITULO", etiqueta: "Título", ordenable: true },
    { campo: "DESCRIPCION", etiqueta: "Descripción", ordenable: false },
    { campo: "FECHASUBIDA", etiqueta: "Fecha de subida", tipo: "fecha", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
};

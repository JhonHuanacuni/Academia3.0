export const notasConfig = {
  modulo: "Académico",
  titulo: "Importar notas",
  entidad: "notas-importacion",
  pk: "IDIMPORTACION",
  columnas: [
    { campo: "_NUMERO", etiqueta: "N°", tipo: "numero", ordenable: false },
    { campo: "NOMBRE_ARCHIVO", etiqueta: "Archivo", ordenable: true },
    { campo: "FECHA_EXAMEN", etiqueta: "Fecha examen", tipo: "fecha", ordenable: true },
    { campo: "TIPO_IMPORTACION", etiqueta: "Tipo", tipo: "tipoExamen", ordenable: true },
    { campo: "TIPO_EXAMEN", etiqueta: "Modo", ordenable: false },
    { campo: "AULA_NOMBRE", etiqueta: "Salón", ordenable: true },
    { campo: "TOTAL_NOTAS", etiqueta: "Estudiantes", ordenable: true },
    { campo: "IMPORTADO_POR", etiqueta: "Importado por", ordenable: true },
  ],
};

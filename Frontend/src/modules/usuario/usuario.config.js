export const usuarioConfig = {
  titulo: "Listado de Usuarios",
  entidad: "usuarios",
  pk: "IDUSUARIO",
  columnas: [
    { campo: "IDUSUARIO", etiqueta: "Usuario", ordenable: true },
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "APELLIDO", etiqueta: "Apellido", ordenable: true },
    { campo: "DNI", etiqueta: "DNI", ordenable: true },
    { campo: "EMAIL", etiqueta: "Email", ordenable: true },
    { campo: "TIPOUSUARIO_DESCRIPCION", etiqueta: "Tipo", ordenable: false },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
  {
    titulo: "Acceso al sistema",
    campos: [
      { campo: "IDUSUARIO", etiqueta: "Usuario", control: "text", obligatorio: true, soloCrear: true },
      { campo: "CONTRA", etiqueta: "Contraseña", control: "password", obligatorio: true, soloCrear: false },
      {
        campo: "IDTIPOUSUARIO",
        etiqueta: "Tipo de usuario",
        control: "select",
        catalogo: "tiposUsuario",
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
  {
    titulo: "Datos personales",
    campos: [
      { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
      { campo: "APELLIDO", etiqueta: "Apellido", control: "text", obligatorio: true },
      { campo: "DNI", etiqueta: "DNI", control: "text", obligatorio: true, validacion: "dni" },
      { campo: "FECHANACIMIENTO", etiqueta: "Fecha de nacimiento", control: "date" },
      { campo: "FOTO", etiqueta: "Foto de perfil", control: "image", full: true },
    ],
  },
  {
    titulo: "Contacto",
    campos: [
      { campo: "EMAIL", etiqueta: "Email", control: "text", obligatorio: true, validacion: "email", full: true },
      { campo: "TELPERSONAL", etiqueta: "Teléfono personal", control: "text" },
      { campo: "TELAPODERADO", etiqueta: "Teléfono apoderado", control: "text" },
      { campo: "DIRECCION", etiqueta: "Dirección", control: "text", full: true },
      { campo: "DISTRITO", etiqueta: "Distrito", control: "text" },
    ],
  },
  {
    titulo: "Datos académicos",
    campos: [
      { campo: "COLEGIO", etiqueta: "Colegio", control: "text" },
      { campo: "GRADO", etiqueta: "Grado", control: "text" },
      { campo: "SITUACIONACADEMICA", etiqueta: "Situación académica", control: "text", full: true },
    ],
  },
  ],
};

// Lista plana para validación y valores por defecto
usuarioConfig.campos = usuarioConfig.secciones.flatMap((s) => s.campos);

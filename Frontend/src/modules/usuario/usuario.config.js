export const usuarioConfig = {
  modulo: "Usuarios",
  titulo: "Listado de Usuarios",
  entidad: "usuarios",
  pk: "IDUSUARIO",
  columnas: [
    { campo: "NOMBRE", etiqueta: "Nombre", ordenable: true },
    { campo: "APELLIDO", etiqueta: "Apellido", ordenable: true },
    { campo: "DNI", etiqueta: "DNI", ordenable: true },
    { campo: "TELAPODERADO", etiqueta: "Cel. apoderado", ordenable: true },
    { campo: "TIPOUSUARIO_DESCRIPCION", etiqueta: "Tipo", ordenable: true },
    { campo: "ESTADO", etiqueta: "Estado", tipo: "estado", ordenable: true },
  ],
  secciones: [
    {
      titulo: "Datos personales",
      campos: [
        { campo: "NOMBRE", etiqueta: "Nombre", control: "text", obligatorio: true },
        { campo: "APELLIDO", etiqueta: "Apellido", control: "text", obligatorio: true },
        { campo: "DNI", etiqueta: "DNI", control: "text", obligatorio: true, validacion: "dni" },
        { campo: "FECHANACIMIENTO", etiqueta: "Fecha de nacimiento", control: "date" },
        { campo: "EMAIL", etiqueta: "Email", control: "text", obligatorio: true, validacion: "email" },
        { campo: "TELPERSONAL", etiqueta: "Teléfono personal", control: "text" },
        { campo: "DIRECCION", etiqueta: "Dirección", control: "text" },
        { campo: "DISTRITO", etiqueta: "Distrito", control: "text" },
        {
          campo: "COMOENTERO",
          etiqueta: "¿De qué manera se enteró?",
          control: "select",
          catalogo: "mediosEntero",
          obligatorio: true,
        },
        { campo: "FOTO", etiqueta: "Foto de perfil", control: "image", full: true },
      ],
    },
    {
      titulo: "Acceso al sistema",
      campos: [
        {
          campo: "CONTRA",
          etiqueta: "Contraseña",
          control: "password",
          soloCrear: false,
          ayuda: "Opcional al crear. Si la dejas vacía, se usará el DNI como contraseña.",
        },
        {
          campo: "CONFIRMAR_CONTRA",
          etiqueta: "Confirmar contraseña",
          control: "password",
          soloCrear: true,
          soloFrontend: true,
        },
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
      titulo: "Datos del apoderado",
      grupo: "extra",
      campos: [
        { campo: "NOMBREAPODERADO", etiqueta: "Nombre y apellido", control: "text", obligatorio: true, full: true },
        { campo: "TELAPODERADO", etiqueta: "Celular", control: "text", obligatorio: true },
        { campo: "PARENTESCO", etiqueta: "Parentesco", control: "text", obligatorio: true },
      ],
    },
    {
      titulo: "Datos académicos",
      grupo: "extra",
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

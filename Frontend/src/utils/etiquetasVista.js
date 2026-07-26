/** Etiquetas legacy del menú en BD (hasta ejecutar script 5.menu_mensualidad_tutor.sql). */
const ALIAS_MENU = {
  Membresías: "Mensualidades",
  "Listado de Membresías": "Listado de Mensualidades",
  Asesores: "Tutores",
  "Mantenedor de asesores": "Tutores",
};

export function etiquetaMenu(nombre, _page) {
  return ALIAS_MENU[nombre] || nombre;
}

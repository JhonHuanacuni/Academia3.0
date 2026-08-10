import ClaseGrabadaAdminPage from "./ClaseGrabadaAdminPage";
import ClaseGrabadaEstudiantePage from "./ClaseGrabadaEstudiantePage";

export default function ClasesGrabadasPorRol({ role }) {
  return role === "estudiante" ? (
    <ClaseGrabadaEstudiantePage />
  ) : (
    <ClaseGrabadaAdminPage />
  );
}

import { useCallback, useEffect, useState } from "react";
import Layout from "./components/layout/Layout";
import LoginPage from "./components/LoginPage";
import "./components/LoginPage.css";
import AdminModulos from "./components/admin/AdminModulos";
import UsuarioPage from "./modules/usuario/UsuarioPage";
import AsistenciaMarcarPage from "./modules/asistencia/AsistenciaMarcarPage";
import AsistenciaListadoPage from "./modules/asistencia/AsistenciaListadoPage";
import JustificacionPage from "./modules/asistencia/JustificacionPage";
import AulaPage from "./modules/aula/AulaPage";
import TutorPage from "./modules/tutor/TutorPage";
import PlanPage from "./modules/plan/PlanPage";
import MensualidadPage from "./modules/mensualidad/MensualidadPage";
import PagoPage from "./modules/pago/PagoPage";
import PagoExtraPage from "./modules/pagoExtra/PagoExtraPage";
import ConceptoPage from "./modules/concepto/ConceptoPage";
import CategoriaPage from "./modules/categoria/CategoriaPage";
import MateriaPage from "./modules/materia/MateriaPage";
import BibliotecaPage from "./modules/biblioteca/BibliotecaPage";
import HorarioPage from "./modules/horario/HorarioPage";
import ExamenPage from "./modules/examen/ExamenPage";
import ExamenEstudiantePage from "./modules/examenEstudiante/ExamenEstudiantePage";
import InformeAsistenciasPage from "./modules/informes/InformeAsistenciasPage";
import DashboardPage from "./modules/dashboard/DashboardPage";
import NotasPage from "./modules/notas/NotasPage";
import AuditoriaPage from "./modules/auditoria/AuditoriaPage";
import ClasesGrabadasPorRol from "./modules/claseGrabada/ClaseGrabadaPage";
import "./App.css";

function ExamenesPorRol({ role }) {
  return role === "estudiante" ? <ExamenEstudiantePage /> : <ExamenPage />;
}

const pageContent = {
  dashboard: {
    title: "Dashboard",
    description: "Estado general del instituto.",
    component: DashboardPage,
  },
  usuarios: {
    title: "Listado de Usuarios",
    description: "Administración de usuarios del sistema.",
    component: UsuarioPage,
  },
  mensualidades: {
    title: "Mensualidades",
    description: "Gestión de mensualidades y cobros.",
    component: MensualidadPage,
  },
  pagos: {
    title: "Pagos",
    description: "Lista de pagos, estado y registro de transacciones.",
    component: PagoPage,
  },
  "pagos-extraordinarios": {
    title: "Pagos extraordinarios",
    description: "Pagos no ligados a mensualidad.",
    component: PagoExtraPage,
  },
  asistencias: {
    title: "Asistencias",
    description: "Control de asistencias.",
  },
  "asistencias-marcar": {
    title: "Marcar asistencia",
    description: "Registro por cámara QR o DNI.",
    component: AsistenciaMarcarPage,
  },
  "asistencias-listado": {
    title: "Ver asistencias",
    description: "Listado del día.",
    component: AsistenciaListadoPage,
  },
  "asistencias-justificacion": {
    title: "Justificación",
    description: "Justificar inasistencias o tardanzas.",
    component: JustificacionPage,
  },
  horario: {
    title: "Horario",
    description: "Agenda y horarios de clases, salones y eventos.",
    component: HorarioPage,
  },
  biblioteca: {
    title: "Biblioteca",
    description: "Acceso a recursos educativos y archivos de la biblioteca.",
    component: BibliotecaPage,
  },
  examenes: {
    title: "Exámenes",
    description: "Gestión de exámenes, resultados y evaluaciones.",
    component: ExamenesPorRol,
  },
  "admin-modulos": {
    title: "Administración de Módulos",
    description: "Asigna acceso a módulos y gestiona permisos de usuarios.",
    component: AdminModulos,
  },
  academico: {
    title: "Académico",
    description: "Gestión académica del instituto.",
  },
  mantenedores: {
    title: "Mantenedores",
    description: "Catálogos y mantenedores del sistema.",
  },
  "mantenedores-aulas": {
    title: "Aulas",
    description: "Registro y administración de aulas / salones.",
    component: AulaPage,
  },
  "mantenedores-tutores": {
    title: "Tutores",
    description: "Registro y administración de tutores.",
    component: TutorPage,
  },
  "mantenedores-planes": {
    title: "Planes",
    description: "Registro y administración de tipos de plan.",
    component: PlanPage,
  },
  "mantenedores-conceptos": {
    title: "Conceptos",
    description: "Conceptos de pago extraordinario (nombre y costo).",
    component: ConceptoPage,
  },
  "mantenedores-categorias": {
    title: "Categorías",
    description: "Categorías de materias para exámenes.",
    component: CategoriaPage,
  },
  "mantenedores-materias": {
    title: "Materias",
    description: "Materias / cursos vinculados a categoría.",
    component: MateriaPage,
  },
  "academico-biblioteca": {
    title: "Biblioteca",
    description: "Recursos educativos y archivos de la biblioteca.",
    component: BibliotecaPage,
  },
  "academico-examenes": {
    title: "Exámenes",
    description: "Gestión de exámenes, resultados y evaluaciones.",
    component: ExamenesPorRol,
  },
  "academico-horario": {
    title: "Horario",
    description: "Agenda y horarios de clases, salones y eventos.",
    component: HorarioPage,
  },
  "academico-clases": {
    title: "Clases grabadas",
    description: "Enlaces a clases grabadas por materia y salón.",
    component: ClasesGrabadasPorRol,
  },
  "academico-notas": {
    title: "Importar notas",
    description: "Importar calificaciones desde Excel Scantron.",
    component: NotasPage,
  },
  "academico-auditoria": {
    title: "Auditoría",
    description: "Historial de altas, modificaciones y eliminaciones en el sistema.",
    component: AuditoriaPage,
  },
  informes: {
    title: "Informes",
    description: "Reportes y estadísticas del instituto.",
  },
  "informes-asistencias": {
    title: "Informe de asistencias",
    description: "Matriz de asistencias por rango de fechas.",
    component: InformeAsistenciasPage,
  },
};

function App() {
  const [role, setRole] = useState(() => localStorage.getItem("role") || "estudiante");
  const [idusuario, setIdusuario] = useState(() => localStorage.getItem("idusuario") || "");
  const [activePage, setActivePage] = useState(() => localStorage.getItem("activePage") || "dashboard");
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(() => localStorage.getItem("isAuthenticated") === "true");
  const [loginError, setLoginError] = useState("");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const page = pageContent[activePage] || pageContent.dashboard;

  const handleMenuLoaded = useCallback((allowedPages) => {
    setActivePage((current) => {
      if (allowedPages.length === 0) return "dashboard";
      if (allowedPages.includes(current)) return current;
      return allowedPages.includes("dashboard") ? "dashboard" : allowedPages[0];
    });
  }, []);

  const handleLogin = async (event) => {
    event.preventDefault();
    setLoginError("");

    try {
      const response = await fetch("/api/login/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ username, password }),
      });

      const data = await response.json();
      if (!response.ok) {
        setLoginError(data.error || "Error al iniciar sesión");
        return;
      }

      if (data.valid) {
        const userRole = data.role || "estudiante";
        const userId = data.idusuario || username;
        setIsAuthenticated(true);
        setRole(userRole);
        setIdusuario(userId);
        setActivePage("dashboard");
        setPassword("");
        setUsername("");
        setLoginError("");
        localStorage.setItem("isAuthenticated", "true");
        localStorage.setItem("role", userRole);
        localStorage.setItem("idusuario", userId);
        if (data.idtipousuario) {
          localStorage.setItem("idtipousuario", String(data.idtipousuario));
        }
        localStorage.setItem("activePage", "dashboard");
      } else {
        setLoginError("Usuario o contraseña incorrectos");
      }
    } catch (error) {
      setLoginError("No se pudo conectar con el backend");
    }
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setActivePage("dashboard");
    setRole("estudiante");
    setIdusuario("");
    setIsSidebarOpen(false);
    localStorage.removeItem("isAuthenticated");
    localStorage.removeItem("role");
    localStorage.removeItem("idusuario");
    localStorage.removeItem("idtipousuario");
    localStorage.removeItem("activePage");
  };

  useEffect(() => {
    if (isAuthenticated) {
      localStorage.setItem("isAuthenticated", "true");
      localStorage.setItem("role", role);
      localStorage.setItem("idusuario", idusuario);
      localStorage.setItem("activePage", activePage);
    }
  }, [isAuthenticated, role, idusuario, activePage]);

  if (!isAuthenticated) {
    return (
      <LoginPage
        username={username}
        password={password}
        loginError={loginError}
        onUsernameChange={setUsername}
        onPasswordChange={setPassword}
        onSubmit={handleLogin}
      />
    );
  }

  return (
    <Layout
      role={role}
      idusuario={idusuario}
      activePage={activePage}
      onChangePage={setActivePage}
      onMenuLoaded={handleMenuLoaded}
      isSidebarOpen={isSidebarOpen}
      onToggleSidebar={() => setIsSidebarOpen((prev) => !prev)}
      onCloseSidebar={() => setIsSidebarOpen(false)}
      onLogout={handleLogout}
    >
      {page.component ? (
        page.component === ExamenesPorRol || page.component === ClasesGrabadasPorRol ? (
          <page.component role={role} />
        ) : (
          <page.component role={role} idusuario={idusuario} onChangePage={setActivePage} />
        )
      ) : (
        <>
          <div className="page-header">
            <h1>{page.title}</h1>
            <p>{page.description}</p>
          </div>
          <section className="page-body">
            <div className="page-card">
              <p>Selecciona otra opción del menú para navegar entre módulos.</p>
            </div>
          </section>
        </>
      )}
    </Layout>
  );
}

export default App;

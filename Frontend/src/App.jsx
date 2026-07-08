import { useCallback, useEffect, useState } from "react";
import Layout from "./components/layout/Layout";
import AdminModulos from "./components/admin/AdminModulos";
import UsuarioPage from "./modules/usuario/UsuarioPage";
import AsistenciaMarcarPage from "./modules/asistencia/AsistenciaMarcarPage";
import AsistenciaListadoPage from "./modules/asistencia/AsistenciaListadoPage";
import AulaPage from "./modules/aula/AulaPage";
import MembresiaPage from "./modules/membresia/MembresiaPage";
import InformeAsistenciasPage from "./modules/informes/InformeAsistenciasPage";
import "./App.css";

const pageContent = {
  dashboard: {
    title: "Dashboard",
    description: "Bienvenido. Aquí se muestra el estado general del sistema.",
  },
  usuarios: {
    title: "Listado de Usuarios",
    description: "Administración de usuarios del sistema.",
    component: UsuarioPage,
  },
  membresias: {
    title: "Membresías",
    description: "Gestión de membresías y cobros.",
    component: MembresiaPage,
  },
  pagos: {
    title: "Pagos",
    description: "Lista de pagos, estado y registro de transacciones.",
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
  horario: {
    title: "Horario",
    description: "Agenda y horarios de clases, salones y eventos.",
  },
  biblioteca: {
    title: "Biblioteca",
    description: "Acceso a recursos educativos y archivos de la biblioteca.",
  },
  examenes: {
    title: "Exámenes",
    description: "Gestión de exámenes, resultados y evaluaciones.",
  },
  notas: {
    title: "Notas",
    description: "Visualiza notas, calificaciones y progreso académico.",
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
  "academico-aulas": {
    title: "Mantenedor de Aulas",
    description: "Registro y administración de aulas / salones.",
    component: AulaPage,
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
      <div className="login-page">
        <div className="login-card">
          <h1>Iniciar sesión</h1>
          <p>Ingresa tus credenciales para acceder al sistema.</p>
          <form className="login-form" onSubmit={handleLogin}>
            <label>
              Usuario
              <input
                type="text"
                value={username}
                onChange={(event) => setUsername(event.target.value)}
                placeholder="Usuario"
                required
              />
            </label>
            <label>
              Contraseña
              <input
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                placeholder="Contraseña"
                required
              />
            </label>
            {loginError && <div className="login-error">{loginError}</div>}
            <button type="submit" className="login-button">
              Entrar
            </button>
          </form>
        </div>
      </div>
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
        <page.component />
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

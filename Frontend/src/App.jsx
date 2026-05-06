import { useEffect, useState } from "react";
import Layout from "./components/layout/Layout";
import "./App.css";

const pageContent = {
  dashboard: {
    title: "Dashboard",
    description: "Bienvenido a Academia 3.0. Aquí se muestra el estado general del sistema.",
  },
  usuarios: {
    title: "Usuarios",
    description: "Administración de usuarios, roles y acceso al sistema.",
  },
  membresias: {
    title: "Membresías",
    description: "Gestión de membresías y cobros en el nuevo sistema.",
  },
  pagos: {
    title: "Pagos",
    description: "Lista de pagos, estado y registro de transacciones.",
  },
  asistencias: {
    title: "Asistencias",
    description: "Control de asistencias y reportes diarios.",
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
};

function App() {
  const [backendMessage, setBackendMessage] = useState("Conectando con backend...");
  const [role, setRole] = useState("admin");
  const [activePage, setActivePage] = useState("dashboard");
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loginError, setLoginError] = useState("");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  useEffect(() => {
    fetch("/api/status/")
      .then((response) => response.json())
      .then((data) => {
        setBackendMessage(data.message ?? "Backend conectado");
      })
      .catch(() => {
        setBackendMessage("No se pudo conectar con el backend");
      });
  }, []);

  const page = pageContent[activePage] || pageContent.dashboard;

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
        setIsAuthenticated(true);
        setRole(data.role || "usuario");
        setActivePage("dashboard");
        setPassword("");
        setUsername("");
        setLoginError("");
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
    setRole("admin");
    setIsSidebarOpen(false);
  };

  if (!isAuthenticated) {
    return (
      <div className="login-page">
        <div className="login-card">
          <h1>Iniciar sesión</h1>
          <p>Ingresa con tu usuario de SQL Server para acceder a Academia 3.0.</p>
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
          <div className="login-footer">
            <span>{backendMessage}</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <Layout
      role={role}
      activePage={activePage}
      onChangePage={setActivePage}
      isSidebarOpen={isSidebarOpen}
      onToggleSidebar={() => setIsSidebarOpen((prev) => !prev)}
      onCloseSidebar={() => setIsSidebarOpen(false)}
      onChangeRole={setRole}
      onLogout={handleLogout}
      backendMessage={backendMessage}
    >
      <div className="page-header">
        <h1>{page.title}</h1>
        <p>{page.description}</p>
      </div>
      <section className="page-body">
        <div className="page-card">
          <h2>Contenido de {page.title}</h2>
          <p>Esta vista está adaptada desde el diseño de Academia 2.0.</p>
          <p>Selecciona otra opción del sidebar para ver los distintos módulos.</p>
        </div>
      </section>
    </Layout>
  );
}

export default App;

import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowRight,
  faArrowLeft,
  faSpinner,
  faSearch,
} from "@fortawesome/free-solid-svg-icons";
import "./AdminModulos.css";

const AdminModulos = () => {
  // Estados
  const [modulosDisponibles, setModulosDisponibles] = useState([]);
  const [modulosAsignados, setModulosAsignados] = useState([]);
  const [usuarioSeleccionado, setUsuarioSeleccionado] = useState("");
  const [usuarios, setUsuarios] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [búsquedaDisponibles, setBúsquedaDisponibles] = useState("");
  const [búsquedaAsignados, setBúsquedaAsignados] = useState("");
  const [draggedModule, setDraggedModule] = useState(null);

  // Cargar usuarios al iniciar
  useEffect(() => {
    cargarUsuarios();
  }, []);

  // Cargar módulos disponibles y asignados cuando cambia el usuario
  useEffect(() => {
    if (usuarioSeleccionado) {
      cargarModulosDisponibles();
      cargarModulosAsignados();
    }
  }, [usuarioSeleccionado]);

  const cargarUsuarios = async () => {
    try {
      setCargando(true);
      const response = await fetch("/api/status/");
      // Aquí deberías hacer un fetch a un endpoint que retorne usuarios
      // Por ahora usamos datos simulados
      setUsuarios([
        { id: "user1", nombre: "Juan Pérez" },
        { id: "user2", nombre: "María García" },
        { id: "user3", nombre: "Carlos López" },
      ]);
    } catch (error) {
      console.error("Error cargando usuarios:", error);
    } finally {
      setCargando(false);
    }
  };

  const cargarModulosDisponibles = async () => {
    try {
      setCargando(true);
      const response = await fetch("/api/modulos-disponibles/");
      if (!response.ok) throw new Error("Error al cargar módulos");
      const data = await response.json();

      if (data.success) {
        // Filtrar módulos no asignados
        const asignados = modulosAsignados.map((m) => m.IDMODULO);
        const disponibles = data.modulos.filter(
          (m) => !asignados.includes(m.IDMODULO)
        );
        setModulosDisponibles(disponibles);
      }
    } catch (error) {
      console.error("Error cargando módulos disponibles:", error);
    } finally {
      setCargando(false);
    }
  };

  const cargarModulosAsignados = async () => {
    try {
      setCargando(true);
      const response = await fetch(
        `/api/modulos-asignados-usuario/?idusuario=${usuarioSeleccionado}`
      );
      if (!response.ok) throw new Error("Error al cargar módulos asignados");
      const data = await response.json();

      if (data.success) {
        setModulosAsignados(data.asignados);
      } else {
        setModulosAsignados([]);
      }
    } catch (error) {
      console.error("Error cargando módulos asignados:", error);
      setModulosAsignados([]);
    } finally {
      setCargando(false);
    }
  };

  const asignarModulo = async (modulo) => {
    if (!usuarioSeleccionado) {
      alert("Selecciona un usuario primero");
      return;
    }

    try {
      setCargando(true);
      const response = await fetch("/api/modulos-asignados-usuario/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": getCookie("csrftoken"),
        },
        body: JSON.stringify({
          idusuario: usuarioSeleccionado,
          idmodulo: modulo.IDMODULO,
          accion: "asignar",
          permisos: ["read", "write"],
        }),
      });

      const data = await response.json();
      if (data.success) {
        // Actualizar listas locales
        setModulosDisponibles(
          modulosDisponibles.filter((m) => m.IDMODULO !== modulo.IDMODULO)
        );
        setModulosAsignados([...modulosAsignados, modulo]);
      } else {
        alert("Error: " + data.error);
      }
    } catch (error) {
      console.error("Error asignando módulo:", error);
      alert("Error al asignar módulo");
    } finally {
      setCargando(false);
    }
  };

  const desasignarModulo = async (modulo) => {
    if (!usuarioSeleccionado) return;

    try {
      setCargando(true);
      const response = await fetch("/api/modulos-asignados-usuario/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": getCookie("csrftoken"),
        },
        body: JSON.stringify({
          idusuario: usuarioSeleccionado,
          idmodulo: modulo.IDMODULO || modulo.IDMODULO_id,
          accion: "desasignar",
        }),
      });

      const data = await response.json();
      if (data.success) {
        // Actualizar listas locales
        const moduloFull = {
          IDMODULO: modulo.IDMODULO || modulo.IDMODULO_id,
          NOMBRE: modulo.NOMBRE || modulo.IDMODULO__NOMBRE,
          ICONO: modulo.ICONO || modulo.IDMODULO__ICONO,
          DESCRIPCION: modulo.DESCRIPCION || "",
        };

        setModulosAsignados(
          modulosAsignados.filter(
            (m) => (m.IDMODULO || m.IDMODULO_id) !== (modulo.IDMODULO || modulo.IDMODULO_id)
          )
        );
        setModulosDisponibles([...modulosDisponibles, moduloFull]);
      } else {
        alert("Error: " + data.error);
      }
    } catch (error) {
      console.error("Error desasignando módulo:", error);
      alert("Error al desasignar módulo");
    } finally {
      setCargando(false);
    }
  };

  // Drag and Drop
  const handleDragStart = (e, modulo) => {
    setDraggedModule(modulo);
    e.dataTransfer.effectAllowed = "move";
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
  };

  const handleDropDisponibles = (e) => {
    e.preventDefault();
    if (draggedModule && modulosAsignados.some((m) => (m.IDMODULO || m.IDMODULO_id) === (draggedModule.IDMODULO || draggedModule.IDMODULO_id))) {
      desasignarModulo(draggedModule);
    }
    setDraggedModule(null);
  };

  const handleDropAsignados = (e) => {
    e.preventDefault();
    if (draggedModule && modulosDisponibles.some((m) => m.IDMODULO === draggedModule.IDMODULO)) {
      asignarModulo(draggedModule);
    }
    setDraggedModule(null);
  };

  // Filtrar módulos
  const disponiblesFiltrados = modulosDisponibles.filter((m) =>
    m.NOMBRE.toLowerCase().includes(búsquedaDisponibles.toLowerCase())
  );

  const asignadosFiltrados = modulosAsignados.filter((m) =>
    (m.NOMBRE || m.IDMODULO__NOMBRE)
      .toLowerCase()
      .includes(búsquedaAsignados.toLowerCase())
  );

  return (
    <div className="admin-modulos">
      <div className="admin-header">
        <h1>Administración de Acceso a Módulos</h1>
        <p>Asigna módulos y permisos a cada usuario</p>
      </div>

      {/* Selector de Usuario */}
      <div className="usuario-selector">
        <label htmlFor="usuario-select">Selecciona un usuario:</label>
        <select
          id="usuario-select"
          value={usuarioSeleccionado}
          onChange={(e) => setUsuarioSeleccionado(e.target.value)}
          disabled={cargando}
        >
          <option value="">-- Selecciona un usuario --</option>
          {usuarios.map((usuario) => (
            <option key={usuario.id} value={usuario.id}>
              {usuario.nombre}
            </option>
          ))}
        </select>
      </div>

      {usuarioSeleccionado ? (
        <div className="modulos-container">
          {/* Panel Izquierdo: Módulos Disponibles */}
          <div className="panel disponibles">
            <div className="panel-header">
              <h2>Módulos Disponibles</h2>
              <span className="count">{disponiblesFiltrados.length}</span>
            </div>

            <div className="search-box">
              <FontAwesomeIcon icon={faSearch} className="search-icon" />
              <input
                type="text"
                placeholder="Buscar módulo..."
                value={búsquedaDisponibles}
                onChange={(e) => setBúsquedaDisponibles(e.target.value)}
              />
            </div>

            <div
              className="modulos-list"
              onDragOver={handleDragOver}
              onDrop={handleDropDisponibles}
            >
              {cargando ? (
                <div className="loading">
                  <FontAwesomeIcon icon={faSpinner} spin />
                  Cargando...
                </div>
              ) : disponiblesFiltrados.length > 0 ? (
                disponiblesFiltrados.map((modulo) => (
                  <div
                    key={modulo.IDMODULO}
                    className="modulo-item"
                    draggable
                    onDragStart={(e) => handleDragStart(e, modulo)}
                  >
                    <div className="modulo-info">
                      <h3>{modulo.NOMBRE}</h3>
                      <p>{modulo.DESCRIPCION}</p>
                      {modulo.submodulos && modulo.submodulos.length > 0 && (
                        <div className="submodulos-preview">
                          <small>
                            +{modulo.submodulos.length} submódulo
                            {modulo.submodulos.length !== 1 ? "s" : ""}
                          </small>
                        </div>
                      )}
                    </div>
                    <button
                      className="btn-asignar"
                      onClick={() => asignarModulo(modulo)}
                      title="Click o arrastra para asignar"
                    >
                      <FontAwesomeIcon icon={faArrowRight} />
                    </button>
                  </div>
                ))
              ) : (
                <div className="empty-state">
                  <p>No hay módulos disponibles</p>
                </div>
              )}
            </div>
          </div>

          {/* Centro: Instrucciones */}
          <div className="center-info">
            <div className="arrow-icon">
              <FontAwesomeIcon icon={faArrowRight} />
            </div>
            <p>Arrastra módulos entre los paneles o usa los botones</p>
          </div>

          {/* Panel Derecho: Módulos Asignados */}
          <div className="panel asignados">
            <div className="panel-header">
              <h2>Módulos Asignados</h2>
              <span className="count">{asignadosFiltrados.length}</span>
            </div>

            <div className="search-box">
              <FontAwesomeIcon icon={faSearch} className="search-icon" />
              <input
                type="text"
                placeholder="Buscar módulo..."
                value={búsquedaAsignados}
                onChange={(e) => setBúsquedaAsignados(e.target.value)}
              />
            </div>

            <div
              className="modulos-list"
              onDragOver={handleDragOver}
              onDrop={handleDropAsignados}
            >
              {cargando ? (
                <div className="loading">
                  <FontAwesomeIcon icon={faSpinner} spin />
                  Cargando...
                </div>
              ) : asignadosFiltrados.length > 0 ? (
                asignadosFiltrados.map((modulo) => (
                  <div
                    key={modulo.IDUSUARIO_MODULO || modulo.IDMODULO_id}
                    className="modulo-item asignado"
                    draggable
                    onDragStart={(e) => handleDragStart(e, modulo)}
                  >
                    <div className="modulo-info">
                      <h3>{modulo.NOMBRE || modulo.IDMODULO__NOMBRE}</h3>
                      <p>{modulo.DESCRIPCION}</p>
                      <div className="permisos-badge">
                        {modulo.PERMISOS &&
                          (Array.isArray(modulo.PERMISOS)
                            ? modulo.PERMISOS
                            : JSON.parse(modulo.PERMISOS || "[]")
                          ).map((perm) => (
                            <span key={perm} className={`perm-${perm}`}>
                              {perm}
                            </span>
                          ))}
                      </div>
                    </div>
                    <button
                      className="btn-desasignar"
                      onClick={() => desasignarModulo(modulo)}
                      title="Click o arrastra para desasignar"
                    >
                      <FontAwesomeIcon icon={faArrowLeft} />
                    </button>
                  </div>
                ))
              ) : (
                <div className="empty-state">
                  <p>Sin módulos asignados</p>
                </div>
              )}
            </div>
          </div>
        </div>
      ) : (
        <div className="no-user-selected">
          <p>Selecciona un usuario para ver y asignar módulos</p>
        </div>
      )}
    </div>
  );
};

// Helper: Obtener CSRF token
function getCookie(name) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== "") {
    const cookies = document.cookie.split(";");
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim();
      if (cookie.substring(0, name.length + 1) === name + "=") {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

export default AdminModulos;

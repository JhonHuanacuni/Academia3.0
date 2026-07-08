import { useCallback, useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowRight,
  faArrowLeft,
  faSpinner,
  faSearch,
} from "@fortawesome/free-solid-svg-icons";
import "./AdminModulos.css";
import { notifyMenuRefresh } from "../sidebar/Sidebar";

async function parseApiResponse(response) {
  const text = await response.text();
  if (!text) {
    if (response.status === 502 || response.status === 503) {
      throw new Error(
        "El backend no está disponible. Inicia Django en otra terminal: cd Backend && python manage.py runserver"
      );
    }
    throw new Error(`El servidor respondió vacío (HTTP ${response.status})`);
  }
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`Respuesta inválida del servidor (HTTP ${response.status})`);
  }
}

const AdminModulos = () => {
  const [modulosDisponibles, setModulosDisponibles] = useState([]);
  const [modulosAsignados, setModulosAsignados] = useState([]);
  const [usuarioSeleccionado, setUsuarioSeleccionado] = useState("");
  const [usuarios, setUsuarios] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [error, setError] = useState("");
  const [búsquedaDisponibles, setBúsquedaDisponibles] = useState("");
  const [búsquedaAsignados, setBúsquedaAsignados] = useState("");
  const [draggedModule, setDraggedModule] = useState(null);
  const [moduloSeleccionado, setModuloSeleccionado] = useState(null);
  const [submodulosDisponibles, setSubmodulosDisponibles] = useState([]);
  const [submodulosAsignados, setSubmodulosAsignados] = useState([]);
  const [draggedSubmodulo, setDraggedSubmodulo] = useState(null);

  const cargarUsuarios = useCallback(async () => {
    try {
      setCargando(true);
      setError("");
      const response = await fetch("/api/usuarios-activos/");
      const data = await parseApiResponse(response);
      if (!response.ok || !data.success) {
        throw new Error(data.error || `Error al cargar usuarios (${response.status})`);
      }
      setUsuarios(data.usuarios || []);
    } catch (err) {
      console.error("Error cargando usuarios:", err);
      setError(err.message || "No se pudieron cargar los usuarios");
    } finally {
      setCargando(false);
    }
  }, []);

  const cargarModulos = useCallback(async (idusuario) => {
    if (!idusuario) return;

    try {
      setCargando(true);
      setError("");

      const [resDisp, resAsig] = await Promise.all([
        fetch(`/api/modulos-disponibles/?idusuario=${encodeURIComponent(idusuario)}`),
        fetch(`/api/modulos-asignados-usuario/?idusuario=${encodeURIComponent(idusuario)}`),
      ]);

      const dataDisp = await parseApiResponse(resDisp);
      const dataAsig = await parseApiResponse(resAsig);

      if (!resDisp.ok || !dataDisp.success) {
        throw new Error(dataDisp.error || "Error al cargar módulos disponibles");
      }
      if (!resAsig.ok || !dataAsig.success) {
        throw new Error(dataAsig.error || "Error al cargar módulos asignados");
      }

      setModulosDisponibles(dataDisp.modulos || []);
      setModulosAsignados(dataAsig.asignados || []);
      setModuloSeleccionado(null);
      setSubmodulosDisponibles([]);
      setSubmodulosAsignados([]);
    } catch (err) {
      console.error("Error cargando módulos:", err);
      setError(err.message || "Error al cargar módulos");
      setModulosDisponibles([]);
      setModulosAsignados([]);
    } finally {
      setCargando(false);
    }
  }, []);

  useEffect(() => {
    cargarUsuarios();
  }, [cargarUsuarios]);

  useEffect(() => {
    if (usuarioSeleccionado) {
      cargarModulos(usuarioSeleccionado);
    } else {
      setModulosDisponibles([]);
      setModulosAsignados([]);
    }
  }, [usuarioSeleccionado, cargarModulos]);

  const asignarModulo = async (modulo) => {
    if (!usuarioSeleccionado) {
      alert("Selecciona un usuario primero");
      return;
    }

    const idmodulo = modulo.IDMODULO;
    try {
      setCargando(true);
      setError("");
      const response = await fetch("/api/modulos-asignados-usuario/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          idusuario: usuarioSeleccionado,
          idmodulo,
          accion: "asignar",
        }),
      });

      const data = await parseApiResponse(response);
      if (!response.ok || !data.success) {
        throw new Error(data.error || data.message || "Error al asignar");
      }
      await cargarModulos(usuarioSeleccionado);
      const currentUser = localStorage.getItem("idusuario");
      if (currentUser === usuarioSeleccionado) {
        notifyMenuRefresh();
      }
    } catch (err) {
      console.error("Error asignando módulo:", err);
      alert(err.message || "Error al asignar módulo");
    } finally {
      setCargando(false);
    }
  };

  const desasignarModulo = async (modulo) => {
    if (!usuarioSeleccionado) return;

    const idmodulo = modulo.IDMODULO || modulo.IDMODULO_id;
    try {
      setCargando(true);
      setError("");
      const response = await fetch("/api/modulos-asignados-usuario/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          idusuario: usuarioSeleccionado,
          idmodulo,
          accion: "desasignar",
        }),
      });

      const data = await parseApiResponse(response);
      if (!response.ok || !data.success) {
        throw new Error(data.error || data.message || "Error al desasignar");
      }
      await cargarModulos(usuarioSeleccionado);
      const currentUser = localStorage.getItem("idusuario");
      if (currentUser === usuarioSeleccionado) {
        notifyMenuRefresh();
      }
    } catch (err) {
      console.error("Error desasignando módulo:", err);
      alert(err.message || "Error al desasignar módulo");
    } finally {
      setCargando(false);
    }
  };

  const cargarSubmodulos = useCallback(async (idmodulo) => {
    if (!usuarioSeleccionado || !idmodulo) return;

    try {
      setCargando(true);
      setError("");
      const response = await fetch(
        `/api/submodulos-modulo-usuario/?idusuario=${encodeURIComponent(usuarioSeleccionado)}&idmodulo=${encodeURIComponent(idmodulo)}`
      );
      const data = await parseApiResponse(response);
      if (!response.ok || !data.success) {
        throw new Error(data.error || "Error al cargar submódulos");
      }
      setSubmodulosDisponibles(data.disponibles || []);
      setSubmodulosAsignados(data.asignados || []);
    } catch (err) {
      console.error("Error cargando submódulos:", err);
      setError(err.message || "Error al cargar submódulos");
      setSubmodulosDisponibles([]);
      setSubmodulosAsignados([]);
    } finally {
      setCargando(false);
    }
  }, [usuarioSeleccionado]);

  const seleccionarModulo = async (modulo) => {
    const idmodulo = getModuloId(modulo);
    const subs = modulo.submodulos || [];
    if (subs.length === 0) {
      setModuloSeleccionado(null);
      setSubmodulosDisponibles([]);
      setSubmodulosAsignados([]);
      return;
    }
    setModuloSeleccionado(modulo);
    await cargarSubmodulos(idmodulo);
  };

  const refrescarTrasCambioSubmodulo = async (idmodulo) => {
    await Promise.all([
      cargarSubmodulos(idmodulo),
      cargarModulos(usuarioSeleccionado),
    ]);
    const currentUser = localStorage.getItem("idusuario");
    if (currentUser === usuarioSeleccionado) {
      notifyMenuRefresh();
    }
  };

  const asignarSubmodulo = async (submodulo) => {
    if (!usuarioSeleccionado || !moduloSeleccionado) return;
    const idmodulo = getModuloId(moduloSeleccionado);

    try {
      setCargando(true);
      setError("");
      const response = await fetch("/api/submodulos-modulo-usuario/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          idusuario: usuarioSeleccionado,
          idsubmodulo: submodulo.IDSUBMODULO,
          accion: "asignar",
        }),
      });
      const data = await parseApiResponse(response);
      if (!response.ok || !data.success) {
        throw new Error(data.error || data.message || "Error al asignar submódulo");
      }
      await refrescarTrasCambioSubmodulo(idmodulo);
    } catch (err) {
      console.error("Error asignando submódulo:", err);
      alert(err.message || "Error al asignar submódulo");
    } finally {
      setCargando(false);
    }
  };

  const desasignarSubmodulo = async (submodulo) => {
    if (!usuarioSeleccionado || !moduloSeleccionado) return;
    const idmodulo = getModuloId(moduloSeleccionado);

    try {
      setCargando(true);
      setError("");
      const response = await fetch("/api/submodulos-modulo-usuario/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          idusuario: usuarioSeleccionado,
          idsubmodulo: submodulo.IDSUBMODULO,
          accion: "desasignar",
        }),
      });
      const data = await parseApiResponse(response);
      if (!response.ok || !data.success) {
        throw new Error(data.error || data.message || "Error al desasignar submódulo");
      }
      await refrescarTrasCambioSubmodulo(idmodulo);
    } catch (err) {
      console.error("Error desasignando submódulo:", err);
      alert(err.message || "Error al desasignar submódulo");
    } finally {
      setCargando(false);
    }
  };

  const handleDragStart = (e, modulo) => {
    setDraggedModule(modulo);
    e.dataTransfer.effectAllowed = "move";
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
  };

  const getModuloId = (modulo) => modulo.IDMODULO || modulo.IDMODULO_id;

  const handleDropDisponibles = (e) => {
    e.preventDefault();
    if (
      draggedModule &&
      modulosAsignados.some((m) => getModuloId(m) === getModuloId(draggedModule))
    ) {
      desasignarModulo(draggedModule);
    }
    setDraggedModule(null);
  };

  const handleDropAsignados = (e) => {
    e.preventDefault();
    if (
      draggedModule &&
      modulosDisponibles.some((m) => m.IDMODULO === draggedModule.IDMODULO)
    ) {
      asignarModulo(draggedModule);
    }
    setDraggedModule(null);
  };

  const handleDragStartSub = (e, submodulo) => {
    setDraggedSubmodulo(submodulo);
    e.dataTransfer.effectAllowed = "move";
  };

  const handleDropSubDisponibles = (e) => {
    e.preventDefault();
    if (
      draggedSubmodulo &&
      submodulosAsignados.some((s) => s.IDSUBMODULO === draggedSubmodulo.IDSUBMODULO)
    ) {
      desasignarSubmodulo(draggedSubmodulo);
    }
    setDraggedSubmodulo(null);
  };

  const handleDropSubAsignados = (e) => {
    e.preventDefault();
    if (
      draggedSubmodulo &&
      submodulosDisponibles.some((s) => s.IDSUBMODULO === draggedSubmodulo.IDSUBMODULO)
    ) {
      asignarSubmodulo(draggedSubmodulo);
    }
    setDraggedSubmodulo(null);
  };

  const normalizarPermisos = (permisos) => {
    if (!permisos) return [];
    if (Array.isArray(permisos)) return permisos;
    try {
      return JSON.parse(permisos);
    } catch {
      return String(permisos).split(",").map((p) => p.trim()).filter(Boolean);
    }
  };

  const clasePermiso = (perm) => {
    const map = {
      VER: "perm-read",
      CREAR: "perm-write",
      EDITAR: "perm-write",
      ELIMINAR: "perm-delete",
      read: "perm-read",
      write: "perm-write",
      delete: "perm-delete",
      admin: "perm-admin",
    };
    return map[perm] || "perm-read";
  };

  const disponiblesFiltrados = modulosDisponibles.filter((m) =>
    m.NOMBRE.toLowerCase().includes(búsquedaDisponibles.toLowerCase())
  );

  const asignadosFiltrados = modulosAsignados.filter((m) =>
    (m.NOMBRE || m.IDMODULO__NOMBRE || "")
      .toLowerCase()
      .includes(búsquedaAsignados.toLowerCase())
  );

  const usuarioInfo = usuarios.find((u) => u.id === usuarioSeleccionado);

  return (
    <div className="admin-modulos">
      <div className="admin-header">
        <h1>Administración de Acceso a Módulos</h1>
        <p>Asigna o quita módulos y submódulos a cada usuario</p>
      </div>

      {error && <div className="admin-error">{error}</div>}

      <div className="usuario-selector">
        <label htmlFor="usuario-select">Selecciona un usuario:</label>
        <select
          id="usuario-select"
          value={usuarioSeleccionado}
          onChange={(e) => setUsuarioSeleccionado(e.target.value)}
          disabled={cargando && usuarios.length === 0}
        >
          <option value="">-- Selecciona un usuario --</option>
          {usuarios.map((usuario) => (
            <option key={usuario.id} value={usuario.id}>
              {usuario.nombre}
              {usuario.tipoUsuario ? ` (${usuario.tipoUsuario})` : ""}
            </option>
          ))}
        </select>
        {usuarioInfo && (
          <p className="usuario-meta">
            ID: {usuarioInfo.id}
            {usuarioInfo.email ? ` · ${usuarioInfo.email}` : ""}
          </p>
        )}
      </div>

      {usuarioSeleccionado ? (
        <>
        <div className="modulos-container">
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
                      {modulo.submodulos?.length > 0 && (
                        <div className="submodulos-preview">
                          <small>
                            +{modulo.submodulos.length} submódulo
                            {modulo.submodulos.length !== 1 ? "s" : ""}
                          </small>
                        </div>
                      )}
                    </div>
                    <button
                      type="button"
                      className="btn-asignar"
                      onClick={() => asignarModulo(modulo)}
                      title="Asignar módulo"
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

          <div className="center-info">
            <div className="arrow-icon">
              <FontAwesomeIcon icon={faArrowRight} />
            </div>
            <p>Arrastra módulos entre los paneles o usa los botones</p>
          </div>

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
                asignadosFiltrados.map((modulo) => {
                  const idmodulo = getModuloId(modulo);
                  const totalSubs = modulo.totalSubmodulos ?? modulo.submodulos?.length ?? 0;
                  const asignadosSubs = modulo.submodulosAsignados ?? totalSubs;
                  const seleccionado = moduloSeleccionado && getModuloId(moduloSeleccionado) === idmodulo;

                  return (
                  <div
                    key={idmodulo}
                    className={`modulo-item asignado ${seleccionado ? "seleccionado" : ""}`}
                    draggable
                    onDragStart={(e) => handleDragStart(e, modulo)}
                    onClick={() => seleccionarModulo(modulo)}
                    role="button"
                    tabIndex={0}
                    onKeyDown={(e) => e.key === "Enter" && seleccionarModulo(modulo)}
                  >
                    <div className="modulo-info">
                      <h3>{modulo.NOMBRE || modulo.IDMODULO__NOMBRE}</h3>
                      <p>{modulo.DESCRIPCION}</p>
                      {totalSubs > 0 && (
                        <div className="submodulos-preview">
                          <small>
                            {asignadosSubs}/{totalSubs} submódulo{totalSubs !== 1 ? "s" : ""} activos
                            {seleccionado ? " · editando" : " · clic para gestionar"}
                          </small>
                        </div>
                      )}
                      <div className="permisos-badge">
                        {normalizarPermisos(modulo.PERMISOS).map((perm) => (
                          <span key={perm} className={clasePermiso(perm)}>
                            {perm}
                          </span>
                        ))}
                      </div>
                    </div>
                    <button
                      type="button"
                      className="btn-desasignar"
                      onClick={(e) => {
                        e.stopPropagation();
                        desasignarModulo(modulo);
                      }}
                      title="Quitar módulo"
                    >
                      <FontAwesomeIcon icon={faArrowLeft} />
                    </button>
                  </div>
                  );
                })
              ) : (
                <div className="empty-state">
                  <p>Sin módulos asignados</p>
                </div>
              )}
            </div>
          </div>
        </div>

        {moduloSeleccionado && (moduloSeleccionado.submodulos?.length > 0 || submodulosAsignados.length > 0 || submodulosDisponibles.length > 0) && (
          <div className="submodulos-section">
            <div className="submodulos-header">
              <h2>
                Submódulos de {moduloSeleccionado.NOMBRE || moduloSeleccionado.IDMODULO__NOMBRE}
              </h2>
              <p>Controla qué opciones del menú ve este usuario dentro del módulo</p>
            </div>

            <div className="modulos-container submodulos-container">
              <div className="panel disponibles">
                <div className="panel-header">
                  <h2>Submódulos sin acceso</h2>
                  <span className="count">{submodulosDisponibles.length}</span>
                </div>
                <div
                  className="modulos-list"
                  onDragOver={handleDragOver}
                  onDrop={handleDropSubDisponibles}
                >
                  {submodulosDisponibles.length > 0 ? (
                    submodulosDisponibles.map((sub) => (
                      <div
                        key={sub.IDSUBMODULO}
                        className="modulo-item submodulo-item"
                        draggable
                        onDragStart={(e) => handleDragStartSub(e, sub)}
                      >
                        <div className="modulo-info">
                          <h3>{sub.NOMBRE}</h3>
                          <p>{sub.DESCRIPCION}</p>
                        </div>
                        <button
                          type="button"
                          className="btn-asignar"
                          onClick={() => asignarSubmodulo(sub)}
                          title="Dar acceso"
                        >
                          <FontAwesomeIcon icon={faArrowRight} />
                        </button>
                      </div>
                    ))
                  ) : (
                    <div className="empty-state">
                      <p>Todos los submódulos están asignados</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="center-info">
                <div className="arrow-icon">
                  <FontAwesomeIcon icon={faArrowRight} />
                </div>
                <p>Arrastra o usa las flechas</p>
              </div>

              <div className="panel asignados">
                <div className="panel-header">
                  <h2>Submódulos con acceso</h2>
                  <span className="count">{submodulosAsignados.length}</span>
                </div>
                <div
                  className="modulos-list"
                  onDragOver={handleDragOver}
                  onDrop={handleDropSubAsignados}
                >
                  {submodulosAsignados.length > 0 ? (
                    submodulosAsignados.map((sub) => (
                      <div
                        key={sub.IDSUBMODULO}
                        className="modulo-item submodulo-item asignado"
                        draggable
                        onDragStart={(e) => handleDragStartSub(e, sub)}
                      >
                        <div className="modulo-info">
                          <h3>{sub.NOMBRE}</h3>
                          <p>{sub.DESCRIPCION}</p>
                        </div>
                        <button
                          type="button"
                          className="btn-desasignar"
                          onClick={() => desasignarSubmodulo(sub)}
                          title="Quitar acceso"
                        >
                          <FontAwesomeIcon icon={faArrowLeft} />
                        </button>
                      </div>
                    ))
                  ) : (
                    <div className="empty-state">
                      <p>Sin submódulos asignados</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
        </>
      ) : (
        <div className="no-user-selected">
          <p>Selecciona un usuario para ver y asignar módulos</p>
        </div>
      )}
    </div>
  );
};

export default AdminModulos;

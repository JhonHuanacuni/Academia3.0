import { useState, useEffect } from "react";

const sidebarConfig = {
  admin: [
    { label: "Dashboard", page: "dashboard" },
    { label: "Usuarios", page: "usuarios" },
    { label: "Membresías", page: "membresias" },
    { label: "Pagos", page: "pagos" },
    { label: "Asistencias", page: "asistencias" },
    { label: "Horario", page: "horario" },
    { label: "Biblioteca", page: "biblioteca" },
    { label: "Exámenes", page: "examenes" },
  ],
  secretario: [
    { label: "Dashboard", page: "dashboard" },
    { label: "Usuarios", page: "usuarios" },
    { label: "Pagos", page: "pagos" },
    { label: "Membresías", page: "membresias" },
    { label: "Asistencias", page: "asistencias" },
    { label: "Horario", page: "horario" },
    { label: "Biblioteca", page: "biblioteca" },
    { label: "Exámenes", page: "examenes" },
  ],
  usuario: [
    { label: "Dashboard", page: "dashboard" },
    { label: "Notas", page: "notas" },
    { label: "Asistencias", page: "asistencias" },
    { label: "Horario", page: "horario" },
    { label: "Biblioteca", page: "biblioteca" },
    { label: "Exámenes", page: "examenes" },
    { label: "Pagos", page: "pagos" },
  ],
};

const Sidebar = ({ role, activePage, onChangePage, isOpen, onClose }) => {
  const [collapsed, setCollapsed] = useState(false);
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 900);
      if (window.innerWidth < 900) {
        setCollapsed(false);
      }
    };

    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  const items = sidebarConfig[role] || sidebarConfig.student;

  const classes = ["sidebar"];
  if (collapsed) classes.push("sidebar-collapsed");
  if (isMobile) {
    classes.push("sidebar-mobile");
    if (isOpen) classes.push("sidebar-mobile-open");
  }

  const handleLink = (page) => {
    onChangePage(page);
    if (isMobile) onClose();
  };

  return (
    <aside className={classes.join(" ")}>
      <div className="sidebar-top">
        <div className="brand">Academia VITA</div>
        {!isMobile && (
          <button
            type="button"
            className="collapse-toggle"
            onClick={() => setCollapsed((prev) => !prev)}
            aria-label={collapsed ? "Expandir menú" : "Colapsar menú"}
          >
            {collapsed ? "›" : "‹"}
          </button>
        )}
      </div>

      <nav className="sidebar-nav">
        {items.map((item) => (
          <button
            key={item.page}
            type="button"
            className={"sidebar-link " + (activePage === item.page ? "active" : "")}
            onClick={() => handleLink(item.page)}
          >
            <span className="sidebar-icon">•</span>
            <span className="sidebar-label">{item.label}</span>
          </button>
        ))}
      </nav>

      {isMobile && isOpen && (
        <button className="sidebar-close" onClick={onClose} aria-label="Cerrar menú">
          ✕
        </button>
      )}
    </aside>
  );
};

export default Sidebar;

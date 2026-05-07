import { useEffect, useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faGauge,
  faUsers,
  faCalendarCheck,
  faUserPlus,
  faClipboardList,
  faMoneyBill,
  faBook,
  faFileLines,
  faFilePen,
  faIdCard,
  faChevronLeft,
  faChevronRight,
} from "@fortawesome/free-solid-svg-icons";
import SidebarSection from "./SidebarSection";
import SidebarSubLink from "./SidebarSubLink";

const sidebarConfig = {
  admin: [
    { type: "link", icon: faGauge, label: "Dashboard", page: "dashboard" },
    {
      type: "section",
      icon: faUsers,
      label: "Usuarios",
      section: "usuarios",
      children: [
        { icon: faUserPlus, label: "Registrar usuario", page: "usuarios" },
        { icon: faClipboardList, label: "Listado de usuarios", page: "usuarios" },
      ],
    },
    {
      type: "section",
      icon: faCalendarCheck,
      label: "Asistencias",
      section: "asistencias",
      children: [
        { icon: faCalendarCheck, label: "Marcar asistencia", page: "asistencias" },
        { icon: faClipboardList, label: "Ver asistencias", page: "asistencias" },
      ],
    },
    {
      type: "section",
      icon: faIdCard,
      label: "Membresías",
      section: "membresias",
      children: [
        { icon: faUserPlus, label: "Registrar membresía", page: "membresias" },
        { icon: faClipboardList, label: "Ver membresías", page: "membresias" },
        { icon: faMoneyBill, label: "Pagos", page: "pagos" },
      ],
    },
    { type: "link", icon: faBook, label: "Biblioteca", page: "biblioteca" },
    { type: "link", icon: faFileLines, label: "Exámenes", page: "examenes" },
    {
      type: "section",
      icon: faFilePen,
      label: "Notas",
      section: "notas",
      children: [
        { icon: faClipboardList, label: "Ver notas", page: "notas" },
      ],
    },
  ],
  secretario: [
    { type: "link", icon: faGauge, label: "Dashboard", page: "dashboard" },
    {
      type: "section",
      icon: faUsers,
      label: "Usuarios",
      section: "usuarios",
      children: [
        { icon: faUserPlus, label: "Registrar usuario", page: "usuarios" },
        { icon: faClipboardList, label: "Listado de usuarios", page: "usuarios" },
      ],
    },
    {
      type: "section",
      icon: faCalendarCheck,
      label: "Asistencias",
      section: "asistencias",
      children: [
        { icon: faCalendarCheck, label: "Marcar asistencia", page: "asistencias" },
        { icon: faClipboardList, label: "Ver asistencias", page: "asistencias" },
      ],
    },
    {
      type: "section",
      icon: faIdCard,
      label: "Membresías",
      section: "membresias",
      children: [
        { icon: faUserPlus, label: "Registrar membresía", page: "membresias" },
        { icon: faClipboardList, label: "Ver membresías", page: "membresias" },
        { icon: faMoneyBill, label: "Pagos", page: "pagos" },
      ],
    },
    { type: "link", icon: faBook, label: "Biblioteca", page: "biblioteca" },
    { type: "link", icon: faFileLines, label: "Exámenes", page: "examenes" },
  ],
  usuario: [
    { type: "link", icon: faGauge, label: "Dashboard", page: "dashboard" },
    { type: "link", icon: faFilePen, label: "Notas", page: "notas" },
    { type: "link", icon: faClipboardList, label: "Asistencias", page: "asistencias" },
    { type: "link", icon: faCalendarCheck, label: "Horario", page: "horario" },
    { type: "link", icon: faBook, label: "Biblioteca", page: "biblioteca" },
    { type: "link", icon: faFileLines, label: "Exámenes", page: "examenes" },
    { type: "link", icon: faMoneyBill, label: "Pagos", page: "pagos" },
  ],
};

const Sidebar = ({ role, activePage, onChangePage, isOpen, onClose }) => {
  const [collapsed, setCollapsed] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [activeSection, setActiveSection] = useState(null);

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      const mobile = width < 900;
      setIsMobile(mobile);
      if (mobile) {
        setCollapsed(false);
      } else if (width < 1100) {
        setCollapsed(true);
      } else {
        setCollapsed(false);
      }
    };

    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  const items = sidebarConfig[role] || sidebarConfig.usuario;
  const sidebarClasses = ["sidebar"];
  if (collapsed) sidebarClasses.push("sidebar-collapsed");
  if (isMobile) {
    sidebarClasses.push("sidebar-mobile");
    if (isOpen) sidebarClasses.push("sidebar-mobile-open");
  }

  const handleLink = (page) => {
    onChangePage(page);
    if (isMobile) onClose();
  };

  const toggleSection = (sectionKey) => {
    setActiveSection((current) => (current === sectionKey ? null : sectionKey));
  };

  return (
    <aside className={sidebarClasses.join(" ")}>
      <div className="sidebar-top">
        <div className="brand">ACADEMIA VITA</div>
        {!isMobile && (
          <button
            type="button"
            className="collapse-toggle"
            onClick={() => setCollapsed((prev) => !prev)}
            aria-label={collapsed ? "Expandir menú" : "Colapsar menú"}
          >
            <FontAwesomeIcon icon={collapsed ? faChevronRight : faChevronLeft} />
          </button>
        )}
      </div>

      <nav className="sidebar-nav">
        {items.map((item) => {
          if (item.type === "link") {
            return (
              <button
                key={item.page + item.label}
                type="button"
                className={"sidebar-link " + (activePage === item.page ? "active" : "")}
                onClick={() => handleLink(item.page)}
              >
                <span className="sidebar-icon">
                  <FontAwesomeIcon icon={item.icon} />
                </span>
                {!collapsed && <span className="sidebar-label">{item.label}</span>}
              </button>
            );
          }

          return (
            <SidebarSection
              key={item.section}
              icon={item.icon}
              label={item.label}
              isOpen={activeSection === item.section}
              onToggle={() => toggleSection(item.section)}
              collapsed={collapsed && !isMobile}
              activePage={activePage}
            >
              {item.children.map((child) => (
                <SidebarSubLink
                  key={child.label}
                  icon={child.icon}
                  label={child.label}
                  collapsed={collapsed && !isMobile}
                  onClick={() => handleLink(child.page)}
                  active={activePage === child.page}
                />
              ))}
            </SidebarSection>
          );
        })}
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

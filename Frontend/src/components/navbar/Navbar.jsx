import { useState, useEffect, useRef } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faBars, faBell, faUser } from "@fortawesome/free-solid-svg-icons";

const Navbar = ({ role, onToggleSidebar, onLogout, backendMessage }) => {
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [notificationCount, setNotificationCount] = useState(0);
  const userMenuRef = useRef(null);
  const notificationsRef = useRef(null);

  const userRole = role ? role.charAt(0).toUpperCase() + role.slice(1) : "Usuario";

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (
        userMenuRef.current && !userMenuRef.current.contains(event.target) &&
        notificationsRef.current && !notificationsRef.current.contains(event.target)
      ) {
        setShowUserMenu(false);
        setShowNotifications(false);
      }
    };

    document.addEventListener("click", handleClickOutside);
    return () => document.removeEventListener("click", handleClickOutside);
  }, []);

  useEffect(() => {
    setNotificationCount(0);
  }, []);

  return (
    <header className="app-navbar">
      <div className="navbar-left">
        <button
          className="navbar-toggle"
          onClick={onToggleSidebar}
          aria-label="Abrir menú"
        >
          <FontAwesomeIcon icon={faBars} />
        </button>
        <div className="navbar-brand" onClick={() => window.scrollTo(0, 0)}>
          ACADEMIA VITA
        </div>
        <div className="navbar-subtitle">Actualización a Academia 3.0</div>
      </div>

      <div className="navbar-right">
        <div className="backend-status">{backendMessage}</div>

        <button
          className="navbar-icon-btn"
          onClick={() => {
            setShowNotifications((prev) => !prev);
            setShowUserMenu(false);
          }}
          ref={notificationsRef}
          aria-label="Notificaciones"
        >
          <FontAwesomeIcon icon={faBell} />
          {notificationCount > 0 && (
            <span className="navbar-badge">{notificationCount}</span>
          )}
        </button>

        <span className="navbar-role">{userRole}</span>

        <div className="navbar-user" ref={userMenuRef}>
          <button
            className="navbar-icon-btn"
            onClick={() => {
              setShowUserMenu((prev) => !prev);
              setShowNotifications(false);
            }}
            aria-label="Abrir menú de usuario"
          >
            <FontAwesomeIcon icon={faUser} />
          </button>
          {showUserMenu && (
            <div className="navbar-dropdown">
              <button className="navbar-dropdown-item" type="button">
                Perfil
              </button>
              <button className="navbar-dropdown-item" type="button" onClick={onLogout}>
                Cerrar sesión
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Navbar;

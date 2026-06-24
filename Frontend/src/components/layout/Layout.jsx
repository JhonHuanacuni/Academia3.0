import Navbar from "../navbar/Navbar";
import Sidebar from "../sidebar/Sidebar";
import Footer from "../footer/Footer";

const Layout = ({
  children,
  role,
  activePage,
  onChangePage,
  isSidebarOpen,
  onToggleSidebar,
  onCloseSidebar,
  onLogout,
}) => {
  return (
    <div className="app-shell">
      <Sidebar
        role={role}
        activePage={activePage}
        onChangePage={onChangePage}
        isOpen={isSidebarOpen}
        onClose={onCloseSidebar}
      />

      <div className="main-content">
        <Navbar
          role={role}
          onToggleSidebar={onToggleSidebar}
          onLogout={onLogout}
        />
        <main className="content">{children}</main>
        <Footer />
      </div>
    </div>
  );
};

export default Layout;

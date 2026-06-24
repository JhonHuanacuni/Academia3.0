const Footer = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="app-footer">
      <span>Academia VITA © {currentYear} — Todos los derechos reservados.</span>
    </footer>
  );
};

export default Footer;

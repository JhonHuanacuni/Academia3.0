export default function ExamenDistribucion({ categorias = [], materias = [] }) {
  if (!categorias.length) {
    return <p className="pago-hint">Sin distribución disponible.</p>;
  }

  return (
    <div className="examen-dist-grid">
      {categorias.map((cat) => {
        const mats = materias.filter((m) => m.IDCATEGORIA === cat.IDCATEGORIA);
        const pct = Number(cat.PORCENTAJE) || 0;
        return (
          <div key={cat.IDCATEGORIA} className="examen-dist-card">
            <div className="examen-dist-head">
              <strong>{cat.CATEGORIA_NOMBRE}</strong>
              <span className="examen-dist-pct">
                {pct.toLocaleString("es-PE", {
                  minimumFractionDigits: 1,
                  maximumFractionDigits: 1,
                })}
                %
              </span>
            </div>
            <div className="examen-dist-meta">
              {cat.AREAS} áreas · {cat.TOTALPREGUNTAS} preguntas
            </div>
            <div className="examen-dist-bar">
              <span style={{ width: `${Math.min(100, pct)}%` }} />
            </div>
            <div className="examen-dist-materias">
              {mats.map((m) => (
                <div key={m.IDMATERIA || m.CODIGO} className="examen-dist-materia">
                  <span className="examen-dist-abrev">{m.CODIGO}</span>
                  <span>{m.MATERIA_NOMBRE}</span>
                  <span>{m.CANTIDAD}</span>
                </div>
              ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}

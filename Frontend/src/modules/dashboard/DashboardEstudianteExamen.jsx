function fmtPct(value) {
  if (value == null || value === "") return "—";
  return `${Number(value).toFixed(1)}%`;
}

function fmtPuntaje(value) {
  if (value == null || value === "") return "—";
  return Number(value).toFixed(1);
}

export default function DashboardEstudianteExamen({ data, onNavigate }) {
  const examenData = data?.ultimoExamen;
  const examen = examenData?.examen;
  const ranking = examenData?.ranking || [];

  return (
    <div className="dash-est">
      <header className="dash-head">
        <h1>Dashboard</h1>
        {data?.acciones?.length > 0 && (
          <div className="dash-shortcuts">
            {data.acciones.map((a) => (
              <button
                key={a.page}
                type="button"
                className="dash-shortcut"
                onClick={() => onNavigate(a.page)}
              >
                {a.label}
              </button>
            ))}
          </div>
        )}
      </header>

      <div className="mantenedor-card dash-est-card">
        {examen?.IDEXAMEN ? (
          <>
            <div className="dash-est-head">
              <div>
                <h2>{examen.TITULO}</h2>
                <p>
                  {examen.AULA_NOMBRE ? `Salón: ${examen.AULA_NOMBRE}` : "Ranking del salón"}
                  {examenData.miPosicion != null && (
                    <span className="dash-est-mi-puesto">
                      Tu puesto: <strong>{examenData.miPosicion}°</strong>
                    </span>
                  )}
                </p>
              </div>
              {examenData.miPuntaje != null && (
                <div className="dash-est-mi-nota">
                  <span className="dash-est-mi-nota-val">{fmtPuntaje(examenData.miPuntaje)}</span>
                  <span className="dash-est-mi-nota-lbl">Tu puntaje</span>
                </div>
              )}
            </div>

            <div className="data-table-wrap">
              <table className="data-table dash-est-table">
                <thead>
                  <tr>
                    <th className="col-num">#</th>
                    <th>DNI</th>
                    <th className="col-num">Puntaje</th>
                    <th className="col-num">% Correctas</th>
                    <th className="col-num">% Errores</th>
                    <th className="col-num">% Blanco</th>
                  </tr>
                </thead>
                <tbody>
                  {ranking.map((row) => {
                    const esYo = row.ES_YO === 1 || row.ES_YO === true;
                    return (
                      <tr key={row.IDUSUARIO || row.DNI} className={esYo ? "dash-est-row--yo" : ""}>
                        <td className="col-num">{row.POSICION ?? "—"}</td>
                        <td>{row.DNI || "—"}</td>
                        <td className="col-num col-puntaje">{fmtPuntaje(row.PUNTAJEOBTENIDO)}</td>
                        <td className="col-num col-ok">{fmtPct(row.PCT_CORRECTAS)}</td>
                        <td className="col-num col-err">{fmtPct(row.PCT_ERRORES)}</td>
                        <td className="col-num col-blank">{fmtPct(row.PCT_BLANCO)}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </>
        ) : (
          <div className="dash-est-empty">
            <p>Aún no hay exámenes realizados en tu salón.</p>
            <button
              type="button"
              className="btn-primary"
              onClick={() => onNavigate("academico-examenes")}
            >
              Ir a exámenes
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

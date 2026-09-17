function fmtPct(value) {
  if (value == null || value === "") return "—";
  return `${Number(value).toFixed(1)}%`;
}

function fmtPuntaje(value) {
  if (value == null || value === "") return "—";
  return Number(value).toFixed(1);
}

function etiquetaTipo(examen) {
  const origen = String(examen?.ORIGEN || examen?.TIPO_EXAMEN || "").toLowerCase();
  if (origen === "importado" || origen === "presencial") {
    const n = examen?.TIPO_IMPORTACION || examen?.TOTALPREGUNTAS;
    return n ? `Presencial · ${n} preguntas` : "Presencial";
  }
  return "Virtual";
}

function dniRanking(row) {
  const esYo = row.ES_YO === 1 || row.ES_YO === true;
  if (esYo && row.DNI) return String(row.DNI);
  return "••••••••";
}

export default function DashboardEstudianteExamen({ data, onNavigate }) {
  const examenData = data?.ultimoExamen;
  const examen = examenData?.examen;
  const ranking = examenData?.ranking || [];
  const hayExamen = Boolean(examen?.TITULO || examen?.IDEXAMEN || examen?.IDIMPORTACION);

  return (
    <div className="dash-est">
      <div className="mantenedor-card dash-est-card">
        {hayExamen ? (
          <>
            <div className="dash-est-head">
              <div>
                <h2>{examen.TITULO}</h2>
                <p>
                  <span className="dash-est-tipo">{etiquetaTipo(examen)}</span>
                  {examen.AULA_NOMBRE ? `Salón: ${examen.AULA_NOMBRE}` : "Ranking"}
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
                    <th className="col-num">N°</th>
                    <th>DNI</th>
                    <th className="col-num">Puntaje</th>
                    <th className="col-num">%<span className="dash-est-th-full"> Correctas</span></th>
                    <th className="col-num dash-est-col-extra">%<span className="dash-est-th-full"> Errores</span></th>
                    <th className="col-num dash-est-col-extra">%<span className="dash-est-th-full"> Blanco</span></th>
                  </tr>
                </thead>
                <tbody>
                  {ranking.map((row) => {
                    const esYo = row.ES_YO === 1 || row.ES_YO === true;
                    return (
                      <tr key={row.IDUSUARIO || `${row.POSICION}-${row.DNI}`} className={esYo ? "dash-est-row--yo" : ""}>
                        <td className="col-num">{row.POSICION ?? "—"}</td>
                        <td>
                          <span className={esYo ? "dash-est-dni dash-est-dni--yo" : "dash-est-dni dash-est-dni--nublado"}>
                            {dniRanking(row)}
                          </span>
                        </td>
                        <td className="col-num col-puntaje">{fmtPuntaje(row.PUNTAJEOBTENIDO)}</td>
                        <td className="col-num col-ok">{fmtPct(row.PCT_CORRECTAS)}</td>
                        <td className="col-num col-err dash-est-col-extra">{fmtPct(row.PCT_ERRORES)}</td>
                        <td className="col-num col-blank dash-est-col-extra">{fmtPct(row.PCT_BLANCO)}</td>
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

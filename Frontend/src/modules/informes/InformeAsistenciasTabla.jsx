import { claseMarca, claseVence, esDiaNoLectivo } from "./informeAsistenciasUtils";

export default function InformeAsistenciasTabla({ filas, dias }) {
  if (!filas?.length || !dias?.length) {
    return <div className="mantenedor-state">No hay datos de asistencia para mostrar.</div>;
  }

  return (
    <div className="informe-tabla-outer">
      <table className="informe-asistencias-table">
        <thead>
          <tr>
            <th className="col-num sticky-izq">N°</th>
            <th className="col-nombre sticky-izq">NOMBRES Y APELLIDOS</th>
            <th className="col-vence sticky-izq sticky-izq--ultimo">VENCE</th>
            <th className="col-tutora">TUTORA</th>
            <th className="col-aula">AULA</th>
            <th className="col-ciclo">CICLO</th>
            <th className="col-estado">ESTADO</th>
            {dias.map((dia) => (
              <th
                key={dia.fecha}
                className={`col-dia${dia.esDomingo ? " col-dia-dom" : ""}`}
                title={dia.fecha}
              >
                {dia.etiqueta}
              </th>
            ))}
            <th className="col-total sticky-der sticky-der--asist">
              TOTAL
              <br />
              ASIST
            </th>
            <th className="col-total sticky-der sticky-der--tard">
              TOTAL
              <br />
              TARD
            </th>
            <th className="col-total sticky-der sticky-der--faltas sticky-der--primero">
              TOTAL
              <br />
              FALTAS
            </th>
          </tr>
        </thead>
        <tbody>
          {filas.map((fila) => (
            <tr key={fila.idusuario || fila.numero}>
              <td className="col-num sticky-izq">{fila.numero}</td>
              <td className="col-nombre sticky-izq" title={fila.nombres}>
                {fila.nombres}
              </td>
              <td className={`col-vence sticky-izq sticky-izq--ultimo ${claseVence(fila)}`}>
                {fila.vence || ""}
              </td>
              <td className="col-tutora">{fila.tutora}</td>
              <td className="col-aula">{fila.aula}</td>
              <td className="col-ciclo">{fila.ciclo}</td>
              <td className="col-estado">{fila.estado}</td>
              {dias.map((dia) => {
                const codigo = fila.marcas?.[dia.fecha] || "";
                const noLectivo = esDiaNoLectivo(fila, dia.fecha);
                const esDomingoVacio = dia.esDomingo && !codigo;
                return (
                  <td
                    key={dia.fecha}
                    className={`col-dia ${claseMarca(codigo)}${
                      noLectivo ? " col-dia-no-lectivo" : ""
                    }${esDomingoVacio ? " col-dia-dom-vacio" : ""}`}
                  >
                    {codigo}
                  </td>
                );
              })}
              <td className="col-total col-total-asist sticky-der sticky-der--asist">{fila.totalAsist}</td>
              <td
                className={`col-total col-total-tard sticky-der sticky-der--tard${
                  fila.totalTard > 0 ? " col-total-tard--destacado" : ""
                }`}
              >
                {fila.totalTard}
              </td>
              <td
                className={`col-total col-total-faltas sticky-der sticky-der--faltas sticky-der--primero${
                  fila.totalFaltas > 0 ? " col-total-faltas--destacado" : ""
                }`}
              >
                {fila.totalFaltas}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

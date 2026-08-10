import { dbToView } from "../../utils/fecha";

export function fmtFechaHora(fecha, hora) {
  if (!fecha || String(fecha).length !== 8) return "—";
  const f = dbToView(String(fecha));
  if (!hora) return f;
  return `${f}, ${hora}`;
}

export default function MateriaChipBar({ materias, totalTodos, seleccionada, onSelect }) {
  return (
    <div className="cg-materias-bar" role="tablist" aria-label="Materias">
      <button
        type="button"
        role="tab"
        className={`cg-materia-chip${!seleccionada ? " cg-materia-chip--activa" : ""}`}
        onClick={() => onSelect("")}
      >
        Ver todos <span>({totalTodos})</span>
      </button>
      {(materias || []).map((m) => (
        <button
          key={m.IDMATERIA}
          type="button"
          role="tab"
          aria-selected={seleccionada === m.IDMATERIA}
          className={`cg-materia-chip${seleccionada === m.IDMATERIA ? " cg-materia-chip--activa" : ""}`}
          onClick={() => onSelect(m.IDMATERIA)}
        >
          {m.MATERIA_NOMBRE} <span>({m.CANTIDAD})</span>
        </button>
      ))}
    </div>
  );
}

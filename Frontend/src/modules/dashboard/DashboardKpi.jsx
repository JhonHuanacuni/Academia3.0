import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCalendarCheck,
  faChartLine,
  faMoneyBillWave,
  faUserCheck,
  faUserGraduate,
  faUsers,
  faWallet,
} from "@fortawesome/free-solid-svg-icons";

const ICONS = {
  estudiantes: faUserGraduate,
  deuda: faWallet,
  cobrado: faMoneyBillWave,
  conDeuda: faChartLine,
  asistencia: faCalendarCheck,
  presentes: faUserCheck,
  usuarios: faUsers,
};

export default function DashboardKpi({ items }) {
  if (!items?.length) return null;
  return (
    <div className="dash-kpis">
      {items.map((item) => (
        <article key={item.key} className={`dash-kpi dash-kpi--${item.tono || "primary"}`}>
          <div className="dash-kpi-icon">
            <FontAwesomeIcon icon={ICONS[item.icon] || faUsers} />
          </div>
          <div className="dash-kpi-body">
            <span className="dash-kpi-valor">{item.valor}</span>
            <span className="dash-kpi-label">{item.etiqueta}</span>
          </div>
        </article>
      ))}
    </div>
  );
}

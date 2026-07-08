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
  faCog,
  faKey,
  faCircle,
  faGraduationCap,
  faChalkboard,
  faChartColumn,
  faCalendarDays,
} from "@fortawesome/free-solid-svg-icons";

const ICON_MAP = {
  faGauge: faGauge,
  faUsers: faUsers,
  faCalendarCheck: faCalendarCheck,
  faUserPlus: faUserPlus,
  faClipboardList: faClipboardList,
  faMoneyBill: faMoneyBill,
  faBook: faBook,
  faFileLines: faFileLines,
  faFilePen: faFilePen,
  faIdCard: faIdCard,
  faCog: faCog,
  faKey: faKey,
  faCircle: faCircle,
  faGraduationCap: faGraduationCap,
  faChalkboard: faChalkboard,
  faChartColumn: faChartColumn,
  faCalendarDays: faCalendarDays,
};

export function resolveSidebarIcon(iconName) {
  if (!iconName) return faCircle;
  const key = iconName.startsWith("fa") ? iconName : `fa${iconName}`;
  return ICON_MAP[key] || faCircle;
}

import {
  faGauge,
  faUsers,
  faCalendarCheck,
  faUserPlus,
  faClipboardList,
  faMoneyBill,
  faMoneyBillWave,
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
  faTags,
  faLayerGroup,
  faBookOpen,
  faFileImport,
} from "@fortawesome/free-solid-svg-icons";

const ICON_MAP = {
  faGauge: faGauge,
  faUsers: faUsers,
  faCalendarCheck: faCalendarCheck,
  faUserPlus: faUserPlus,
  faClipboardList: faClipboardList,
  faMoneyBill: faMoneyBill,
  faMoneyBillWave: faMoneyBillWave,
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
  faTags: faTags,
  faLayerGroup: faLayerGroup,
  faBookOpen: faBookOpen,
  faFileImport: faFileImport,
};

export function resolveSidebarIcon(iconName) {
  if (!iconName) return faCircle;
  const key = iconName.startsWith("fa") ? iconName : `fa${iconName}`;
  return ICON_MAP[key] || faCircle;
}

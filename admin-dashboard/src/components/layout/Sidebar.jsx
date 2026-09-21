import { NavLink } from 'react-router-dom';
import {
  BuildingOffice2Icon,
  UsersIcon,
  DocumentTextIcon,
  UserGroupIcon,
  IdentificationIcon,
  BanknotesIcon,
  BellIcon,
  RectangleGroupIcon,
  WrenchScrewdriverIcon,
  CalendarDaysIcon,
  CheckCircleIcon,
  ChatBubbleLeftRightIcon,
  DevicePhoneMobileIcon,
  DocumentChartBarIcon,
  ChartBarIcon,
  Squares2X2Icon,
} from '@heroicons/react/24/outline';
import { useLocale } from '../../context/LocaleContext';
import { resources } from '../../config/resources';

const NAV_ITEMS = [
  { key: 'dashboard', icon: Squares2X2Icon, path: '/' },
  { key: 'properties', icon: BuildingOffice2Icon },
  { key: 'tenants', icon: UsersIcon },
  { key: 'contracts', icon: DocumentTextIcon },
  { key: 'owners', icon: UserGroupIcon },
  { key: 'users', icon: IdentificationIcon },
  { key: 'payments', icon: BanknotesIcon },
  { key: 'notifications', icon: BellIcon },
  { key: 'projects', icon: RectangleGroupIcon },
  { key: 'maintenance_requests', icon: WrenchScrewdriverIcon },
  { key: 'calendar_events', icon: CalendarDaysIcon },
  { key: 'tasks', icon: CheckCircleIcon },
  { key: 'conversations', icon: ChatBubbleLeftRightIcon },
  { key: 'mobile_requests', icon: DevicePhoneMobileIcon },
  { key: 'reports', icon: DocumentChartBarIcon },
  { key: 'analytics', icon: ChartBarIcon, path: '/analytics' },
];

export default function Sidebar({ open, onClose }) {
  const { t } = useLocale();

  return (
    <>
      {open && <div className="sidebar-backdrop" onClick={onClose} />}
      <aside className={`sidebar${open ? ' is-open' : ''}`}>
        <div className="sidebar-header">
          <BuildingOffice2Icon />
          <span>{t.brand}</span>
        </div>
        <nav className="sidebar-nav">
          {NAV_ITEMS.map(({ key, icon: Icon, path }) => {
            const resolvedPath = path ?? (resources[key] ? `/${resources[key].key}` : null);

            if (!resolvedPath) {
              return (
                <button key={key} type="button" className="sidebar-item" disabled>
                  <Icon />
                  <span>{t.nav[key]}</span>
                </button>
              );
            }

            return (
              <NavLink
                key={key}
                to={resolvedPath}
                end={resolvedPath === '/'}
                onClick={onClose}
                className={({ isActive }) => `sidebar-item is-clickable${isActive ? ' is-active' : ''}`}
              >
                <Icon />
                <span>{t.nav[key]}</span>
              </NavLink>
            );
          })}
        </nav>
      </aside>
    </>
  );
}

import { ArrowRightStartOnRectangleIcon, Bars3Icon } from '@heroicons/react/24/outline';
import { useLocale } from '../../context/LocaleContext';
import { useAuth } from '../../context/AuthContext';
import LocaleSwitcher from './LocaleSwitcher';

export default function Topbar({ heading, onMenuClick }) {
  const { t } = useLocale();
  const { logout } = useAuth();

  return (
    <header className="topbar">
      <div className="topbar-start">
        <button type="button" className="menu-btn" onClick={onMenuClick} aria-label="Menu">
          <Bars3Icon />
        </button>
        <h1 className="topbar-heading">{heading ?? t.dashboard}</h1>
      </div>
      <div className="topbar-actions">
        <LocaleSwitcher />
        <button type="button" className="logout-btn" onClick={logout}>
          <ArrowRightStartOnRectangleIcon />
          <span>{t.logout}</span>
        </button>
      </div>
    </header>
  );
}

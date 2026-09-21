import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { translations } from '../i18n/translations';

const LocaleContext = createContext(null);
const STORAGE_KEY = 'admin_dashboard_locale';

export function LocaleProvider({ children }) {
  const [locale, setLocaleState] = useState(() => localStorage.getItem(STORAGE_KEY) || 'en');

  // Written synchronously (not in an effect) so API calls triggered by this same
  // locale change — which run in child effects before this provider's own effect —
  // read the new value instead of racing ahead of it.
  function setLocale(next) {
    localStorage.setItem(STORAGE_KEY, next);
    setLocaleState(next);
  }

  useEffect(() => {
    document.documentElement.lang = locale;
    document.documentElement.dir = translations[locale].dir;
  }, [locale]);

  const value = useMemo(
    () => ({ locale, setLocale, t: translations[locale] }),
    [locale],
  );

  return <LocaleContext.Provider value={value}>{children}</LocaleContext.Provider>;
}

export function useLocale() {
  const ctx = useContext(LocaleContext);
  if (!ctx) {
    throw new Error('useLocale must be used within LocaleProvider');
  }
  return ctx;
}

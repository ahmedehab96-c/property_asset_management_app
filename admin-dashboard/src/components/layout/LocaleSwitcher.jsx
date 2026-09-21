import { useState } from 'react';
import { GlobeAltIcon, ChevronDownIcon, CheckIcon } from '@heroicons/react/24/outline';
import { useLocale } from '../../context/LocaleContext';

const OPTIONS = [
  { code: 'en', flag: '🇬🇧' },
  { code: 'ar', flag: '🇦🇪' },
];

export default function LocaleSwitcher() {
  const { locale, setLocale, t } = useLocale();
  const [open, setOpen] = useState(false);

  return (
    <div className="locale-switcher">
      <button type="button" className="locale-trigger" onClick={() => setOpen((v) => !v)}>
        <GlobeAltIcon width={18} height={18} />
        <span>{locale.toUpperCase()}</span>
        <ChevronDownIcon width={14} height={14} />
      </button>
      {open && (
        <div className="locale-menu">
          {OPTIONS.map((option) => (
            <button
              key={option.code}
              type="button"
              className={`locale-option${locale === option.code ? ' is-active' : ''}`}
              onClick={() => {
                setLocale(option.code);
                setOpen(false);
              }}
            >
              <span className="locale-flag">{option.flag}</span>
              <span>{option.code === 'en' ? t.english : t.arabic}</span>
              {locale === option.code && <CheckIcon width={14} height={14} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

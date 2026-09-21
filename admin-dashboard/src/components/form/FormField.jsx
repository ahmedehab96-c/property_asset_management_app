import { useLocale } from '../../context/LocaleContext';
import { fieldHint, fieldLabel } from '../../i18n/translations';

function toDateInputValue(value) {
  if (!value) return '';
  return String(value).slice(0, 10);
}

export default function FormField({ field, value, onChange, options }) {
  const { locale } = useLocale();
  const commonProps = {
    id: field.name,
    name: field.name,
    required: field.required,
  };

  if (field.type === 'checkbox') {
    return (
      <div className={`form-field form-field-checkbox${field.fullWidth ? ' field-full' : ''}`}>
        <label htmlFor={field.name} className="checkbox-label">
          <input
            id={field.name}
            name={field.name}
            type="checkbox"
            checked={Boolean(value)}
            onChange={(e) => onChange(field.name, e.target.checked)}
          />
          <span>{fieldLabel(field.label, locale)}</span>
        </label>
      </div>
    );
  }

  return (
    <div className={`form-field${field.fullWidth ? ' field-full' : ''}`}>
      <label htmlFor={field.name}>
        {fieldLabel(field.label, locale)}
        {field.required && <span className="field-required">*</span>}
      </label>
      {field.type === 'textarea' && (
        <textarea
          {...commonProps}
          rows={4}
          value={value ?? ''}
          onChange={(e) => onChange(field.name, e.target.value)}
        />
      )}
      {field.type === 'number' && (
        <input
          {...commonProps}
          type="number"
          step="any"
          value={value ?? ''}
          onChange={(e) => onChange(field.name, e.target.value)}
        />
      )}
      {field.type === 'text' && (
        <input
          {...commonProps}
          type={field.inputType ?? 'text'}
          value={value ?? ''}
          onChange={(e) => onChange(field.name, e.target.value)}
        />
      )}
      {field.type === 'date' && (
        <input
          {...commonProps}
          type="date"
          value={toDateInputValue(value)}
          onChange={(e) => onChange(field.name, e.target.value)}
        />
      )}
      {field.type === 'datetime' && (
        <input
          {...commonProps}
          type="datetime-local"
          value={value ? String(value).slice(0, 16) : ''}
          onChange={(e) => onChange(field.name, e.target.value)}
        />
      )}
      {(field.type === 'select' || field.type === 'relation-select') && (
        <select
          {...commonProps}
          value={value ?? ''}
          onChange={(e) => onChange(field.name, e.target.value)}
        >
          <option value="">—</option>
          {(options ?? field.options ?? []).map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      )}
      {field.hint && <span className="field-hint">{fieldHint(field.hint, locale)}</span>}
    </div>
  );
}

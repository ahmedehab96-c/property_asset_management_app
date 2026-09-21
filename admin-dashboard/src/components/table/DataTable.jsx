import { ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/16/solid';
import { useLocale } from '../../context/LocaleContext';
import { fieldLabel } from '../../i18n/translations';

function formatCell(column, value, locale, lookups) {
  if (column.boolean) {
    return value ? '✓' : '—';
  }
  if (column.lookup) {
    const label = lookups?.[column.key]?.[value];
    if (label) return label;
  }
  if (value === null || value === undefined || value === '') return '—';
  if (column.datetime) {
    return new Date(value).toLocaleString(locale === 'ar' ? 'ar-EG' : 'en-US', {
      dateStyle: 'medium',
      timeStyle: 'short',
    });
  }
  if (column.date) {
    return new Date(value).toLocaleDateString(locale === 'ar' ? 'ar-EG' : 'en-US', {
      dateStyle: 'medium',
    });
  }
  if (column.currency) {
    return `${Number(value).toLocaleString(locale === 'ar' ? 'ar-EG' : 'en-US')} AED`;
  }
  if (column.numeric) {
    return Number(value).toLocaleString(locale === 'ar' ? 'ar-EG' : 'en-US');
  }
  return value;
}

export default function DataTable({
  columns,
  rows,
  rowKey = 'id',
  sortKey,
  sortDir,
  onSort,
  selectedIds,
  onToggleSelect,
  onToggleSelectAll,
  renderRowActions,
  lookups,
}) {
  const { locale } = useLocale();
  const allSelected = rows.length > 0 && rows.every((r) => selectedIds.has(r[rowKey]));

  return (
    <div className="table-scroll">
      <table className="data-table">
        <thead>
          <tr>
            {onToggleSelect && (
              <th className="col-checkbox">
                <input
                  type="checkbox"
                  checked={allSelected}
                  onChange={(e) => onToggleSelectAll(e.target.checked)}
                />
              </th>
            )}
            {columns.map((col) => (
              <th key={col.key}>
                {col.sortable ? (
                  <button type="button" className="th-sort-btn" onClick={() => onSort(col.key)}>
                    <span>{fieldLabel(col.label, locale)}</span>
                    {sortKey === col.key &&
                      (sortDir === 'asc' ? <ChevronUpIcon width={14} /> : <ChevronDownIcon width={14} />)}
                  </button>
                ) : (
                  fieldLabel(col.label, locale)
                )}
              </th>
            ))}
            {renderRowActions && <th className="col-actions" />}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 && (
            <tr>
              <td colSpan={columns.length + 2} className="table-empty">
                —
              </td>
            </tr>
          )}
          {rows.map((row) => (
            <tr key={row[rowKey]}>
              {onToggleSelect && (
                <td className="col-checkbox">
                  <input
                    type="checkbox"
                    checked={selectedIds.has(row[rowKey])}
                    onChange={() => onToggleSelect(row[rowKey])}
                  />
                </td>
              )}
              {columns.map((col) => (
                <td key={col.key}>
                  {col.badge ? (
                    <span className={`badge badge-${String(row[col.key] ?? '').toLowerCase()}`}>
                      {formatCell(col, row[col.key], locale)}
                    </span>
                  ) : (
                    formatCell(col, row[col.key], locale, lookups)
                  )}
                </td>
              ))}
              {renderRowActions && <td className="col-actions">{renderRowActions(row)}</td>}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

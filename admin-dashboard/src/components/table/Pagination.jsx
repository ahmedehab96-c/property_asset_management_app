import { ChevronLeftIcon, ChevronRightIcon } from '@heroicons/react/16/solid';

export default function Pagination({ meta, onPageChange }) {
  const { current_page: current = 1, last_page: last = 1, total = 0 } = meta;

  if (last <= 1) return null;

  return (
    <div className="pagination">
      <span className="pagination-total">{total}</span>
      <button
        type="button"
        className="pagination-btn"
        disabled={current <= 1}
        onClick={() => onPageChange(current - 1)}
      >
        <ChevronLeftIcon width={16} />
      </button>
      <span className="pagination-page">
        {current} / {last}
      </span>
      <button
        type="button"
        className="pagination-btn"
        disabled={current >= last}
        onClick={() => onPageChange(current + 1)}
      >
        <ChevronRightIcon width={16} />
      </button>
    </div>
  );
}

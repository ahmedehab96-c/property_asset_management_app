import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { PlusIcon, TrashIcon, PencilSquareIcon, Bars3BottomLeftIcon } from '@heroicons/react/20/solid';
import { apiRequest } from '../../api/client';
import { listResource, deleteResource } from '../../api/resource';
import { useLocale } from '../../context/LocaleContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import DataTable from '../../components/table/DataTable';
import Pagination from '../../components/table/Pagination';

export default function ResourceListPage({ resource }) {
  const { t, locale } = useLocale();
  const navigate = useNavigate();

  const [rows, setRows] = useState([]);
  const [meta, setMeta] = useState({ current_page: 1, last_page: 1, total: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [sortKey, setSortKey] = useState(null);
  const [sortDir, setSortDir] = useState('asc');
  const [selectedIds, setSelectedIds] = useState(new Set());
  const [showHiddenColumns, setShowHiddenColumns] = useState(false);
  const [lookups, setLookups] = useState({});

  useEffect(() => {
    resource.columns
      .filter((c) => c.lookup)
      .forEach((col) => {
        apiRequest(`${col.lookup.endpoint}?per_page=200`)
          .then((payload) => {
            const items = payload?.items ?? payload?.data ?? [];
            const map = {};
            items.forEach((item) => {
              map[item.id] = item[col.lookup.labelField];
            });
            setLookups((prev) => ({ ...prev, [col.key]: map }));
          })
          .catch(() => {});
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [resource, locale]);

  const columns = useMemo(
    () => resource.columns.filter((c) => !c.hiddenByDefault || showHiddenColumns),
    [resource.columns, showHiddenColumns],
  );
  const hasHiddenColumns = resource.columns.some((c) => c.hiddenByDefault);

  function load() {
    setLoading(true);
    setError('');
    listResource(resource.endpoint, { search, page })
      .then(({ items, meta: pageMeta }) => {
        setRows(items);
        setMeta(pageMeta);
        setSelectedIds(new Set());
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [resource.endpoint, page, locale]);

  const prevSearchRef = useRef(search);
  useEffect(() => {
    if (prevSearchRef.current === search) {
      return undefined;
    }
    prevSearchRef.current = search;
    const handle = setTimeout(() => {
      setPage(1);
      load();
    }, 350);
    return () => clearTimeout(handle);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search]);

  const sortedRows = useMemo(() => {
    if (!sortKey) return rows;
    const copy = [...rows];
    copy.sort((a, b) => {
      const av = a[sortKey];
      const bv = b[sortKey];
      if (av === bv) return 0;
      const result = av > bv ? 1 : -1;
      return sortDir === 'asc' ? result : -result;
    });
    return copy;
  }, [rows, sortKey, sortDir]);

  function handleSort(key) {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
  }

  function toggleSelect(id) {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  function toggleSelectAll(checked) {
    setSelectedIds(checked ? new Set(rows.map((r) => r.id)) : new Set());
  }

  async function handleBulkDelete() {
    if (selectedIds.size === 0) return;
    if (!window.confirm(t.table.confirmDelete)) return;
    await Promise.all([...selectedIds].map((id) => deleteResource(resource.endpoint, id)));
    load();
  }

  async function handleDeleteOne(id) {
    if (!window.confirm(t.table.confirmDelete)) return;
    await deleteResource(resource.endpoint, id);
    load();
  }

  return (
    <DashboardLayout heading={t.nav[resource.navKey]}>
      <div className="panel list-panel">
        <div className="list-toolbar">
          <div className="list-toolbar-actions">
            <input
              type="text"
              className="search-input"
              placeholder={t.table.search}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            <div className="list-toolbar-buttons">
              {hasHiddenColumns && (
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={() => setShowHiddenColumns((v) => !v)}
                  title={t.table.toggleColumns}
                >
                  <Bars3BottomLeftIcon width={16} />
                </button>
              )}
              {selectedIds.size > 0 && (
                <button type="button" className="btn-danger" onClick={handleBulkDelete}>
                  <TrashIcon width={16} />
                  <span>
                    {t.table.deleteSelected} ({selectedIds.size})
                  </span>
                </button>
              )}
              <button type="button" className="btn-primary btn-sm" onClick={() => navigate('create')}>
                <PlusIcon width={16} />
                <span>{t.table.new}</span>
              </button>
            </div>
          </div>
        </div>

        {error && <div className="form-error">{error}</div>}
        {loading && <div className="state-message">{t.loading}</div>}

        {!loading && !error && (
          <>
            <DataTable
              columns={columns}
              rows={sortedRows}
              sortKey={sortKey}
              sortDir={sortDir}
              onSort={handleSort}
              selectedIds={selectedIds}
              onToggleSelect={toggleSelect}
              onToggleSelectAll={toggleSelectAll}
              lookups={lookups}
              renderRowActions={(row) => (
                <div className="row-actions">
                  <button
                    type="button"
                    className="icon-btn"
                    onClick={() => navigate(`${row.id}/edit`)}
                    title={t.table.edit}
                  >
                    <PencilSquareIcon width={16} />
                  </button>
                  <button
                    type="button"
                    className="icon-btn icon-btn-danger"
                    onClick={() => handleDeleteOne(row.id)}
                    title={t.table.delete}
                  >
                    <TrashIcon width={16} />
                  </button>
                </div>
              )}
            />
            <Pagination meta={meta} onPageChange={setPage} />
          </>
        )}
      </div>
    </DashboardLayout>
  );
}

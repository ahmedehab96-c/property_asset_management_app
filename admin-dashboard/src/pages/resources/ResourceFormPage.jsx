import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { apiRequest } from '../../api/client';
import { createResource, fetchResourceById, updateResource } from '../../api/resource';
import { useLocale } from '../../context/LocaleContext';
import DashboardLayout from '../../components/layout/DashboardLayout';
import ResourceForm from '../../components/form/ResourceForm';

function initialValues(fields) {
  const values = {};
  fields.forEach((field) => {
    values[field.name] = field.default ?? '';
  });
  return values;
}

export default function ResourceFormPage({ resource }) {
  const { t } = useLocale();
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [values, setValues] = useState(() => initialValues(resource.fields));
  const [relationOptions, setRelationOptions] = useState({});
  const [loading, setLoading] = useState(isEdit);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    resource.fields
      .filter((f) => f.type === 'relation-select')
      .forEach((field) => {
        apiRequest(`${field.endpoint}?per_page=200`)
          .then((payload) => {
            const items = payload?.items ?? payload?.data ?? [];
            setRelationOptions((prev) => ({
              ...prev,
              [field.name]: items.map((item) => ({ value: item.id, label: item[field.labelField] })),
            }));
          })
          .catch(() => {});
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [resource]);

  useEffect(() => {
    if (!isEdit) return;
    fetchResourceById(resource.endpoint, id)
      .then((record) => {
        const next = {};
        resource.fields.forEach((field) => {
          next[field.name] = record[field.name] ?? '';
        });
        setValues(next);
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isEdit, id, resource]);

  function handleChange(name, value) {
    setValues((prev) => ({ ...prev, [name]: value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setSaving(true);
    setError('');
    try {
      const payload = { ...values };
      resource.fields.forEach((field) => {
        if (field.omitIfEmpty && !payload[field.name]) {
          delete payload[field.name];
        }
      });
      if (isEdit) {
        await updateResource(resource.endpoint, id, payload);
      } else {
        await createResource(resource.endpoint, payload);
      }
      navigate(`/${resource.key}`);
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  const heading = `${isEdit ? t.table.editTitle : t.table.createTitle} — ${t.nav[resource.navKey]}`;

  return (
    <DashboardLayout heading={heading}>
      <form className="panel form-panel" onSubmit={handleSubmit}>
        {error && <div className="form-error">{error}</div>}
        {loading && <div className="state-message">{t.loading}</div>}

        {!loading && (
          <>
            <ResourceForm
              fields={resource.fields}
              values={values}
              onChange={handleChange}
              relationOptions={relationOptions}
            />
            <div className="form-actions">
              <button type="button" className="btn-secondary" onClick={() => navigate(`/${resource.key}`)}>
                {t.table.cancel}
              </button>
              <button type="submit" className="btn-primary" disabled={saving}>
                {saving ? t.table.saving : t.table.save}
              </button>
            </div>
          </>
        )}
      </form>
    </DashboardLayout>
  );
}

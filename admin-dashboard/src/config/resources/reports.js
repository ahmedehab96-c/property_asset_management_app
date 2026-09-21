export const reportsResource = {
  key: 'reports',
  endpoint: '/api/v1/reports',
  navKey: 'reports',
  columns: [
    { key: 'title', label: 'Title', sortable: true },
    { key: 'type', label: 'Type' },
    { key: 'owner_id', label: 'Owner', lookup: { endpoint: '/api/v1/owners', labelField: 'name' } },
    { key: 'property_name', label: 'Property' },
    { key: 'amount', label: 'Amount', sortable: true, numeric: true, currency: true },
    { key: 'created_at', label: 'Created at', datetime: true, hiddenByDefault: true },
    { key: 'updated_at', label: 'Updated at', datetime: true, hiddenByDefault: true },
  ],
  fields: [
    { name: 'title', label: 'Title', type: 'text', required: true },
    { name: 'title_ar', label: 'Title (Arabic)', type: 'text' },
    { name: 'type', label: 'Type', type: 'text', required: true, default: 'financial' },
    { name: 'owner_id', label: 'Owner', type: 'relation-select', endpoint: '/api/v1/owners', labelField: 'name' },
    { name: 'property_id', label: 'Property', type: 'relation-select', endpoint: '/api/v1/properties', labelField: 'name' },
    { name: 'amount', label: 'Amount', type: 'number' },
  ],
};

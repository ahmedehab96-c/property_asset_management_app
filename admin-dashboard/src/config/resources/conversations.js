export const conversationsResource = {
  key: 'conversations',
  endpoint: '/api/v1/conversations',
  navKey: 'conversations',
  columns: [
    { key: 'subject', label: 'Subject', sortable: true },
    { key: 'owner_name', label: 'Owner' },
    { key: 'tenant_name', label: 'Tenant' },
    { key: 'last_message_at', label: 'Last message at', datetime: true },
    { key: 'created_at', label: 'Created at', datetime: true, hiddenByDefault: true },
    { key: 'updated_at', label: 'Updated at', datetime: true, hiddenByDefault: true },
  ],
  fields: [
    { name: 'subject', label: 'Subject', type: 'text' },
    { name: 'subject_ar', label: 'Subject (Arabic)', type: 'text' },
    { name: 'owner_id', label: 'Owner', type: 'relation-select', endpoint: '/api/v1/owners', labelField: 'name' },
    { name: 'tenant_id', label: 'Tenant', type: 'relation-select', endpoint: '/api/v1/tenants', labelField: 'name' },
    { name: 'last_message_at', label: 'Last message at', type: 'datetime' },
  ],
};

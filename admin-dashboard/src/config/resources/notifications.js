export const notificationsResource = {
  key: 'notifications',
  endpoint: '/api/v1/notifications',
  navKey: 'notifications',
  columns: [
    { key: 'user_id', label: 'User', lookup: { endpoint: '/api/v1/users', labelField: 'name' } },
    { key: 'title', label: 'Title', sortable: true },
    { key: 'type', label: 'Type' },
    { key: 'read_at', label: 'Read at', datetime: true },
    { key: 'created_at', label: 'Created at', datetime: true, hiddenByDefault: true },
    { key: 'updated_at', label: 'Updated at', datetime: true, hiddenByDefault: true },
  ],
  fields: [
    { name: 'user_id', label: 'User', type: 'relation-select', endpoint: '/api/v1/users', labelField: 'name', required: true },
    { name: 'title', label: 'Title', type: 'text', required: true },
    { name: 'title_ar', label: 'Title (Arabic)', type: 'text' },
    { name: 'message', label: 'Message', type: 'textarea', fullWidth: true },
    { name: 'message_ar', label: 'Message (Arabic)', type: 'textarea', fullWidth: true },
    { name: 'type', label: 'Type', type: 'text', required: true, default: 'info' },
    { name: 'read_at', label: 'Read at', type: 'datetime' },
  ],
};

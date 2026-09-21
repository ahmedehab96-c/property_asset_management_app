export const mobileRequestsResource = {
  key: 'mobile-requests',
  endpoint: '/api/v1/mobile-requests',
  navKey: 'mobile_requests',
  columns: [
    { key: 'user_id', label: 'User', lookup: { endpoint: '/api/v1/users', labelField: 'name' } },
    { key: 'type', label: 'Type' },
    { key: 'title', label: 'Title', sortable: true },
    { key: 'status', label: 'Status' },
    { key: 'created_at', label: 'Created at', datetime: true, hiddenByDefault: true },
    { key: 'updated_at', label: 'Updated at', datetime: true, hiddenByDefault: true },
  ],
  fields: [
    { name: 'type', label: 'Type', type: 'text', required: true, default: 'service' },
    { name: 'title', label: 'Title', type: 'text' },
    { name: 'description', label: 'Description', type: 'textarea', fullWidth: true },
    { name: 'status', label: 'Status', type: 'text', required: true, default: 'pending' },
  ],
};

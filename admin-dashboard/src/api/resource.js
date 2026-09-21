import { apiRequest } from './client';

export function listResource(endpoint, { search, status, page = 1, perPage = 20 } = {}) {
  const params = new URLSearchParams();
  if (search) params.set('search', search);
  if (status) params.set('status', status);
  params.set('page', String(page));
  params.set('per_page', String(perPage));

  return apiRequest(`${endpoint}?${params.toString()}`).then((payload) => ({
    items: payload?.items ?? payload?.data ?? [],
    meta: payload?.meta ?? { current_page: 1, last_page: 1, total: (payload?.items ?? []).length },
  }));
}

export function createResource(endpoint, body) {
  return apiRequest(endpoint, { method: 'POST', body });
}

export function updateResource(endpoint, id, body) {
  return apiRequest(`${endpoint}/${id}`, { method: 'PUT', body });
}

// Always fetched in the canonical (English) locale — edit forms carry explicit
// `_ar` fields for the Arabic value, so the base field must show the raw stored
// value rather than whatever the current UI locale would resolve it to.
export function fetchResourceById(endpoint, id) {
  return apiRequest(`${endpoint}/${id}`, { locale: 'en' });
}

export function deleteResource(endpoint, id) {
  return apiRequest(`${endpoint}/${id}`, { method: 'DELETE' });
}

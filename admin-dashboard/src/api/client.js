// In dev, set VITE_API_URL in .env to point at the Laravel server (see .env.example).
// In production this is built into backend/public/dashboard and served by Laravel
// itself, so an unset VITE_API_URL correctly falls back to same-origin requests.
const API_BASE = import.meta.env.VITE_API_URL || '';
const TOKEN_KEY = 'admin_dashboard_token';
const LOCALE_KEY = 'admin_dashboard_locale';

export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearToken() {
  localStorage.removeItem(TOKEN_KEY);
}

export async function apiRequest(path, { method = 'GET', body, auth = true, locale } = {}) {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'Accept-Language': locale || localStorage.getItem(LOCALE_KEY) || 'en',
  };

  if (auth) {
    const token = getToken();
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
  }

  const response = await fetch(`${API_BASE}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  const payload = await response.json().catch(() => null);

  if (!response.ok) {
    const message =
      payload?.message ||
      payload?.errors?.email?.[0] ||
      'Request failed';
    const error = new Error(message);
    error.status = response.status;
    error.payload = payload;
    throw error;
  }

  return payload?.data;
}

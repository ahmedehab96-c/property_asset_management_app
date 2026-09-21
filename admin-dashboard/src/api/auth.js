import { apiRequest } from './client';

export function login(email, password) {
  return apiRequest('/api/v1/auth/login', {
    method: 'POST',
    body: { email, password },
    auth: false,
  });
}

export function fetchCurrentUser() {
  return apiRequest('/api/v1/auth/user');
}

export function logout() {
  return apiRequest('/api/v1/auth/logout', { method: 'POST' });
}

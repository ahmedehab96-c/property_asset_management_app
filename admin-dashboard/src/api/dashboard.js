import { apiRequest } from './client';

export function fetchMetrics() {
  return apiRequest('/api/v1/dashboard/metrics');
}

export function fetchRevenue() {
  return apiRequest('/api/v1/analytics/revenue');
}

export function fetchOccupancy() {
  return apiRequest('/api/v1/analytics/occupancy');
}

export function fetchOperations() {
  return apiRequest('/api/v1/analytics/operations');
}

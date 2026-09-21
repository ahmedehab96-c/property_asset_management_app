import {
  BuildingOffice2Icon,
  UsersIcon,
  DocumentTextIcon,
  UserGroupIcon,
  BanknotesIcon,
  ChartBarIcon,
  ClockIcon,
} from '@heroicons/react/24/outline';

export function buildDashboardStats(metrics, t, locale) {
  const w = t.widgets;
  const numberLocale = locale === 'ar' ? 'ar-EG' : 'en-US';

  return [
    {
      key: 'properties',
      label: w.properties,
      value: metrics.properties_count,
      description: w.total_managed_units,
      icon: BuildingOffice2Icon,
      color: 'primary',
    },
    {
      key: 'tenants',
      label: w.tenants,
      value: metrics.tenants_count,
      description: w.active_portfolio,
      icon: UsersIcon,
      color: 'success',
    },
    {
      key: 'contracts',
      label: w.contracts,
      value: metrics.contracts_count,
      description: w.all_agreements,
      icon: DocumentTextIcon,
      color: 'info',
    },
    {
      key: 'owners',
      label: w.owners,
      value: metrics.owners_count,
      description: w.partners,
      icon: UserGroupIcon,
      color: 'warning',
    },
    {
      key: 'monthly_revenue',
      label: w.monthly_revenue,
      value: `${Number(metrics.monthly_revenue).toLocaleString(numberLocale)} AED`,
      description: w.portfolio_income,
      icon: BanknotesIcon,
      color: 'success',
    },
    {
      key: 'occupancy',
      label: w.occupancy,
      value: `${metrics.occupancy_rate}%`,
      description: w.occupied_units,
      icon: ChartBarIcon,
      color: 'primary',
    },
    {
      key: 'pending_payments',
      label: w.pending_payments,
      value: metrics.pending_payments,
      description: w.awaiting_collection,
      icon: ClockIcon,
      color: 'danger',
    },
  ];
}

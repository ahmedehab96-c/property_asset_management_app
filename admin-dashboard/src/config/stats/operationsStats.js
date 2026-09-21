import {
  WrenchScrewdriverIcon,
  RectangleGroupIcon,
  CheckCircleIcon,
  CalendarDaysIcon,
  DevicePhoneMobileIcon,
} from '@heroicons/react/24/outline';

export function buildOperationsStats(stats, t) {
  const w = t.widgets;

  return [
    {
      key: 'open_maintenance',
      label: w.open_maintenance,
      value: stats.open_maintenance,
      description: w.in_progress,
      icon: WrenchScrewdriverIcon,
      color: 'warning',
    },
    {
      key: 'active_projects',
      label: w.active_projects,
      value: stats.active_projects,
      description: w.under_construction,
      icon: RectangleGroupIcon,
      color: 'primary',
    },
    {
      key: 'pending_tasks',
      label: w.pending_tasks,
      value: stats.pending_tasks,
      description: w.needs_attention,
      icon: CheckCircleIcon,
      color: 'danger',
    },
    {
      key: 'upcoming_events',
      label: w.upcoming_events,
      value: stats.upcoming_events,
      description: w.from_today,
      icon: CalendarDaysIcon,
      color: 'info',
    },
    {
      key: 'pending_mobile_requests',
      label: w.mobile_requests,
      value: stats.pending_mobile_requests,
      description: w.awaiting_review,
      icon: DevicePhoneMobileIcon,
      color: 'success',
    },
  ];
}

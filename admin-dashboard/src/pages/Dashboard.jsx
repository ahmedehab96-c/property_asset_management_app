import { fetchMetrics, fetchOccupancy, fetchRevenue } from '../api/dashboard';
import { useAsyncAll } from '../hooks/useAsyncAll';
import { useLocale } from '../context/LocaleContext';
import { buildDashboardStats } from '../config/stats/dashboardStats';
import StatsPage from '../components/dashboard/StatsPage';
import RevenueChart from '../components/dashboard/RevenueChart';
import OccupancyChart from '../components/dashboard/OccupancyChart';

export default function Dashboard() {
  const { t, locale } = useLocale();
  const { data, error } = useAsyncAll([fetchMetrics, fetchRevenue, fetchOccupancy]);
  const [metrics, revenue, occupancy] = data ?? [];

  return (
    <StatsPage
      heading={t.dashboard}
      loading={!data && !error}
      error={error}
      cards={metrics ? buildDashboardStats(metrics, t, locale) : []}
    >
      <div className="charts-grid">
        <RevenueChart months={revenue?.months ?? []} />
        <OccupancyChart byStatus={occupancy?.by_status ?? {}} />
      </div>
    </StatsPage>
  );
}

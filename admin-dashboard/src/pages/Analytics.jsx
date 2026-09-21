import { fetchOccupancy, fetchOperations, fetchRevenue } from '../api/dashboard';
import { useAsyncAll } from '../hooks/useAsyncAll';
import { useLocale } from '../context/LocaleContext';
import { buildOperationsStats } from '../config/stats/operationsStats';
import StatsPage from '../components/dashboard/StatsPage';
import RevenueChart from '../components/dashboard/RevenueChart';
import OccupancyChart from '../components/dashboard/OccupancyChart';

export default function Analytics() {
  const { t } = useLocale();
  const { data, error } = useAsyncAll([fetchOperations, fetchRevenue, fetchOccupancy]);
  const [operations, revenue, occupancy] = data ?? [];

  return (
    <StatsPage
      heading={t.nav.analytics}
      loading={!data && !error}
      error={error}
      cards={operations ? buildOperationsStats(operations, t) : []}
    >
      <div className="charts-grid">
        <RevenueChart months={revenue?.months ?? []} />
        <OccupancyChart byStatus={occupancy?.by_status ?? {}} />
      </div>
    </StatsPage>
  );
}

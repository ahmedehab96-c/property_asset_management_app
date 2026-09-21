import { useLocale } from '../../context/LocaleContext';
import DashboardLayout from '../layout/DashboardLayout';
import StatsGrid from './StatsGrid';

export default function StatsPage({ heading, loading, error, cards, children }) {
  const { t } = useLocale();

  return (
    <DashboardLayout heading={heading}>
      {error && <div className="form-error">{error}</div>}
      {!error && loading && <div className="state-message">{t.loading}</div>}
      {!error && !loading && (
        <>
          <StatsGrid cards={cards} />
          {children}
        </>
      )}
    </DashboardLayout>
  );
}

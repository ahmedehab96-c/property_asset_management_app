import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';
import { Doughnut } from 'react-chartjs-2';
import { useLocale } from '../../context/LocaleContext';
import { occupancyStatusColors, occupancyStatusLabels } from '../../i18n/translations';

ChartJS.register(ArcElement, Tooltip, Legend);

export default function OccupancyChart({ byStatus }) {
  const { t, locale } = useLocale();
  const statuses = Object.keys(byStatus);
  const labels = statuses.map((s) => occupancyStatusLabels[locale][s] ?? s);
  const values = statuses.map((s) => byStatus[s]);
  const colors = statuses.map((s) => occupancyStatusColors[s] ?? '#4A6FA5');

  const data = {
    labels: labels.length ? labels : ['—'],
    datasets: [
      {
        data: values.length ? values : [1],
        backgroundColor: colors.length ? colors : ['#64748B'],
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'bottom', labels: { boxWidth: 12, font: { family: 'Cairo' } } },
    },
  };

  return (
    <div className="panel chart-panel">
      <h3 className="chart-panel-heading">{t.widgets.occupancy_by_status}</h3>
      <div className="chart-canvas-wrap">
        <Doughnut data={data} options={options} />
      </div>
    </div>
  );
}

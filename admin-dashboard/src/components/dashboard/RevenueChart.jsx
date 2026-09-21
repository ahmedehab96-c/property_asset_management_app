import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  Filler,
} from 'chart.js';
import { Line } from 'react-chartjs-2';
import { useLocale } from '../../context/LocaleContext';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Tooltip, Filler);

export default function RevenueChart({ months }) {
  const { t } = useLocale();

  const data = {
    labels: months.map((m) => m.label),
    datasets: [
      {
        label: 'AED',
        data: months.map((m) => m.amount),
        borderColor: '#2563EB',
        backgroundColor: 'rgba(37, 99, 235, 0.2)',
        tension: 0.35,
        fill: true,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { display: false } },
      y: { grid: { color: 'rgba(15, 23, 42, 0.06)' } },
    },
  };

  return (
    <div className="panel chart-panel">
      <h3 className="chart-panel-heading">{t.widgets.revenue_last_6_months}</h3>
      <div className="chart-canvas-wrap">
        <Line data={data} options={options} />
      </div>
    </div>
  );
}

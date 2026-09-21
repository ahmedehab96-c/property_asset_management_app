import StatCard from './StatCard';

export default function StatsGrid({ cards }) {
  return (
    <div className="stats-grid">
      {cards.map(({ key, ...card }) => (
        <StatCard key={key} {...card} />
      ))}
    </div>
  );
}

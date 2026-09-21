const COLOR_MAP = {
  primary: 'var(--color-primary)',
  success: 'var(--color-success)',
  warning: 'var(--color-warning)',
  danger: 'var(--color-danger)',
  info: 'var(--color-info)',
};

export default function StatCard({ label, value, description, icon: Icon, color = 'primary' }) {
  const accent = COLOR_MAP[color] ?? COLOR_MAP.primary;

  return (
    <div className="panel stat-card">
      <div className="stat-card-top">
        <span className="stat-card-label">{label}</span>
        <span
          className="stat-card-icon"
          style={{ background: `${accent}1a`, color: accent }}
        >
          <Icon />
        </span>
      </div>
      <div className="stat-card-value">{value}</div>
      {description && (
        <div className="stat-card-desc" style={{ color: accent }}>
          <Icon />
          <span>{description}</span>
        </div>
      )}
    </div>
  );
}

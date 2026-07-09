interface DashboardMetricCardProps {
  title: string;
  value: number;
  description: string;
}

export function DashboardMetricCard({
  title,
  value,
  description,
}: DashboardMetricCardProps) {
  return (
    <article className="metric-card">
      <span>{title}</span>
      <strong>{value}</strong>
      <p>{description}</p>
    </article>
  );
}
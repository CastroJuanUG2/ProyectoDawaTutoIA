interface BadgeProps {
  children: string;
  variant?: "success" | "danger" | "warning" | "info" | "neutral";
}

export function Badge({ children, variant = "neutral" }: BadgeProps) {
  return <span className={`app-badge app-badge-${variant}`}>{children}</span>;
}
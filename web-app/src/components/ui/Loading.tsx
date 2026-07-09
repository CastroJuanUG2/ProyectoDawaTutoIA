interface LoadingProps {
  text?: string;
}

export function Loading({ text = "Cargando..." }: LoadingProps) {
  return (
    <div className="loading-screen">
      <div className="loading-card">
        <div className="loading-spinner" />
        <p>{text}</p>
      </div>
    </div>
  );
}
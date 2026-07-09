interface AcademicPageHeaderProps {
  title: string;
  description: string;
}

export function AcademicPageHeader({
  title,
  description,
}: AcademicPageHeaderProps) {
  return (
    <div className="academic-page-header">
      <div>
        <span className="section-label">Administración académica</span>
        <h2>{title}</h2>
        <p>{description}</p>
      </div>
    </div>
  );
}
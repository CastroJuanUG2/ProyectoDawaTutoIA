import { InputHTMLAttributes } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export function Input({
  label,
  error,
  className = "",
  ...props
}: InputProps) {
  return (
    <div className="input-group">
      <label className="input-label">{label}</label>
      <input className={`app-input ${className}`} {...props} />
      {error && <small className="input-error">{error}</small>}
    </div>
  );
}
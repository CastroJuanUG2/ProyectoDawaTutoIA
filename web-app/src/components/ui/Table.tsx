import { ReactNode } from "react";

interface TableColumn<T> {
  header: string;
  accessor: keyof T | ((row: T) => ReactNode);
}

interface TableProps<T> {
  columns: TableColumn<T>[];
  data: T[];
  emptyMessage?: string;
}

export function Table<T>({
  columns,
  data,
  emptyMessage = "No existen registros disponibles.",
}: TableProps<T>) {
  return (
    <div className="table-wrapper">
      <table className="app-table">
        <thead>
          <tr>
            {columns.map((column, index) => (
              <th key={index}>{column.header}</th>
            ))}
          </tr>
        </thead>

        <tbody>
          {data.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="table-empty">
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((row, rowIndex) => (
              <tr key={rowIndex}>
                {columns.map((column, columnIndex) => {
                  const value =
                    typeof column.accessor === "function"
                      ? column.accessor(row)
                      : row[column.accessor];

                  return <td key={columnIndex}>{value as ReactNode}</td>;
                })}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
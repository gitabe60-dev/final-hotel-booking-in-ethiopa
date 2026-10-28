// components/shared/DataTable.tsx
import { motion } from 'framer-motion'
import EmptyState from './EmptyState'

interface Column {
  key: string
  label: string
  render?: (row: any) => React.ReactNode
}

interface Props {
  columns: Column[]
  data: any[]
  emptyTitle?: string
  emptySubtitle?: string
}

export default function DataTable({ columns, data, emptyTitle = 'No data', emptySubtitle }: Props) {
  if (!data || data.length === 0) {
    return <EmptyState title={emptyTitle} subtitle={emptySubtitle} icon="📋" />
  }

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50 border-b border-gray-100">
              {columns.map((col) => (
                <th key={col.key} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                  {col.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.map((row, i) => (
              <motion.tr
                key={i}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: i * 0.03 }}
                className="border-b border-gray-50 hover:bg-gray-50 transition-colors"
              >
                {columns.map((col) => (
                  <td key={col.key} className="px-4 py-3 text-sm text-gray-700">
                    {col.render ? col.render(row) : row[col.key]}
                  </td>
                ))}
              </motion.tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

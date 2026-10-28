// components/shared/StatCard.tsx
import { motion } from 'framer-motion'

interface Props {
  label: string
  value: string | number
  icon: string
  color?: string
  delay?: number
}

export default function StatCard({ label, value, icon, color = 'bg-blue-500', delay = 0 }: Props) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      className="bg-white rounded-xl p-5 shadow-sm border border-gray-100 hover:shadow-md transition-shadow"
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-gray-500 font-medium">{label}</p>
          <p className="text-2xl font-bold text-gray-800 mt-1">{value}</p>
        </div>
        <div className={`w-12 h-12 rounded-xl ${color} bg-opacity-10 flex items-center justify-center text-2xl`}>
          {icon}
        </div>
      </div>
    </motion.div>
  )
}

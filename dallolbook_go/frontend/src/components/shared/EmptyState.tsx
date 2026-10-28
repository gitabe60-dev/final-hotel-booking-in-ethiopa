// components/shared/EmptyState.tsx
import { motion } from 'framer-motion'

interface Props {
  title: string
  subtitle?: string
  icon?: string
}

export default function EmptyState({ title, subtitle, icon = '📭' }: Props) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className="flex flex-col items-center justify-center py-16 text-center"
    >
      <div className="text-5xl mb-3">{icon}</div>
      <p className="text-gray-600 font-medium">{title}</p>
      {subtitle && <p className="text-gray-400 text-sm mt-1">{subtitle}</p>}
    </motion.div>
  )
}

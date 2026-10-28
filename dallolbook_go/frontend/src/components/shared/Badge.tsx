// components/shared/Badge.tsx
interface Props {
  status: string
}

const COLORS: Record<string, string> = {
  pending:    'bg-amber-100 text-amber-700',
  confirmed:  'bg-blue-100 text-blue-700',
  completed:  'bg-emerald-100 text-emerald-700',
  cancelled:  'bg-red-100 text-red-700',
  failed:     'bg-red-100 text-red-700',
  submitted:  'bg-purple-100 text-purple-700',
  active:     'bg-emerald-100 text-emerald-700',
  inactive:   'bg-gray-100 text-gray-500',
  available:  'bg-emerald-100 text-emerald-700',
}

export default function Badge({ status }: Props) {
  const color = COLORS[status] || 'bg-gray-100 text-gray-600'
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${color}`}>
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>
  )
}

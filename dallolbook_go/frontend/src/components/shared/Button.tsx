import { ReactNode } from 'react'

interface Props {
  children: ReactNode; onClick?: () => void; type?: 'button' | 'submit'
  variant?: 'primary' | 'secondary' | 'danger' | 'outline'
  disabled?: boolean; loading?: boolean; className?: string; fullWidth?: boolean
}

export default function Button({
  children, onClick, type = 'button', variant = 'primary',
  disabled, loading, className = '', fullWidth
}: Props) {
  const base = 'inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 font-medium text-sm transition-colors focus:outline-none disabled:opacity-60'
  const variants = {
    primary:   'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-amber-500 text-white hover:bg-amber-600',
    danger:    'bg-red-600 text-white hover:bg-red-700',
    outline:   'border border-gray-300 text-gray-700 hover:bg-gray-50',
  }
  return (
    <button type={type} onClick={onClick} disabled={disabled || loading}
      className={`${base} ${variants[variant]} ${fullWidth ? 'w-full' : ''} ${className}`}>
      {loading && <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />}
      {children}
    </button>
  )
}

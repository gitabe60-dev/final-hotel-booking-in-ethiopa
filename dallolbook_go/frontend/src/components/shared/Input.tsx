interface Props {
  label?: string; type?: string; name?: string
  value?: string; onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void
  placeholder?: string; required?: boolean; error?: string; disabled?: boolean
}

export default function Input({ label, type = 'text', name, value, onChange, placeholder, required, error, disabled }: Props) {
  return (
    <div className="flex flex-col gap-1">
      {label && <label className="text-sm font-medium text-gray-700">{label}{required && <span className="text-red-500 ml-1">*</span>}</label>}
      <input
        type={type} name={name} value={value} onChange={onChange}
        placeholder={placeholder} required={required} disabled={disabled}
        className={`w-full rounded-lg border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500
          ${error ? 'border-red-400' : 'border-gray-300'}
          ${disabled ? 'bg-gray-100' : 'bg-white'}`}
      />
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  )
}

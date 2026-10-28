export default function Spinner({ size = 'md' }: { size?: 'sm' | 'md' | 'lg' }) {
  const sz = { sm: 'h-5 w-5', md: 'h-8 w-8', lg: 'h-12 w-12' }[size]
  return (
    <div className="flex items-center justify-center py-10">
      <div className={`${sz} animate-spin rounded-full border-4 border-blue-200 border-t-blue-600`} />
    </div>
  )
}

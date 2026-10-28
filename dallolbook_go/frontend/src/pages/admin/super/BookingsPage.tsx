// pages/admin/super/BookingsPage.tsx
import { useEffect, useState } from 'react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function BookingsPage() {
  const [bookings, setBookings] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState('')

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.superBookings(statusFilter)
      setBookings(res.data.data || [])
    } catch { toast.error('Failed to load bookings') }
    setLoading(false)
  }

  useEffect(() => { load() }, [statusFilter])

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="super_admin">
      <PageHeader title="All Bookings" subtitle="View all hotel bookings across the platform" />

      <div className="flex gap-2 mb-6">
        {['', 'pending', 'confirmed', 'completed', 'cancelled'].map(s => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              statusFilter === s ? 'bg-blue-600 text-white' : 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
            }`}>
            {s === '' ? 'All' : s.charAt(0).toUpperCase() + s.slice(1)}
          </button>
        ))}
      </div>

      <DataTable
        columns={[
          { key: 'id', label: 'ID', render: (r) => <span className="font-mono text-xs">#{r.id}</span> },
          { key: 'guest_name', label: 'Guest' },
          { key: 'hotel_name', label: 'Hotel' },
          { key: 'city', label: 'City' },
          { key: 'check_in', label: 'Check In' },
          { key: 'check_out', label: 'Check Out' },
          { key: 'total_price', label: 'Total', render: (r) => <span className="font-semibold">ETB {r.total_price}</span> },
          { key: 'payment_method', label: 'Payment' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
        ]}
        data={bookings}
        emptyTitle="No bookings found"
        emptySubtitle="Bookings will appear here when users book hotels"
      />
    </AdminLayout>
  )
}

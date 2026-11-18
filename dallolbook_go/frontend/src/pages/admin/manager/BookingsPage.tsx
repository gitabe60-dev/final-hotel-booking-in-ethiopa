// pages/admin/manager/BookingsPage.tsx
import { useEffect, useState } from 'react'
import { CheckCircle, XCircle, Clock } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function ManagerBookingsPage() {
  const [bookings, setBookings] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState('')

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.managerBookings(statusFilter)
      setBookings(res.data.data || [])
    } catch { toast.error('Failed to load bookings') }
    setLoading(false)
  }

  useEffect(() => { load() }, [statusFilter])

  const handleStatus = async (id: number, status: string) => {
    try {
      await adminService.updateBookingStatus(id, status)
      toast.success(`Booking ${status}`)
      load()
    } catch { toast.error('Failed to update status') }
  }

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="hotel_manager">
      <PageHeader title="Bookings" subtitle="Manage bookings for your hotel" />

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
          { key: 'check_in', label: 'Check In' },
          { key: 'check_out', label: 'Check Out' },
          { key: 'rooms', label: 'Rooms' },
          { key: 'total_price', label: 'Total', render: (r) => <span className="font-semibold">ETB {r.total_price}</span> },
          { key: 'payment_method', label: 'Payment' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'actions', label: 'Actions', render: (r) => (
            <div className="flex items-center gap-1">
              {r.status === 'pending' && (
                <>
                  <button onClick={() => handleStatus(r.id, 'confirmed')} className="p-1.5 rounded-lg hover:bg-emerald-50 text-emerald-600" title="Confirm">
                    <CheckCircle size={16} />
                  </button>
                  <button onClick={() => handleStatus(r.id, 'cancelled')} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500" title="Cancel">
                    <XCircle size={16} />
                  </button>
                </>
              )}
              {r.status === 'confirmed' && (
                <button onClick={() => handleStatus(r.id, 'completed')} className="p-1.5 rounded-lg hover:bg-blue-50 text-blue-600" title="Mark Complete">
                  <Clock size={16} />
                </button>
              )}
            </div>
          ) },
        ]}
        data={bookings}
        emptyTitle="No bookings yet"
      />
    </AdminLayout>
  )
}

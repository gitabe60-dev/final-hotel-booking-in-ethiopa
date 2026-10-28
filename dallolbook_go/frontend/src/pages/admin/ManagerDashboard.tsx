// pages/admin/ManagerDashboard.tsx — hotel manager dashboard
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Bed, Calendar, CreditCard, CheckCircle, XCircle, ArrowRight, ExternalLink, Bell } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatCard from '../../components/shared/StatCard'
import Badge from '../../components/shared/Badge'
import Spinner from '../../components/shared/Spinner'
import EmptyState from '../../components/shared/EmptyState'
import Modal from '../../components/shared/Modal'
import { adminService } from '../../services/admin'
import { notificationService } from '../../services/notifications'
import toast from 'react-hot-toast'

export default function ManagerDashboard() {
  const navigate = useNavigate()
  const [data, setData] = useState<any>(null)
  const [payments, setPayments] = useState<any[]>([])
  const [notifications, setNotifications] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [viewScreenshot, setViewScreenshot] = useState<string | null>(null)

  const load = async () => {
    setLoading(true)
    try {
      const [dashRes, payRes, notifRes] = await Promise.all([
        adminService.managerDashboard(),
        adminService.managerPayments(),
        notificationService.listAdmin(),
      ])
      setData(dashRes.data.data)
      setPayments(payRes.data.data || [])
      setNotifications(notifRes.data.data?.notifications || [])
    } catch { toast.error('Failed to load dashboard') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleVerify = async (id: number, status: 'approved' | 'rejected') => {
    if (!confirm(`${status === 'approved' ? 'Approve' : 'Reject'} this payment?`)) return
    try {
      await adminService.verifyPayment(id, status)
      toast.success(`Payment ${status}`)
      load()
    } catch { toast.error('Failed to verify payment') }
  }

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  const rooms = data?.rooms || []
  const bookings = data?.recent_bookings || []
  const pendingPayments = payments.filter((p: any) => p.status === 'submitted')

  return (
    <AdminLayout role="hotel_manager">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-800">Hotel Manager Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Manage your hotel rooms, bookings and verify payments</p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <StatCard label="Total Rooms" value={rooms.length} icon="🛏️" color="bg-blue-500" delay={0} />
          <StatCard label="Available Rooms" value={rooms.filter((r: any) => r.is_available).length} icon="✅" color="bg-emerald-500" delay={0.1} />
          <StatCard label="Pending Payments" value={pendingPayments.length} icon="💳" color="bg-amber-500" delay={0.2} />
          <StatCard label="Unread Messages" value={data?.unread_messages || 0} icon="📨" color="bg-purple-500" delay={0.3} />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Pending Payments — most important for manager */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5 lg:col-span-2">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <CreditCard size={18} className="text-amber-600" />
                Payment Verification
                {pendingPayments.length > 0 && (
                  <span className="bg-amber-100 text-amber-700 text-xs px-2 py-0.5 rounded-full font-medium ml-1">
                    {pendingPayments.length} pending
                  </span>
                )}
              </h2>
              <button onClick={() => navigate('/admin/manager/payments')}
                className="flex items-center gap-1 text-amber-600 text-sm hover:text-amber-800 font-medium">
                View All <ArrowRight size={15} />
              </button>
            </div>
            {pendingPayments.length === 0 ? (
              <div className="text-center py-8 text-gray-400 text-sm">No payments pending verification</div>
            ) : (
              <div className="space-y-3">
                {pendingPayments.slice(0, 5).map((p: any) => (
                  <motion.div key={p.id} initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                    className="border border-amber-100 bg-amber-50 rounded-xl p-4">
                    <div className="flex items-start justify-between flex-wrap gap-3">
                      <div>
                        <p className="font-semibold text-gray-800">Payment #{p.id} — {p.guest_name}</p>
                        <p className="text-sm text-gray-500">{p.method} · {p.check_in} → {p.check_out}</p>
                        <p className="text-sm font-mono text-gray-600 mt-1">TXN: {p.transaction_id || 'N/A'}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-lg font-bold text-gray-800">ETB {p.amount}</p>
                        <Badge status={p.status} />
                      </div>
                    </div>
                    <div className="flex items-center gap-3 mt-3">
                      {p.screenshot_url && (
                        <button onClick={() => setViewScreenshot(p.screenshot_url)}
                          className="flex items-center gap-1 text-blue-600 text-sm hover:underline">
                          <ExternalLink size={14} /> View Screenshot
                        </button>
                      )}
                      <div className="flex gap-2 ml-auto">
                        <button onClick={() => handleVerify(p.id, 'approved')}
                          className="flex items-center gap-1.5 bg-emerald-600 text-white px-3 py-1.5 rounded-lg hover:bg-emerald-700 text-sm font-medium">
                          <CheckCircle size={15} /> Approve
                        </button>
                        <button onClick={() => handleVerify(p.id, 'rejected')}
                          className="flex items-center gap-1.5 bg-red-600 text-white px-3 py-1.5 rounded-lg hover:bg-red-700 text-sm font-medium">
                          <XCircle size={15} /> Reject
                        </button>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            )}
          </div>

          {/* Rooms */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <Bed size={18} className="text-blue-600" /> My Rooms
              </h2>
              <button onClick={() => navigate('/admin/manager/rooms')}
                className="flex items-center gap-1 text-blue-600 text-sm hover:text-blue-800 font-medium">
                Manage <ArrowRight size={15} />
              </button>
            </div>
            {rooms.length === 0 ? <EmptyState title="No rooms added" icon="🛏️" /> : (
              <div className="space-y-2">
                {rooms.slice(0, 5).map((r: any) => (
                  <div key={r.id} className="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50">
                    <div>
                      <p className="font-medium text-sm text-gray-800">{r.name}</p>
                      <p className="text-xs text-gray-500">{r.bed_type} · ETB {r.price_per_night}/night · {r.max_guests} guests</p>
                    </div>
                    <Badge status={r.is_available ? 'available' : 'inactive'} />
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Recent Bookings */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <Calendar size={18} className="text-emerald-600" /> Recent Bookings
              </h2>
              <button onClick={() => navigate('/admin/manager/bookings')}
                className="flex items-center gap-1 text-emerald-600 text-sm hover:text-emerald-800 font-medium">
                View All <ArrowRight size={15} />
              </button>
            </div>
            {bookings.length === 0 ? <EmptyState title="No bookings" icon="📅" /> : (
              <div className="space-y-2">
                {bookings.slice(0, 5).map((b: any) => (
                  <div key={b.id} className="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50">
                    <div>
                      <p className="font-medium text-sm text-gray-800">{b.guest_name}</p>
                      <p className="text-xs text-gray-500">{b.check_in} → {b.check_out}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-semibold text-blue-600">ETB {b.total_price?.toLocaleString()}</p>
                      <Badge status={b.status} />
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Recent Notifications */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5 lg:col-span-2">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <Bell size={18} className="text-purple-600" /> Recent Notifications
              </h2>
              <button onClick={() => { notificationService.readAllAdmin(); load() }}
                className="text-xs text-purple-600 hover:text-purple-800 font-medium">
                Mark all read
              </button>
            </div>
            {notifications.length === 0 ? (
              <div className="text-center py-6 text-gray-400 text-sm">
                <Bell size={28} className="mx-auto mb-2 opacity-30" />
                No notifications yet
              </div>
            ) : (
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {notifications.slice(0, 8).map((n: any) => (
                  <div key={n.id}
                    onClick={() => { if (!n.is_read) notificationService.readAdmin(n.id).then(load); if (n.type === 'booking_new') navigate('/admin/manager/payments') }}
                    className={`flex gap-3 p-2.5 rounded-lg cursor-pointer transition-colors ${!n.is_read ? 'bg-blue-50 hover:bg-blue-100' : 'hover:bg-gray-50'}`}>
                    <div className="mt-0.5">
                      {n.type === 'booking_new'
                        ? <Calendar size={15} className="text-blue-500" />
                        : <CreditCard size={15} className="text-emerald-500" />}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-800 text-sm">{n.title}</p>
                      <p className="text-xs text-gray-500 line-clamp-1">{n.message}</p>
                    </div>
                    {!n.is_read && <span className="w-2 h-2 rounded-full bg-blue-500 mt-2 flex-shrink-0" />}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </motion.div>

      {/* Screenshot Viewer */}
      <Modal open={!!viewScreenshot} onClose={() => setViewScreenshot(null)} title="Payment Screenshot" size="lg">
        {viewScreenshot && <img src={viewScreenshot} alt="Payment proof" className="max-w-full max-h-96 mx-auto rounded-lg" />}
      </Modal>
    </AdminLayout>
  )
}

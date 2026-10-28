// pages/dashboard/BookingsList.tsx
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Calendar, Users, Bed, MapPin, XCircle, CreditCard, ArrowRight } from 'lucide-react'
import toast from 'react-hot-toast'
import { useBookings } from '../../hooks/useBooking'
import { bookingService } from '../../services/booking'
import { paymentService } from '../../services/payment'
import Navbar from '../../components/shared/Navbar'
import Spinner from '../../components/shared/Spinner'
import Badge from '../../components/shared/Badge'
import EmptyState from '../../components/shared/EmptyState'

export default function BookingsList() {
  const navigate = useNavigate()
  const { bookings, loading, reload } = useBookings()
  const [filter, setFilter] = useState('all')
  const [cancelling, setCancelling] = useState<number | null>(null)
  const [paymentStatuses, setPaymentStatuses] = useState<Record<number, string>>({})

  // Fetch payment status for each booking
  useEffect(() => {
    if (bookings.length > 0) {
      bookings.forEach((b: any) => {
        paymentService.getStatus(b.id).then(res => {
          setPaymentStatuses(prev => ({ ...prev, [b.id]: res.data.data?.status || 'pending' }))
        }).catch(() => {})
      })
    }
  }, [bookings])

  const cancel = async (id: number) => {
    if (!confirm('Cancel this booking?')) return
    setCancelling(id)
    try {
      await bookingService.cancel(id)
      toast.success('Booking cancelled')
      reload()
    } catch { toast.error('Failed to cancel') }
    finally { setCancelling(null) }
  }

  const filtered = filter === 'all' ? bookings : bookings.filter((b: any) => b.status === filter)

  return (
    <>
      <Navbar />
      <div className="max-w-4xl mx-auto px-4 py-10">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">My Bookings</h1>

        {/* Stats */}
        <div className="grid grid-cols-4 gap-3 mb-6">
          {[
            { key: 'all', label: 'All', count: bookings.length },
            { key: 'pending', label: 'Pending', count: bookings.filter((b: any) => b.status === 'pending').length },
            { key: 'confirmed', label: 'Confirmed', count: bookings.filter((b: any) => b.status === 'confirmed').length },
            { key: 'completed', label: 'Completed', count: bookings.filter((b: any) => b.status === 'completed').length },
          ].map(s => (
            <button key={s.key} onClick={() => setFilter(s.key)}
              className={`p-4 rounded-xl text-center transition-all ${filter === s.key ? 'bg-blue-600 text-white shadow-sm' : 'bg-white border border-gray-100 hover:bg-gray-50'}`}>
              <p className={`text-2xl font-bold ${filter === s.key ? 'text-white' : 'text-gray-800'}`}>{s.count}</p>
              <p className={`text-xs ${filter === s.key ? 'text-blue-100' : 'text-gray-500'}`}>{s.label}</p>
            </button>
          ))}
        </div>

        {loading ? <Spinner /> : filtered.length === 0 ? (
          <EmptyState title="No bookings found" subtitle="Browse hotels and make your first booking!" icon="📅" />
        ) : (
          <div className="space-y-4">
            <AnimatePresence>
              {filtered.map((b: any) => (
                <motion.div
                  key={b.id}
                  layout
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="bg-white border border-gray-100 rounded-xl p-5 hover:shadow-sm transition-shadow">
                  <div className="flex gap-4">
                    <img src={b.hotel_image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200'} alt=""
                      className="w-20 h-20 rounded-lg object-cover flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between flex-wrap gap-2">
                        <div>
                          <h3 className="font-semibold text-gray-900 text-lg">{b.hotel_name}</h3>
                          <p className="text-gray-500 text-sm flex items-center gap-1"><MapPin size={14} /> {b.hotel_city}</p>
                        </div>
                        <div className="flex gap-2">
                          <Badge status={b.status} />
                          {paymentStatuses[b.id] && <Badge status={paymentStatuses[b.id]} />}
                        </div>
                      </div>

                      <div className="flex items-center gap-4 mt-3 text-sm text-gray-600 flex-wrap">
                        <span className="flex items-center gap-1"><Calendar size={14} /> {b.check_in} → {b.check_out}</span>
                        <span className="flex items-center gap-1"><Bed size={14} /> {b.rooms} room(s)</span>
                        <span className="flex items-center gap-1"><Users size={14} /> {b.adults} adults</span>
                      </div>

                      <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-50">
                        <div className="flex items-center gap-3">
                          <span className="font-bold text-blue-600 text-lg">ETB {b.total_price?.toLocaleString()}</span>
                          <span className="text-gray-400 text-xs uppercase">{b.payment_method?.replace('_', ' ')}</span>
                        </div>
                        <div className="flex gap-2">
                          {(b.status === 'pending' || b.status === 'confirmed') && (
                            <button onClick={() => cancel(b.id)} disabled={cancelling === b.id}
                              className="flex items-center gap-1 text-red-500 hover:text-red-700 text-sm font-medium px-3 py-1.5 rounded-lg hover:bg-red-50 transition-colors">
                              <XCircle size={16} /> Cancel
                            </button>
                          )}
                          {b.status === 'pending' && (
                            <button onClick={() => navigate(`/payment/${b.id}`)}
                              className="flex items-center gap-1 bg-blue-600 text-white px-3 py-1.5 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
                              <CreditCard size={16} /> Pay Now <ArrowRight size={14} />
                            </button>
                          )}
                          {b.status === 'confirmed' && (
                            <button onClick={() => navigate(`/payment/${b.id}`)}
                              className="flex items-center gap-1 border border-gray-200 text-gray-600 px-3 py-1.5 rounded-lg hover:bg-gray-50 transition-colors text-sm font-medium">
                              View Details
                            </button>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
        )}
      </div>
    </>
  )
}

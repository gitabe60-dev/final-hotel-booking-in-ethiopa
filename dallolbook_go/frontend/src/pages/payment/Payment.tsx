// pages/payment/Payment.tsx
import { useState, useEffect } from 'react'
import { useParams, useNavigate, Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Clock, CheckCircle, XCircle, CreditCard, ArrowRight } from 'lucide-react'
import toast from 'react-hot-toast'
import { useBooking } from '../../hooks/useBooking'
import { paymentService } from '../../services/payment'
import Navbar from '../../components/shared/Navbar'
import Spinner from '../../components/shared/Spinner'
import Badge from '../../components/shared/Badge'

export default function Payment() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { booking, loading } = useBooking(Number(id))
  const [payment, setPayment] = useState<any>(null)

  useEffect(() => {
    if (booking) {
      paymentService.getStatus(Number(id)).then(res => {
        setPayment(res.data.data)
      }).catch(() => {})
    }
  }, [booking, id])

  if (loading) return <><Navbar /><Spinner size="lg" /></>
  if (!booking) return <><Navbar /><div className="text-center py-20">Booking not found</div></>

  return (
    <>
      <Navbar />
      <div className="max-w-lg mx-auto px-4 py-10">
        <h1 className="text-2xl font-bold mb-6">Booking & Payment</h1>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-xl shadow-sm p-6 space-y-4">
          {/* Booking info */}
          <div className="border-b pb-4">
            <div className="flex gap-3">
              <img src={booking.hotel_image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200'} alt="" className="w-16 h-16 rounded-lg object-cover" />
              <div>
                <h2 className="font-semibold text-gray-800">{booking.hotel_name}</h2>
                <p className="text-gray-500 text-sm">{booking.hotel_city}</p>
                <p className="text-sm mt-1">{booking.check_in} → {booking.check_out}</p>
                <p className="text-sm">{booking.rooms} room(s) · {booking.adults} adults</p>
              </div>
            </div>
          </div>

          {/* Status */}
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Payment Method</span>
              <span className="font-medium capitalize">{booking.payment_method?.replace('_', ' ')}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Booking Status</span>
              <Badge status={booking.status} />
            </div>
            {payment && (
              <div className="flex justify-between items-center">
                <span className="text-gray-600">Payment Status</span>
                <Badge status={payment.status} />
              </div>
            )}
            <div className="flex justify-between text-lg font-bold pt-2 border-t">
              <span>Total Amount</span>
              <span className="text-blue-600">ETB {booking.total_price?.toLocaleString()}</span>
            </div>
          </div>

          {/* Status message */}
          {payment?.status === 'submitted' && (
            <div className="bg-purple-50 rounded-lg p-4 flex items-start gap-3">
              <Clock size={20} className="text-purple-600 mt-0.5" />
              <div>
                <p className="font-medium text-purple-800 text-sm">Payment Submitted</p>
                <p className="text-xs text-purple-600 mt-1">Your payment is being verified by the hotel manager. You'll be notified once approved.</p>
              </div>
            </div>
          )}
          {payment?.status === 'completed' && (
            <div className="bg-emerald-50 rounded-lg p-4 flex items-start gap-3">
              <CheckCircle size={20} className="text-emerald-600 mt-0.5" />
              <div>
                <p className="font-medium text-emerald-800 text-sm">Payment Confirmed!</p>
                <p className="text-xs text-emerald-600 mt-1">Your booking is confirmed. Enjoy your stay!</p>
              </div>
            </div>
          )}
          {payment?.status === 'failed' && (
            <div className="bg-red-50 rounded-lg p-4 flex items-start gap-3">
              <XCircle size={20} className="text-red-600 mt-0.5" />
              <div>
                <p className="font-medium text-red-800 text-sm">Payment Rejected</p>
                <p className="text-xs text-red-600 mt-1">Your payment was rejected. Please contact the hotel or try again.</p>
              </div>
            </div>
          )}
          {payment?.status === 'pending' && (
            <div className="bg-amber-50 rounded-lg p-4 flex items-start gap-3">
              <CreditCard size={20} className="text-amber-600 mt-0.5" />
              <div>
                <p className="font-medium text-amber-800 text-sm">Payment Pending</p>
                <p className="text-xs text-amber-600 mt-1">Please complete your payment to confirm your booking.</p>
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="flex gap-3">
            <Link to="/dashboard/bookings" className="flex-1 text-center border border-gray-300 px-4 py-2.5 rounded-lg font-medium hover:bg-gray-50 transition-colors text-sm">
              View Bookings
            </Link>
            {payment?.status === 'pending' && (
              <button onClick={() => navigate(`/booking/${booking.hotel_id}`)}
                className="flex-1 flex items-center justify-center gap-2 bg-blue-600 text-white px-4 py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium text-sm">
                Complete Payment <ArrowRight size={16} />
              </button>
            )}
          </div>
        </motion.div>
      </div>
    </>
  )
}

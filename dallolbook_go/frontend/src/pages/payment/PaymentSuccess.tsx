// pages/payment/PaymentSuccess.tsx
import { useParams } from 'react-router-dom'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { CheckCircle, Clock, Bell } from 'lucide-react'
import Navbar from '../../components/shared/Navbar'

export default function PaymentSuccess() {
  const { id } = useParams() // booking id

  return (
    <>
      <Navbar />
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-emerald-50 to-blue-50 px-4 py-12">
        <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }}
          className="text-center bg-white rounded-3xl shadow-xl p-10 max-w-md w-full">

          {/* Animated checkmark */}
          <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
            className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle className="w-11 h-11 text-emerald-600" />
          </motion.div>

          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 }}>
            <h1 className="text-2xl font-extrabold text-gray-900 mb-2">Booking Submitted!</h1>
            <p className="text-gray-500 text-sm">Your booking and payment proof have been submitted successfully.</p>
          </motion.div>

          {/* Status steps */}
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}
            className="mt-6 space-y-3 text-left">
            <div className="flex items-center gap-3 bg-emerald-50 rounded-xl p-3">
              <CheckCircle size={18} className="text-emerald-600 flex-shrink-0" />
              <div>
                <p className="text-sm font-semibold text-emerald-800">Booking Created</p>
                <p className="text-xs text-emerald-600">Your room has been reserved</p>
              </div>
            </div>
            <div className="flex items-center gap-3 bg-amber-50 rounded-xl p-3">
              <Clock size={18} className="text-amber-600 flex-shrink-0" />
              <div>
                <p className="text-sm font-semibold text-amber-800">Payment Under Verification</p>
                <p className="text-xs text-amber-600">Hotel manager is reviewing your payment proof</p>
              </div>
            </div>
            <div className="flex items-center gap-3 bg-blue-50 rounded-xl p-3">
              <Bell size={18} className="text-blue-600 flex-shrink-0" />
              <div>
                <p className="text-sm font-semibold text-blue-800">Notification Coming</p>
                <p className="text-xs text-blue-600">You'll be notified by email and in-app once approved</p>
              </div>
            </div>
          </motion.div>

          {/* Actions */}
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.65 }}
            className="flex gap-3 mt-8">
            <Link to="/dashboard/bookings"
              className="flex-1 bg-blue-600 text-white py-3 rounded-xl font-semibold text-sm hover:bg-blue-700 transition-colors text-center">
              My Bookings
            </Link>
            {id && (
              <Link to={`/payment/${id}`}
                className="flex-1 border-2 border-gray-200 text-gray-700 py-3 rounded-xl font-semibold text-sm hover:bg-gray-50 transition-colors text-center">
                View Status
              </Link>
            )}
          </motion.div>

          <Link to="/hotels"
            className="block mt-3 text-sm text-gray-400 hover:text-gray-600 transition-colors">
            Browse more hotels →
          </Link>
        </motion.div>
      </div>
    </>
  )
}

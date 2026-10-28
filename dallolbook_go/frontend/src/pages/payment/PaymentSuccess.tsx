// pages/payment/PaymentSuccess.tsx
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { CheckCircle, Clock } from 'lucide-react'
import Navbar from '../../components/shared/Navbar'

export default function PaymentSuccess() {
  return (
    <>
      <Navbar />
      <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center bg-white rounded-2xl shadow-lg p-12 max-w-md">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: 'spring' }}
            className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle className="w-10 h-10 text-emerald-600" />
          </motion.div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Booking Submitted!</h1>
          <p className="text-gray-500 mb-4">Your booking and payment have been submitted successfully.</p>

          <div className="bg-purple-50 rounded-lg p-4 mb-8 flex items-start gap-3 text-left">
            <Clock size={20} className="text-purple-600 mt-0.5 flex-shrink-0" />
            <div>
              <p className="font-medium text-purple-800 text-sm">Payment Pending Verification</p>
              <p className="text-xs text-purple-600 mt-1">The hotel manager will verify your payment shortly. You can check the status in your bookings.</p>
            </div>
          </div>

          <div className="flex gap-3 justify-center">
            <Link to="/dashboard/bookings" className="bg-blue-600 text-white px-6 py-2.5 rounded-lg font-medium hover:bg-blue-700 transition-colors text-sm">
              View My Bookings
            </Link>
            <Link to="/hotels" className="border border-gray-300 px-6 py-2.5 rounded-lg font-medium hover:bg-gray-50 transition-colors text-sm">
              Browse More Hotels
            </Link>
          </div>
        </motion.div>
      </div>
    </>
  )
}

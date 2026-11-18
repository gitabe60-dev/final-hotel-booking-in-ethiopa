// pages/dashboard/Dashboard.tsx
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Calendar, Heart, User, Bell, ChevronRight } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import { useBookings } from '../../hooks/useBooking'
import Navbar from '../../components/shared/Navbar'
import Spinner from '../../components/shared/Spinner'
import NotificationBell from '../../components/shared/NotificationBell'

const STATUS_STYLES: Record<string, string> = {
  pending:   'bg-amber-100 text-amber-700',
  confirmed: 'bg-emerald-100 text-emerald-700',
  completed: 'bg-blue-100 text-blue-700',
  cancelled: 'bg-red-100 text-red-700',
}

export default function Dashboard() {
  const { user } = useAuth()
  const { bookings, counts, loading, error } = useBookings()

  return (
    <>
      <Navbar />
      <div className="max-w-5xl mx-auto px-4 py-10">

        {/* Welcome header */}
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
          className="flex items-center justify-between mb-8 flex-wrap gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              Welcome back, {user?.first_name || 'Guest'}! 👋
            </h1>
            <p className="text-gray-500 text-sm mt-1">Manage your bookings, wishlist, and profile.</p>
          </div>
          <NotificationBell />
        </motion.div>

        {/* Stats grid */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          {[
            { label: 'Pending',   value: counts?.pending   || 0, color: 'bg-amber-50 text-amber-700',  emoji: '⏳' },
            { label: 'Confirmed', value: counts?.confirmed || 0, color: 'bg-emerald-50 text-emerald-700', emoji: '✅' },
            { label: 'Completed', value: counts?.completed || 0, color: 'bg-blue-50 text-blue-700',   emoji: '🏁' },
            { label: 'Cancelled', value: counts?.cancelled || 0, color: 'bg-red-50 text-red-700',    emoji: '❌' },
          ].map((s, i) => (
            <motion.div key={s.label}
              initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: i * 0.08 }}
              className={`${s.color} rounded-2xl p-5 text-center shadow-sm border border-white/50`}>
              <div className="text-3xl mb-1">{s.emoji}</div>
              <div className="text-2xl font-bold">{s.value}</div>
              <div className="text-xs font-medium mt-0.5 opacity-80">{s.label}</div>
            </motion.div>
          ))}
        </motion.div>

        {/* Quick actions */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
          className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-10">
          {[
            { to: '/dashboard/bookings', label: 'My Bookings',  desc: 'View and manage your reservations', icon: '📋', color: 'hover:border-blue-300' },
            { to: '/dashboard/wishlist', label: 'Wishlist',     desc: 'Your saved hotels',                icon: '♥',  color: 'hover:border-red-300' },
            { to: '/dashboard/profile',  label: 'Edit Profile', desc: 'Update your personal info',       icon: '👤', color: 'hover:border-purple-300' },
          ].map(link => (
            <Link key={link.to} to={link.to}
              className={`bg-white border-2 border-gray-100 rounded-2xl p-6 hover:shadow-md transition-all ${link.color} group`}>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-3xl mb-2">{link.icon}</div>
                  <div className="font-semibold text-gray-800">{link.label}</div>
                  <div className="text-xs text-gray-400 mt-0.5">{link.desc}</div>
                </div>
                <ChevronRight size={20} className="text-gray-300 group-hover:text-blue-500 transition-colors" />
              </div>
            </Link>
          ))}
        </motion.div>

        {/* Recent Bookings */}
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-900">Recent Bookings</h2>
          <Link to="/dashboard/bookings" className="text-sm text-blue-600 font-medium hover:underline">
            View all →
          </Link>
        </div>

        {loading ? (
          <div className="flex justify-center py-10"><Spinner /></div>
        ) : error ? (
          <div className="bg-red-50 border border-red-100 rounded-2xl p-8 text-center">
            <p className="text-red-500 font-medium">{error}</p>
            <p className="text-gray-400 text-sm mt-1">Make sure the backend is running on port 8080.</p>
          </div>
        ) : bookings.length === 0 ? (
          <div className="bg-gray-50 border border-gray-100 rounded-2xl p-10 text-center">
            <Calendar size={40} className="mx-auto text-gray-300 mb-3" />
            <p className="text-gray-500 font-medium">No bookings yet</p>
            <p className="text-gray-400 text-sm mt-1">Browse hotels and make your first reservation!</p>
            <Link to="/hotels" className="inline-flex items-center gap-1.5 mt-4 bg-blue-600 text-white px-5 py-2.5 rounded-xl text-sm font-medium hover:bg-blue-700 transition-colors">
              Browse Hotels <ChevronRight size={16} />
            </Link>
          </div>
        ) : (
          <div className="space-y-3">
            {bookings.slice(0, 5).map((b: any) => (
              <motion.div key={b.id}
                initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                className="bg-white border border-gray-100 rounded-2xl p-4 flex items-center justify-between hover:shadow-sm transition-shadow">
                <div className="flex items-center gap-3">
                  <img src={b.hotel_image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100'} alt=""
                    className="w-14 h-14 rounded-xl object-cover flex-shrink-0" />
                  <div>
                    <p className="font-semibold text-gray-800">{b.hotel_name}</p>
                    <p className="text-xs text-gray-500">{b.check_in} → {b.check_out} · {b.rooms} room(s)</p>
                  </div>
                </div>
                <div className="text-right">
                  <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${STATUS_STYLES[b.status] || 'bg-gray-100 text-gray-600'}`}>
                    {b.status}
                  </span>
                  <p className="text-sm font-bold text-blue-600 mt-1">ETB {b.total_price?.toLocaleString()}</p>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </>
  )
}

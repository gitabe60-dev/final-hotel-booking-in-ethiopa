// pages/dashboard/Dashboard.tsx
import { Link } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import { useBookings } from '../../hooks/useBooking'
import Navbar from '../../components/shared/Navbar'
import Spinner from '../../components/shared/Spinner'

export default function Dashboard() {
  const { user } = useAuth()
  const { bookings, counts, loading } = useBookings()

  return (
    <>
      <Navbar />
      <div className="max-w-5xl mx-auto px-4 py-10">
        <h1 className="text-2xl font-bold mb-2">Welcome, {user?.first_name}!</h1>
        <p className="text-gray-500 mb-8">Manage your bookings, wishlist, and profile.</p>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
          {[
            { label: 'Pending',   value: counts.pending   || 0, color: 'bg-amber-50  text-amber-700'  },
            { label: 'Confirmed', value: counts.confirmed || 0, color: 'bg-green-50  text-green-700'  },
            { label: 'Completed', value: counts.completed || 0, color: 'bg-blue-50   text-blue-700'   },
            { label: 'Cancelled', value: counts.cancelled || 0, color: 'bg-red-50    text-red-700'    },
          ].map(s => (
            <div key={s.label} className={`${s.color} rounded-xl p-4 text-center`}>
              <div className="text-3xl font-bold">{s.value}</div>
              <div className="text-sm font-medium mt-1">{s.label}</div>
            </div>
          ))}
        </div>

        {/* Nav Links */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-10">
          {[
            { to: '/dashboard/bookings', label: 'My Bookings',  icon: '📋' },
            { to: '/dashboard/wishlist', label: 'Wishlist',     icon: '♥'  },
            { to: '/dashboard/profile',  label: 'Edit Profile', icon: '👤' },
          ].map(link => (
            <Link key={link.to} to={link.to}
              className="bg-white border rounded-xl p-6 text-center hover:shadow-md transition-shadow">
              <div className="text-3xl mb-2">{link.icon}</div>
              <div className="font-semibold text-gray-800">{link.label}</div>
            </Link>
          ))}
        </div>

        {/* Recent Bookings */}
        <h2 className="text-xl font-bold mb-4">Recent Bookings</h2>
        {loading ? <Spinner /> : (
          <div className="space-y-3">
            {bookings.slice(0, 5).map((b: any) => (
              <div key={b.id} className="bg-white border rounded-xl p-4 flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <img src={b.hotel_image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100'} alt=""
                    className="w-14 h-14 rounded-lg object-cover" />
                  <div>
                    <p className="font-semibold">{b.hotel_name}</p>
                    <p className="text-sm text-gray-500">{b.check_in} → {b.check_out}</p>
                  </div>
                </div>
                <div className="text-right">
                  <span className={`text-xs px-2 py-1 rounded-full font-medium
                    ${b.status === 'confirmed' ? 'bg-green-100 text-green-700' :
                      b.status === 'pending'   ? 'bg-amber-100 text-amber-700' :
                      b.status === 'cancelled' ? 'bg-red-100 text-red-700' :
                                                 'bg-blue-100 text-blue-700'}`}>
                    {b.status}
                  </span>
                  <p className="text-sm font-bold text-blue-600 mt-1">ETB {b.total_price?.toLocaleString()}</p>
                </div>
              </div>
            ))}
            {bookings.length === 0 && <p className="text-center text-gray-400 py-10">No bookings yet.</p>}
          </div>
        )}
      </div>
    </>
  )
}

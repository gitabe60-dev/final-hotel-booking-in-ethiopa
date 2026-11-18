// pages/admin/SubAdminDashboard.tsx
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Hotel, Users, Calendar, MapPin, ArrowRight } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatCard from '../../components/shared/StatCard'
import Badge from '../../components/shared/Badge'
import Spinner from '../../components/shared/Spinner'
import EmptyState from '../../components/shared/EmptyState'
import { adminService } from '../../services/admin'

export default function SubAdminDashboard() {
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    adminService.subDashboard().then(r => setData(r.data.data)).finally(() => setLoading(false))
  }, [])

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  const hotels   = data?.hotels         || []
  const bookings = data?.recent_bookings || []
  const managers = data?.managers        || []

  return (
    <AdminLayout role="sub_admin">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-800">Sub-Admin Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1 flex items-center gap-1">
            <MapPin size={15} className="text-blue-600" />
            Your assigned city: <span className="font-semibold text-blue-600 ml-1">{data?.city || 'Not assigned'}</span>
          </p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
          <StatCard label="Hotels" value={hotels.length} icon="🏨" color="bg-blue-500" delay={0} />
          <StatCard label="Hotel Managers" value={managers.length} icon="👨‍💼" color="bg-emerald-500" delay={0.1} />
          <StatCard label="Recent Bookings" value={bookings.length} icon="📅" color="bg-amber-500" delay={0.2} />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Hotels */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <Hotel size={18} className="text-blue-600" /> Hotels in {data?.city}
              </h2>
              <button onClick={() => navigate('/admin/subadmin/hotels')}
                className="flex items-center gap-1 text-blue-600 text-sm hover:text-blue-800 font-medium">
                Manage <ArrowRight size={15} />
              </button>
            </div>
            {hotels.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-gray-400 text-sm">No hotels yet.</p>
                <button onClick={() => navigate('/admin/subadmin/hotels')}
                  className="mt-3 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-700">
                  Add First Hotel
                </button>
              </div>
            ) : (
              <div className="space-y-3">
                {hotels.slice(0, 5).map((h: any) => (
                  <motion.div key={h.id} initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                    className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50">
                    <img src={h.image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=80'}
                      alt="" className="w-12 h-12 rounded-lg object-cover" />
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-800 truncate">{h.name}</p>
                      <p className="text-xs text-gray-500">{h.type} · ETB {h.price_per_night?.toLocaleString()}/night</p>
                    </div>
                    <Badge status={h.is_active ? 'active' : 'inactive'} />
                  </motion.div>
                ))}
              </div>
            )}
          </div>

          {/* Managers */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <Users size={18} className="text-emerald-600" /> Hotel Managers
              </h2>
              <button onClick={() => navigate('/admin/subadmin/managers')}
                className="flex items-center gap-1 text-emerald-600 text-sm hover:text-emerald-800 font-medium">
                Manage <ArrowRight size={15} />
              </button>
            </div>
            {managers.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-gray-400 text-sm">No managers assigned yet.</p>
                <button onClick={() => navigate('/admin/subadmin/managers')}
                  className="mt-3 bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-emerald-700">
                  Assign Manager
                </button>
              </div>
            ) : (
              <div className="space-y-3">
                {managers.slice(0, 5).map((m: any) => (
                  <div key={m.id} className="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50">
                    <div>
                      <p className="font-medium text-gray-800">{m.full_name}</p>
                      <p className="text-xs text-gray-500">{m.hotel_name}</p>
                    </div>
                    <Badge status={m.status} />
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Recent Bookings */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5 lg:col-span-2">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                <Calendar size={18} className="text-amber-600" /> Recent Bookings
              </h2>
              <button onClick={() => navigate('/admin/subadmin/bookings')}
                className="flex items-center gap-1 text-amber-600 text-sm hover:text-amber-800 font-medium">
                View All <ArrowRight size={15} />
              </button>
            </div>
            {bookings.length === 0 ? (
              <EmptyState title="No bookings yet" icon="📅" />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left py-2 px-2 text-gray-500 font-medium">Guest</th>
                      <th className="text-left py-2 px-2 text-gray-500 font-medium">Hotel</th>
                      <th className="text-left py-2 px-2 text-gray-500 font-medium">Dates</th>
                      <th className="text-left py-2 px-2 text-gray-500 font-medium">Amount</th>
                      <th className="text-left py-2 px-2 text-gray-500 font-medium">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {bookings.map((b: any) => (
                      <tr key={b.id} className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-2 px-2 font-medium">{b.guest_name}</td>
                        <td className="py-2 px-2 text-gray-600">{b.hotel_name}</td>
                        <td className="py-2 px-2 text-gray-500">{b.check_in} → {b.check_out}</td>
                        <td className="py-2 px-2 font-semibold text-blue-600">ETB {b.total_price?.toLocaleString()}</td>
                        <td className="py-2 px-2"><Badge status={b.status} /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </motion.div>
    </AdminLayout>
  )
}

// pages/admin/SuperDashboard.tsx — Super admin: only Cities & Sub-Admins
import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { Users, MapPin, Building2, TrendingUp } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import StatCard from '../../components/shared/StatCard'
import Spinner from '../../components/shared/Spinner'
import { adminService } from '../../services/admin'

export default function SuperDashboard() {
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    adminService.superDashboard().then(r => setData(r.data.data)).finally(() => setLoading(false))
  }, [])

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  const o = data?.overview || {}

  return (
    <AdminLayout role="super_admin">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-800">Super Admin Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Manage cities and sub-admins across the platform</p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <StatCard label="Sub-Admins" value={o.sub_admins || 0} icon="👥" color="bg-blue-500" delay={0} />
          <StatCard label="Cities" value={o.active_hotels || 0} icon="📍" color="bg-purple-500" delay={0.1} />
          <StatCard label="Hotel Managers" value={o.hotel_managers || 0} icon="👨‍💼" color="bg-emerald-500" delay={0.2} />
          <StatCard label="Total Revenue" value={`ETB ${Number(o.total_revenue || 0).toLocaleString()}`} icon="💰" color="bg-amber-500" delay={0.3} />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 }}
            className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <div className="flex items-center gap-2 mb-4">
              <MapPin size={20} className="text-purple-600" />
              <h2 className="font-semibold text-gray-800">Quick Actions</h2>
            </div>
            <div className="space-y-3">
              <a href="/admin/super/cities" className="flex items-center gap-3 p-3 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors group">
                <MapPin size={20} className="text-purple-600" />
                <div>
                  <p className="font-medium text-gray-800">Manage Cities</p>
                  <p className="text-xs text-gray-500">Add, edit or remove cities</p>
                </div>
              </a>
              <a href="/admin/super/sub-admins" className="flex items-center gap-3 p-3 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors group">
                <Users size={20} className="text-blue-600" />
                <div>
                  <p className="font-medium text-gray-800">Manage Sub-Admins</p>
                  <p className="text-xs text-gray-500">Create sub-admins and assign cities</p>
                </div>
              </a>
            </div>
          </motion.div>

          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.3 }}
            className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp size={20} className="text-emerald-600" />
              <h2 className="font-semibold text-gray-800">Platform Overview</h2>
            </div>
            <div className="space-y-2 text-sm">
              {[
                { label: 'Active Hotels', value: o.active_hotels || 0 },
                { label: 'Total Guests', value: o.total_guests || 0 },
                { label: 'Confirmed Bookings', value: o.confirmed_bookings || 0 },
                { label: 'Pending Bookings', value: o.pending_bookings || 0 },
              ].map(s => (
                <div key={s.label} className="flex justify-between items-center py-2 border-b border-gray-50">
                  <span className="text-gray-500">{s.label}</span>
                  <span className="font-semibold text-gray-800">{s.value}</span>
                </div>
              ))}
            </div>
          </motion.div>
        </div>
      </motion.div>
    </AdminLayout>
  )
}

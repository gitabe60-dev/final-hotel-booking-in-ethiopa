// components/admin/AdminLayout.tsx
import { ReactNode, useState } from 'react'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import { Menu, X, LogOut } from 'lucide-react'
import AdminNotificationBell from './AdminNotificationBell'

interface Props { children: ReactNode; role: string }

const NAV: Record<string, { label: string; to: string; icon: string }[]> = {
  super_admin: [
    { label: 'Dashboard',  to: '/admin/super/dashboard',  icon: '📊' },
    { label: 'Sub-Admins', to: '/admin/super/sub-admins', icon: '👥' },
    { label: 'Cities',     to: '/admin/super/cities',     icon: '📍' },
    { label: 'Settings',   to: '/admin/super/settings',   icon: '⚙️' },
  ],
  sub_admin: [
    { label: 'Dashboard', to: '/admin/subadmin/dashboard', icon: '📊' },
    { label: 'Hotels',    to: '/admin/subadmin/hotels',    icon: '🏨' },
    { label: 'Bookings',  to: '/admin/subadmin/bookings',  icon: '📅' },
    { label: 'Managers',  to: '/admin/subadmin/managers',  icon: '👨‍💼' },
    { label: 'Settings',  to: '/admin/subadmin/settings',  icon: '⚙️' },
  ],
  broker: [
    { label: 'Dashboard', to: '/admin/broker/dashboard', icon: '📊' },
    { label: 'Bookings',  to: '/admin/broker/bookings',  icon: '📅' },
    { label: 'Inbox',     to: '/admin/broker/inbox',     icon: '📨' },
  ],
  hotel_manager: [
    { label: 'Dashboard', to: '/admin/manager/dashboard', icon: '📊' },
    { label: 'Rooms',     to: '/admin/manager/rooms',     icon: '🛏️' },
    { label: 'Bookings',  to: '/admin/manager/bookings',  icon: '📅' },
    { label: 'Payments',  to: '/admin/manager/payments',  icon: '💳' },
    { label: 'Settings',  to: '/admin/manager/settings',  icon: '⚙️' },
  ],
}

export default function AdminLayout({ children, role }: Props) {
  const { adminUser, logoutAdmin } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [sidebarOpen, setSidebarOpen] = useState(false)

  const logout = () => { logoutAdmin(); navigate('/login') }

  const navItems = NAV[role] || []

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Mobile overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 bg-black/50 z-30 md:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed md:fixed z-40 md:z-auto inset-y-0 left-0 w-56 bg-gray-900 text-white flex flex-col transition-transform duration-300
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
      `}>
        <div className="flex items-center justify-between p-4 border-b border-gray-700">
          <div>
            <div className="font-bold text-lg">DallolBook</div>
            <div className="text-xs text-gray-400 mt-0.5 capitalize">{role.replace('_', ' ')}</div>
          </div>
          <button onClick={() => setSidebarOpen(false)} className="md:hidden text-gray-400 hover:text-white">
            <X size={20} />
          </button>
        </div>

        <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
          {navItems.map(item => {
            const isActive = location.pathname === item.to
            return (
              <Link key={item.to} to={item.to}
                onClick={() => setSidebarOpen(false)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all ${
                  isActive
                    ? 'bg-blue-600 text-white shadow-sm'
                    : 'text-gray-300 hover:bg-gray-700 hover:text-white'
                }`}>
                <span className="text-base">{item.icon}</span>
                {item.label}
              </Link>
            )
          })}
        </nav>

        <div className="p-4 border-t border-gray-700">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-400 truncate flex-1">{adminUser?.full_name}</span>
            {role === 'hotel_manager' && <AdminNotificationBell />}
          </div>
          <button onClick={logout} className="flex items-center gap-2 w-full text-xs text-red-400 hover:text-red-300 text-left">
            <LogOut size={14} /> Logout
          </button>
        </div>
      </aside>

      {/* Mobile menu button */}
      <button
        onClick={() => setSidebarOpen(true)}
        className="fixed top-4 left-4 z-20 md:hidden bg-gray-900 text-white p-2 rounded-lg"
      >
        <Menu size={20} />
      </button>

      {/* Main */}
      <main className="flex-1 overflow-auto md:ml-56">
        <div className="p-4 md:p-6">{children}</div>
      </main>
    </div>
  )
}

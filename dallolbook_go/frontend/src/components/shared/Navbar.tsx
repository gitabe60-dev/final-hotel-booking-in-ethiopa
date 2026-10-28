// components/shared/Navbar.tsx
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Menu, X, Heart, LayoutDashboard, LogOut, ShieldCheck } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import NotificationBell from './NotificationBell'

export default function Navbar() {
  const { user, logout, isAuthenticated, isAdminAuthenticated, adminUser, logoutAdmin } = useAuth()
  const navigate = useNavigate()
  const [menuOpen, setMenuOpen] = useState(false)

  const handleLogout = () => { logout(); navigate('/login') }
  const handleAdminLogout = () => { logoutAdmin(); navigate('/admin/login') }

  const adminDashboardRoute: Record<string, string> = {
    super_admin:   '/admin/super/dashboard',
    sub_admin:     '/admin/subadmin/dashboard',
    hotel_manager: '/admin/manager/dashboard',
    broker:        '/admin/broker/dashboard',
  }

  return (
    <nav className="bg-white shadow-sm sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
        <Link to="/" className="text-2xl font-bold text-blue-600">DallolBook</Link>

        {/* Desktop */}
        <div className="hidden md:flex items-center gap-6">
          <Link to="/hotels" className="text-gray-600 hover:text-blue-600 font-medium transition-colors">Hotels</Link>

          {isAdminAuthenticated ? (
            <div className="flex items-center gap-3">
              <Link to={adminDashboardRoute[adminUser?.role || 'super_admin']}
                className="flex items-center gap-1.5 text-purple-600 hover:text-purple-800 font-medium">
                <ShieldCheck size={18} /> Admin Panel
              </Link>
              <div className="h-5 w-px bg-gray-200" />
              <span className="text-sm text-gray-600">{adminUser?.full_name}</span>
              <button onClick={handleAdminLogout}
                className="flex items-center gap-1.5 bg-red-50 text-red-600 px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-red-100 transition-colors">
                <LogOut size={15} /> Logout
              </button>
            </div>
          ) : isAuthenticated ? (
            <div className="flex items-center gap-4">
              <NotificationBell />
              <Link to="/dashboard" className="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-medium">
                <LayoutDashboard size={18} /> Dashboard
              </Link>
              <Link to="/dashboard/wishlist" className="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-medium">
                <Heart size={18} /> Wishlist
              </Link>
              <div className="h-5 w-px bg-gray-200" />
              <span className="text-sm text-gray-600 font-medium">Hi, {user?.first_name}</span>
              <button onClick={handleLogout}
                className="flex items-center gap-1.5 bg-red-50 text-red-600 px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-red-100 transition-colors">
                <LogOut size={15} /> Logout
              </button>
            </div>
          ) : (
            <div className="flex gap-3 items-center">
              <Link to="/login" className="text-gray-600 hover:text-blue-600 font-medium transition-colors">Login</Link>
              <Link to="/admin/login"
                className="flex items-center gap-1.5 text-purple-600 hover:text-purple-800 font-medium transition-colors">
                <ShieldCheck size={17} /> Admin
              </Link>
              <Link to="/register"
                className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
                Register
              </Link>
            </div>
          )}
        </div>

        {/* Mobile burger */}
        <button className="md:hidden text-gray-600" onClick={() => setMenuOpen(!menuOpen)}>
          {menuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile menu */}
      {menuOpen && (
        <div className="md:hidden bg-white border-t border-gray-100 px-4 py-4 space-y-3">
          <Link to="/hotels" className="block text-gray-700 hover:text-blue-600 font-medium py-1" onClick={() => setMenuOpen(false)}>Hotels</Link>
          {isAdminAuthenticated ? (
            <>
              <Link to={adminDashboardRoute[adminUser?.role || 'super_admin']} className="block text-purple-600 font-medium py-1" onClick={() => setMenuOpen(false)}>Admin Panel</Link>
              <button onClick={() => { handleAdminLogout(); setMenuOpen(false) }} className="block text-red-600 font-medium py-1">Logout Admin</button>
            </>
          ) : isAuthenticated ? (
            <>
              <Link to="/dashboard" className="block text-gray-700 font-medium py-1" onClick={() => setMenuOpen(false)}>Dashboard</Link>
              <Link to="/dashboard/wishlist" className="block text-gray-700 font-medium py-1" onClick={() => setMenuOpen(false)}>Wishlist</Link>
              <button onClick={() => { handleLogout(); setMenuOpen(false) }} className="block text-red-600 font-medium py-1">Logout</button>
            </>
          ) : (
            <>
              <Link to="/login" className="block text-gray-700 font-medium py-1" onClick={() => setMenuOpen(false)}>Login</Link>
              <Link to="/admin/login" className="block text-purple-600 font-medium py-1" onClick={() => setMenuOpen(false)}>Admin Login</Link>
              <Link to="/register" className="block text-blue-600 font-medium py-1" onClick={() => setMenuOpen(false)}>Register</Link>
            </>
          )}
        </div>
      )}
    </nav>
  )
}

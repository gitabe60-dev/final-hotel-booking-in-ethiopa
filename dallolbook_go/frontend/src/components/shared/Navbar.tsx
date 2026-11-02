// components/shared/Navbar.tsx
import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Menu, X, Heart, LayoutDashboard, LogOut, ShieldCheck } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { useAuth } from '../../context/AuthContext'
import NotificationBell from './NotificationBell'
import LanguageSwitcher from './LanguageSwitcher'

export default function Navbar() {
  const { t } = useTranslation()
  const { user, logout, isAuthenticated, isAdminAuthenticated, adminUser, logoutAdmin } = useAuth()
  const navigate = useNavigate()
  const [menuOpen, setMenuOpen] = useState(false)

  const handleLogout      = () => { logout();      navigate('/login') }
  const handleAdminLogout = () => { logoutAdmin(); navigate('/login') }

  const adminDashboardRoute: Record<string, string> = {
    super_admin:   '/admin/super/dashboard',
    sub_admin:     '/admin/subadmin/dashboard',
    hotel_manager: '/admin/manager/dashboard',
    broker:        '/admin/broker/dashboard',
  }

  return (
    <nav className="bg-white shadow-sm sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between gap-3">
        {/* Brand — logo image + text */}
        <Link to="/" className="flex items-center gap-2.5 flex-shrink-0 group">
          <div className="w-9 h-9 rounded-xl overflow-hidden shadow-sm border border-blue-100 flex-shrink-0 transition-transform group-hover:scale-105">
            <img
              src="https://hotelethiopia.com/wp-content/uploads/2025/10/WhatsApp-Image-2025-10-08-at-8.01.41-PM.png.webp"
              alt="Hotel Ethiopia"
              className="w-full h-full object-cover"
              onError={e => { (e.target as HTMLImageElement).style.display = 'none' }}
            />
          </div>
          <span className="text-xl font-extrabold text-blue-600 leading-tight">{t('nav.brand')}</span>
        </Link>

        {/* Desktop */}
        <div className="hidden md:flex items-center gap-4 flex-1 justify-end">
          <Link to="/hotels" className="text-gray-600 hover:text-blue-600 font-medium transition-colors">{t('nav.hotels')}</Link>

          {isAdminAuthenticated ? (
            <div className="flex items-center gap-3">
              <Link to={adminDashboardRoute[adminUser?.role || 'super_admin']}
                className="flex items-center gap-1.5 text-purple-600 hover:text-purple-800 font-medium">
                <ShieldCheck size={18} /> {t('nav.adminPanel')}
              </Link>
              <div className="h-5 w-px bg-gray-200" />
              <span className="text-sm text-gray-600">{adminUser?.full_name}</span>
              <button onClick={handleAdminLogout}
                className="flex items-center gap-1.5 bg-red-50 text-red-600 px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-red-100 transition-colors">
                <LogOut size={15} /> {t('nav.logout')}
              </button>
            </div>
          ) : isAuthenticated ? (
            <div className="flex items-center gap-4">
              <NotificationBell />
              <Link to="/dashboard" className="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-medium">
                <LayoutDashboard size={18} /> {t('nav.dashboard')}
              </Link>
              <Link to="/dashboard/wishlist" className="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-medium">
                <Heart size={18} /> {t('nav.wishlist')}
              </Link>
              <div className="h-5 w-px bg-gray-200" />
              <span className="text-sm text-gray-600 font-medium">Hi, {user?.first_name}</span>
              <button onClick={handleLogout}
                className="flex items-center gap-1.5 bg-red-50 text-red-600 px-3 py-1.5 rounded-lg text-sm font-medium hover:bg-red-100 transition-colors">
                <LogOut size={15} /> {t('nav.logout')}
              </button>
            </div>
          ) : (
            <div className="flex gap-3 items-center">
              <Link to="/login"    className="text-gray-600 hover:text-blue-600 font-medium transition-colors">{t('nav.login')}</Link>
              <Link to="/register" className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
                {t('nav.register')}
              </Link>
            </div>
          )}

          {/* Language switcher — always visible on desktop */}
          <LanguageSwitcher />
        </div>

        {/* Mobile right: language + burger */}
        <div className="md:hidden flex items-center gap-2">
          <LanguageSwitcher />
          <button className="text-gray-600 p-1" onClick={() => setMenuOpen(!menuOpen)}>
            {menuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {menuOpen && (
        <div className="md:hidden bg-white border-t border-gray-100 px-4 py-4 space-y-3">
          <Link to="/hotels" className="block text-gray-700 hover:text-blue-600 font-medium py-1" onClick={() => setMenuOpen(false)}>
            {t('nav.hotels')}
          </Link>
          {isAdminAuthenticated ? (
            <>
              <Link to={adminDashboardRoute[adminUser?.role || 'super_admin']} className="block text-purple-600 font-medium py-1" onClick={() => setMenuOpen(false)}>
                {t('nav.adminPanel')}
              </Link>
              <button onClick={() => { handleAdminLogout(); setMenuOpen(false) }} className="block text-red-600 font-medium py-1">
                {t('nav.logout')}
              </button>
            </>
          ) : isAuthenticated ? (
            <>
              <Link to="/dashboard"          className="block text-gray-700 font-medium py-1" onClick={() => setMenuOpen(false)}>{t('nav.dashboard')}</Link>
              <Link to="/dashboard/wishlist" className="block text-gray-700 font-medium py-1" onClick={() => setMenuOpen(false)}>{t('nav.wishlist')}</Link>
              <button onClick={() => { handleLogout(); setMenuOpen(false) }} className="block text-red-600 font-medium py-1">{t('nav.logout')}</button>
            </>
          ) : (
            <>
              <Link to="/login"    className="block text-gray-700 font-medium py-1" onClick={() => setMenuOpen(false)}>{t('nav.login')}</Link>
              <Link to="/register" className="block text-blue-600 font-medium py-1" onClick={() => setMenuOpen(false)}>{t('nav.register')}</Link>
            </>
          )}
        </div>
      )}
    </nav>
  )
}

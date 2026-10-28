// router/index.tsx — all application routes.
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

// Public pages
import Home           from '../pages/home/Home'
import HotelList      from '../pages/hotels/HotelList'
import HotelDetail    from '../pages/hotels/HotelDetail'

// Auth pages
import Login          from '../pages/auth/Login'
import Register       from '../pages/auth/Register'
import OTP            from '../pages/auth/OTP'
import ForgotPassword from '../pages/auth/ForgotPassword'

// Protected user pages
import Dashboard      from '../pages/dashboard/Dashboard'
import BookingsList   from '../pages/dashboard/BookingsList'
import Profile        from '../pages/dashboard/Profile'
import Wishlist       from '../pages/dashboard/Wishlist'
import BookingConfirm from '../pages/booking/BookingConfirm'
import Payment        from '../pages/payment/Payment'
import PaymentSuccess from '../pages/payment/PaymentSuccess'

// Admin pages
import AdminLogin       from '../pages/admin/AdminLogin'
import SuperDashboard   from '../pages/admin/SuperDashboard'
import SubAdminDashboard from '../pages/admin/SubAdminDashboard'
import BrokerDashboard  from '../pages/admin/BrokerDashboard'
import ManagerDashboard from '../pages/admin/ManagerDashboard'

// Super admin sub-pages
import SubAdminsPage from '../pages/admin/super/SubAdminsPage'
import CitiesPage    from '../pages/admin/super/CitiesPage'

// Sub admin sub-pages
import SubHotelsPage   from '../pages/admin/subadmin/HotelsPage'
import SubBookingsPage from '../pages/admin/subadmin/BookingsPage'
import BrokersPage     from '../pages/admin/subadmin/BrokersPage'
import ManagersPage    from '../pages/admin/subadmin/ManagersPage'

// Hotel manager sub-pages
import ManagerRoomsPage    from '../pages/admin/manager/RoomsPage'
import ManagerBookingsPage from '../pages/admin/manager/BookingsPage'
import ManagerPaymentsPage from '../pages/admin/manager/PaymentsPage'

// Shared settings page (accepts role prop)
import SettingsPage from '../pages/admin/SettingsPage'

// Route guards
function PrivateRoute({ children }: { children: JSX.Element }) {
  const { isAuthenticated } = useAuth()
  return isAuthenticated ? children : <Navigate to="/login" replace />
}

function AdminRoute({ children, role }: { children: JSX.Element; role: string }) {
  const { isAdminAuthenticated, adminUser } = useAuth()
  if (!isAdminAuthenticated) return <Navigate to="/admin/login" replace />
  if (adminUser?.role !== role) return <Navigate to="/admin/login" replace />
  return children
}

export default function AppRouter() {
  return (
    <Routes>
      {/* ── Public ─────────────────────────────────────── */}
      <Route path="/"         element={<Home />} />
      <Route path="/hotels"   element={<HotelList />} />
      <Route path="/hotels/:id" element={<HotelDetail />} />

      {/* ── Auth ───────────────────────────────────────── */}
      <Route path="/login"           element={<Login />} />
      <Route path="/register"        element={<Register />} />
      <Route path="/otp"             element={<OTP />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />

      {/* ── User Protected ─────────────────────────────── */}
      <Route path="/dashboard" element={<PrivateRoute><Dashboard /></PrivateRoute>} />
      <Route path="/dashboard/bookings" element={<PrivateRoute><BookingsList /></PrivateRoute>} />
      <Route path="/dashboard/profile"  element={<PrivateRoute><Profile /></PrivateRoute>} />
      <Route path="/dashboard/wishlist" element={<PrivateRoute><Wishlist /></PrivateRoute>} />
      <Route path="/booking/:id"        element={<PrivateRoute><BookingConfirm /></PrivateRoute>} />
      <Route path="/payment/:id"        element={<PrivateRoute><Payment /></PrivateRoute>} />
      <Route path="/payment/:id/success" element={<PrivateRoute><PaymentSuccess /></PrivateRoute>} />

      {/* ── Admin Auth ─────────────────────────────────── */}
      <Route path="/admin/login" element={<AdminLogin />} />

      {/* ── Super Admin ────────────────────────────────── */}
      <Route path="/admin/super/dashboard"    element={<AdminRoute role="super_admin"><SuperDashboard /></AdminRoute>} />
      <Route path="/admin/super/sub-admins"   element={<AdminRoute role="super_admin"><SubAdminsPage /></AdminRoute>} />
      <Route path="/admin/super/cities"       element={<AdminRoute role="super_admin"><CitiesPage /></AdminRoute>} />
      <Route path="/admin/super/settings"     element={<AdminRoute role="super_admin"><SettingsPage role="super_admin" /></AdminRoute>} />

      {/* ── Sub Admin ──────────────────────────────────── */}
      <Route path="/admin/subadmin/dashboard" element={<AdminRoute role="sub_admin"><SubAdminDashboard /></AdminRoute>} />
      <Route path="/admin/subadmin/hotels"   element={<AdminRoute role="sub_admin"><SubHotelsPage /></AdminRoute>} />
      <Route path="/admin/subadmin/bookings"  element={<AdminRoute role="sub_admin"><SubBookingsPage /></AdminRoute>} />
      <Route path="/admin/subadmin/brokers"   element={<AdminRoute role="sub_admin"><BrokersPage /></AdminRoute>} />
      <Route path="/admin/subadmin/managers"  element={<AdminRoute role="sub_admin"><ManagersPage /></AdminRoute>} />
      <Route path="/admin/subadmin/settings"  element={<AdminRoute role="sub_admin"><SettingsPage role="sub_admin" /></AdminRoute>} />

      {/* ── Broker ─────────────────────────────────────── */}
      <Route path="/admin/broker/dashboard" element={<AdminRoute role="broker"><BrokerDashboard /></AdminRoute>} />

      {/* ── Hotel Manager ──────────────────────────────── */}
      <Route path="/admin/manager/dashboard" element={<AdminRoute role="hotel_manager"><ManagerDashboard /></AdminRoute>} />
      <Route path="/admin/manager/rooms"    element={<AdminRoute role="hotel_manager"><ManagerRoomsPage /></AdminRoute>} />
      <Route path="/admin/manager/bookings"  element={<AdminRoute role="hotel_manager"><ManagerBookingsPage /></AdminRoute>} />
      <Route path="/admin/manager/payments" element={<AdminRoute role="hotel_manager"><ManagerPaymentsPage /></AdminRoute>} />
      <Route path="/admin/manager/settings"  element={<AdminRoute role="hotel_manager"><SettingsPage role="hotel_manager" /></AdminRoute>} />

      {/* ── Fallback ───────────────────────────────────── */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

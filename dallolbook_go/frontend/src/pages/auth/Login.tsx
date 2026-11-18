// pages/auth/Login.tsx — Unified login for users AND admins
// Detects role from response and redirects accordingly.
import { useState, FormEvent } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Mail, Lock, Eye, EyeOff, AlertCircle, ShieldCheck,
  User, Hotel, ChevronRight
} from 'lucide-react'
import toast from 'react-hot-toast'
import { useTranslation } from 'react-i18next'
import { authService } from '../../services/auth'
import { adminService } from '../../services/admin'
import { useAuth } from '../../context/AuthContext'
import { validateEmail, FieldError } from '../../utils/validate'

function Err({ msg }: { msg: FieldError }) {
  if (!msg) return null
  return <p className="flex items-center gap-1 text-red-500 text-xs mt-1.5"><AlertCircle size={11} /> {msg}</p>
}

const ADMIN_ROUTES: Record<string, string> = {
  super_admin:   '/admin/super/dashboard',
  sub_admin:     '/admin/subadmin/dashboard',
  broker:        '/admin/broker/dashboard',
  hotel_manager: '/admin/manager/dashboard',
}

export default function Login() {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const { setAuth, setAdminAuth } = useAuth()

  const redirectTo = searchParams.get('redirect') || '/dashboard'

  const [tab, setTab]       = useState<'guest' | 'admin'>('guest')
  const [form, setForm]     = useState({ email: '', password: '' })
  const [touched, setTouched] = useState({ email: false, password: false })
  const [showPw, setShowPw] = useState(false)
  const [loading, setLoading] = useState(false)

  const set  = (k: 'email' | 'password') => (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm(f => ({ ...f, [k]: e.target.value }))
    setTouched(t => ({ ...t, [k]: true }))
  }
  const blur = (k: 'email' | 'password') => () => setTouched(t => ({ ...t, [k]: true }))

  const errEmail = validateEmail(form.email)
  const errPass: FieldError = form.password.trim() === '' ? 'Password is required' : null

  const inputCls = (k: 'email' | 'password') => {
    const err = k === 'email' ? errEmail : errPass
    return `w-full border rounded-xl pl-10 pr-10 py-3 text-sm outline-none transition-all ${
      touched[k] && err   ? 'border-red-400 bg-red-50 focus:ring-2 focus:ring-red-200'
      : touched[k] && !err ? 'border-emerald-400 bg-emerald-50/30 focus:ring-2 focus:ring-emerald-200'
      : 'border-gray-200 focus:ring-2 focus:ring-blue-400 bg-white'
    }`
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setTouched({ email: true, password: true })
    if (errEmail || errPass) { toast.error('Please fix the errors below'); return }
    setLoading(true)

    try {
      if (tab === 'admin') {
        // Admin login
        const res = await adminService.login(form.email.trim(), form.password)
        const { admin, token } = res.data.data
        setAdminAuth(admin, token)
        toast.success(`Welcome, ${admin.full_name}! 👋`)
        navigate(ADMIN_ROUTES[admin.role] || '/admin/super/dashboard')
      } else {
        // User login
        const res = await authService.login(form.email.trim(), form.password)
        setAuth(res.data.data.user, res.data.data.token)
        toast.success(`Welcome back, ${res.data.data.user.first_name}! 👋`)
        navigate(redirectTo)
      }
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Invalid email or password')
    } finally { setLoading(false) }
  }

  // If a redirect is set, show what they came from
  const hasRedirect = redirectTo !== '/dashboard'

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900 px-4 py-10">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-indigo-500/10 rounded-full blur-3xl" />
      </div>

      <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md relative z-10">

        {/* Logo */}
        <div className="text-center mb-6">
          {/* Hotel Ethiopia logo with glow effect */}
          <div className="relative inline-block mb-3">
            <div className="absolute inset-0 bg-blue-500/30 rounded-2xl blur-xl scale-110" />
            <div className="relative w-20 h-20 bg-white rounded-2xl overflow-hidden shadow-2xl border-2 border-white/40 mx-auto">
              <img
                src="https://hotelethiopia.com/wp-content/uploads/2025/10/WhatsApp-Image-2025-10-08-at-8.01.41-PM.png.webp"
                alt="Hotel Ethiopia"
                className="w-full h-full object-cover"
                onError={e => {
                  const img = e.target as HTMLImageElement
                  img.style.display = 'none'
                  const parent = img.parentElement
                  if (parent) {
                    parent.innerHTML = '<div class="w-full h-full flex items-center justify-center"><span class="text-blue-600 text-4xl font-extrabold">H</span></div>'
                  }
                }}
              />
            </div>
          </div>
          <h1 className="text-2xl font-extrabold text-white">{t('login.title')}</h1>
          <p className="text-blue-200 text-sm mt-1">{t('login.subtitle')}</p>
        </div>

        {/* Redirect notice */}
        {hasRedirect && (
          <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}
            className="bg-amber-500/20 border border-amber-400/30 rounded-xl p-3 mb-4 flex items-start gap-2 text-amber-200 text-sm">
            <Hotel size={16} className="flex-shrink-0 mt-0.5" />
            <span>{t('login.redirectNote')}</span>
          </motion.div>
        )}

        {/* Card */}
        <div className="bg-white rounded-2xl shadow-2xl overflow-hidden">

          {/* Tabs */}
          <div className="flex border-b border-gray-100">
            {[
              { key: 'guest', label: t('login.tabGuest'), icon: User },
              { key: 'admin', label: t('login.tabAdmin'), icon: ShieldCheck },
            ].map(t => (
              <button key={t.key}
                onClick={() => { setTab(t.key as any); setTouched({ email: false, password: false }) }}
                className={`flex-1 flex items-center justify-center gap-2 py-4 text-sm font-semibold transition-all border-b-2 ${
                  tab === t.key
                    ? t.key === 'admin'
                      ? 'border-purple-600 text-purple-700 bg-purple-50'
                      : 'border-blue-600 text-blue-700 bg-blue-50'
                    : 'border-transparent text-gray-400 hover:text-gray-600 hover:bg-gray-50'
                }`}>
                <t.icon size={16} />
                {t.label}
              </button>
            ))}
          </div>

          {/* Form */}
          <div className="p-7">
            <AnimatePresence mode="wait">
              <motion.div key={tab}
                initial={{ opacity: 0, x: tab === 'admin' ? 20 : -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2 }}>

                <h2 className="text-xl font-bold text-gray-900 mb-1">
                  {tab === 'admin' ? t('login.adminTitle') : t('login.guestTitle')}
                </h2>
                <p className="text-gray-400 text-sm mb-6">
                  {tab === 'admin' ? t('login.adminSub') : t('login.guestSub')}
                </p>

                <form onSubmit={handleSubmit} className="space-y-4" noValidate>
                  {/* Email */}
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-1.5">
                      {t('login.email')} <span className="text-red-500">*</span>
                    </label>
                    <div className="relative">
                      <Mail size={16} className="absolute left-3 top-3.5 text-gray-400" />
                      <input type="email" value={form.email} onChange={set('email')} onBlur={blur('email')}
                        placeholder={tab === 'admin' ? 'admin@hotelbook.com' : 'you@email.com'}
                        className={inputCls('email')} />
                    </div>
                    <Err msg={touched.email ? errEmail : null} />
                  </div>

                  {/* Password */}
                  <div>
                    <div className="flex justify-between items-center mb-1.5">
                      <label className="text-sm font-semibold text-gray-700">
                        {t('login.password')} <span className="text-red-500">*</span>
                      </label>
                      {tab === 'guest' && (
                        <Link to="/forgot-password" className="text-xs text-blue-600 hover:underline">
                          {t('login.forgot')}
                        </Link>
                      )}
                    </div>
                    <div className="relative">
                      <Lock size={16} className="absolute left-3 top-3.5 text-gray-400" />
                      <input type={showPw ? 'text' : 'password'}
                        value={form.password} onChange={set('password')} onBlur={blur('password')}
                        placeholder="Your password"
                        className={inputCls('password')} />
                      <button type="button" onClick={() => setShowPw(!showPw)}
                        className="absolute right-3 top-3 text-gray-400 hover:text-gray-600">
                        {showPw ? <EyeOff size={17} /> : <Eye size={17} />}
                      </button>
                    </div>
                    <Err msg={touched.password ? errPass : null} />
                  </div>

                  <button type="submit" disabled={loading}
                    className={`w-full flex items-center justify-center gap-2 py-3.5 rounded-xl font-bold text-base transition-all shadow-md disabled:opacity-50 active:scale-[.98] ${
                      tab === 'admin'
                        ? 'bg-purple-600 hover:bg-purple-700 text-white'
                        : 'bg-blue-600 hover:bg-blue-700 text-white'
                    }`}>
                    {loading ? (
                      <><div className="w-5 h-5 border-2 border-white/40 border-t-white rounded-full animate-spin" /> {t('login.signingIn')}</>
                    ) : (
                      <>{t('login.signIn')} <ChevronRight size={18} /></>
                    )}
                  </button>
                </form>

                {/* Guest: register + OTP links */}
                {tab === 'guest' && (
                  <div className="mt-6 space-y-3">
                    <div className="relative flex items-center gap-3 text-gray-300">
                      <div className="flex-1 h-px bg-gray-200" />
                      <span className="text-xs text-gray-400 flex-shrink-0">{t('login.newTo')}</span>
                      <div className="flex-1 h-px bg-gray-200" />
                    </div>
                    <Link to={`/register${hasRedirect ? `?redirect=${encodeURIComponent(redirectTo)}` : ''}`}
                      className="w-full flex items-center justify-center gap-2 border-2 border-blue-200 text-blue-600 py-3 rounded-xl font-semibold hover:bg-blue-50 transition-colors">
                      {t('login.createFree')}
                    </Link>
                    <Link to="/otp"
                      className="w-full text-center block text-sm text-gray-400 hover:text-gray-600 py-1">
                      {t('login.otpLogin')}
                    </Link>
                  </div>
                )}
              </motion.div>
            </AnimatePresence>
          </div>
        </div>

        <p className="text-center text-blue-200/60 text-xs mt-4">
          {t('login.copyright')}
        </p>
      </motion.div>
    </div>
  )
}

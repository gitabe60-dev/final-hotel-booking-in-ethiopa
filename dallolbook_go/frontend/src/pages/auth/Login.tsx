// pages/auth/Login.tsx
import { useState, FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Mail, Lock, Eye, EyeOff, AlertCircle, ShieldCheck } from 'lucide-react'
import toast from 'react-hot-toast'
import { authService } from '../../services/auth'
import { useAuth } from '../../context/AuthContext'
import { validateEmail, validatePassword, FieldError, hasErrors } from '../../utils/validate'

function Err({ msg }: { msg: FieldError }) {
  if (!msg) return null
  return <p className="flex items-center gap-1 text-red-500 text-xs mt-1"><AlertCircle size={11} /> {msg}</p>
}

export default function Login() {
  const navigate  = useNavigate()
  const { setAuth } = useAuth()
  const [form, setForm]     = useState({ email: '', password: '' })
  const [touched, setTouched] = useState({ email: false, password: false })
  const [showPw, setShowPw] = useState(false)
  const [loading, setLoading] = useState(false)

  const set  = (k: 'email' | 'password') => (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm(f => ({ ...f, [k]: e.target.value }))
    setTouched(t => ({ ...t, [k]: true }))
  }
  const blur = (k: 'email' | 'password') => () => setTouched(t => ({ ...t, [k]: true }))

  const errors = {
    email:    validateEmail(form.email),
    password: validatePassword(form.password),
  }

  const fieldCls = (k: 'email' | 'password') =>
    `w-full border rounded-xl pl-10 pr-10 py-2.5 text-sm outline-none transition-all ${
      touched[k] && errors[k]  ? 'border-red-400 bg-red-50 focus:ring-2 focus:ring-red-200'
      : touched[k] && !errors[k] ? 'border-emerald-400 focus:ring-2 focus:ring-emerald-200'
      : 'border-gray-200 focus:ring-2 focus:ring-blue-400'
    }`

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setTouched({ email: true, password: true })
    if (hasErrors(errors)) { toast.error('Please fix the errors below'); return }
    setLoading(true)
    try {
      const res = await authService.login(form.email.trim(), form.password)
      setAuth(res.data.data.user, res.data.data.token)
      toast.success('Welcome back! 👋')
      navigate('/dashboard')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Login failed — check your credentials')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-50 px-4">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md bg-white rounded-2xl shadow-xl p-8">

        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-14 h-14 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-3 shadow-md">
            <span className="text-white text-2xl font-extrabold">D</span>
          </div>
          <h1 className="text-2xl font-extrabold text-gray-900">Welcome Back</h1>
          <p className="text-gray-500 text-sm mt-1">Sign in to your DallolBook account</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4" noValidate>
          {/* Email */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1.5">
              Email Address<span className="text-red-500 ml-0.5">*</span>
            </label>
            <div className="relative">
              <Mail size={16} className="absolute left-3 top-3 text-gray-400" />
              <input type="email" value={form.email} onChange={set('email')} onBlur={blur('email')}
                placeholder="you@example.com"
                className={fieldCls('email')} />
            </div>
            <Err msg={touched.email ? errors.email : null} />
          </div>

          {/* Password */}
          <div>
            <div className="flex justify-between items-center mb-1.5">
              <label className="block text-sm font-semibold text-gray-700">
                Password<span className="text-red-500 ml-0.5">*</span>
              </label>
              <Link to="/forgot-password" className="text-xs text-blue-600 hover:underline font-medium">
                Forgot password?
              </Link>
            </div>
            <div className="relative">
              <Lock size={16} className="absolute left-3 top-3 text-gray-400" />
              <input type={showPw ? 'text' : 'password'}
                value={form.password} onChange={set('password')} onBlur={blur('password')}
                placeholder="Your password"
                className={fieldCls('password')} />
              <button type="button" onClick={() => setShowPw(!showPw)}
                className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600">
                {showPw ? <EyeOff size={17} /> : <Eye size={17} />}
              </button>
            </div>
            <Err msg={touched.password ? errors.password : null} />
          </div>

          <button type="submit" disabled={loading}
            className="w-full flex items-center justify-center gap-2 bg-blue-600 text-white py-3.5 rounded-xl font-bold text-base hover:bg-blue-700 active:scale-[.98] transition-all shadow-md disabled:opacity-50 mt-2">
            {loading ? (
              <><div className="w-5 h-5 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Signing in…</>
            ) : 'Sign In →'}
          </button>
        </form>

        {/* Admin login hint */}
        <div className="mt-4 flex items-center gap-2 bg-purple-50 rounded-xl p-3 border border-purple-100">
          <ShieldCheck size={15} className="text-purple-600 flex-shrink-0" />
          <p className="text-xs text-purple-700">
            Admin?{' '}
            <Link to="/admin/login" className="font-semibold underline">Go to Admin Login</Link>
          </p>
        </div>

        <div className="mt-5 text-center space-y-2">
          <p className="text-sm text-gray-600">
            Don't have an account?{' '}
            <Link to="/register" className="text-blue-600 font-semibold hover:underline">Register free</Link>
          </p>
          <p className="text-sm text-gray-600">
            Prefer OTP login?{' '}
            <Link to="/otp" className="text-blue-600 font-medium hover:underline">Use OTP</Link>
          </p>
        </div>
      </motion.div>
    </div>
  )
}

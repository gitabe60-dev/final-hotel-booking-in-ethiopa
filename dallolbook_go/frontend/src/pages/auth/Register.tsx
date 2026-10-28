// pages/auth/Register.tsx
import { useState, FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { User, Mail, Phone, Lock, Globe, Eye, EyeOff, AlertCircle, CheckCircle } from 'lucide-react'
import toast from 'react-hot-toast'
import { authService } from '../../services/auth'
import { useAuth } from '../../context/AuthContext'
import {
  validateName, validateEmail, validatePhone,
  validatePassword, FieldError, hasErrors
} from '../../utils/validate'

function FieldWrap({ label, error, success, required, children }: {
  label: string; error: FieldError; success?: boolean; required?: boolean; children: React.ReactNode
}) {
  return (
    <div>
      <label className="block text-sm font-semibold text-gray-700 mb-1.5">
        {label}{required && <span className="text-red-500 ml-0.5">*</span>}
      </label>
      {children}
      {error && (
        <p className="flex items-center gap-1 text-red-500 text-xs mt-1">
          <AlertCircle size={11} /> {error}
        </p>
      )}
      {!error && success && (
        <p className="flex items-center gap-1 text-emerald-600 text-xs mt-1">
          <CheckCircle size={11} /> Looks good
        </p>
      )}
    </div>
  )
}

const cls = (err: FieldError, touched: boolean) =>
  `w-full border rounded-xl px-3 py-2.5 text-sm outline-none transition-all pl-10 ${
    touched && err ? 'border-red-400 bg-red-50 focus:ring-2 focus:ring-red-200'
    : touched && !err ? 'border-emerald-400 bg-emerald-50 focus:ring-2 focus:ring-emerald-200'
    : 'border-gray-200 focus:ring-2 focus:ring-blue-400'
  }`

export default function Register() {
  const navigate = useNavigate()
  const { setAuth } = useAuth()
  const [form, setForm] = useState({
    first_name: '', last_name: '', email: '', phone: '', password: '', nationality: ''
  })
  const [touched, setTouched] = useState<Record<string, boolean>>({})
  const [showPw, setShowPw]   = useState(false)
  const [loading, setLoading] = useState(false)

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm(f => ({ ...f, [k]: e.target.value }))
    setTouched(t => ({ ...t, [k]: true }))
  }
  const blur = (k: string) => () => setTouched(t => ({ ...t, [k]: true }))

  const errors = {
    first_name: validateName(form.first_name, 'First name'),
    last_name:  validateName(form.last_name, 'Last name'),
    email:      validateEmail(form.email, !form.phone),
    phone:      validatePhone(form.phone, !form.email),
    password:   validatePassword(form.password),
  }

  // Password strength
  const pwStrength = (() => {
    const v = form.password
    if (!v) return { score: 0, label: '' }
    let s = 0
    if (v.length >= 6) s++
    if (v.length >= 10) s++
    if (/[A-Z]/.test(v)) s++
    if (/[0-9]/.test(v)) s++
    if (/[^A-Za-z0-9]/.test(v)) s++
    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong', 'Very Strong']
    const colors = ['', 'bg-red-400', 'bg-orange-400', 'bg-yellow-400', 'bg-emerald-400', 'bg-emerald-600']
    return { score: s, label: labels[s], color: colors[s] }
  })()

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    const allTouched = Object.fromEntries(Object.keys(errors).map(k => [k, true]))
    setTouched(allTouched)
    if (!form.email && !form.phone) { toast.error('Provide email or phone number'); return }
    if (hasErrors(errors)) { toast.error('Please fix the errors below'); return }
    setLoading(true)
    try {
      const res = await authService.register({
        first_name: form.first_name.trim(),
        last_name:  form.last_name.trim(),
        email:      form.email.trim()   || undefined,
        phone:      form.phone.trim()   || undefined,
        password:   form.password,
        nationality: form.nationality.trim() || undefined,
      })
      setAuth(res.data.data.user, res.data.data.token)
      toast.success('Account created! Welcome 🎉')
      navigate('/dashboard')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Registration failed')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-50 px-4 py-8">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md bg-white rounded-2xl shadow-xl p-8">

        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-14 h-14 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-3 shadow-md">
            <span className="text-white text-2xl font-extrabold">D</span>
          </div>
          <h1 className="text-2xl font-extrabold text-gray-900">Create Account</h1>
          <p className="text-gray-500 text-sm mt-1">Join DallolBook and start booking</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4" noValidate>
          <div className="grid grid-cols-2 gap-3">
            <FieldWrap label="First Name" error={touched.first_name ? errors.first_name : null}
              success={touched.first_name && !errors.first_name} required>
              <div className="relative">
                <User size={16} className="absolute left-3 top-3 text-gray-400" />
                <input value={form.first_name} onChange={set('first_name')} onBlur={blur('first_name')}
                  placeholder="Abebe"
                  className={cls(touched.first_name ? errors.first_name : null, !!touched.first_name)} />
              </div>
            </FieldWrap>
            <FieldWrap label="Last Name" error={touched.last_name ? errors.last_name : null}
              success={touched.last_name && !errors.last_name} required>
              <div className="relative">
                <User size={16} className="absolute left-3 top-3 text-gray-400" />
                <input value={form.last_name} onChange={set('last_name')} onBlur={blur('last_name')}
                  placeholder="Kebede"
                  className={cls(touched.last_name ? errors.last_name : null, !!touched.last_name)} />
              </div>
            </FieldWrap>
          </div>

          <FieldWrap label="Email Address" error={touched.email ? errors.email : null}
            success={touched.email && !errors.email} required={!form.phone}>
            <div className="relative">
              <Mail size={16} className="absolute left-3 top-3 text-gray-400" />
              <input type="email" value={form.email} onChange={set('email')} onBlur={blur('email')}
                placeholder="you@email.com"
                className={cls(touched.email ? errors.email : null, !!touched.email)} />
            </div>
          </FieldWrap>

          <FieldWrap label="Phone Number" error={touched.phone ? errors.phone : null}
            success={touched.phone && !errors.phone} required={!form.email}>
            <div className="relative">
              <Phone size={16} className="absolute left-3 top-3 text-gray-400" />
              <input type="tel" value={form.phone} onChange={set('phone')} onBlur={blur('phone')}
                placeholder="0912345678"
                className={cls(touched.phone ? errors.phone : null, !!touched.phone)} />
            </div>
          </FieldWrap>

          <FieldWrap label="Password" error={touched.password ? errors.password : null}
            success={touched.password && !errors.password} required>
            <div className="relative">
              <Lock size={16} className="absolute left-3 top-3 text-gray-400" />
              <input type={showPw ? 'text' : 'password'}
                value={form.password} onChange={set('password')} onBlur={blur('password')}
                placeholder="Min 6 chars with letters & numbers"
                className={cls(touched.password ? errors.password : null, !!touched.password) + ' pr-10'} />
              <button type="button" onClick={() => setShowPw(!showPw)}
                className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600">
                {showPw ? <EyeOff size={17} /> : <Eye size={17} />}
              </button>
            </div>
            {/* Strength bar */}
            {form.password.length > 0 && (
              <div className="mt-1.5">
                <div className="flex gap-1 mb-1">
                  {[1,2,3,4,5].map(i => (
                    <div key={i} className={`h-1.5 flex-1 rounded-full transition-all ${i <= pwStrength.score ? pwStrength.color : 'bg-gray-200'}`} />
                  ))}
                </div>
                <p className="text-xs text-gray-500">{pwStrength.label}</p>
              </div>
            )}
          </FieldWrap>

          <FieldWrap label="Nationality" error={null}>
            <div className="relative">
              <Globe size={16} className="absolute left-3 top-3 text-gray-400" />
              <input value={form.nationality} onChange={set('nationality')}
                placeholder="Ethiopian (optional)"
                className="w-full border border-gray-200 rounded-xl px-3 py-2.5 pl-10 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
            </div>
          </FieldWrap>

          <button type="submit" disabled={loading}
            className="w-full flex items-center justify-center gap-2 bg-blue-600 text-white py-3.5 rounded-xl font-bold text-base hover:bg-blue-700 active:scale-[.98] transition-all shadow-md disabled:opacity-50 mt-2">
            {loading ? (
              <><div className="w-5 h-5 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Creating Account…</>
            ) : 'Create Account →'}
          </button>
        </form>

        <p className="mt-5 text-center text-sm text-gray-600">
          Already have an account?{' '}
          <Link to="/login" className="text-blue-600 font-semibold hover:underline">Sign in</Link>
        </p>
      </motion.div>
    </div>
  )
}

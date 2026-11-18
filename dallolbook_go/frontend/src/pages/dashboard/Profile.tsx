// pages/dashboard/Profile.tsx
import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { User, Lock, Save, Eye, EyeOff, AlertCircle } from 'lucide-react'
import toast from 'react-hot-toast'
import { guestService } from '../../services/guest'
import { useAuth } from '../../context/AuthContext'
import Navbar from '../../components/shared/Navbar'
import Footer from '../../components/shared/Footer'
import Spinner from '../../components/shared/Spinner'
import { validateName, validatePhone, validatePassword } from '../../utils/validate'

export default function Profile() {
  const { setAuth, token, user } = useAuth()
  const [profileLoading, setProfileLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [changingPw, setChangingPw] = useState(false)
  const [showPw, setShowPw] = useState(false)

  const [form, setForm] = useState({
    first_name: '', last_name: '', phone: '', nationality: ''
  })
  const [pwForm, setPwForm] = useState({
    current: '', new_pass: '', confirm: ''
  })
  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    guestService.getProfile()
      .then(r => {
        const d = r.data.data
        setForm({
          first_name:  d.first_name  || '',
          last_name:   d.last_name   || '',
          phone:       d.phone       || '',
          nationality: d.nationality || '',
        })
      })
      .catch(() => toast.error('Failed to load profile'))
      .finally(() => setProfileLoading(false))
  }, [])

  const validateProfile = () => {
    const e: Record<string, string> = {}
    const fn = validateName(form.first_name, 'First name')
    const ln = validateName(form.last_name, 'Last name')
    if (fn) e.first_name = fn
    if (ln) e.last_name  = ln
    if (form.phone && validatePhone(form.phone, false)) e.phone = validatePhone(form.phone, false) as string
    setErrors(e)
    return Object.keys(e).length === 0
  }

  const handleSaveProfile = async () => {
    if (!validateProfile()) { toast.error('Please fix the errors'); return }
    setSaving(true)
    try {
      const res = await guestService.updateProfile({
        first_name: form.first_name.trim(),
        last_name:  form.last_name.trim(),
        phone:      form.phone.trim() || undefined,
        nationality: form.nationality.trim() || undefined,
      })
      if (token) setAuth(res.data.data, token)
      toast.success('Profile updated!')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to update profile')
    } finally { setSaving(false) }
  }

  const handleChangePw = async () => {
    if (!pwForm.current) { toast.error('Enter your current password'); return }
    const err = validatePassword(pwForm.new_pass)
    if (err) { toast.error(err); return }
    if (pwForm.new_pass !== pwForm.confirm) { toast.error('Passwords do not match'); return }
    setChangingPw(true)
    try {
      await guestService.changePassword(pwForm.current, pwForm.new_pass)
      toast.success('Password changed!')
      setPwForm({ current: '', new_pass: '', confirm: '' })
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Current password is incorrect')
    } finally { setChangingPw(false) }
  }

  const inputCls = (field: string) =>
    `w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 outline-none transition-all ${
      errors[field] ? 'border-red-400 bg-red-50 focus:ring-red-200' : 'border-gray-200 focus:ring-blue-400'
    }`

  if (profileLoading) return (
    <>
      <Navbar />
      <div className="flex items-center justify-center min-h-screen"><Spinner size="lg" /></div>
    </>
  )

  return (
    <>
      <Navbar />
      <div className="max-w-2xl mx-auto px-4 py-10 space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Profile</h1>
          <p className="text-gray-500 text-sm mt-1">Manage your personal information and security</p>
        </div>

        {/* Personal Info */}
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 space-y-4">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
              <User size={20} className="text-blue-600" />
            </div>
            <div>
              <h2 className="font-semibold text-gray-800">Personal Information</h2>
              <p className="text-xs text-gray-400">Update your name, phone and nationality</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">First Name *</label>
              <input value={form.first_name} onChange={e => setForm(f => ({ ...f, first_name: e.target.value }))}
                className={inputCls('first_name')} placeholder="e.g. Abebe" />
              {errors.first_name && <p className="text-red-500 text-xs mt-1 flex items-center gap-1"><AlertCircle size={11} />{errors.first_name}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Last Name *</label>
              <input value={form.last_name} onChange={e => setForm(f => ({ ...f, last_name: e.target.value }))}
                className={inputCls('last_name')} placeholder="e.g. Kebede" />
              {errors.last_name && <p className="text-red-500 text-xs mt-1 flex items-center gap-1"><AlertCircle size={11} />{errors.last_name}</p>}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Phone Number</label>
            <input value={form.phone} onChange={e => setForm(f => ({ ...f, phone: e.target.value }))}
              className={inputCls('phone')} placeholder="0912345678" type="tel" />
            {errors.phone && <p className="text-red-500 text-xs mt-1 flex items-center gap-1"><AlertCircle size={11} />{errors.phone}</p>}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Nationality</label>
            <input value={form.nationality} onChange={e => setForm(f => ({ ...f, nationality: e.target.value }))}
              className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-blue-400 outline-none"
              placeholder="Ethiopian (optional)" />
          </div>

          <button onClick={handleSaveProfile} disabled={saving}
            className="flex items-center gap-2 bg-blue-600 text-white px-5 py-2.5 rounded-xl font-medium text-sm hover:bg-blue-700 transition-colors disabled:opacity-50">
            {saving ? <><div className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Saving…</> : <><Save size={16} /> Save Profile</>}
          </button>
        </motion.div>

        {/* Change Password */}
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 space-y-4">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center">
              <Lock size={20} className="text-amber-600" />
            </div>
            <div>
              <h2 className="font-semibold text-gray-800">Change Password</h2>
              <p className="text-xs text-gray-400">Keep your account secure with a strong password</p>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Current Password</label>
            <div className="relative">
              <input type={showPw ? 'text' : 'password'} value={pwForm.current}
                onChange={e => setPwForm(f => ({ ...f, current: e.target.value }))}
                className="w-full border border-gray-200 rounded-xl px-3 py-2.5 pr-10 text-sm focus:ring-2 focus:ring-amber-400 outline-none"
                placeholder="Your current password" />
              <button type="button" onClick={() => setShowPw(!showPw)} className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600">
                {showPw ? <EyeOff size={17} /> : <Eye size={17} />}
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">New Password</label>
            <input type="password" value={pwForm.new_pass}
              onChange={e => setPwForm(f => ({ ...f, new_pass: e.target.value }))}
              className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-amber-400 outline-none"
              placeholder="Min 6 chars, include a number" />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1.5">Confirm New Password</label>
            <input type="password" value={pwForm.confirm}
              onChange={e => setPwForm(f => ({ ...f, confirm: e.target.value }))}
              className={`w-full border rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-amber-400 outline-none ${
                pwForm.confirm && pwForm.confirm !== pwForm.new_pass ? 'border-red-400 bg-red-50' : 'border-gray-200'
              }`}
              placeholder="Re-enter new password" />
            {pwForm.confirm && pwForm.confirm !== pwForm.new_pass && (
              <p className="text-red-500 text-xs mt-1 flex items-center gap-1"><AlertCircle size={11} /> Passwords do not match</p>
            )}
          </div>

          <button onClick={handleChangePw} disabled={changingPw}
            className="flex items-center gap-2 bg-amber-500 text-white px-5 py-2.5 rounded-xl font-medium text-sm hover:bg-amber-600 transition-colors disabled:opacity-50">
            {changingPw ? <><div className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Changing…</> : <><Lock size={16} /> Change Password</>}
          </button>
        </motion.div>
      </div>
      <Footer />
    </>
  )
}

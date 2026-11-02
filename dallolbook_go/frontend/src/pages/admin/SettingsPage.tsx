// pages/admin/SettingsPage.tsx — shared settings page for all admin roles
import { useEffect, useState } from 'react'
import { User, Lock, Save } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import PageHeader from '../../components/shared/PageHeader'
import Spinner from '../../components/shared/Spinner'
import {
  validateName, validatePhone, validatePassword,
  validateConfirmPassword, type FieldError,
} from '../../utils/validate'
import { adminService } from '../../services/admin'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

interface Props { role: string }

const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

const EMPTY_PW = { current_password: '', new_password: '', confirm_password: '' }
const EMPTY_PW_ERRS = {
  new_password:     null as FieldError,
  confirm_password: null as FieldError,
}

export default function SettingsPage({ role }: Props) {
  const { adminUser, adminToken, setAdminAuth } = useAuth()
  const [loading, setLoading] = useState(true)
  const [profile, setProfile] = useState({ full_name: '', email: '', phone: '' })
  const [profileErrs, setProfileErrs] = useState({ full_name: null as FieldError, phone: null as FieldError })
  const [pwForm, setPwForm] = useState({ ...EMPTY_PW })
  const [pwErrs, setPwErrs]   = useState({ ...EMPTY_PW_ERRS })
  const [savingProfile, setSavingProfile] = useState(false)
  const [savingPw,      setSavingPw]      = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.getProfile()
      const d = res.data.data
      setProfile({ full_name: d.full_name || '', email: d.email || '', phone: d.phone || '' })
    } catch { toast.error('Failed to load profile') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  // ── profile field helpers ─────────────────────────────────────────────────
  const setProfileField = (key: 'full_name' | 'phone', val: string) => {
    setProfile(p => ({ ...p, [key]: val }))
    setProfileErrs(e => ({ ...e, [key]: null }))
  }

  const validateProfile = () => {
    const next = {
      full_name: validateName(profile.full_name, 'Full name'),
      phone:     validatePhone(profile.phone, false),   // phone optional
    }
    setProfileErrs(next)
    return !next.full_name && !next.phone
  }

  const handleSaveProfile = async () => {
    if (!validateProfile()) return
    setSavingProfile(true)
    try {
      await adminService.updateProfile({ full_name: profile.full_name.trim(), phone: profile.phone.trim() })
      toast.success('Profile updated')
      if (adminUser) setAdminAuth({ ...adminUser, full_name: profile.full_name }, adminToken || '')
    } catch { toast.error('Failed to update profile') }
    setSavingProfile(false)
  }

  // ── password helpers ──────────────────────────────────────────────────────
  const setPwField = (key: keyof typeof pwForm, val: string) => {
    setPwForm(f => ({ ...f, [key]: val }))
    setPwErrs(e => ({ ...e, [key]: null }))
  }

  const validatePw = () => {
    const next = {
      new_password:     validatePassword(pwForm.new_password),
      confirm_password: validateConfirmPassword(pwForm.new_password, pwForm.confirm_password),
    }
    setPwErrs(next)
    return !next.new_password && !next.confirm_password
  }

  const handleChangePw = async () => {
    if (!pwForm.current_password.trim()) {
      toast.error('Current password is required'); return
    }
    if (!validatePw()) return
    setSavingPw(true)
    try {
      await adminService.changePassword(pwForm.current_password, pwForm.new_password)
      toast.success('Password changed')
      setPwForm({ ...EMPTY_PW })
      setPwErrs({ ...EMPTY_PW_ERRS })
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to change password')
    }
    setSavingPw(false)
  }

  if (loading) return <AdminLayout role={role}><Spinner /></AdminLayout>

  return (
    <AdminLayout role={role}>
      <PageHeader title="Settings" subtitle="Manage your account profile and password" />

      <div className="max-w-2xl space-y-6">
        {/* ── Profile card ─────────────────────────────────────────────────── */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center gap-2 mb-5">
            <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center">
              <User size={20} className="text-blue-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Profile Information</h3>
          </div>

          <div className="space-y-4">
            {/* full name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input
                value={profile.full_name}
                onChange={e => setProfileField('full_name', e.target.value)}
                onBlur={() => setProfileErrs(e => ({ ...e, full_name: validateName(profile.full_name, 'Full name') }))}
                placeholder="e.g. Abebe Kebede"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${profileErrs.full_name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={profileErrs.full_name} />
              <p className="text-xs text-gray-400 mt-0.5">Letters and spaces only</p>
            </div>

            {/* email (read-only) */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input
                value={profile.email}
                disabled
                className="w-full border border-gray-200 rounded-lg px-3 py-2 bg-gray-50 text-gray-400 outline-none cursor-not-allowed"
              />
            </div>

            {/* phone */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone <span className="text-gray-400 font-normal">(optional)</span></label>
              <input
                value={profile.phone}
                onChange={e => setProfileField('phone', e.target.value.replace(/[^\d+]/g, ''))}
                onBlur={() => setProfileErrs(e => ({ ...e, phone: validatePhone(profile.phone, false) }))}
                placeholder="09XXXXXXXX or +251XXXXXXXXX"
                maxLength={13}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${profileErrs.phone ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={profileErrs.phone} />
              <p className="text-xs text-gray-400 mt-0.5">Numbers only — Ethiopian format</p>
            </div>

            <button
              onClick={handleSaveProfile}
              disabled={savingProfile}
              className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium text-sm disabled:opacity-60">
              <Save size={16} /> {savingProfile ? 'Saving…' : 'Save Profile'}
            </button>
          </div>
        </div>

        {/* ── Password card ─────────────────────────────────────────────────── */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center gap-2 mb-5">
            <div className="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center">
              <Lock size={20} className="text-amber-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Change Password</h3>
          </div>

          <div className="space-y-4">
            {/* current password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Current Password *</label>
              <input
                type="password"
                value={pwForm.current_password}
                onChange={e => setPwField('current_password', e.target.value)}
                placeholder="Your current password"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-amber-500 focus:border-transparent outline-none"
              />
            </div>

            {/* new password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">New Password *</label>
              <input
                type="password"
                value={pwForm.new_password}
                onChange={e => setPwField('new_password', e.target.value)}
                onBlur={() => setPwErrs(e => ({ ...e, new_password: validatePassword(pwForm.new_password) }))}
                placeholder="Min 6 chars, letters + numbers"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-amber-500 focus:border-transparent outline-none transition ${pwErrs.new_password ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={pwErrs.new_password} />
              <p className="text-xs text-gray-400 mt-0.5">At least 6 characters with a letter and a number</p>
            </div>

            {/* confirm password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Confirm New Password *</label>
              <input
                type="password"
                value={pwForm.confirm_password}
                onChange={e => setPwField('confirm_password', e.target.value)}
                onBlur={() => setPwErrs(e => ({ ...e, confirm_password: validateConfirmPassword(pwForm.new_password, pwForm.confirm_password) }))}
                placeholder="Re-enter your new password"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-amber-500 focus:border-transparent outline-none transition ${pwErrs.confirm_password ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={pwErrs.confirm_password} />
            </div>

            <button
              onClick={handleChangePw}
              disabled={savingPw}
              className="flex items-center gap-2 bg-amber-500 text-white px-4 py-2.5 rounded-lg hover:bg-amber-600 transition-colors font-medium text-sm disabled:opacity-60">
              <Lock size={16} /> {savingPw ? 'Saving…' : 'Change Password'}
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}

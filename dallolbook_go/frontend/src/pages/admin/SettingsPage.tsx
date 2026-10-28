// pages/admin/SettingsPage.tsx — shared settings page for all admin roles
import { useEffect, useState } from 'react'
import { User, Lock, Save } from 'lucide-react'
import AdminLayout from '../../components/admin/AdminLayout'
import PageHeader from '../../components/shared/PageHeader'
import Spinner from '../../components/shared/Spinner'
import { adminService } from '../../services/admin'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

interface Props {
  role: string
}

export default function SettingsPage({ role }: Props) {
  const { adminUser, adminToken, setAdminAuth } = useAuth()
  const [loading, setLoading] = useState(true)
  const [profile, setProfile] = useState({ full_name: '', email: '', phone: '' })
  const [pwForm, setPwForm] = useState({ current_password: '', new_password: '', confirm_password: '' })

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

  const handleSaveProfile = async () => {
    try {
      await adminService.updateProfile({ full_name: profile.full_name, phone: profile.phone })
      toast.success('Profile updated')
      if (adminUser) setAdminAuth({ ...adminUser, full_name: profile.full_name }, adminToken || '')
    } catch { toast.error('Failed to update profile') }
  }

  const handleChangePw = async () => {
    if (pwForm.new_password !== pwForm.confirm_password) {
      toast.error('Passwords do not match'); return
    }
    if (pwForm.new_password.length < 6) {
      toast.error('Password must be at least 6 characters'); return
    }
    try {
      await adminService.changePassword(pwForm.current_password, pwForm.new_password)
      toast.success('Password changed')
      setPwForm({ current_password: '', new_password: '', confirm_password: '' })
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to change password')
    }
  }

  if (loading) return <AdminLayout role={role}><Spinner /></AdminLayout>

  return (
    <AdminLayout role={role}>
      <PageHeader title="Settings" subtitle="Manage your account profile and password" />

      <div className="max-w-2xl space-y-6">
        {/* Profile */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center gap-2 mb-5">
            <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center">
              <User size={20} className="text-blue-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Profile Information</h3>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input value={profile.full_name} onChange={e => setProfile({...profile, full_name: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input value={profile.email} disabled
                className="w-full border border-gray-200 rounded-lg px-3 py-2 bg-gray-50 text-gray-500 outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input value={profile.phone} onChange={e => setProfile({...profile, phone: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <button onClick={handleSaveProfile}
              className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium text-sm">
              <Save size={16} /> Save Profile
            </button>
          </div>
        </div>

        {/* Password */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center gap-2 mb-5">
            <div className="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center">
              <Lock size={20} className="text-amber-600" />
            </div>
            <h3 className="font-semibold text-gray-800">Change Password</h3>
          </div>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
              <input type="password" value={pwForm.current_password} onChange={e => setPwForm({...pwForm, current_password: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-amber-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">New Password</label>
              <input type="password" value={pwForm.new_password} onChange={e => setPwForm({...pwForm, new_password: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-amber-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
              <input type="password" value={pwForm.confirm_password} onChange={e => setPwForm({...pwForm, confirm_password: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-amber-500 focus:border-transparent outline-none" />
            </div>
            <button onClick={handleChangePw}
              className="flex items-center gap-2 bg-amber-500 text-white px-4 py-2.5 rounded-lg hover:bg-amber-600 transition-colors font-medium text-sm">
              <Lock size={16} /> Change Password
            </button>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}

// pages/dashboard/Profile.tsx
import { useState, useEffect } from 'react'
import toast from 'react-hot-toast'
import { guestService } from '../../services/guest'
import { useAuth } from '../../context/AuthContext'
import Navbar from '../../components/shared/Navbar'
import Input from '../../components/shared/Input'
import Button from '../../components/shared/Button'

export default function Profile() {
  const { setAuth, token } = useAuth()
  const [form, setForm]       = useState({ first_name: '', last_name: '', phone: '', nationality: '' })
  const [pwForm, setPwForm]   = useState({ current: '', new_pass: '', confirm: '' })
  const [loading, setLoading] = useState(false)
  const [saving, setSaving]   = useState(false)

  useEffect(() => {
    setLoading(true)
    guestService.getProfile()
      .then(r => {
        const u = r.data.data.user
        setForm({ first_name: u.first_name, last_name: u.last_name, phone: u.phone || '', nationality: u.nationality || '' })
      })
      .finally(() => setLoading(false))
  }, [])

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm(f => ({ ...f, [k]: e.target.value }))

  const saveProfile = async () => {
    setSaving(true)
    try {
      const res = await guestService.updateProfile({
        first_name: form.first_name, last_name: form.last_name,
        phone: form.phone || undefined, nationality: form.nationality || undefined,
      })
      if (token) setAuth(res.data.data, token)
      toast.success('Profile updated!')
    } catch { toast.error('Failed to update') }
    finally { setSaving(false) }
  }

  const changePassword = async () => {
    if (pwForm.new_pass !== pwForm.confirm) { toast.error('Passwords do not match'); return }
    setSaving(true)
    try {
      await guestService.changePassword(pwForm.current, pwForm.new_pass)
      toast.success('Password changed!')
      setPwForm({ current: '', new_pass: '', confirm: '' })
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed')
    } finally { setSaving(false) }
  }

  return (
    <>
      <Navbar />
      <div className="max-w-lg mx-auto px-4 py-10 space-y-6">
        <h1 className="text-2xl font-bold">Edit Profile</h1>

        <div className="bg-white rounded-xl shadow p-6 space-y-4">
          <h2 className="font-semibold text-gray-800">Personal Info</h2>
          <div className="grid grid-cols-2 gap-4">
            <Input label="First Name" value={form.first_name} onChange={set('first_name')} required />
            <Input label="Last Name"  value={form.last_name}  onChange={set('last_name')}  required />
          </div>
          <Input label="Phone"       value={form.phone}       onChange={set('phone')} />
          <Input label="Nationality" value={form.nationality} onChange={set('nationality')} />
          <Button fullWidth onClick={saveProfile} loading={saving}>Save Changes</Button>
        </div>

        <div className="bg-white rounded-xl shadow p-6 space-y-4">
          <h2 className="font-semibold text-gray-800">Change Password</h2>
          <Input label="Current Password" type="password" value={pwForm.current}
            onChange={e => setPwForm(f => ({ ...f, current: e.target.value }))} />
          <Input label="New Password" type="password" value={pwForm.new_pass}
            onChange={e => setPwForm(f => ({ ...f, new_pass: e.target.value }))} />
          <Input label="Confirm New Password" type="password" value={pwForm.confirm}
            onChange={e => setPwForm(f => ({ ...f, confirm: e.target.value }))} />
          <Button fullWidth variant="outline" onClick={changePassword} loading={saving}>Update Password</Button>
        </div>
      </div>
    </>
  )
}

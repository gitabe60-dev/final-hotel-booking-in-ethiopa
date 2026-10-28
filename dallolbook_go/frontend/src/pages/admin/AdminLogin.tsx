// pages/admin/AdminLogin.tsx
import { useState, FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { adminService } from '../../services/admin'
import { useAuth } from '../../context/AuthContext'
import Input from '../../components/shared/Input'
import Button from '../../components/shared/Button'

export default function AdminLogin() {
  const navigate = useNavigate()
  const { setAdminAuth } = useAuth()
  const [form, setForm]   = useState({ email: '', password: '' })
  const [loading, setLoading] = useState(false)

  const submit = async (e: FormEvent) => {
    e.preventDefault()
    setLoading(true)
    try {
      const res = await adminService.login(form.email, form.password)
      const { admin, token } = res.data.data
      setAdminAuth(admin, token)

      const routes: Record<string, string> = {
        super_admin:   '/admin/super/dashboard',
        sub_admin:     '/admin/subadmin/dashboard',
        broker:        '/admin/broker/dashboard',
        hotel_manager: '/admin/manager/dashboard',
      }
      navigate(routes[admin.role] || '/admin/super/dashboard')
      toast.success(`Welcome, ${admin.full_name}!`)
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Login failed')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900 px-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl p-8">
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-gray-900">DallolBook Admin</h1>
          <p className="text-gray-500 mt-1 text-sm">Sign in to the admin panel</p>
        </div>
        <form onSubmit={submit} className="space-y-4">
          <Input label="Email" type="email" required value={form.email}
            onChange={e => setForm(f => ({ ...f, email: e.target.value }))} placeholder="admin@dallolbook.com" />
          <Input label="Password" type="password" required value={form.password}
            onChange={e => setForm(f => ({ ...f, password: e.target.value }))} placeholder="••••••••" />
          <Button type="submit" fullWidth loading={loading}>Sign In</Button>
        </form>
      </div>
    </div>
  )
}

// pages/admin/subadmin/ManagersPage.tsx
import { useEffect, useState } from 'react'
import { UserPlus, Trash2, Hotel } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import {
  validateName, validateEmail, validatePhone, validatePassword,
  hasErrors, type FieldError,
} from '../../../utils/validate'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

const EMPTY = { full_name: '', email: '', phone: '', password: '', hotel_id: 0 }
const EMPTY_ERRS = {
  full_name: null as FieldError,
  email:     null as FieldError,
  phone:     null as FieldError,
  password:  null as FieldError,
  hotel_id:  null as FieldError,
}

export default function ManagersPage() {
  const [managers, setManagers] = useState<any[]>([])
  const [hotels,   setHotels]   = useState<any[]>([])
  const [loading,  setLoading]  = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ ...EMPTY })
  const [errs, setErrs] = useState({ ...EMPTY_ERRS })
  const [submitting, setSubmitting] = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const [mgrRes, hotelRes] = await Promise.all([
        adminService.getSubManagers(),
        adminService.subHotels(),
      ])
      setManagers(mgrRes.data.data || [])
      setHotels(hotelRes.data.data || [])
    } catch { toast.error('Failed to load managers') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const setField = (key: keyof typeof form, val: string | number) => {
    setForm(f => ({ ...f, [key]: val }))
    setErrs(e => ({ ...e, [key]: null }))
  }

  const validate = () => {
    const next = {
      full_name: validateName(form.full_name, 'Full name'),
      email:     validateEmail(form.email),
      phone:     validatePhone(form.phone, false),
      password:  validatePassword(form.password),
      hotel_id:  form.hotel_id === 0 ? 'Please select a hotel' : null,
    }
    setErrs(next)
    return !hasErrors(next)
  }

  const handleCreate = async () => {
    if (!validate()) return
    setSubmitting(true)
    try {
      await adminService.createManager(form)
      toast.success('Hotel manager created')
      setForm({ ...EMPTY })
      setErrs({ ...EMPTY_ERRS })
      setShowCreate(false)
      load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to create manager')
    }
    setSubmitting(false)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Remove this hotel manager?')) return
    try {
      await adminService.deleteManager(id)
      toast.success('Manager removed')
      load()
    } catch { toast.error('Failed to remove manager') }
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Hotel Managers"
        subtitle="Assign managers to hotels in your city"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Manager
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email',     label: 'Email' },
          { key: 'phone',     label: 'Phone', render: (r) => r.phone || '-' },
          {
            key: 'hotel_name', label: 'Hotel', render: (r) => (
              <span className="flex items-center gap-1.5">
                <Hotel size={14} className="text-blue-500" /> {r.hotel_name}
              </span>
            ),
          },
          { key: 'hotel_city', label: 'City' },
          { key: 'status',     label: 'Status', render: (r) => <Badge status={r.status} /> },
          {
            key: 'actions', label: '', render: (r) => (
              <button onClick={() => handleDelete(r.id)}
                className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
                <Trash2 size={16} />
              </button>
            ),
          },
        ]}
        data={managers}
        emptyTitle="No managers assigned"
        emptySubtitle="Create hotel managers to manage rooms and verify payments"
      />

      <Modal open={showCreate} onClose={() => { setShowCreate(false); setErrs({ ...EMPTY_ERRS }) }} title="Add Hotel Manager">
        <div className="space-y-4">
          {/* full name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
            <input
              value={form.full_name}
              onChange={e => setField('full_name', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, full_name: validateName(form.full_name, 'Full name') }))}
              placeholder="e.g. Tigist Alemu"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.full_name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={errs.full_name} />
            <p className="text-xs text-gray-400 mt-0.5">Letters and spaces only</p>
          </div>

          {/* email */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input
              type="email"
              value={form.email}
              onChange={e => setField('email', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, email: validateEmail(form.email) }))}
              placeholder="e.g. manager@hotel.com"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.email ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={errs.email} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* phone */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input
                value={form.phone}
                onChange={e => setField('phone', e.target.value.replace(/[^\d+]/g, ''))}
                onBlur={() => setErrs(e => ({ ...e, phone: validatePhone(form.phone, false) }))}
                placeholder="09XXXXXXXX"
                maxLength={13}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.phone ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={errs.phone} />
              <p className="text-xs text-gray-400 mt-0.5">Numbers only</p>
            </div>

            {/* password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
              <input
                type="password"
                value={form.password}
                onChange={e => setField('password', e.target.value)}
                onBlur={() => setErrs(e => ({ ...e, password: validatePassword(form.password) }))}
                placeholder="Min 6 chars"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.password ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={errs.password} />
            </div>
          </div>

          {/* hotel select */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Assign to Hotel *</label>
            <select
              value={form.hotel_id}
              onChange={e => setField('hotel_id', +e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, hotel_id: form.hotel_id === 0 ? 'Please select a hotel' : null }))}
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.hotel_id ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}>
              <option value={0}>Select hotel...</option>
              {hotels.map((h: any) => <option key={h.id} value={h.id}>{h.name}</option>)}
            </select>
            <Err msg={errs.hotel_id} />
          </div>

          <button
            onClick={handleCreate}
            disabled={submitting}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {submitting ? 'Creating…' : 'Create & Assign Manager'}
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

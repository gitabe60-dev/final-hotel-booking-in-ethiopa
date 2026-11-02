// pages/admin/subadmin/ManagersPage.tsx
// Sub-admin creates hotel managers. Payment methods are managed by the
// hotel manager themselves from their own dashboard (Payment Methods page).
import { useEffect, useState } from 'react'
import { UserPlus, Trash2, Hotel, Info } from 'lucide-react'
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

const inputCls = (err: boolean) =>
  `w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition ${
    err ? 'border-red-400 bg-red-50' : 'border-gray-200 bg-white'
  }`

const EMPTY = { full_name: '', email: '', phone: '', password: '', hotel_id: 0 }
const EMPTY_ERRS = {
  full_name: null as FieldError, email: null as FieldError,
  phone: null as FieldError, password: null as FieldError, hotel_id: null as FieldError,
}

export default function ManagersPage() {
  const [managers,   setManagers]   = useState<any[]>([])
  const [hotels,     setHotels]     = useState<any[]>([])
  const [loading,    setLoading]    = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form,       setForm]       = useState({ ...EMPTY })
  const [errs,       setErrs]       = useState({ ...EMPTY_ERRS })
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
    } catch { toast.error('Failed to load') }
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
      toast.success('Hotel manager created — they can add payment methods from their dashboard')
      setForm({ ...EMPTY }); setErrs({ ...EMPTY_ERRS })
      setShowCreate(false); load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to create manager')
    }
    setSubmitting(false)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Remove this hotel manager?')) return
    try { await adminService.deleteManager(id); toast.success('Manager removed'); load() }
    catch { toast.error('Failed to remove') }
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Hotel Managers"
        subtitle="Create manager accounts and assign them to hotels in your city"
        action={
          <button onClick={() => { setForm({ ...EMPTY }); setErrs({ ...EMPTY_ERRS }); setShowCreate(true) }}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Manager
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email',     label: 'Email' },
          { key: 'phone',     label: 'Phone', render: (r) => r.phone || '—' },
          { key: 'hotel_name', label: 'Hotel', render: (r) => (
            <span className="flex items-center gap-1.5">
              <Hotel size={14} className="text-blue-500" /> {r.hotel_name}
            </span>
          )},
          { key: 'hotel_city', label: 'City' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'actions', label: '', render: (r) => (
            <button onClick={() => handleDelete(r.id)}
              className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
              <Trash2 size={16} />
            </button>
          )},
        ]}
        data={managers}
        emptyTitle="No managers yet"
        emptySubtitle="Create a manager account and assign it to a hotel"
      />

      {/* ── Create Manager Modal ── */}
      <Modal
        open={showCreate}
        onClose={() => { setShowCreate(false); setErrs({ ...EMPTY_ERRS }) }}
        title="Add Hotel Manager">
        <div className="space-y-4">

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
            <input value={form.full_name}
              onChange={e => setField('full_name', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, full_name: validateName(form.full_name, 'Full name') }))}
              placeholder="e.g. Tigist Alemu"
              className={inputCls(!!errs.full_name)} />
            <Err msg={errs.full_name} />
            <p className="text-xs text-gray-400 mt-0.5">Letters and spaces only</p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input type="email" value={form.email}
              onChange={e => setField('email', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, email: validateEmail(form.email) }))}
              placeholder="manager@hotel.com"
              className={inputCls(!!errs.email)} />
            <Err msg={errs.email} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Phone <span className="text-gray-400 font-normal text-xs">(optional)</span>
              </label>
              <input value={form.phone}
                onChange={e => setField('phone', e.target.value.replace(/[^\d+]/g, ''))}
                onBlur={() => setErrs(e => ({ ...e, phone: validatePhone(form.phone, false) }))}
                placeholder="09XXXXXXXX" maxLength={13}
                className={inputCls(!!errs.phone)} />
              <Err msg={errs.phone} />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
              <input type="password" value={form.password}
                onChange={e => setField('password', e.target.value)}
                onBlur={() => setErrs(e => ({ ...e, password: validatePassword(form.password) }))}
                placeholder="Min 6 chars, letters + numbers"
                className={inputCls(!!errs.password)} />
              <Err msg={errs.password} />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Assign to Hotel *</label>
            <select value={form.hotel_id}
              onChange={e => setField('hotel_id', +e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, hotel_id: form.hotel_id === 0 ? 'Please select a hotel' : null }))}
              className={inputCls(!!errs.hotel_id)}>
              <option value={0}>Select hotel…</option>
              {hotels.map((h: any) => <option key={h.id} value={h.id}>{h.name} — {h.city}</option>)}
            </select>
            <Err msg={errs.hotel_id} />
          </div>

          {/* Info: payment methods managed by manager */}
          <div className="flex items-start gap-2 bg-blue-50 border border-blue-100 rounded-lg px-3 py-3 text-xs text-blue-700">
            <Info size={13} className="flex-shrink-0 mt-0.5" />
            <span>
              The hotel manager sets up their own payment accounts (Telebirr, CBE Birr, bank accounts, etc.)
              from their <strong>Payment Methods</strong> page after signing in. Guests see those accounts when paying.
            </span>
          </div>

          <button onClick={handleCreate} disabled={submitting}
            className="w-full bg-blue-600 text-white py-3 rounded-xl hover:bg-blue-700 transition-colors font-bold text-sm disabled:opacity-60 flex items-center justify-center gap-2">
            {submitting
              ? <><div className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Creating…</>
              : <><UserPlus size={16} /> Create Hotel Manager</>
            }
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

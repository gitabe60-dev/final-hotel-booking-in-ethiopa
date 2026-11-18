// pages/admin/subadmin/BrokersPage.tsx
import { useEffect, useState } from 'react'
import { UserPlus } from 'lucide-react'
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

const validateCommission = (v: number): FieldError => {
  if (v < 0 || v > 100) return 'Commission must be between 0 and 100'
  return null
}

const EMPTY = { full_name: '', email: '', phone: '', password: '', city: '', commission_pct: 0 }
const EMPTY_ERRS = {
  full_name:      null as FieldError,
  email:          null as FieldError,
  phone:          null as FieldError,
  password:       null as FieldError,
  commission_pct: null as FieldError,
}

export default function BrokersPage() {
  const [brokers, setBrokers] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ ...EMPTY })
  const [errs, setErrs] = useState({ ...EMPTY_ERRS })
  const [submitting, setSubmitting] = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.getSubBrokers()
      setBrokers(res.data.data || [])
    } catch { toast.error('Failed to load brokers') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const setField = (key: keyof typeof form, val: string | number) => {
    setForm(f => ({ ...f, [key]: val }))
    setErrs(e => ({ ...e, [key]: null }))
  }

  const validate = () => {
    const next = {
      full_name:      validateName(form.full_name, 'Full name'),
      email:          validateEmail(form.email),
      phone:          validatePhone(form.phone, false),
      password:       validatePassword(form.password),
      commission_pct: validateCommission(form.commission_pct),
    }
    setErrs(next)
    return !hasErrors(next)
  }

  const handleCreate = async () => {
    if (!validate()) return
    setSubmitting(true)
    try {
      await adminService.createBroker(form)
      toast.success('Broker created')
      setForm({ ...EMPTY })
      setErrs({ ...EMPTY_ERRS })
      setShowCreate(false)
      load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to create broker')
    }
    setSubmitting(false)
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Brokers"
        subtitle="Manage brokers in your city"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Broker
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email',     label: 'Email' },
          { key: 'phone',     label: 'Phone', render: (r) => r.phone || '-' },
          { key: 'city',      label: 'City' },
          { key: 'commission_pct', label: 'Commission', render: (r) => `${r.commission_pct}%` },
          { key: 'status',    label: 'Status', render: (r) => <Badge status={r.status} /> },
          {
            key: 'hotel_count', label: 'Hotels', render: (r) => (
              <span className="bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full text-xs font-medium">{r.hotel_count}</span>
            ),
          },
        ]}
        data={brokers}
        emptyTitle="No brokers yet"
        emptySubtitle="Add brokers to link with hotels"
      />

      <Modal open={showCreate} onClose={() => { setShowCreate(false); setErrs({ ...EMPTY_ERRS }) }} title="Add Broker">
        <div className="space-y-4">
          {/* full name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
            <input
              value={form.full_name}
              onChange={e => setField('full_name', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, full_name: validateName(form.full_name, 'Full name') }))}
              placeholder="e.g. Dawit Bekele"
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
              placeholder="e.g. broker@example.com"
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

          <div className="grid grid-cols-2 gap-4">
            {/* city (free text) */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">City</label>
              <input
                value={form.city}
                onChange={e => setField('city', e.target.value.replace(/[^A-Za-z\u1200-\u137F\s'-]/g, ''))}
                placeholder="e.g. Dire Dawa"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none"
              />
              <p className="text-xs text-gray-400 mt-0.5">Letters only</p>
            </div>

            {/* commission */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Commission %</label>
              <input
                type="number"
                min={0}
                max={100}
                step={0.1}
                value={form.commission_pct}
                onChange={e => setField('commission_pct', +e.target.value)}
                onBlur={() => setErrs(e => ({ ...e, commission_pct: validateCommission(form.commission_pct) }))}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.commission_pct ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={errs.commission_pct} />
              <p className="text-xs text-gray-400 mt-0.5">0 – 100</p>
            </div>
          </div>

          <button
            onClick={handleCreate}
            disabled={submitting}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {submitting ? 'Creating…' : 'Create Broker'}
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

// pages/admin/super/SubAdminsPage.tsx
import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { UserPlus, Trash2, MapPin, X, Info } from 'lucide-react'
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

interface SubAdmin {
  id: number; full_name: string; email: string; phone?: string
  role: string; status: string; created_at: string
}

// Inline error helper
const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

const EMPTY_FORM = { full_name: '', email: '', phone: '', password: '', city: '' }
const EMPTY_ERRS = { full_name: null as FieldError, email: null as FieldError, phone: null as FieldError, password: null as FieldError }

export default function SubAdminsPage() {
  const [subAdmins, setSubAdmins] = useState<SubAdmin[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [cities, setCities] = useState<any[]>([])
  const [selectedAdmin, setSelectedAdmin] = useState<SubAdmin | null>(null)
  const [adminCities, setAdminCities] = useState<string[]>([])
  const [showAssign, setShowAssign] = useState(false)
  const [form, setForm] = useState({ ...EMPTY_FORM })
  const [errs, setErrs] = useState({ ...EMPTY_ERRS })
  const [assignCity, setAssignCity] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const [res, citiesRes] = await Promise.all([
        adminService.getSubAdmins(),
        adminService.getCities(),
      ])
      setSubAdmins(res.data.data || [])
      setCities(citiesRes.data.data || [])
    } catch { toast.error('Failed to load sub-admins') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  // ── live validation as user types ──────────────────────────────────────────
  const setField = (key: keyof typeof form, val: string) => {
    setForm(f => ({ ...f, [key]: val }))
    // clear the error for that field immediately on change
    setErrs(e => ({ ...e, [key]: null }))
  }

  const validate = () => {
    const next = {
      full_name: validateName(form.full_name, 'Full name'),
      email:     validateEmail(form.email),
      phone:     validatePhone(form.phone, false),   // phone optional
      password:  validatePassword(form.password),
    }
    setErrs(next)
    return !hasErrors(next)
  }

  const handleCreate = async () => {
    if (!validate()) return
    setSubmitting(true)
    try {
      await adminService.createSubAdmin(form)
      toast.success('Sub-admin created')
      setForm({ ...EMPTY_FORM })
      setErrs({ ...EMPTY_ERRS })
      setShowCreate(false)
      load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to create sub-admin')
    }
    setSubmitting(false)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this sub-admin?')) return
    try {
      await adminService.deleteSubAdmin(id)
      toast.success('Sub-admin deleted')
      load()
    } catch { toast.error('Failed to delete') }
  }

  const openAssign = (admin: SubAdmin) => {
    setSelectedAdmin(admin)
    setAdminCities([])
    setAssignCity('')
    setShowAssign(true)
  }

  const handleAssign = async () => {
    if (!selectedAdmin || !assignCity) return
    try {
      await adminService.assignCity(selectedAdmin.id, assignCity)
      toast.success(`Assigned ${assignCity} to ${selectedAdmin.full_name}`)
      setAssignCity('')
      setAdminCities(prev => [...prev, assignCity])
    } catch { toast.error('Failed to assign city') }
  }

  const handleRevoke = async (city: string) => {
    if (!selectedAdmin) return
    try {
      await adminService.revokeCity(selectedAdmin.id, city)
      toast.success(`Revoked ${city}`)
      setAdminCities(adminCities.filter(c => c !== city))
    } catch { toast.error('Failed to revoke city') }
  }

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="super_admin">
      <PageHeader
        title="Sub-Admins"
        subtitle="Manage sub-administrators and city assignments"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Sub-Admin
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email', label: 'Email' },
          { key: 'phone', label: 'Phone', render: (r) => r.phone || '-' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'created_at', label: 'Created', render: (r) => new Date(r.created_at).toLocaleDateString() },
          {
            key: 'actions', label: 'Actions', render: (r) => (
              <div className="flex items-center gap-2">
                <button onClick={() => openAssign(r)}
                  className="text-blue-600 hover:text-blue-800 p-1.5 rounded-lg hover:bg-blue-50 transition-colors"
                  title="Assign City">
                  <MapPin size={16} />
                </button>
                <button onClick={() => handleDelete(r.id)}
                  className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors"
                  title="Delete">
                  <Trash2 size={16} />
                </button>
              </div>
            ),
          },
        ]}
        data={subAdmins}
        emptyTitle="No sub-admins yet"
        emptySubtitle="Create one to assign cities and manage hotels"
      />

      {/* ── Create Sub-Admin Modal ──────────────────────────────────────────── */}
      <Modal open={showCreate} onClose={() => { setShowCreate(false); setErrs({ ...EMPTY_ERRS }) }} title="Add Sub-Admin">
        <div className="space-y-4">
          {/* full name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
            <input
              value={form.full_name}
              onChange={e => setField('full_name', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, full_name: validateName(form.full_name, 'Full name') }))}
              placeholder="e.g. Abebe Kebede"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${errs.full_name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
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
              placeholder="e.g. abebe@example.com"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${errs.email ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={errs.email} />
          </div>

          {/* phone */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
            <input
              value={form.phone}
              onChange={e => {
                // only allow digits, +, leading zeros
                const cleaned = e.target.value.replace(/[^\d+]/g, '')
                setField('phone', cleaned)
              }}
              onBlur={() => setErrs(e => ({ ...e, phone: validatePhone(form.phone, false) }))}
              placeholder="e.g. 0912345678 or +251912345678"
              maxLength={13}
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${errs.phone ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={errs.phone} />
            <p className="text-xs text-gray-400 mt-0.5">Numbers only — Ethiopian format (09XXXXXXXX)</p>
          </div>

          {/* password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
            <input
              type="password"
              value={form.password}
              onChange={e => setField('password', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, password: validatePassword(form.password) }))}
              placeholder="Min 6 chars, letters + numbers"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${errs.password ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={errs.password} />
            <p className="text-xs text-gray-400 mt-0.5">At least 6 characters with a letter and a number</p>
          </div>

          {/* city (optional at create time) */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Assign City (optional)</label>
            <select
              value={form.city}
              onChange={e => setForm(f => ({ ...f, city: e.target.value }))}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
              <option value="">Select city to assign...</option>
              {cities.map((c: any) => (
                <option key={c.id} value={c.name}>{c.name}</option>
              ))}
            </select>
          </div>

          {/* multi-city info banner */}
          <div className="flex items-start gap-2 bg-blue-50 border border-blue-100 rounded-lg p-3 text-xs text-blue-700">
            <Info size={14} className="mt-0.5 flex-shrink-0" />
            <span>
              <strong>Multiple sub-admins per city is allowed.</strong> Different sub-admins can manage the same city — use the <MapPin size={11} className="inline" /> icon in the table to assign additional cities after creation.
            </span>
          </div>

          <button
            onClick={handleCreate}
            disabled={submitting}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {submitting ? 'Creating…' : 'Create Sub-Admin'}
          </button>
        </div>
      </Modal>

      {/* ── Assign City Modal ───────────────────────────────────────────────── */}
      <Modal
        open={showAssign}
        onClose={() => setShowAssign(false)}
        title={`Assign City — ${selectedAdmin?.full_name || ''}`}>
        <div className="space-y-4">
          <div className="flex items-start gap-2 bg-blue-50 border border-blue-100 rounded-lg p-3 text-xs text-blue-700">
            <Info size={14} className="mt-0.5 flex-shrink-0" />
            <span>You can assign <strong>multiple cities</strong> to this sub-admin. Multiple sub-admins can also manage the same city simultaneously.</span>
          </div>

          <div className="flex gap-2">
            <select
              value={assignCity}
              onChange={e => setAssignCity(e.target.value)}
              className="flex-1 border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
              <option value="">Select a city...</option>
              {cities.map((c: any) => (
                <option key={c.id} value={c.name}>{c.name}</option>
              ))}
            </select>
            <button
              onClick={handleAssign}
              disabled={!assignCity}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 text-sm font-medium">
              Assign
            </button>
          </div>

          <div className="space-y-2">
            {adminCities.length === 0 ? (
              <p className="text-gray-400 text-sm text-center py-4">No cities assigned yet — select above to assign.</p>
            ) : (
              adminCities.map(city => (
                <div key={city} className="flex items-center justify-between bg-gray-50 rounded-lg px-3 py-2">
                  <span className="text-sm text-gray-700 flex items-center gap-2">
                    <MapPin size={14} className="text-blue-500" /> {city}
                  </span>
                  <button onClick={() => handleRevoke(city)} className="text-red-400 hover:text-red-600">
                    <X size={16} />
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      </Modal>
    </AdminLayout>
  )
}

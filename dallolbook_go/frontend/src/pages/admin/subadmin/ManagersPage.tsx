// pages/admin/subadmin/ManagersPage.tsx
// Allows sub-admin to create hotel managers AND configure per-hotel payment
// accounts (phone / account number) that guests see when paying.
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { UserPlus, Trash2, Hotel, CreditCard, Phone, Hash, Plus, Pencil, Check } from 'lucide-react'
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

// ── All supported Ethiopian payment methods ────────────────────────────────
const PM_OPTIONS = [
  { value: 'telebirr',    label: 'Telebirr',           logo: '📱' },
  { value: 'cbe_birr',   label: 'CBE Birr',            logo: '🏦' },
  { value: 'chapa',      label: 'Chapa',               logo: '🔵' },
  { value: 'awash_bank', label: 'Awash Bank',          logo: '🏦' },
  { value: 'abyssinia',  label: 'Bank of Abyssinia',   logo: '🏦' },
  { value: 'dashen',     label: 'Dashen Bank',         logo: '🏦' },
  { value: 'oromia_coop',label: 'Oromia Bank',         logo: '🏦' },
  { value: 'united',     label: 'United Bank',         logo: '🏦' },
  { value: 'nib',        label: 'NIB International',   logo: '🏦' },
  { value: 'wegagen',    label: 'Wegagen Bank',        logo: '🏦' },
  { value: 'bunna',      label: 'Bunna Bank',          logo: '🏦' },
]

const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

const EMPTY_MGR = { full_name: '', email: '', phone: '', password: '', hotel_id: 0 }
const EMPTY_ERRS = {
  full_name: null as FieldError, email: null as FieldError,
  phone: null as FieldError,     password: null as FieldError,
  hotel_id:  null as FieldError,
}
const EMPTY_PM = { method: '', account_name: '', account_number: '', phone_number: '', instructions: '' }

export default function ManagersPage() {
  const [managers,  setManagers]  = useState<any[]>([])
  const [hotels,    setHotels]    = useState<any[]>([])
  const [loading,   setLoading]   = useState(true)

  // Manager creation modal
  const [showCreate,  setShowCreate]  = useState(false)
  const [form,        setForm]        = useState({ ...EMPTY_MGR })
  const [errs,        setErrs]        = useState({ ...EMPTY_ERRS })
  const [submitting,  setSubmitting]  = useState(false)

  // Payment methods modal (opened after selecting a hotel from the table)
  const [showPM,      setShowPM]      = useState(false)
  const [pmHotel,     setPmHotel]     = useState<any>(null)   // hotel being configured
  const [pmList,      setPmList]      = useState<any[]>([])
  const [pmLoading,   setPmLoading]   = useState(false)
  const [pmForm,      setPmForm]      = useState({ ...EMPTY_PM })
  const [pmSaving,    setPmSaving]    = useState(false)
  const [editingPm,   setEditingPm]   = useState<any>(null)

  // ── data loading ──────────────────────────────────────────────────────────
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

  const loadPM = async (hotelId: number) => {
    setPmLoading(true)
    try {
      const res = await adminService.getHotelPaymentMethods(hotelId)
      setPmList(res.data.data || [])
    } catch { setPmList([]) }
    setPmLoading(false)
  }

  // ── manager form helpers ──────────────────────────────────────────────────
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
      setForm({ ...EMPTY_MGR }); setErrs({ ...EMPTY_ERRS })
      setShowCreate(false); load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to create manager')
    }
    setSubmitting(false)
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Remove this hotel manager?')) return
    try { await adminService.deleteManager(id); toast.success('Manager removed'); load() }
    catch { toast.error('Failed to remove manager') }
  }

  // ── payment method helpers ────────────────────────────────────────────────
  const openPM = async (hotel: any) => {
    setPmHotel(hotel)
    setPmForm({ ...EMPTY_PM })
    setEditingPm(null)
    setShowPM(true)
    await loadPM(hotel.id)
  }

  const setPmField = (key: keyof typeof pmForm, val: string) =>
    setPmForm(f => ({ ...f, [key]: val }))

  const savePM = async () => {
    if (!pmForm.method) { toast.error('Select a payment method'); return }
    if (!pmForm.account_name.trim()) { toast.error('Account name is required'); return }
    if (!pmForm.phone_number.trim() && !pmForm.account_number.trim()) {
      toast.error('Enter phone number or account number'); return
    }
    setPmSaving(true)
    try {
      if (editingPm) {
        await adminService.updatePaymentMethod(editingPm.id, {
          account_name:   pmForm.account_name,
          account_number: pmForm.account_number,
          phone_number:   pmForm.phone_number,
          instructions:   pmForm.instructions,
          is_active:      true,   // keep active on edit
        })
        toast.success('Payment method updated')
      } else {
        await adminService.addPaymentMethod(pmHotel.id, pmForm)
        toast.success('Payment method added')
      }
      setPmForm({ ...EMPTY_PM }); setEditingPm(null)
      await loadPM(pmHotel.id)
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to save payment method')
    }
    setPmSaving(false)
  }

  const startEditPm = (pm: any) => {
    setEditingPm(pm)
    setPmForm({
      method:         pm.method,
      account_name:   pm.account_name   || '',
      account_number: pm.account_number || '',
      phone_number:   pm.phone_number   || '',
      instructions:   pm.instructions   || '',
    })
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Hotel Managers"
        subtitle="Assign managers to hotels and configure payment accounts"
        action={
          <button onClick={() => { setForm({ ...EMPTY_MGR }); setErrs({ ...EMPTY_ERRS }); setShowCreate(true) }}
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
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          {
            key: 'actions', label: 'Actions', render: (r) => (
              <div className="flex items-center gap-2">
                {/* Configure hotel payment accounts */}
                <button
                  onClick={() => openPM({ id: r.hotel_id, name: r.hotel_name })}
                  className="flex items-center gap-1.5 text-xs bg-purple-50 text-purple-700 px-2.5 py-1.5 rounded-lg hover:bg-purple-100 transition-colors font-medium"
                  title="Configure payment methods">
                  <CreditCard size={13} /> Payment
                </button>
                <button onClick={() => handleDelete(r.id)}
                  className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
                  <Trash2 size={16} />
                </button>
              </div>
            ),
          },
        ]}
        data={managers}
        emptyTitle="No managers assigned"
        emptySubtitle="Create hotel managers to manage rooms and verify payments"
      />

      {/* ── Create Manager Modal ──────────────────────────────────────────── */}
      <Modal open={showCreate} onClose={() => { setShowCreate(false); setErrs({ ...EMPTY_ERRS }) }} title="Add Hotel Manager">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
            <input value={form.full_name}
              onChange={e => setField('full_name', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, full_name: validateName(form.full_name, 'Full name') }))}
              placeholder="e.g. Tigist Alemu"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.full_name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`} />
            <Err msg={errs.full_name} />
            <p className="text-xs text-gray-400 mt-0.5">Letters and spaces only</p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input type="email" value={form.email}
              onChange={e => setField('email', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, email: validateEmail(form.email) }))}
              placeholder="manager@hotel.com"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.email ? 'border-red-400 bg-red-50' : 'border-gray-200'}`} />
            <Err msg={errs.email} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input value={form.phone}
                onChange={e => setField('phone', e.target.value.replace(/[^\d+]/g, ''))}
                onBlur={() => setErrs(e => ({ ...e, phone: validatePhone(form.phone, false) }))}
                placeholder="09XXXXXXXX" maxLength={13}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.phone ? 'border-red-400 bg-red-50' : 'border-gray-200'}`} />
              <Err msg={errs.phone} />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
              <input type="password" value={form.password}
                onChange={e => setField('password', e.target.value)}
                onBlur={() => setErrs(e => ({ ...e, password: validatePassword(form.password) }))}
                placeholder="Min 6 chars"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.password ? 'border-red-400 bg-red-50' : 'border-gray-200'}`} />
              <Err msg={errs.password} />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Assign to Hotel *</label>
            <select value={form.hotel_id}
              onChange={e => setField('hotel_id', +e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, hotel_id: form.hotel_id === 0 ? 'Please select a hotel' : null }))}
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${errs.hotel_id ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}>
              <option value={0}>Select hotel...</option>
              {hotels.map((h: any) => <option key={h.id} value={h.id}>{h.name}</option>)}
            </select>
            <Err msg={errs.hotel_id} />
          </div>

          <div className="flex items-start gap-2 bg-blue-50 border border-blue-100 rounded-lg p-3 text-xs text-blue-700">
            <CreditCard size={13} className="mt-0.5 flex-shrink-0" />
            <span>After creating the manager, click <strong>Payment</strong> in the table row to configure the hotel's payment accounts (phone number, account number) that guests will see when paying.</span>
          </div>

          <button onClick={handleCreate} disabled={submitting}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {submitting ? 'Creating…' : 'Create & Assign Manager'}
          </button>
        </div>
      </Modal>

      {/* ── Payment Methods Modal ─────────────────────────────────────────── */}
      <Modal
        open={showPM}
        onClose={() => { setShowPM(false); setPmHotel(null); setPmForm({ ...EMPTY_PM }); setEditingPm(null) }}
        title={`Payment Accounts — ${pmHotel?.name || ''}`}
        size="lg">
        <div className="space-y-5">
          <p className="text-sm text-gray-500">
            Configure which payment methods guests can use to pay for this hotel.
            The <strong>phone number</strong> or <strong>account number</strong> you enter will be shown to guests when they book so they can send payment.
          </p>

          {/* Existing methods */}
          {pmLoading ? (
            <div className="flex items-center justify-center py-6 gap-2 text-gray-400">
              <div className="w-5 h-5 border-2 border-blue-300 border-t-blue-600 rounded-full animate-spin" />
              Loading…
            </div>
          ) : pmList.length === 0 ? (
            <p className="text-gray-400 text-sm text-center py-4">No payment methods configured yet — add one below.</p>
          ) : (
            <div className="space-y-2">
              {pmList.map((pm: any) => {
                const opt = PM_OPTIONS.find(o => o.value === pm.method)
                return (
                  <motion.div key={pm.id} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }}
                    className={`flex items-center gap-3 rounded-xl border px-4 py-3 transition-all ${
                      editingPm?.id === pm.id ? 'border-blue-400 bg-blue-50' : 'border-gray-200 bg-gray-50'
                    }`}>
                    <span className="text-xl flex-shrink-0">{opt?.logo || '🏦'}</span>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-sm text-gray-800">{opt?.label || pm.method}</p>
                      <div className="flex items-center gap-3 mt-0.5 flex-wrap">
                        {pm.account_name && (
                          <span className="text-xs text-gray-500 flex items-center gap-1">
                            <Check size={10} className="text-emerald-500" /> {pm.account_name}
                          </span>
                        )}
                        {pm.phone_number && (
                          <span className="text-xs text-gray-500 flex items-center gap-1">
                            <Phone size={10} className="text-blue-500" /> {pm.phone_number}
                          </span>
                        )}
                        {pm.account_number && (
                          <span className="text-xs text-gray-500 flex items-center gap-1">
                            <Hash size={10} className="text-purple-500" /> {pm.account_number}
                          </span>
                        )}
                      </div>
                    </div>
                    <button onClick={() => startEditPm(pm)}
                      className="p-1.5 text-blue-500 hover:text-blue-700 hover:bg-blue-100 rounded-lg transition-colors flex-shrink-0">
                      <Pencil size={14} />
                    </button>
                  </motion.div>
                )
              })}
            </div>
          )}

          {/* Add / Edit form */}
          <div className={`rounded-xl border p-4 space-y-3 ${editingPm ? 'border-blue-300 bg-blue-50' : 'border-gray-200 bg-gray-50'}`}>
            <h4 className="text-sm font-semibold text-gray-700 flex items-center gap-2">
              <Plus size={15} className="text-blue-600" />
              {editingPm ? 'Edit Payment Method' : 'Add Payment Method'}
            </h4>

            {/* Method selector (disabled when editing) */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Payment Method *</label>
              <select value={pmForm.method}
                onChange={e => setPmField('method', e.target.value)}
                disabled={!!editingPm}
                className={`w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-400 ${editingPm ? 'bg-gray-100 cursor-not-allowed' : 'bg-white'}`}>
                <option value="">Select payment method…</option>
                {PM_OPTIONS.map(o => (
                  <option key={o.value} value={o.value}>{o.logo} {o.label}</option>
                ))}
              </select>
            </div>

            {/* Account name */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Account Name * <span className="text-gray-400 font-normal">(name shown to guest)</span></label>
              <input value={pmForm.account_name}
                onChange={e => setPmField('account_name', e.target.value)}
                placeholder="e.g. Sheraton Hotel Addis"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-400 bg-white" />
            </div>

            <div className="grid grid-cols-2 gap-3">
              {/* Phone number */}
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  <Phone size={11} className="inline mr-1 text-blue-500" />
                  Phone / Wallet Number
                </label>
                <input value={pmForm.phone_number}
                  onChange={e => setPmField('phone_number', e.target.value.replace(/[^\d+]/g, ''))}
                  placeholder="e.g. 0912345678"
                  maxLength={13}
                  className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-400 bg-white font-mono" />
                <p className="text-[10px] text-gray-400 mt-0.5">Numbers only — for Telebirr, CBE Birr etc.</p>
              </div>

              {/* Account number */}
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  <Hash size={11} className="inline mr-1 text-purple-500" />
                  Account Number
                </label>
                <input value={pmForm.account_number}
                  onChange={e => setPmField('account_number', e.target.value)}
                  placeholder="e.g. 1000123456789"
                  className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-400 bg-white font-mono" />
                <p className="text-[10px] text-gray-400 mt-0.5">For bank transfers (Awash, Abyssinia, etc.)</p>
              </div>
            </div>

            {/* Instructions */}
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Instructions <span className="text-gray-400 font-normal">(optional — shown to guest)</span></label>
              <textarea value={pmForm.instructions}
                onChange={e => setPmField('instructions', e.target.value)}
                rows={2} placeholder="e.g. Send payment and note your booking reference number"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-400 bg-white resize-none" />
            </div>

            <div className="flex gap-2 pt-1">
              {editingPm && (
                <button onClick={() => { setEditingPm(null); setPmForm({ ...EMPTY_PM }) }}
                  className="px-4 py-2 rounded-lg border border-gray-200 text-sm text-gray-600 hover:bg-gray-100 transition-colors">
                  Cancel
                </button>
              )}
              <button onClick={savePM} disabled={pmSaving}
                className="flex-1 bg-blue-600 text-white py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-60">
                {pmSaving ? 'Saving…' : editingPm ? '✓ Save Changes' : '+ Add Payment Method'}
              </button>
            </div>
          </div>
        </div>
      </Modal>
    </AdminLayout>
  )
}

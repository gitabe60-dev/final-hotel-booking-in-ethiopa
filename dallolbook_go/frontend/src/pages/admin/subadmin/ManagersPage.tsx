// pages/admin/subadmin/ManagersPage.tsx
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  UserPlus, Trash2, Hotel, CreditCard, Phone, Hash,
  Plus, Pencil, Check, X, ChevronDown, ChevronUp, Info,
} from 'lucide-react'
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

// ── Ethiopian payment methods ──────────────────────────────────────────────────
const PM_OPTIONS = [
  { value: 'telebirr',     label: 'Telebirr',           logo: '📱', hint: 'Mobile wallet — phone number required' },
  { value: 'cbe_birr',    label: 'CBE Birr',            logo: '🏦', hint: 'Commercial Bank of Ethiopia mobile app' },
  { value: 'chapa',       label: 'Chapa',               logo: '🔵', hint: 'Online payment gateway' },
  { value: 'awash_bank',  label: 'Awash Bank',          logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'abyssinia',   label: 'Bank of Abyssinia',   logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'dashen',      label: 'Dashen Bank',         logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'oromia_coop', label: 'Oromia Bank',         logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'united',      label: 'United Bank',         logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'nib',         label: 'NIB International',   logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'wegagen',     label: 'Wegagen Bank',        logo: '🏦', hint: 'Bank transfer — account number required' },
  { value: 'bunna',       label: 'Bunna Bank',          logo: '🏦', hint: 'Bank transfer — account number required' },
]

interface PmEntry {
  method: string; account_name: string; phone_number: string
  account_number: string; instructions: string
}

const EMPTY_PM_ENTRY = (): PmEntry => ({
  method: '', account_name: '', phone_number: '', account_number: '', instructions: '',
})

// ── Validation helpers ─────────────────────────────────────────────────────────
const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

const inputCls = (err: boolean) =>
  `w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition ${
    err ? 'border-red-400 bg-red-50' : 'border-gray-200 bg-white'
  }`

const EMPTY_MGR  = { full_name: '', email: '', phone: '', password: '', hotel_id: 0 }
const EMPTY_ERRS = {
  full_name: null as FieldError, email: null as FieldError,
  phone: null as FieldError, password: null as FieldError, hotel_id: null as FieldError,
}

// ── Component ──────────────────────────────────────────────────────────────────
export default function ManagersPage() {
  const [managers,   setManagers]   = useState<any[]>([])
  const [hotels,     setHotels]     = useState<any[]>([])
  const [loading,    setLoading]    = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  // Manager fields
  const [form, setForm] = useState({ ...EMPTY_MGR })
  const [errs, setErrs] = useState({ ...EMPTY_ERRS })

  // Payment methods attached to the create form
  const [pmEntries,  setPmEntries]  = useState<PmEntry[]>([])
  const [showPmForm, setShowPmForm] = useState(false)
  const [newPm,      setNewPm]      = useState<PmEntry>(EMPTY_PM_ENTRY())
  const [pmErrs,     setPmErrs]     = useState({ method: null as FieldError, account_name: null as FieldError })

  // Separate payment config modal (for existing managers)
  const [showPM,     setShowPM]     = useState(false)
  const [pmHotel,    setPmHotel]    = useState<any>(null)
  const [pmList,     setPmList]     = useState<any[]>([])
  const [pmLoading,  setPmLoading]  = useState(false)
  const [editPm,     setEditPm]     = useState<any>(null)
  const [editPmForm, setEditPmForm] = useState<PmEntry>(EMPTY_PM_ENTRY())
  const [pmSaving,   setPmSaving]   = useState(false)

  // ── loaders ────────────────────────────────────────────────────────────────
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

  const loadPM = async (hotelId: number) => {
    setPmLoading(true)
    try { const res = await adminService.getHotelPaymentMethods(hotelId); setPmList(res.data.data || []) }
    catch { setPmList([]) }
    setPmLoading(false)
  }

  // ── open/close create modal ────────────────────────────────────────────────
  const openCreate = () => {
    setForm({ ...EMPTY_MGR }); setErrs({ ...EMPTY_ERRS })
    setPmEntries([]); setNewPm(EMPTY_PM_ENTRY()); setShowPmForm(false)
    setShowCreate(true)
  }
  const closeCreate = () => {
    setShowCreate(false); setPmEntries([]); setNewPm(EMPTY_PM_ENTRY()); setShowPmForm(false)
  }

  // ── manager field helpers ──────────────────────────────────────────────────
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
    setErrs(next); return !hasErrors(next)
  }

  // ── payment entry helpers (inside create form) ─────────────────────────────
  const validateNewPm = () => {
    const next = {
      method:       !newPm.method ? 'Select a payment method' : null,
      account_name: !newPm.account_name.trim() ? 'Account name is required' : null,
    }
    setPmErrs(next)
    if (next.method || next.account_name) return false
    if (!newPm.phone_number.trim() && !newPm.account_number.trim()) {
      toast.error('Enter phone number or account number'); return false
    }
    return true
  }

  const addPmEntry = () => {
    if (!validateNewPm()) return
    // prevent duplicate method
    if (pmEntries.some(p => p.method === newPm.method)) {
      toast.error('This payment method is already added'); return
    }
    setPmEntries(prev => [...prev, { ...newPm }])
    setNewPm(EMPTY_PM_ENTRY())
    setPmErrs({ method: null, account_name: null })
    setShowPmForm(false)
    toast.success(`${PM_OPTIONS.find(o => o.value === newPm.method)?.label} added ✓`)
  }

  const removePmEntry = (index: number) =>
    setPmEntries(prev => prev.filter((_, i) => i !== index))

  // ── create manager ─────────────────────────────────────────────────────────
  const handleCreate = async () => {
    if (!validate()) return
    setSubmitting(true)
    try {
      await adminService.createManager({ ...form, payment_methods: pmEntries })
      toast.success(`Manager created${pmEntries.length > 0 ? ` with ${pmEntries.length} payment method${pmEntries.length > 1 ? 's' : ''}` : ''}`)
      closeCreate(); load()
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

  // ── existing manager payment config ───────────────────────────────────────
  const openPM = async (hotel: any) => {
    setPmHotel(hotel); setEditPm(null); setEditPmForm(EMPTY_PM_ENTRY())
    setShowPM(true); await loadPM(hotel.id)
  }
  const savePM = async () => {
    if (!editPmForm.method) { toast.error('Select a payment method'); return }
    if (!editPmForm.account_name.trim()) { toast.error('Account name is required'); return }
    if (!editPmForm.phone_number.trim() && !editPmForm.account_number.trim()) {
      toast.error('Enter phone number or account number'); return
    }
    setPmSaving(true)
    try {
      if (editPm) {
        await adminService.updatePaymentMethod(editPm.id, { ...editPmForm, is_active: true })
        toast.success('Payment method updated')
      } else {
        await adminService.addPaymentMethod(pmHotel.id, editPmForm)
        toast.success('Payment method added')
      }
      setEditPm(null); setEditPmForm(EMPTY_PM_ENTRY()); await loadPM(pmHotel.id)
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to save')
    }
    setPmSaving(false)
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Hotel Managers"
        subtitle="Create managers and configure their hotel's payment accounts"
        action={
          <button onClick={openCreate}
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
          { key: 'actions', label: 'Actions', render: (r) => (
            <div className="flex items-center gap-2">
              <button onClick={() => openPM({ id: r.hotel_id, name: r.hotel_name })}
                className="flex items-center gap-1 text-xs bg-purple-50 text-purple-700 px-2.5 py-1.5 rounded-lg hover:bg-purple-100 transition-colors font-medium">
                <CreditCard size={13} /> Payment
              </button>
              <button onClick={() => handleDelete(r.id)}
                className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
                <Trash2 size={16} />
              </button>
            </div>
          )},
        ]}
        data={managers}
        emptyTitle="No managers yet"
        emptySubtitle="Add a manager to start managing rooms and payments"
      />

      {/* ══════════════════════════════════════════════════════════════════════
          CREATE MANAGER MODAL
      ══════════════════════════════════════════════════════════════════════ */}
      <Modal open={showCreate} onClose={closeCreate} title="Add Hotel Manager" size="lg">
        <div className="space-y-5">

          {/* ── Section 1: Manager account ──────────────────────────────── */}
          <div className="space-y-4">
            <div className="flex items-center gap-2 pb-2 border-b border-gray-100">
              <div className="w-6 h-6 rounded-full bg-blue-600 text-white flex items-center justify-center text-xs font-bold flex-shrink-0">1</div>
              <h3 className="font-semibold text-gray-800 text-sm">Manager Account Details</h3>
            </div>

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
                <label className="block text-sm font-medium text-gray-700 mb-1">Phone <span className="text-gray-400 font-normal text-xs">(optional)</span></label>
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
          </div>

          {/* ── Section 2: Payment accounts ─────────────────────────────── */}
          <div className="space-y-3">
            <div className="flex items-center gap-2 pb-2 border-b border-gray-100">
              <div className="w-6 h-6 rounded-full bg-purple-600 text-white flex items-center justify-center text-xs font-bold flex-shrink-0">2</div>
              <h3 className="font-semibold text-gray-800 text-sm">Hotel Payment Accounts</h3>
              <span className="text-xs text-gray-400 font-normal">(shown to guests when paying)</span>
            </div>

            {/* Added entries list */}
            <AnimatePresence>
              {pmEntries.map((pm, idx) => {
                const opt = PM_OPTIONS.find(o => o.value === pm.method)
                return (
                  <motion.div key={idx}
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: 'auto' }}
                    exit={{ opacity: 0, height: 0 }}
                    className="overflow-hidden">
                    <div className="flex items-start gap-3 bg-purple-50 border border-purple-200 rounded-xl px-4 py-3">
                      <span className="text-xl flex-shrink-0 mt-0.5">{opt?.logo || '🏦'}</span>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-sm text-purple-900">{opt?.label || pm.method}</p>
                        <div className="flex flex-wrap gap-x-4 gap-y-0.5 mt-1">
                          <span className="text-xs text-purple-700 flex items-center gap-1">
                            <Check size={10} /> {pm.account_name}
                          </span>
                          {pm.phone_number && (
                            <span className="text-xs text-purple-700 flex items-center gap-1">
                              <Phone size={10} /> {pm.phone_number}
                            </span>
                          )}
                          {pm.account_number && (
                            <span className="text-xs text-purple-700 flex items-center gap-1">
                              <Hash size={10} /> {pm.account_number}
                            </span>
                          )}
                          {pm.instructions && (
                            <span className="text-xs text-purple-500 italic truncate max-w-xs">{pm.instructions}</span>
                          )}
                        </div>
                      </div>
                      <button onClick={() => removePmEntry(idx)}
                        className="text-purple-400 hover:text-red-500 p-1 rounded-lg hover:bg-red-50 transition-colors flex-shrink-0">
                        <X size={15} />
                      </button>
                    </div>
                  </motion.div>
                )
              })}
            </AnimatePresence>

            {/* Add payment method toggle */}
            {!showPmForm ? (
              <button onClick={() => setShowPmForm(true)}
                className="w-full flex items-center justify-center gap-2 border-2 border-dashed border-purple-200 text-purple-600 hover:border-purple-400 hover:bg-purple-50 rounded-xl py-3 text-sm font-medium transition-all">
                <Plus size={16} /> Add Payment Method
              </button>
            ) : (
              <motion.div
                initial={{ opacity: 0, y: -8 }}
                animate={{ opacity: 1, y: 0 }}
                className="border border-purple-200 bg-purple-50/60 rounded-xl p-4 space-y-3">
                <div className="flex items-center justify-between mb-1">
                  <h4 className="text-sm font-semibold text-purple-800 flex items-center gap-1.5">
                    <CreditCard size={14} /> New Payment Method
                  </h4>
                  <button onClick={() => { setShowPmForm(false); setNewPm(EMPTY_PM_ENTRY()); setPmErrs({ method: null, account_name: null }) }}
                    className="text-gray-400 hover:text-gray-600 p-1 rounded">
                    <X size={14} />
                  </button>
                </div>

                {/* Method selector */}
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Payment Method *</label>
                  <select value={newPm.method}
                    onChange={e => { setNewPm(p => ({ ...p, method: e.target.value })); setPmErrs(er => ({ ...er, method: null })) }}
                    className={`w-full border rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white ${pmErrs.method ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}>
                    <option value="">Select method…</option>
                    {PM_OPTIONS.filter(o => !pmEntries.some(p => p.method === o.value)).map(o => (
                      <option key={o.value} value={o.value}>{o.logo} {o.label}</option>
                    ))}
                  </select>
                  <Err msg={pmErrs.method} />
                  {newPm.method && (
                    <p className="text-xs text-purple-600 mt-0.5 flex items-center gap-1">
                      <Info size={10} /> {PM_OPTIONS.find(o => o.value === newPm.method)?.hint}
                    </p>
                  )}
                </div>

                {/* Account name */}
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">
                    Account Name * <span className="text-gray-400 font-normal">(shown to guest)</span>
                  </label>
                  <input value={newPm.account_name}
                    onChange={e => { setNewPm(p => ({ ...p, account_name: e.target.value })); setPmErrs(er => ({ ...er, account_name: null })) }}
                    placeholder="e.g. Sheraton Addis Hotel"
                    className={`w-full border rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white ${pmErrs.account_name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`} />
                  <Err msg={pmErrs.account_name} />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  {/* Phone number */}
                  <div>
                    <label className="block text-xs font-semibold text-gray-700 mb-1">
                      <Phone size={11} className="inline mr-1 text-blue-500" />
                      Phone / Wallet No.
                    </label>
                    <input value={newPm.phone_number}
                      onChange={e => setNewPm(p => ({ ...p, phone_number: e.target.value.replace(/[^\d+]/g, '') }))}
                      placeholder="09XXXXXXXX" maxLength={13}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white font-mono" />
                    <p className="text-[10px] text-gray-400 mt-0.5">For Telebirr, CBE Birr, etc.</p>
                  </div>

                  {/* Account number */}
                  <div>
                    <label className="block text-xs font-semibold text-gray-700 mb-1">
                      <Hash size={11} className="inline mr-1 text-purple-500" />
                      Account Number
                    </label>
                    <input value={newPm.account_number}
                      onChange={e => setNewPm(p => ({ ...p, account_number: e.target.value }))}
                      placeholder="e.g. 1000123456789"
                      className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white font-mono" />
                    <p className="text-[10px] text-gray-400 mt-0.5">For Awash, Abyssinia, etc.</p>
                  </div>
                </div>

                {/* Instructions */}
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">
                    Instructions <span className="text-gray-400 font-normal">(optional)</span>
                  </label>
                  <textarea value={newPm.instructions}
                    onChange={e => setNewPm(p => ({ ...p, instructions: e.target.value }))}
                    rows={2} placeholder="e.g. Include your booking reference in the transfer note"
                    className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white resize-none" />
                </div>

                <button onClick={addPmEntry}
                  className="w-full bg-purple-600 text-white py-2 rounded-lg text-sm font-semibold hover:bg-purple-700 transition-colors flex items-center justify-center gap-2">
                  <Plus size={15} /> Add This Payment Method
                </button>
              </motion.div>
            )}

            {pmEntries.length === 0 && !showPmForm && (
              <div className="flex items-start gap-2 bg-amber-50 border border-amber-100 rounded-lg px-3 py-2.5 text-xs text-amber-700">
                <Info size={13} className="flex-shrink-0 mt-0.5" />
                <span>No payment methods added yet — guests won't be able to pay until at least one is configured. You can also add them later via the <strong>Payment</strong> button on the manager row.</span>
              </div>
            )}
          </div>

          {/* ── Summary + Submit ─────────────────────────────────────────── */}
          {pmEntries.length > 0 && (
            <div className="bg-emerald-50 border border-emerald-200 rounded-xl px-4 py-3 text-sm text-emerald-800 flex items-center gap-2">
              <Check size={15} className="text-emerald-600 flex-shrink-0" />
              <span>
                <strong>{pmEntries.length}</strong> payment method{pmEntries.length > 1 ? 's' : ''} will be saved:&nbsp;
                {pmEntries.map(p => PM_OPTIONS.find(o => o.value === p.method)?.label).join(', ')}
              </span>
            </div>
          )}

          <button onClick={handleCreate} disabled={submitting}
            className="w-full bg-blue-600 text-white py-3 rounded-xl hover:bg-blue-700 transition-colors font-bold text-sm disabled:opacity-60 flex items-center justify-center gap-2">
            {submitting
              ? <><div className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Creating…</>
              : <><UserPlus size={16} /> Create Manager {pmEntries.length > 0 ? `+ ${pmEntries.length} Payment Method${pmEntries.length > 1 ? 's' : ''}` : ''}</>
            }
          </button>
        </div>
      </Modal>

      {/* ══════════════════════════════════════════════════════════════════════
          PAYMENT CONFIG MODAL (for existing managers)
      ══════════════════════════════════════════════════════════════════════ */}
      <Modal
        open={showPM}
        onClose={() => { setShowPM(false); setPmHotel(null); setEditPm(null); setEditPmForm(EMPTY_PM_ENTRY()) }}
        title={`Payment Accounts — ${pmHotel?.name || ''}`}
        size="lg">
        <div className="space-y-4">
          <p className="text-sm text-gray-500">
            These accounts are shown to guests on the payment screen.
            The phone number or account number they see here is where they send payment.
          </p>

          {pmLoading ? (
            <div className="flex items-center justify-center py-8 gap-2 text-gray-400">
              <div className="w-5 h-5 border-2 border-purple-300 border-t-purple-600 rounded-full animate-spin" />
              Loading…
            </div>
          ) : pmList.length === 0 ? (
            <p className="text-gray-400 text-sm text-center py-4">No payment methods yet — add one below.</p>
          ) : (
            <div className="space-y-2">
              {pmList.map((pm: any) => {
                const opt = PM_OPTIONS.find(o => o.value === pm.method)
                const isEditing = editPm?.id === pm.id
                return (
                  <motion.div key={pm.id} layout
                    className={`rounded-xl border px-4 py-3 transition-all ${isEditing ? 'border-purple-400 bg-purple-50' : 'border-gray-200 bg-gray-50'}`}>
                    <div className="flex items-start gap-3">
                      <span className="text-xl flex-shrink-0 mt-0.5">{opt?.logo || '🏦'}</span>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-sm text-gray-800">{opt?.label || pm.method}</p>
                        <div className="flex flex-wrap gap-x-3 gap-y-0.5 mt-0.5">
                          {pm.account_name && <span className="text-xs text-gray-500"><Check size={10} className="inline text-emerald-500" /> {pm.account_name}</span>}
                          {pm.phone_number  && <span className="text-xs text-gray-500"><Phone size={10} className="inline text-blue-500" /> {pm.phone_number}</span>}
                          {pm.account_number && <span className="text-xs text-gray-500"><Hash size={10} className="inline text-purple-500" /> {pm.account_number}</span>}
                        </div>
                      </div>
                      <button onClick={() => {
                        if (isEditing) { setEditPm(null); setEditPmForm(EMPTY_PM_ENTRY()) }
                        else { setEditPm(pm); setEditPmForm({ method: pm.method, account_name: pm.account_name || '', phone_number: pm.phone_number || '', account_number: pm.account_number || '', instructions: pm.instructions || '' }) }
                      }}
                        className="p-1.5 text-blue-500 hover:text-blue-700 hover:bg-blue-100 rounded-lg transition-colors flex-shrink-0">
                        {isEditing ? <ChevronUp size={15} /> : <Pencil size={14} />}
                      </button>
                    </div>

                    {/* Inline edit form */}
                    <AnimatePresence>
                      {isEditing && (
                        <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
                          className="overflow-hidden">
                          <div className="mt-3 pt-3 border-t border-purple-200 space-y-3">
                            <div>
                              <label className="block text-xs font-semibold text-gray-700 mb-1">Account Name *</label>
                              <input value={editPmForm.account_name} onChange={e => setEditPmForm(f => ({ ...f, account_name: e.target.value }))}
                                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white" />
                            </div>
                            <div className="grid grid-cols-2 gap-3">
                              <div>
                                <label className="block text-xs font-semibold text-gray-700 mb-1"><Phone size={10} className="inline mr-1 text-blue-500" />Phone / Wallet</label>
                                <input value={editPmForm.phone_number}
                                  onChange={e => setEditPmForm(f => ({ ...f, phone_number: e.target.value.replace(/[^\d+]/g, '') }))}
                                  maxLength={13} className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white font-mono" />
                              </div>
                              <div>
                                <label className="block text-xs font-semibold text-gray-700 mb-1"><Hash size={10} className="inline mr-1 text-purple-500" />Account Number</label>
                                <input value={editPmForm.account_number}
                                  onChange={e => setEditPmForm(f => ({ ...f, account_number: e.target.value }))}
                                  className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white font-mono" />
                              </div>
                            </div>
                            <div>
                              <label className="block text-xs font-semibold text-gray-700 mb-1">Instructions</label>
                              <textarea value={editPmForm.instructions}
                                onChange={e => setEditPmForm(f => ({ ...f, instructions: e.target.value }))}
                                rows={2} className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white resize-none" />
                            </div>
                            <div className="flex gap-2">
                              <button onClick={() => { setEditPm(null); setEditPmForm(EMPTY_PM_ENTRY()) }}
                                className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-600 hover:bg-gray-100 transition-colors">Cancel</button>
                              <button onClick={savePM} disabled={pmSaving}
                                className="flex-1 bg-purple-600 text-white py-2 rounded-lg text-sm font-semibold hover:bg-purple-700 transition-colors disabled:opacity-60">
                                {pmSaving ? 'Saving…' : '✓ Save Changes'}
                              </button>
                            </div>
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </motion.div>
                )
              })}
            </div>
          )}

          {/* Add new method */}
          {!editPm && (
            <div className="border border-gray-200 rounded-xl p-4 space-y-3 bg-gray-50">
              <h4 className="text-sm font-semibold text-gray-700 flex items-center gap-2"><Plus size={14} className="text-purple-600" /> Add New Method</h4>
              <select value={editPmForm.method} onChange={e => setEditPmForm(f => ({ ...f, method: e.target.value }))}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white">
                <option value="">Select method…</option>
                {PM_OPTIONS.filter(o => !pmList.some((p: any) => p.method === o.value)).map(o => (
                  <option key={o.value} value={o.value}>{o.logo} {o.label}</option>
                ))}
              </select>
              <input value={editPmForm.account_name} onChange={e => setEditPmForm(f => ({ ...f, account_name: e.target.value }))}
                placeholder="Account name *"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white" />
              <div className="grid grid-cols-2 gap-3">
                <input value={editPmForm.phone_number}
                  onChange={e => setEditPmForm(f => ({ ...f, phone_number: e.target.value.replace(/[^\d+]/g, '') }))}
                  placeholder="Phone / wallet no." maxLength={13}
                  className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white font-mono" />
                <input value={editPmForm.account_number}
                  onChange={e => setEditPmForm(f => ({ ...f, account_number: e.target.value }))}
                  placeholder="Account number"
                  className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white font-mono" />
              </div>
              <textarea value={editPmForm.instructions}
                onChange={e => setEditPmForm(f => ({ ...f, instructions: e.target.value }))}
                rows={2} placeholder="Instructions (optional)"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-purple-400 bg-white resize-none" />
              <button onClick={savePM} disabled={pmSaving}
                className="w-full bg-purple-600 text-white py-2 rounded-lg text-sm font-semibold hover:bg-purple-700 transition-colors disabled:opacity-60">
                {pmSaving ? 'Saving…' : '+ Add Payment Method'}
              </button>
            </div>
          )}
        </div>
      </Modal>
    </AdminLayout>
  )
}

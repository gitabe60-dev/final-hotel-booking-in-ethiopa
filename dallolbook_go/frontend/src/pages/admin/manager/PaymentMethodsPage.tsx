// pages/admin/manager/PaymentMethodsPage.tsx
// Hotel manager can add, edit, delete payment methods for their hotel.
// These accounts are shown to guests on the booking payment screen.
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  CreditCard, Plus, Pencil, Trash2, Phone, Hash,
  Check, X, Info, RefreshCw, Eye, EyeOff,
} from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'

// ── All Ethiopian payment methods ─────────────────────────────────────────────
const PM_OPTIONS = [
  { value: 'telebirr',     label: 'Telebirr',           logo: '📱', color: 'bg-green-500',   type: 'mobile'  },
  { value: 'cbe_birr',    label: 'CBE Birr',            logo: '🏦', color: 'bg-amber-500',   type: 'mobile'  },
  { value: 'chapa',       label: 'Chapa',               logo: '🔵', color: 'bg-blue-500',    type: 'online'  },
  { value: 'awash_bank',  label: 'Awash Bank',          logo: '🏦', color: 'bg-purple-500',  type: 'bank'    },
  { value: 'abyssinia',   label: 'Bank of Abyssinia',   logo: '🏦', color: 'bg-rose-500',    type: 'bank'    },
  { value: 'dashen',      label: 'Dashen Bank',         logo: '🏦', color: 'bg-teal-500',    type: 'bank'    },
  { value: 'oromia_coop', label: 'Oromia Bank',         logo: '🏦', color: 'bg-orange-500',  type: 'bank'    },
  { value: 'united',      label: 'United Bank',         logo: '🏦', color: 'bg-indigo-500',  type: 'bank'    },
  { value: 'nib',         label: 'NIB International',   logo: '🏦', color: 'bg-lime-600',    type: 'bank'    },
  { value: 'wegagen',     label: 'Wegagen Bank',        logo: '🏦', color: 'bg-cyan-600',    type: 'bank'    },
  { value: 'bunna',       label: 'Bunna Bank',          logo: '🏦', color: 'bg-fuchsia-500', type: 'bank'    },
]

const EMPTY_FORM = {
  method: '', account_name: '', phone_number: '', account_number: '', instructions: '', is_active: true,
}

function PmBadge({ method }: { method: string }) {
  const opt = PM_OPTIONS.find(o => o.value === method)
  if (!opt) return null
  return (
    <span className={`inline-flex items-center gap-1.5 text-white text-xs font-bold px-2.5 py-1 rounded-full ${opt.color}`}>
      {opt.logo} {opt.label}
    </span>
  )
}

export default function ManagerPaymentMethodsPage() {
  const [methods,    setMethods]    = useState<any[]>([])
  const [loading,    setLoading]    = useState(true)
  const [showForm,   setShowForm]   = useState(false)
  const [editing,    setEditing]    = useState<any>(null)
  const [form,       setForm]       = useState({ ...EMPTY_FORM })
  const [submitting, setSubmitting] = useState(false)
  const [deleting,   setDeleting]   = useState<number | null>(null)
  const [revealed,   setRevealed]   = useState<Record<number, boolean>>({}) // show/hide account numbers

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.managerGetPaymentMethods()
      setMethods(res.data.data || [])
    } catch { toast.error('Failed to load payment methods') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  // All 11 methods always available — multiple accounts per method allowed
  const available = PM_OPTIONS

  const setField = (k: keyof typeof form, v: string | boolean) =>
    setForm(f => ({ ...f, [k]: v }))

  const openAdd = () => {
    setForm({ ...EMPTY_FORM })
    setEditing(null)
    setShowForm(true)
  }

  const openEdit = (pm: any) => {
    setForm({
      method:         pm.method,
      account_name:   pm.account_name   || '',
      phone_number:   pm.phone_number   || '',
      account_number: pm.account_number || '',
      instructions:   pm.instructions   || '',
      is_active:      pm.is_active,
    })
    setEditing(pm)
    setShowForm(true)
  }

  const validate = () => {
    if (!form.method) { toast.error('Select a payment method'); return false }
    if (!form.account_name.trim()) { toast.error('Account name is required'); return false }
    if (!form.phone_number.trim() && !form.account_number.trim()) {
      toast.error('Enter phone number or account number — at least one is required')
      return false
    }
    return true
  }

  const handleSave = async () => {
    if (!validate()) return
    setSubmitting(true)
    try {
      if (editing) {
        await adminService.managerUpdatePaymentMethod(editing.id, {
          account_name:   form.account_name,
          phone_number:   form.phone_number,
          account_number: form.account_number,
          instructions:   form.instructions,
          is_active:      form.is_active,
        })
        toast.success('Payment method updated')
      } else {
        await adminService.managerAddPaymentMethod(form)
        toast.success(`${PM_OPTIONS.find(o => o.value === form.method)?.label} added`)
      }
      setShowForm(false)
      setEditing(null)
      setForm({ ...EMPTY_FORM })
      load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to save')
    }
    setSubmitting(false)
  }

  const handleDelete = async (id: number, label: string) => {
    if (!confirm(`Remove ${label}? Guests won't see this payment option anymore.`)) return
    setDeleting(id)
    try {
      await adminService.managerDeletePaymentMethod(id)
      toast.success(`${label} removed`)
      load()
    } catch { toast.error('Failed to remove') }
    setDeleting(null)
  }

  const toggleReveal = (id: number) =>
    setRevealed(r => ({ ...r, [id]: !r[id] }))

  const selectedOpt = PM_OPTIONS.find(o => o.value === form.method)

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="hotel_manager">
      <PageHeader
        title="Payment Methods"
        subtitle="Add the payment accounts guests use to pay for bookings at your hotel"
        action={
          <div className="flex items-center gap-2">
            <button onClick={load}
              className="border border-gray-200 bg-white text-gray-600 px-3 py-2 rounded-lg hover:bg-gray-50 text-sm flex items-center gap-1.5 transition-colors">
              <RefreshCw size={14} /> Refresh
            </button>
            <button onClick={openAdd}
              className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
              <Plus size={16} /> Add Payment Method
            </button>
          </div>
        }
      />

      {/* Info banner */}
      <div className="flex items-start gap-3 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 mb-6 text-sm text-blue-700">
        <Info size={16} className="flex-shrink-0 mt-0.5" />
        <div>
          <p className="font-semibold">How this works</p>
          <p className="text-xs text-blue-600 mt-0.5">
            When a guest books your hotel and goes to the payment step, they see all the methods you add here.
            They click the method they want (e.g. Telebirr) and see your <strong>phone number</strong> or <strong>account number</strong> to send payment to.
            You can add <strong>multiple accounts</strong> for the same method (e.g. two Telebirr numbers).
          </p>
        </div>
      </div>

      {/* ── Methods list ── */}
      {methods.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-xl border border-gray-100 shadow-sm">
          <CreditCard size={48} className="mx-auto text-gray-300 mb-3" />
          <p className="text-gray-500 font-semibold text-lg">No payment methods yet</p>
          <p className="text-gray-400 text-sm mt-1 mb-5">Add your first payment method so guests can pay for bookings.</p>
          <button onClick={openAdd}
            className="inline-flex items-center gap-2 bg-blue-600 text-white px-5 py-2.5 rounded-xl hover:bg-blue-700 transition-colors text-sm font-semibold">
            <Plus size={16} /> Add First Payment Method
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <AnimatePresence>
            {methods.map((pm, i) => {
              const opt = PM_OPTIONS.find(o => o.value === pm.method)
              const show = revealed[pm.id]
              const busy = deleting === pm.id

              return (
                <motion.div key={pm.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ delay: i * 0.05 }}
                  className={`bg-white rounded-2xl border shadow-sm overflow-hidden transition-all ${
                    pm.is_active ? 'border-gray-100' : 'border-gray-200 opacity-60'
                  } ${busy ? 'opacity-40' : ''}`}>

                  {/* Card header */}
                  <div className={`${opt?.color || 'bg-gray-500'} px-5 py-4 flex items-center justify-between`}>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-xl bg-white/20 backdrop-blur flex items-center justify-center text-xl">
                        {opt?.logo || '🏦'}
                      </div>
                      <div>
                        <p className="text-white font-extrabold">{opt?.label || pm.method}</p>
                        <p className="text-white/70 text-xs capitalize">{opt?.type || 'payment'}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${
                        pm.is_active ? 'bg-white/20 text-white' : 'bg-white/10 text-white/60'
                      }`}>
                        {pm.is_active ? '✓ Active' : 'Inactive'}
                      </span>
                    </div>
                  </div>

                  {/* Card body */}
                  <div className="p-4 space-y-2">
                    {/* Account name */}
                    {pm.account_name && (
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-gray-500 text-xs font-medium uppercase tracking-wide">Account Name</span>
                        <span className="font-semibold text-gray-800">{pm.account_name}</span>
                      </div>
                    )}

                    {/* Phone */}
                    {pm.phone_number && (
                      <div className="flex items-center justify-between bg-gray-50 rounded-xl px-3 py-2">
                        <div className="flex items-center gap-2">
                          <Phone size={14} className="text-blue-500" />
                          <div>
                            <p className="text-[10px] text-gray-400 uppercase font-semibold tracking-wide">Phone / Wallet</p>
                            <p className="font-mono font-bold text-gray-800 text-sm">
                              {show ? pm.phone_number : pm.phone_number.replace(/\d(?=\d{4})/g, '•')}
                            </p>
                          </div>
                        </div>
                        <button onClick={() => toggleReveal(pm.id)}
                          className="p-1.5 text-gray-400 hover:text-gray-600 transition-colors">
                          {show ? <EyeOff size={14} /> : <Eye size={14} />}
                        </button>
                      </div>
                    )}

                    {/* Account number */}
                    {pm.account_number && (
                      <div className="flex items-center justify-between bg-gray-50 rounded-xl px-3 py-2">
                        <div className="flex items-center gap-2">
                          <Hash size={14} className="text-purple-500" />
                          <div>
                            <p className="text-[10px] text-gray-400 uppercase font-semibold tracking-wide">Account Number</p>
                            <p className="font-mono font-bold text-gray-800 text-sm">
                              {show ? pm.account_number : pm.account_number.replace(/\d(?=\d{4})/g, '•')}
                            </p>
                          </div>
                        </div>
                        <button onClick={() => toggleReveal(pm.id)}
                          className="p-1.5 text-gray-400 hover:text-gray-600 transition-colors">
                          {show ? <EyeOff size={14} /> : <Eye size={14} />}
                        </button>
                      </div>
                    )}

                    {/* Instructions */}
                    {pm.instructions && (
                      <p className="text-xs text-gray-500 italic px-1">{pm.instructions}</p>
                    )}

                    {/* Actions */}
                    <div className="flex gap-2 pt-1">
                      <button onClick={() => openEdit(pm)}
                        className="flex-1 flex items-center justify-center gap-1.5 border border-gray-200 text-gray-600 hover:bg-gray-50 text-sm font-medium py-2 rounded-xl transition-colors">
                        <Pencil size={13} /> Edit
                      </button>
                      <button onClick={() => handleDelete(pm.id, opt?.label || pm.method)}
                        disabled={busy}
                        className="flex-1 flex items-center justify-center gap-1.5 border border-red-100 text-red-500 hover:bg-red-50 text-sm font-medium py-2 rounded-xl transition-colors disabled:opacity-40">
                        <Trash2 size={13} /> Remove
                      </button>
                    </div>
                  </div>
                </motion.div>
              )
            })}
          </AnimatePresence>
        </div>
      )}

      {/* ── Add / Edit slide-in form panel ── */}
      <AnimatePresence>
        {showForm && (
          <>
            {/* Backdrop */}
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/40 z-40"
              onClick={() => { setShowForm(false); setEditing(null) }} />

            {/* Panel */}
            <motion.div
              initial={{ x: '100%' }} animate={{ x: 0 }} exit={{ x: '100%' }}
              transition={{ type: 'spring', stiffness: 300, damping: 30 }}
              className="fixed right-0 top-0 h-full w-full max-w-md bg-white shadow-2xl z-50 overflow-y-auto">

              {/* Panel header */}
              <div className="sticky top-0 bg-white border-b border-gray-100 px-6 py-4 flex items-center justify-between">
                <div>
                  <h2 className="font-bold text-gray-900 text-lg">
                    {editing ? 'Edit Payment Method' : 'Add Payment Method'}
                  </h2>
                  {editing && <PmBadge method={editing.method} />}
                </div>
                <button onClick={() => { setShowForm(false); setEditing(null) }}
                  className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition-colors">
                  <X size={20} />
                </button>
              </div>

              <div className="p-6 space-y-5">

                {/* Method selector (only for new) */}
                {!editing && (
                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">Payment Method *</label>
                    <div className="grid grid-cols-2 gap-2 max-h-64 overflow-y-auto pr-1">
                      {available.map(opt => (
                        <button key={opt.value}
                          onClick={() => setField('method', opt.value)}
                          className={`flex items-center gap-2 p-3 rounded-xl border-2 text-left transition-all ${
                            form.method === opt.value
                              ? 'border-blue-500 bg-blue-50'
                              : 'border-gray-200 hover:border-blue-300 hover:bg-gray-50'
                          }`}>
                          <div className={`w-8 h-8 rounded-lg ${opt.color} flex items-center justify-center flex-shrink-0`}>
                            <span className="text-base">{opt.logo}</span>
                          </div>
                          <span className={`text-xs font-semibold leading-tight ${
                            form.method === opt.value ? 'text-blue-700' : 'text-gray-700'
                          }`}>{opt.label}</span>
                          {form.method === opt.value && <Check size={12} className="text-blue-600 ml-auto flex-shrink-0" />}
                        </button>
                      ))}
                    </div>

                  </div>
                )}

                {/* ── Fields (shown after method selected or while editing) ── */}
                {(form.method || editing) && (
                  <div className="space-y-4">
                    {/* Hint about field types */}
                    {selectedOpt && !editing && (
                      <div className="bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 text-xs text-blue-700 flex items-start gap-2">
                        <Info size={13} className="flex-shrink-0 mt-0.5" />
                        <span>
                          {selectedOpt.type === 'mobile'
                            ? 'Mobile wallet — fill in your phone / wallet number'
                            : selectedOpt.type === 'bank'
                            ? 'Bank transfer — fill in your bank account number'
                            : 'Online gateway — account name is sufficient'}
                        </span>
                      </div>
                    )}

                    {/* Account name */}
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1.5">
                        Account Name * <span className="text-gray-400 font-normal text-xs">(shown to guest)</span>
                      </label>
                      <input value={form.account_name}
                        onChange={e => setField('account_name', e.target.value)}
                        placeholder="e.g. Sheraton Addis Hotel"
                        className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent" />
                    </div>

                    {/* Phone number */}
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1.5 flex items-center gap-1">
                        <Phone size={13} className="text-blue-500" /> Phone / Wallet Number
                      </label>
                      <input value={form.phone_number}
                        onChange={e => setField('phone_number', e.target.value.replace(/[^\d+]/g, ''))}
                        placeholder="e.g. 0912345678"
                        maxLength={13}
                        className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-400 font-mono" />
                      <p className="text-xs text-gray-400 mt-1">Required for Telebirr, CBE Birr — digits only</p>
                    </div>

                    {/* Account number */}
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1.5 flex items-center gap-1">
                        <Hash size={13} className="text-purple-500" /> Account Number
                      </label>
                      <input value={form.account_number}
                        onChange={e => setField('account_number', e.target.value)}
                        placeholder="e.g. 1000123456789"
                        className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-400 font-mono" />
                      <p className="text-xs text-gray-400 mt-1">Required for Awash, Abyssinia, Dashen and other banks</p>
                    </div>

                    {/* Instructions */}
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-1.5">
                        Instructions <span className="text-gray-400 font-normal text-xs">(optional — shown to guest)</span>
                      </label>
                      <textarea value={form.instructions}
                        onChange={e => setField('instructions', e.target.value)}
                        rows={3}
                        placeholder="e.g. Include your booking reference number in the transfer note"
                        className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-blue-400 resize-none" />
                    </div>

                    {/* Active toggle (edit only) */}
                    {editing && (
                      <div className="flex items-center justify-between bg-gray-50 rounded-xl px-4 py-3">
                        <div>
                          <p className="text-sm font-semibold text-gray-700">Visible to guests</p>
                          <p className="text-xs text-gray-400">Disable to hide without deleting</p>
                        </div>
                        <button onClick={() => setField('is_active', !form.is_active)}
                          className={`relative w-12 h-6 rounded-full transition-colors ${form.is_active ? 'bg-blue-600' : 'bg-gray-300'}`}>
                          <span className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform ${form.is_active ? 'left-6' : 'left-0.5'}`} />
                        </button>
                      </div>
                    )}
                  </div>
                )}

                {/* Save button */}
                <button onClick={handleSave}
                  disabled={submitting || (!form.method && !editing)}
                  className="w-full bg-blue-600 text-white py-3 rounded-xl font-bold text-sm hover:bg-blue-700 active:scale-[.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2">
                  {submitting
                    ? <><div className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Saving…</>
                    : <><Check size={16} /> {editing ? 'Save Changes' : 'Add Payment Method'}</>
                  }
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </AdminLayout>
  )
}

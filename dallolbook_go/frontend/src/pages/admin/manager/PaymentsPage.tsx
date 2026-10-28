// pages/admin/manager/PaymentsPage.tsx — Hotel manager: full guest info + national ID verification
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  CheckCircle, XCircle, ExternalLink, CreditCard, User,
  Phone, Mail, IdCard, Calendar, Bed, DollarSign,
  ChevronDown, ChevronUp, Image as ImgIcon, Clock
} from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Badge from '../../../components/shared/Badge'
import Spinner from '../../../components/shared/Spinner'
import EmptyState from '../../../components/shared/EmptyState'
import Modal from '../../../components/shared/Modal'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

const STATUS_COLOR: Record<string, string> = {
  submitted: 'border-amber-300 bg-amber-50',
  completed: 'border-emerald-300 bg-emerald-50',
  failed:    'border-red-300 bg-red-50',
  pending:   'border-gray-200 bg-white',
}

const PM_LABELS: Record<string, string> = {
  telebirr:     'Telebirr',
  cbe_birr:     'CBE Birr',
  chapa:        'Chapa',
  bank_transfer:'CBE Transfer',
  awash_bank:   'Awash Bank',
  abyssinia:    'Bank of Abyssinia',
  dashen:       'Dashen Bank',
  oromia_coop:  'Oromia Bank',
  united:       'United Bank',
  nib:          'NIB International',
  wegagen:      'Wegagen Bank',
  bunna:        'Bunna Bank',
  cooperative:  'Cooperative Bank',
}

export default function ManagerPaymentsPage() {
  const [payments, setPayments] = useState<any[]>([])
  const [loading, setLoading]   = useState(true)
  const [filter, setFilter]     = useState<'all' | 'submitted' | 'completed' | 'failed' | 'pending'>('all')
  const [expanded, setExpanded] = useState<number | null>(null)
  const [lightbox, setLightbox] = useState<{ src: string; title: string } | null>(null)

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.managerPayments()
      setPayments(res.data.data || [])
    } catch { toast.error('Failed to load payments') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleVerify = async (id: number, status: 'approved' | 'rejected') => {
    if (!confirm(`${status === 'approved' ? 'APPROVE' : 'REJECT'} this payment?`)) return
    try {
      await adminService.verifyPayment(id, status)
      toast.success(`Payment ${status}`)
      load()
    } catch { toast.error('Failed to verify payment') }
  }

  const filtered = filter === 'all' ? payments : payments.filter(p => p.status === filter)

  const counts = {
    all:       payments.length,
    submitted: payments.filter(p => p.status === 'submitted').length,
    completed: payments.filter(p => p.status === 'completed').length,
    failed:    payments.filter(p => p.status === 'failed').length,
    pending:   payments.filter(p => p.status === 'pending').length,
  }

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="hotel_manager">
      <PageHeader title="Payment Verification"
        subtitle="Review guest bookings, verify payment proofs, and check national IDs" />

      {/* Filter tabs */}
      <div className="flex flex-wrap gap-2 mb-6">
        {(Object.keys(counts) as Array<keyof typeof counts>).map(s => (
          <button key={s} onClick={() => setFilter(s)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${
              filter === s
                ? 'bg-blue-600 text-white shadow-sm'
                : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
            }`}>
            {s === 'all' ? 'All' : s.charAt(0).toUpperCase() + s.slice(1)}
            <span className={`ml-1.5 text-xs px-1.5 py-0.5 rounded-full ${
              filter === s ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-500'
            }`}>{counts[s]}</span>
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <EmptyState title="No payments found"
          subtitle={filter === 'submitted' ? 'No payments waiting for verification' : 'No payments in this category'}
          icon="💳" />
      ) : (
        <div className="space-y-3">
          {filtered.map((p, i) => {
            const isExpanded = expanded === p.id
            const borderCls  = STATUS_COLOR[p.status] || STATUS_COLOR.pending

            return (
              <motion.div key={p.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04 }}
                className={`rounded-2xl border-2 shadow-sm overflow-hidden transition-all ${borderCls}`}>

                {/* ── Card header (always visible) ─────────────── */}
                <div className="p-5">
                  <div className="flex items-start justify-between flex-wrap gap-3">

                    {/* Left: guest name + booking summary */}
                    <div className="flex items-start gap-3 min-w-0">
                      <div className="w-10 h-10 rounded-xl bg-white border border-gray-200 flex items-center justify-center flex-shrink-0 shadow-sm">
                        <User size={18} className="text-blue-500" />
                      </div>
                      <div className="min-w-0">
                        <p className="font-bold text-gray-800 text-base">
                          {p.guest_full_name || p.guest_name}
                        </p>
                        <div className="flex flex-wrap gap-3 mt-1 text-xs text-gray-500">
                          {(p.guest_email || p.user_email) && (
                            <span className="flex items-center gap-1">
                              <Mail size={11} /> {p.guest_email || p.user_email}
                            </span>
                          )}
                          {(p.guest_phone || p.user_phone) && (
                            <span className="flex items-center gap-1">
                              <Phone size={11} /> {p.guest_phone || p.user_phone}
                            </span>
                          )}
                          <span className="flex items-center gap-1">
                            <Calendar size={11} /> {p.check_in} → {p.check_out}
                          </span>
                          {p.room_type_name && (
                            <span className="flex items-center gap-1">
                              <Bed size={11} /> {p.room_type_name}
                            </span>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Right: amount + status */}
                    <div className="text-right flex-shrink-0">
                      <p className="text-2xl font-extrabold text-gray-900">
                        ETB {Number(p.amount).toLocaleString()}
                      </p>
                      <div className="flex justify-end gap-1.5 mt-1">
                        <Badge status={p.status} />
                        {p.status === 'submitted' && (
                          <span className="text-[10px] bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full font-semibold animate-pulse">
                            ACTION NEEDED
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Quick info row */}
                  <div className="flex flex-wrap gap-4 mt-4 pt-3 border-t border-white/60 text-sm text-gray-600">
                    <span className="flex items-center gap-1.5">
                      <CreditCard size={14} className="text-gray-400" />
                      {PM_LABELS[p.method] || p.method}
                    </span>
                    <span className="flex items-center gap-1.5">
                      <DollarSign size={14} className="text-gray-400" />
                      Booking #{p.booking_id}
                    </span>
                    {p.transaction_id && (
                      <span className="flex items-center gap-1.5 font-mono text-xs bg-gray-100 px-2 py-0.5 rounded-lg">
                        TXN: {p.transaction_id}
                      </span>
                    )}
                    <span className="flex items-center gap-1.5 text-xs text-gray-400 ml-auto">
                      <Clock size={12} /> {new Date(p.created_at).toLocaleString()}
                    </span>
                  </div>

                  {/* Action buttons (for submitted payments) */}
                  {p.status === 'submitted' && (
                    <div className="flex gap-3 mt-4">
                      <button onClick={() => handleVerify(p.id, 'approved')}
                        className="flex-1 flex items-center justify-center gap-2 bg-emerald-600 text-white px-4 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors font-semibold text-sm shadow-sm hover:shadow-emerald-200">
                        <CheckCircle size={17} /> Approve Payment
                      </button>
                      <button onClick={() => handleVerify(p.id, 'rejected')}
                        className="flex-1 flex items-center justify-center gap-2 bg-red-600 text-white px-4 py-2.5 rounded-xl hover:bg-red-700 transition-colors font-semibold text-sm shadow-sm hover:shadow-red-200">
                        <XCircle size={17} /> Reject Payment
                      </button>
                    </div>
                  )}

                  {/* Expand/collapse toggle */}
                  <button onClick={() => setExpanded(isExpanded ? null : p.id)}
                    className="w-full flex items-center justify-center gap-1.5 text-xs text-gray-400 hover:text-gray-600 mt-3 pt-3 border-t border-white/60 transition-colors">
                    {isExpanded ? <><ChevronUp size={14} /> Hide details</> : <><ChevronDown size={14} /> View full details &amp; documents</>}
                  </button>
                </div>

                {/* ── Expanded details ──────────────────────────── */}
                <AnimatePresence>
                  {isExpanded && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      className="border-t-2 border-white/60 overflow-hidden">
                      <div className="p-5 space-y-5 bg-white/40">

                        {/* Booking details grid */}
                        <div>
                          <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-3">Booking Details</p>
                          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                            {[
                              { label: 'Adults',         value: p.adults },
                              { label: 'Children',       value: p.children },
                              { label: 'Rooms',          value: p.rooms },
                              { label: 'Total Booking',  value: `ETB ${Number(p.total_price).toLocaleString()}` },
                            ].map(item => (
                              <div key={item.label} className="bg-white rounded-xl px-3 py-2.5 border border-gray-100">
                                <p className="text-[10px] text-gray-400 uppercase tracking-wide">{item.label}</p>
                                <p className="font-bold text-gray-800 mt-0.5">{item.value}</p>
                              </div>
                            ))}
                          </div>
                          {p.special_requests && (
                            <div className="mt-2 bg-blue-50 rounded-xl px-3 py-2.5 border border-blue-100 text-sm text-blue-700">
                              <span className="font-semibold">Special Requests: </span>{p.special_requests}
                            </div>
                          )}
                        </div>

                        {/* Payment proof images */}
                        {(p.screenshot_url || p.national_id_front || p.national_id_back) && (
                          <div>
                            <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-3">Uploaded Documents</p>
                            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">

                              {p.screenshot_url && (
                                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                                  <div className="bg-gray-50 px-3 py-2 flex items-center gap-2 border-b border-gray-100">
                                    <CreditCard size={14} className="text-gray-500" />
                                    <span className="text-xs font-semibold text-gray-600">Payment Screenshot</span>
                                  </div>
                                  <div className="p-2">
                                    <img src={p.screenshot_url} alt="Payment proof"
                                      className="w-full h-32 object-cover rounded-lg cursor-pointer hover:opacity-90 transition-opacity"
                                      onClick={() => setLightbox({ src: p.screenshot_url, title: 'Payment Screenshot' })} />
                                    <button
                                      onClick={() => setLightbox({ src: p.screenshot_url, title: 'Payment Screenshot' })}
                                      className="w-full mt-1.5 text-xs text-blue-600 hover:text-blue-800 flex items-center justify-center gap-1">
                                      <ExternalLink size={11} /> View full size
                                    </button>
                                  </div>
                                </div>
                              )}

                              {p.national_id_front && (
                                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                                  <div className="bg-gray-50 px-3 py-2 flex items-center gap-2 border-b border-gray-100">
                                    <IdCard size={14} className="text-gray-500" />
                                    <span className="text-xs font-semibold text-gray-600">National ID — Front</span>
                                  </div>
                                  <div className="p-2">
                                    <img src={p.national_id_front} alt="ID Front"
                                      className="w-full h-32 object-cover rounded-lg cursor-pointer hover:opacity-90 transition-opacity"
                                      onClick={() => setLightbox({ src: p.national_id_front, title: 'National ID — Front' })} />
                                    <button
                                      onClick={() => setLightbox({ src: p.national_id_front, title: 'National ID — Front' })}
                                      className="w-full mt-1.5 text-xs text-blue-600 hover:text-blue-800 flex items-center justify-center gap-1">
                                      <ExternalLink size={11} /> View full size
                                    </button>
                                  </div>
                                </div>
                              )}

                              {p.national_id_back && (
                                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                                  <div className="bg-gray-50 px-3 py-2 flex items-center gap-2 border-b border-gray-100">
                                    <IdCard size={14} className="text-gray-500" />
                                    <span className="text-xs font-semibold text-gray-600">National ID — Back</span>
                                  </div>
                                  <div className="p-2">
                                    <img src={p.national_id_back} alt="ID Back"
                                      className="w-full h-32 object-cover rounded-lg cursor-pointer hover:opacity-90 transition-opacity"
                                      onClick={() => setLightbox({ src: p.national_id_back, title: 'National ID — Back' })} />
                                    <button
                                      onClick={() => setLightbox({ src: p.national_id_back, title: 'National ID — Back' })}
                                      className="w-full mt-1.5 text-xs text-blue-600 hover:text-blue-800 flex items-center justify-center gap-1">
                                      <ExternalLink size={11} /> View full size
                                    </button>
                                  </div>
                                </div>
                              )}

                              {!p.screenshot_url && !p.national_id_front && !p.national_id_back && (
                                <div className="col-span-3 flex items-center gap-2 text-gray-400 text-sm py-4 justify-center">
                                  <ImgIcon size={18} /> No documents uploaded
                                </div>
                              )}
                            </div>
                          </div>
                        )}

                        {/* Approved/rejected by info */}
                        {p.paid_at && (
                          <div className="text-xs text-gray-400 flex items-center gap-1.5">
                            <CheckCircle size={12} className="text-emerald-500" />
                            Payment verified on {new Date(p.paid_at).toLocaleString()}
                          </div>
                        )}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            )
          })}
        </div>
      )}

      {/* Lightbox */}
      <Modal open={!!lightbox} onClose={() => setLightbox(null)}
        title={lightbox?.title || 'Document'} size="lg">
        {lightbox && (
          <div className="flex flex-col items-center gap-3">
            <img src={lightbox.src} alt={lightbox.title}
              className="max-w-full max-h-[70vh] rounded-xl shadow-lg object-contain" />
            <a href={lightbox.src} target="_blank" rel="noreferrer"
              className="flex items-center gap-1.5 text-blue-600 text-sm hover:underline font-medium">
              <ExternalLink size={14} /> Open in new tab
            </a>
          </div>
        )}
      </Modal>
    </AdminLayout>
  )
}

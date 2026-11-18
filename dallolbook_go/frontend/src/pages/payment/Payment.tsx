// pages/payment/Payment.tsx — View booking + submit payment proof
import { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  Clock, CheckCircle, XCircle, CreditCard, ArrowRight,
  Upload, Copy, Check, AlertCircle
} from 'lucide-react'
import toast from 'react-hot-toast'
import { useBooking } from '../../hooks/useBooking'
import { paymentService } from '../../services/payment'
import { hotelService } from '../../services/hotels'
import Navbar from '../../components/shared/Navbar'
import Spinner from '../../components/shared/Spinner'
import Badge from '../../components/shared/Badge'
import { fileToBase64 } from '../../utils/validate'

const PM_LABELS: Record<string, string> = {
  telebirr: 'Telebirr', cbe_birr: 'CBE Birr', chapa: 'Chapa',
  awash_bank: 'Awash Bank', abyssinia: 'Bank of Abyssinia',
  dashen: 'Dashen Bank', oromia_coop: 'Oromia Bank', united: 'United Bank',
  nib: 'NIB International', wegagen: 'Wegagen Bank', bunna: 'Bunna Bank',
  cooperative: 'Cooperative Bank',
}

export default function Payment() {
  const { id } = useParams()
  const { booking, loading } = useBooking(Number(id))
  const [payment, setPayment] = useState<any>(null)
  const [pmDetails, setPmDetails] = useState<any>(null)
  const [txnId, setTxnId] = useState('')
  const [screenshot, setScreenshot] = useState('')
  const [uploading, setUploading] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    if (booking) {
      paymentService.getStatus(Number(id))
        .then(res => setPayment(res.data.data))
        .catch(() => {})
      // Load hotel payment methods to show account details
      if (booking.hotel_id) {
        hotelService.getPaymentMethods(booking.hotel_id)
          .then(res => {
            const methods = res.data.data || []
            const m = methods.find((x: any) => x.method === booking.payment_method)
            setPmDetails(m || null)
          })
          .catch(() => {})
      }
    }
  }, [booking, id])

  const handleScreenshot = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    if (!file.type.startsWith('image/')) { toast.error('Image files only'); return }
    if (file.size > 5 * 1024 * 1024) { toast.error('Max 5MB'); return }
    setUploading(true)
    try {
      const b64 = await fileToBase64(file)
      setScreenshot(b64)
      toast.success('Screenshot attached ✓')
    } catch { toast.error('Failed to process image') }
    setUploading(false)
  }

  const handleSubmit = async () => {
    if (!txnId.trim() || txnId.trim().length < 4) { toast.error('Enter a valid transaction ID'); return }
    if (!screenshot) { toast.error('Upload payment screenshot'); return }
    if (!payment?.id) { toast.error('Payment not found'); return }
    setSubmitting(true)
    try {
      await paymentService.submit(payment.id, txnId.trim(), screenshot)
      toast.success('Payment proof submitted! Hotel manager will verify shortly.')
      setPayment((p: any) => ({ ...p, status: 'submitted' }))
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Submission failed')
    } finally { setSubmitting(false) }
  }

  const copy = (text: string, label: string) => {
    navigator.clipboard.writeText(text)
    toast.success(`${label} copied!`)
  }

  if (loading) return <><Navbar /><div className="flex items-center justify-center min-h-screen"><Spinner size="lg" /></div></>
  if (!booking) return <><Navbar /><div className="text-center py-20 text-gray-400">Booking not found</div></>

  const canSubmit = payment?.status === 'pending' || payment?.status === 'failed'

  return (
    <>
      <Navbar />
      <div className="max-w-xl mx-auto px-4 py-10 space-y-5">
        <h1 className="text-2xl font-bold text-gray-900">Booking & Payment</h1>

        {/* Booking summary */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
          <div className="flex gap-4">
            <img src={booking.hotel_image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200'}
              alt="" className="w-16 h-16 rounded-xl object-cover flex-shrink-0" />
            <div className="flex-1 min-w-0">
              <h2 className="font-bold text-gray-800">{booking.hotel_name}</h2>
              <p className="text-sm text-gray-500">{booking.hotel_city}</p>
              <p className="text-sm mt-1 text-gray-600">{booking.check_in} → {booking.check_out}</p>
              <p className="text-sm text-gray-600">{booking.rooms} room{booking.rooms > 1 ? 's' : ''} · {booking.adults} adult{booking.adults > 1 ? 's' : ''}</p>
            </div>
          </div>
          <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-50">
            <div className="flex gap-2 flex-wrap">
              <Badge status={booking.status} />
              {payment && <Badge status={payment.status} />}
            </div>
            <span className="text-xl font-bold text-blue-600">ETB {booking.total_price?.toLocaleString()}</span>
          </div>
        </div>

        {/* Payment method account details */}
        {pmDetails && canSubmit && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-3 flex items-center justify-between">
              <div>
                <p className="text-white font-bold">{PM_LABELS[pmDetails.method] || pmDetails.method}</p>
                <p className="text-blue-200 text-xs">Send ETB {booking.total_price?.toLocaleString()} to this account</p>
              </div>
              <span className="text-2xl">
                {pmDetails.method === 'telebirr' ? '📱' : pmDetails.method === 'chapa' ? '🔵' : '🏦'}
              </span>
            </div>
            <div className="p-5 space-y-3">
              {pmDetails.account_name && (
                <div className="flex items-center justify-between bg-gray-50 rounded-xl px-4 py-3">
                  <div><p className="text-[10px] text-gray-400 uppercase font-semibold">Account Name</p><p className="font-semibold text-sm">{pmDetails.account_name}</p></div>
                  <button onClick={() => copy(pmDetails.account_name, 'Account name')} className="p-1.5 hover:bg-gray-200 rounded-lg"><Copy size={14} className="text-gray-500" /></button>
                </div>
              )}
              {pmDetails.phone_number && (
                <div className="flex items-center justify-between bg-blue-50 rounded-xl px-4 py-3 border border-blue-100">
                  <div><p className="text-[10px] text-blue-500 uppercase font-semibold">Phone / Wallet</p><p className="font-black text-xl tracking-widest font-mono text-gray-800">{pmDetails.phone_number}</p></div>
                  <button onClick={() => copy(pmDetails.phone_number, 'Phone')} className="p-1.5 hover:bg-blue-100 rounded-lg"><Copy size={14} className="text-blue-500" /></button>
                </div>
              )}
              {pmDetails.account_number && (
                <div className="flex items-center justify-between bg-gray-50 rounded-xl px-4 py-3">
                  <div><p className="text-[10px] text-gray-400 uppercase font-semibold">Account Number</p><p className="font-black text-base tracking-widest font-mono">{pmDetails.account_number}</p></div>
                  <button onClick={() => copy(pmDetails.account_number, 'Account number')} className="p-1.5 hover:bg-gray-200 rounded-lg"><Copy size={14} className="text-gray-500" /></button>
                </div>
              )}
              {pmDetails.instructions && (
                <div className="text-xs text-blue-700 bg-blue-50 rounded-xl px-4 py-3 border border-blue-100">{pmDetails.instructions}</div>
              )}
            </div>
          </motion.div>
        )}

        {/* Payment proof submission */}
        {canSubmit && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 space-y-4">
            <h3 className="font-bold text-gray-800 flex items-center gap-2">
              <Upload size={18} className="text-blue-600" /> Submit Payment Proof
            </h3>
            {payment?.status === 'failed' && (
              <div className="bg-red-50 border border-red-200 rounded-xl p-3 flex items-start gap-2 text-red-700 text-sm">
                <AlertCircle size={16} className="flex-shrink-0 mt-0.5" />
                Previous payment was rejected. Please try a different payment method or re-submit.
              </div>
            )}
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1.5">
                Transaction ID <span className="text-red-500">*</span>
              </label>
              <input value={txnId} onChange={e => setTxnId(e.target.value)}
                placeholder="e.g. TXN123456789"
                className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm font-mono focus:ring-2 focus:ring-blue-400 outline-none" />
              <p className="text-xs text-gray-400 mt-1">Enter the transaction reference from your payment app/receipt</p>
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-1.5">
                Payment Screenshot <span className="text-red-500">*</span>
              </label>
              <label className={`block border-2 border-dashed rounded-2xl cursor-pointer transition-all p-4 text-center ${
                uploading ? 'border-blue-400 bg-blue-50'
                : screenshot ? 'border-emerald-400 bg-emerald-50'
                : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
              }`}>
                {uploading ? (
                  <div className="space-y-2">
                    <div className="w-6 h-6 border-2 border-blue-400 border-t-blue-600 rounded-full animate-spin mx-auto" />
                    <p className="text-sm text-blue-600">Processing…</p>
                  </div>
                ) : screenshot ? (
                  <div>
                    <img src={screenshot} alt="Screenshot" className="max-h-36 mx-auto rounded-xl mb-2 shadow-sm" />
                    <p className="text-xs text-emerald-600 font-semibold flex items-center justify-center gap-1">
                      <Check size={13} /> Screenshot attached
                    </p>
                    <span onClick={e => { e.preventDefault(); setScreenshot('') }}
                      className="text-xs text-red-400 mt-1 inline-block cursor-pointer hover:text-red-600">Remove</span>
                  </div>
                ) : (
                  <div className="space-y-1.5">
                    <Upload size={28} className="mx-auto text-gray-400" />
                    <p className="text-sm font-medium text-gray-600">Click to upload screenshot</p>
                    <p className="text-xs text-gray-400">PNG, JPG up to 5MB</p>
                  </div>
                )}
                <input type="file" accept="image/*" onChange={handleScreenshot} className="hidden" disabled={uploading} />
              </label>
            </div>
            <button onClick={handleSubmit} disabled={submitting || !txnId.trim() || !screenshot}
              className="w-full flex items-center justify-center gap-2 bg-emerald-600 text-white py-3.5 rounded-xl font-bold hover:bg-emerald-700 transition-all disabled:opacity-40 disabled:cursor-not-allowed">
              {submitting ? (
                <><div className="w-5 h-5 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Submitting…</>
              ) : (
                <><Check size={18} /> Submit Payment Proof</>
              )}
            </button>
          </motion.div>
        )}

        {/* Status banners */}
        {payment?.status === 'submitted' && (
          <div className="bg-purple-50 rounded-2xl p-4 flex items-start gap-3 border border-purple-100">
            <Clock size={20} className="text-purple-600 mt-0.5 flex-shrink-0" />
            <div>
              <p className="font-semibold text-purple-800">Payment Submitted — Pending Verification</p>
              <p className="text-xs text-purple-600 mt-0.5">The hotel manager will verify your payment. You'll be notified by email/notification once approved.</p>
            </div>
          </div>
        )}
        {payment?.status === 'completed' && (
          <div className="bg-emerald-50 rounded-2xl p-4 flex items-start gap-3 border border-emerald-100">
            <CheckCircle size={20} className="text-emerald-600 mt-0.5 flex-shrink-0" />
            <div>
              <p className="font-semibold text-emerald-800">Payment Confirmed — Booking Active!</p>
              <p className="text-xs text-emerald-600 mt-0.5">Your booking is confirmed. Enjoy your stay!</p>
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-3">
          <Link to="/dashboard/bookings"
            className="flex-1 text-center border-2 border-gray-200 text-gray-700 px-4 py-3 rounded-xl font-semibold hover:bg-gray-50 transition-colors text-sm">
            My Bookings
          </Link>
          <Link to="/hotels"
            className="flex-1 flex items-center justify-center gap-1.5 bg-blue-600 text-white px-4 py-3 rounded-xl font-semibold hover:bg-blue-700 transition-colors text-sm">
            Browse Hotels <ArrowRight size={16} />
          </Link>
        </div>
      </div>
    </>
  )
}

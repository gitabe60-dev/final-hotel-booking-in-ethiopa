// pages/booking/BookingConfirm.tsx — 2-step booking: Guest Info → Payment
import { useState, useEffect } from 'react'
import { useParams, useNavigate, useSearchParams } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Users, CreditCard, Upload, Check, ChevronRight, ChevronLeft,
  Bed, Copy, Phone, Building, Wallet, Smartphone, Info,
  AlertCircle, IdCard, Mail, Calendar, User, MapPin
} from 'lucide-react'
import toast from 'react-hot-toast'
import { useHotel } from '../../hooks/useHotels'
import { hotelService } from '../../services/hotels'
import { bookingService } from '../../services/booking'
import { paymentService } from '../../services/payment'
import { useAuth } from '../../context/AuthContext'
import Navbar from '../../components/shared/Navbar'
import Spinner from '../../components/shared/Spinner'
import {
  validateName, validateEmail, validatePhone,
  validateFutureDate, validateDateRange,
  validateTransactionId, validatePositiveNumber,
  hasErrors, FieldError, fileToBase64
} from '../../utils/validate'

// ─── helpers ──────────────────────────────────────────────────────────────────
const today    = () => new Date().toISOString().split('T')[0]
const tomorrow = () => { const d = new Date(); d.setDate(d.getDate() + 1); return d.toISOString().split('T')[0] }

// ─── All Ethiopian payment methods (no cash, no card, no mobile_money, no bank_transfer duplicate) ──
const PM_CONFIG: Record<string, {
  label: string; logo: string; bgGrad: string; badgeColor: string
}> = {
  telebirr:     { label: 'Telebirr',              logo: '📱', bgGrad: 'from-green-500 to-emerald-600',   badgeColor: 'bg-green-50 border-green-200 text-green-800'   },
  cbe_birr:     { label: 'CBE Birr',              logo: '🏦', bgGrad: 'from-amber-500 to-yellow-600',    badgeColor: 'bg-amber-50 border-amber-200 text-amber-800'   },
  chapa:        { label: 'Chapa',                 logo: '🔵', bgGrad: 'from-blue-500 to-blue-600',       badgeColor: 'bg-blue-50 border-blue-200 text-blue-800'      },
  awash_bank:   { label: 'Awash Bank',            logo: '🏦', bgGrad: 'from-purple-500 to-purple-600',   badgeColor: 'bg-purple-50 border-purple-200 text-purple-800'},
  abyssinia:    { label: 'Bank of Abyssinia',     logo: '🏦', bgGrad: 'from-rose-500 to-pink-600',       badgeColor: 'bg-rose-50 border-rose-200 text-rose-800'      },
  dashen:       { label: 'Dashen Bank',           logo: '🏦', bgGrad: 'from-teal-500 to-teal-600',       badgeColor: 'bg-teal-50 border-teal-200 text-teal-800'      },
  oromia_coop:  { label: 'Oromia Bank',           logo: '🏦', bgGrad: 'from-orange-500 to-orange-600',   badgeColor: 'bg-orange-50 border-orange-200 text-orange-800'},
  united:       { label: 'United Bank',           logo: '🏦', bgGrad: 'from-indigo-500 to-indigo-600',   badgeColor: 'bg-indigo-50 border-indigo-200 text-indigo-800'},
  nib:          { label: 'NIB International',     logo: '🏦', bgGrad: 'from-lime-600 to-lime-700',       badgeColor: 'bg-lime-50 border-lime-200 text-lime-800'      },
  wegagen:      { label: 'Wegagen Bank',          logo: '🏦', bgGrad: 'from-cyan-600 to-cyan-700',       badgeColor: 'bg-cyan-50 border-cyan-200 text-cyan-800'      },
  bunna:        { label: 'Bunna Bank',            logo: '🏦', bgGrad: 'from-fuchsia-500 to-fuchsia-600', badgeColor: 'bg-fuchsia-50 border-fuchsia-200 text-fuchsia-800'},
  cooperative:  { label: 'Cooperative Bank',      logo: '🏦', bgGrad: 'from-emerald-600 to-green-700',   badgeColor: 'bg-emerald-50 border-emerald-200 text-emerald-800'},
}

// ─── Tiny helper components ────────────────────────────────────────────────────
function Err({ msg }: { msg: FieldError }) {
  if (!msg) return null
  return <p className="flex items-center gap-1 text-red-500 text-xs mt-1.5"><AlertCircle size={11} /> {msg}</p>
}

function F({ label, required, error, hint, children }: {
  label: string; required?: boolean; error: FieldError; hint?: string; children: React.ReactNode
}) {
  return (
    <div>
      <label className="block text-sm font-semibold text-gray-700 mb-1.5">
        {label}{required && <span className="text-red-500 ml-0.5">*</span>}
      </label>
      {children}
      {hint && !error && <p className="text-xs text-gray-400 mt-1">{hint}</p>}
      <Err msg={error} />
    </div>
  )
}

const inputCls = (err: FieldError, touched: boolean) =>
  `w-full border rounded-xl px-3 py-2.5 text-sm outline-none transition-all ${
    touched && err  ? 'border-red-400 bg-red-50 focus:ring-2 focus:ring-red-200'
    : touched && !err ? 'border-emerald-400 focus:ring-2 focus:ring-emerald-200'
    : 'border-gray-200 focus:ring-2 focus:ring-blue-400 bg-white'
  }`

// ─── Main ──────────────────────────────────────────────────────────────────────
export default function BookingConfirm() {
  const { id }  = useParams()
  const navigate = useNavigate()
  const [urlP]  = useSearchParams()
  const { user } = useAuth()
  const { hotel, loading } = useHotel(Number(id))

  const preCheckIn   = urlP.get('check_in')   || today()
  const preCheckOut  = urlP.get('check_out')  || tomorrow()
  const preRoomId    = urlP.get('room_id')    ? Number(urlP.get('room_id'))    : undefined
  const preRoomName  = urlP.get('room_name')  || ''
  const preRoomPrice = urlP.get('room_price') ? Number(urlP.get('room_price')) : 0
  // Number of rooms the user already selected on the hotel page — LOCKED, not editable here
  const preRooms     = urlP.get('rooms')      ? Number(urlP.get('rooms'))      : 1
  // Total max guests = max_guests per room × number of rooms (passed from HotelDetail)
  const preMaxGuests = urlP.get('max_guests') ? Number(urlP.get('max_guests')) : preRooms * 2

  const [step, setStep]         = useState(1)
  const [submitting, setSub]    = useState(false)
  const [payMethods, setPayMethods] = useState<any[]>([])
  const [pmLoading, setPmLoad]  = useState(true)
  const [touched, setTouched]   = useState<Record<string, boolean>>({})
  const [uploading, setUploading] = useState<Record<string, boolean>>({})

  const [form, setForm] = useState({
    first_name:   user?.first_name || '',
    last_name:    user?.last_name  || '',
    email:        user?.email      || '',
    phone:        user?.phone      || '',
    nationality:  '',
    check_in:     preCheckIn,
    check_out:    preCheckOut,
    // Adults default = preMaxGuests (all capacity), user can reduce but not exceed
    adults:       Math.max(1, preMaxGuests),
    children:     0,
    rooms:        preRooms,   // LOCKED — set from hotel selection, not editable
    special_requests: '',
    national_id_front: '',
    national_id_back:  '',
    payment_method:    '',
    transaction_id:    '',
    screenshot_url:    '',
  })

  const nights    = Math.max(1, Math.round((new Date(form.check_out).getTime() - new Date(form.check_in).getTime()) / 86400000))
  const unitPrice  = preRoomPrice || hotel?.price_per_night || 0
  const total      = unitPrice * nights * Number(form.rooms)
  // Capacity: preMaxGuests is the total capacity for all selected rooms
  const totalCapacity = preMaxGuests > 0 ? preMaxGuests : (Number(form.rooms) * 2)

  const set  = (k: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setForm(f => ({ ...f, [k]: e.target.value }))
    setTouched(t => ({ ...t, [k]: true }))
  }
  const blur = (k: string) => () => setTouched(t => ({ ...t, [k]: true }))
  const inc  = (k: 'adults' | 'children' | 'rooms', min: number) => (delta: number) => {
    setForm(f => ({ ...f, [k]: Math.max(min, Number((f as any)[k]) + delta) }))
    setTouched(t => ({ ...t, [k]: true }))
  }

  // Load hotel payment methods
  useEffect(() => {
    if (!id) return
    hotelService.getPaymentMethods(Number(id))
      .then(res => {
        const m = res.data.data || []
        setPayMethods(m)
        if (m.length > 0) setForm(f => ({ ...f, payment_method: m[0].method }))
      })
      .catch(() => {})
      .finally(() => setPmLoad(false))
  }, [id])

  const selectedPm = payMethods.find(m => m.method === form.payment_method)
  const pmCfg      = PM_CONFIG[form.payment_method] || { label: '', logo: '🏦', bgGrad: 'from-gray-500 to-gray-600', badgeColor: '' }

  // ── Step 1 validation ─────────────────────────────────────────────────────
  const e1 = {
    first_name:         validateName(form.first_name, 'First name'),
    last_name:          validateName(form.last_name, 'Last name'),
    email:              validateEmail(form.email, !form.phone),
    phone:              validatePhone(form.phone, !form.email),
    check_in:           validateFutureDate(form.check_in, 'Check-in'),
    check_out:          validateDateRange(form.check_in, form.check_out),
    adults:             validatePositiveNumber(form.adults, 'Adults'),
    rooms:              null as FieldError,   // locked from hotel selection — not validated here
    national_id_front:  !form.national_id_front ? 'National ID front photo is required' : null,
    national_id_back:   !form.national_id_back  ? 'National ID back photo is required'  : null,
    capacity: (Number(form.adults) + Number(form.children)) > totalCapacity
      ? `Total guests (${Number(form.adults) + Number(form.children)}) exceed room capacity (${totalCapacity} guests for ${preRooms} room${preRooms > 1 ? 's' : ''})`
      : null,
  }

  // ── Step 2 validation ─────────────────────────────────────────────────────
  const e2 = {
    payment_method: !form.payment_method ? 'Select a payment method' : null,
    transaction_id: validateTransactionId(form.transaction_id),
    screenshot_url: !form.screenshot_url ? 'Payment screenshot is required' : null,
  }

  const touchAll = (errs: Record<string, FieldError>) =>
    setTouched(t => ({ ...t, ...Object.fromEntries(Object.keys(errs).map(k => [k, true])) }))

  const goStep2 = () => {
    touchAll(e1)
    if (!hasErrors(e1)) { setStep(2); window.scrollTo(0, 0) }
    else {
      toast.error('Please complete all required fields including National ID photos')
      // Scroll to first error
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }

  // Image pickers — convert to base64 so they can be sent to server and opened anywhere
  const pickImg = (field: 'national_id_front' | 'national_id_back' | 'screenshot_url') =>
    async (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0]
      if (!file) return
      // Validate file type and size
      if (!file.type.startsWith('image/')) {
        toast.error('Only image files are accepted (JPG, PNG, WEBP)')
        return
      }
      if (file.size > 5 * 1024 * 1024) {
        toast.error('Image must be smaller than 5MB')
        return
      }
      setUploading(u => ({ ...u, [field]: true }))
      try {
        const base64 = await fileToBase64(file)
        setForm(f => ({ ...f, [field]: base64 }))
        setTouched(t => ({ ...t, [field]: true }))
        toast.success(field === 'screenshot_url' ? 'Screenshot attached ✓' : 'ID photo attached ✓')
      } catch {
        toast.error('Failed to process image. Please try again.')
      } finally {
        setUploading(u => ({ ...u, [field]: false }))
      }
    }

  const copy = (text: string, label: string) => {
    navigator.clipboard.writeText(text)
    toast.success(`${label} copied!`)
  }

  // Submit
  const submit = async () => {
    touchAll(e2)
    if (hasErrors(e2)) {
      if (!form.payment_method)  toast.error('Please select a payment method')
      else if (!form.transaction_id || form.transaction_id.trim().length < 4) toast.error('Transaction ID is required')
      else if (!form.screenshot_url) toast.error('Payment screenshot is required — please upload a screenshot')
      else toast.error('Please fix the errors above')
      return
    }
    setSub(true)
    try {
      const guestEmail = form.email.trim() || undefined
      const guestPhone = form.phone.trim() || undefined
      const natFront   = form.national_id_front || undefined
      const natBack    = form.national_id_back  || undefined
      const guestFull  = `${form.first_name.trim()} ${form.last_name.trim()}`

      const bRes = await bookingService.create({
        hotel_id:         Number(id),
        room_type_id:     preRoomId,
        check_in:         form.check_in,
        check_out:        form.check_out,
        adults:           Number(form.adults),
        children:         Number(form.children),
        rooms:            Number(form.rooms),
        payment_method:   form.payment_method,
        special_requests: form.special_requests || undefined,
        guest_full_name:  guestFull,
        guest_email:      guestEmail,
        guest_phone:      guestPhone,
        national_id_front: natFront,
        national_id_back:  natBack,
      })
      const booking = bRes.data.data

      const pRes = await paymentService.initiate(booking.id, form.payment_method)
      const paymentId = pRes.data.data.payment_id

      await paymentService.submit(paymentId, form.transaction_id, form.screenshot_url || '')
      toast.success('Booking submitted! Awaiting payment verification.')
      navigate(`/payment/${booking.id}/success`)
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Booking failed — please try again.')
    } finally { setSub(false) }
  }

  if (loading) return <><Navbar /><div className="flex items-center justify-center min-h-screen"><Spinner size="lg" /></div></>

  return (
    <>
      <Navbar />
      <div className="min-h-screen bg-gray-50 pb-12">

        {/* ── Page header ───────────────────────── */}
        <div className="bg-white border-b border-gray-100 sticky top-16 z-10">
          <div className="max-w-2xl mx-auto px-4 py-4 flex items-center gap-4">
            {/* Step pills */}
            {[
              { num: 1, label: 'Your Details', icon: Users },
              { num: 2, label: 'Payment',      icon: CreditCard },
            ].map((s, i) => (
              <div key={s.num} className="flex items-center">
                <div className={`flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-semibold transition-all ${
                  step === s.num ? 'bg-blue-600 text-white'
                  : step > s.num ? 'bg-emerald-100 text-emerald-700'
                  : 'bg-gray-100 text-gray-400'
                }`}>
                  {step > s.num ? <Check size={14} /> : <s.icon size={14} />}
                  <span className="hidden sm:inline">{s.label}</span>
                  <span className="sm:hidden">{s.num}</span>
                </div>
                {i === 0 && <div className={`w-8 h-0.5 mx-1 ${step > 1 ? 'bg-emerald-400' : 'bg-gray-200'}`} />}
              </div>
            ))}

            {/* Hotel mini-summary */}
            <div className="ml-auto flex items-center gap-2 text-right">
              <div>
                <p className="text-xs font-bold text-gray-700 truncate max-w-[120px]">{hotel?.name}</p>
                <p className="text-xs text-blue-600 font-bold">ETB {total.toLocaleString()}</p>
              </div>
              <img src={hotel?.images?.[0] || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=80'}
                alt="" className="w-10 h-10 rounded-lg object-cover" />
            </div>
          </div>
        </div>

        <div className="max-w-2xl mx-auto px-4 pt-6">
          <AnimatePresence mode="wait">

            {/* ══════════════════════════════════════
                STEP 1 — Guest Details + Dates + ID
            ══════════════════════════════════════ */}
            {step === 1 && (
              <motion.div key="s1"
                initial={{ opacity: 0, x: 30 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -30 }}
                className="space-y-5">

                {/* Room & dates summary banner */}
                <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl p-4 text-white">
                  <div className="flex items-center justify-between flex-wrap gap-2">
                    <div>
                      {preRoomName && (
                        <p className="flex items-center gap-1.5 text-blue-100 text-sm mb-1">
                          <Bed size={14} /> {preRoomName}
                        </p>
                      )}
                      <p className="flex items-center gap-1.5 text-sm text-blue-100">
                        <Calendar size={14} /> {preCheckIn} → {preCheckOut} · {nights} night{nights > 1 ? 's' : ''}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-2xl font-extrabold">ETB {total.toLocaleString()}</p>
                      <p className="text-blue-200 text-xs">
                        ETB {unitPrice.toLocaleString()} × {nights} night{nights > 1 ? 's' : ''} × {form.rooms} room{Number(form.rooms) > 1 ? 's' : ''}
                      </p>
                    </div>
                  </div>
                </div>

                {/* ── Personal Info ── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-4">
                  <h2 className="font-bold text-gray-800 flex items-center gap-2">
                    <User size={18} className="text-blue-600" /> Personal Information
                  </h2>
                  <div className="grid grid-cols-2 gap-4">
                    <F label="First Name" required error={touched.first_name ? e1.first_name : null}>
                      <input value={form.first_name} onChange={set('first_name')} onBlur={blur('first_name')}
                        placeholder="e.g. Abebe"
                        className={inputCls(e1.first_name, !!touched.first_name)} />
                    </F>
                    <F label="Last Name" required error={touched.last_name ? e1.last_name : null}>
                      <input value={form.last_name} onChange={set('last_name')} onBlur={blur('last_name')}
                        placeholder="e.g. Kebede"
                        className={inputCls(e1.last_name, !!touched.last_name)} />
                    </F>
                  </div>
                  <F label="Email Address" error={touched.email ? e1.email : null}
                    hint="Required if no phone provided">
                    <div className="relative">
                      <Mail size={15} className="absolute left-3 top-3 text-gray-400" />
                      <input type="email" value={form.email} onChange={set('email')} onBlur={blur('email')}
                        placeholder="your@email.com"
                        className={inputCls(e1.email, !!touched.email) + ' pl-9'} />
                    </div>
                  </F>
                  <F label="Phone Number" error={touched.phone ? e1.phone : null}
                    hint="Ethiopian number, e.g. 0912345678">
                    <div className="relative">
                      <Phone size={15} className="absolute left-3 top-3 text-gray-400" />
                      <input type="tel" value={form.phone} onChange={set('phone')} onBlur={blur('phone')}
                        placeholder="0912345678"
                        className={inputCls(e1.phone, !!touched.phone) + ' pl-9'} />
                    </div>
                  </F>
                  <F label="Nationality" error={null}>
                    <div className="relative">
                      <MapPin size={15} className="absolute left-3 top-3 text-gray-400" />
                      <input value={form.nationality} onChange={set('nationality')}
                        placeholder="Ethiopian (optional)"
                        className="w-full border border-gray-200 rounded-xl px-3 py-2.5 pl-9 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
                    </div>
                  </F>
                </div>

                {/* ── Dates & Guests ── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-4">
                  <h2 className="font-bold text-gray-800 flex items-center gap-2">
                    <Calendar size={18} className="text-blue-600" /> Stay Details
                  </h2>
                  {/* ── Dates ── */}
                  <div className="grid grid-cols-2 gap-4">
                    <F label="Check-in" required error={touched.check_in ? e1.check_in : null}>
                      <input type="date" value={form.check_in} min={today()}
                        onChange={set('check_in')} onBlur={blur('check_in')}
                        className={inputCls(e1.check_in, !!touched.check_in)} />
                    </F>
                    <F label="Check-out" required error={touched.check_out ? e1.check_out : null}>
                      <input type="date" value={form.check_out} min={form.check_in}
                        onChange={set('check_out')} onBlur={blur('check_out')}
                        className={inputCls(e1.check_out, !!touched.check_out)} />
                    </F>
                  </div>

                  {/* ── Rooms locked banner ── */}
                  <div className="flex items-center gap-3 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3">
                    <Bed size={18} className="text-blue-500 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold text-blue-800">
                        {preRooms} Room{preRooms > 1 ? 's' : ''} Selected
                        {preRoomName ? ` — ${preRoomName}` : ''}
                      </p>
                      <p className="text-xs text-blue-600 mt-0.5">
                        Room capacity: <strong>{preMaxGuests}</strong> guest{preMaxGuests > 1 ? 's' : ''} max
                        {preRooms > 1 ? ` (${preMaxGuests / preRooms} per room × ${preRooms} rooms)` : ''}
                      </p>
                    </div>
                    <span className="text-xs bg-blue-600 text-white px-2.5 py-1 rounded-full font-semibold flex-shrink-0">
                      Locked
                    </span>
                  </div>

                  {/* ── Adults & Children (capped to room capacity) ── */}
                  <div className="grid grid-cols-2 gap-4">
                    {([
                      {
                        k: 'adults' as const,
                        label: 'Adults',
                        min: 1,
                        // max adults = total capacity minus children already selected
                        max: Math.max(1, preMaxGuests - Number(form.children)),
                        err: e1.adults,
                        required: true,
                        hint: `Min 1, max ${Math.max(1, preMaxGuests - Number(form.children))}`,
                      },
                      {
                        k: 'children' as const,
                        label: 'Children',
                        min: 0,
                        // max children = total capacity minus adults already selected
                        max: Math.max(0, preMaxGuests - Number(form.adults)),
                        err: null as FieldError,
                        required: false,
                        hint: `Max ${Math.max(0, preMaxGuests - Number(form.adults))}`,
                      },
                    ]).map(f => (
                      <F key={f.k} label={f.label} error={touched[f.k] ? f.err as FieldError : null} required={f.required}>
                        <div className="flex items-center border border-gray-200 rounded-xl overflow-hidden">
                          <button type="button"
                            onClick={() => {
                              const v = Math.max(f.min, Number((form as any)[f.k]) - 1)
                              setForm(p => ({ ...p, [f.k]: v }))
                              setTouched(t => ({ ...t, [f.k]: true }))
                            }}
                            disabled={Number((form as any)[f.k]) <= f.min}
                            className="px-3 py-2.5 text-gray-500 hover:bg-gray-100 font-bold border-r border-gray-200 text-lg disabled:opacity-30 disabled:cursor-not-allowed">−</button>
                          <span className="flex-1 text-center text-sm font-semibold py-2.5 bg-white">
                            {(form as any)[f.k]}
                          </span>
                          <button type="button"
                            onClick={() => {
                              const v = Math.min(f.max, Number((form as any)[f.k]) + 1)
                              setForm(p => ({ ...p, [f.k]: v }))
                              setTouched(t => ({ ...t, [f.k]: true }))
                            }}
                            disabled={Number((form as any)[f.k]) >= f.max}
                            className="px-3 py-2.5 text-gray-500 hover:bg-gray-100 font-bold border-l border-gray-200 text-lg disabled:opacity-30 disabled:cursor-not-allowed">+</button>
                        </div>
                        <p className="text-[10px] text-gray-400 mt-1 text-center">{f.hint}</p>
                      </F>
                    ))}
                  </div>
                  <F label="Special Requests" error={null}>
                    <textarea value={form.special_requests} onChange={e => setForm(f => ({ ...f, special_requests: e.target.value }))}
                      rows={2} placeholder="Early check-in, room preferences, allergies…"
                      className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-blue-400 outline-none resize-none" />
                  </F>

                  {/* Capacity info / warning */}
                  <div className={`rounded-xl px-4 py-3 text-sm flex items-start gap-2 ${
                    e1.capacity ? 'bg-red-50 border border-red-200 text-red-700' : 'bg-emerald-50 border border-emerald-100 text-emerald-700'
                  }`}>
                    <Users size={15} className="flex-shrink-0 mt-0.5" />
                    <div>
                      {e1.capacity
                        ? <span className="font-medium">{e1.capacity}</span>
                        : <span>
                            Total guests: <strong>{Number(form.adults) + Number(form.children)}</strong>
                            {' '}/ <strong>{totalCapacity}</strong> capacity
                            {Number(form.adults) + Number(form.children) < totalCapacity &&
                              <span className="text-emerald-600"> ✓ Within capacity</span>}
                          </span>
                      }
                    </div>
                  </div>
                </div>

                {/* ── National ID ── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-4">
                  <div>
                    <h2 className="font-bold text-gray-800 flex items-center gap-2">
                      <IdCard size={18} className="text-blue-600" /> National ID / Passport
                    </h2>
                    <p className="text-xs text-gray-400 mt-1">
                      Upload photos of your national ID or passport (front &amp; back) — required for check-in verification.
                    </p>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    {([
                      { field: 'national_id_front' as const, label: 'Front Side *', icon: '🪪' },
                      { field: 'national_id_back'  as const, label: 'Back Side *',  icon: '🪪' },
                    ]).map(({ field, label, icon }) => (
                      <div key={field}>
                        <p className="text-sm font-semibold text-gray-700 mb-2">{label}</p>
                        <label className={`block border-2 border-dashed rounded-xl cursor-pointer transition-all ${
                          uploading[field]      ? 'border-blue-400 bg-blue-50 opacity-70'
                          : form[field]         ? 'border-emerald-400 bg-emerald-50'
                          : touched[field] && e1[field] ? 'border-red-400 bg-red-50'
                          : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
                        }`}>
                          {uploading[field] ? (
                            <div className="p-4 text-center space-y-2">
                              <div className="w-6 h-6 border-2 border-blue-400 border-t-blue-600 rounded-full animate-spin mx-auto" />
                              <p className="text-xs text-blue-600 font-medium">Processing…</p>
                            </div>
                          ) : form[field] ? (
                            <div className="p-2">
                              <img src={form[field]} alt={label} className="w-full h-28 object-cover rounded-lg" />
                              <p className="text-xs text-center text-emerald-600 mt-1.5 font-medium flex items-center justify-center gap-1">
                                <Check size={12} /> Attached
                              </p>
                            </div>
                          ) : (
                            <div className="p-4 text-center space-y-1">
                              <span className="text-3xl">{icon}</span>
                              <p className="text-xs text-gray-500 font-medium">Tap to upload</p>
                              <p className="text-[10px] text-gray-400">JPG or PNG, max 5MB</p>
                            </div>
                          )}
                          <input type="file" accept="image/*" onChange={pickImg(field)} className="hidden" disabled={uploading[field]} />
                        </label>
                        {form[field] && !uploading[field] && (
                          <button onClick={() => { setForm(f => ({ ...f, [field]: '' })); setTouched(t => ({ ...t, [field]: true })) }}
                            className="text-xs text-red-400 mt-1 hover:text-red-600 w-full text-center">
                            Remove
                          </button>
                        )}
                        {touched[field] && e1[field] && (
                          <p className="text-red-500 text-xs mt-1 flex items-center gap-1">
                            <AlertCircle size={11} /> {e1[field]}
                          </p>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                <button onClick={goStep2}
                  className="w-full flex items-center justify-center gap-2 bg-blue-600 text-white py-4 rounded-2xl font-bold text-base hover:bg-blue-700 active:scale-[.98] transition-all shadow-lg">
                  Continue to Payment <ChevronRight size={20} />
                </button>
              </motion.div>
            )}

            {/* ══════════════════════════════════════
                STEP 2 — Payment Method
            ══════════════════════════════════════ */}
            {step === 2 && (
              <motion.div key="s2"
                initial={{ opacity: 0, x: 30 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -30 }}
                className="space-y-5">

                {/* ── Booking summary banner ── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 flex items-center gap-3">
                  <img src={hotel?.images?.[0] || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=80'}
                    alt="" className="w-14 h-14 rounded-xl object-cover flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-gray-800 truncate">{hotel?.name}</p>
                    {preRoomName && <p className="text-xs text-blue-600 flex items-center gap-1"><Bed size={11} /> {preRoomName}</p>}
                    <p className="text-xs text-gray-500">{form.check_in} → {form.check_out} · {nights}N · {form.adults} adult{Number(form.adults) > 1 ? 's' : ''}</p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xl font-extrabold text-gray-900">ETB {total.toLocaleString()}</p>
                    <p className="text-[11px] text-gray-400">Total amount</p>
                  </div>
                </div>

                {/* ── Payment method selector ── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                  <h2 className="font-bold text-gray-800 flex items-center gap-2 mb-4">
                    <CreditCard size={18} className="text-blue-600" /> Choose How You'll Pay
                  </h2>

                  {pmLoading ? (
                    <div className="flex items-center justify-center py-10 gap-2 text-gray-400">
                      <div className="w-5 h-5 border-2 border-blue-300 border-t-blue-600 rounded-full animate-spin" />
                      Loading payment options…
                    </div>
                  ) : payMethods.length === 0 ? (
                    <div className="text-center py-8 text-gray-400">
                      <CreditCard size={36} className="mx-auto mb-2 opacity-40" />
                      <p className="text-sm font-medium">No payment methods configured for this hotel.</p>
                      <p className="text-xs mt-1">Contact the hotel directly to arrange payment.</p>
                    </div>
                  ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                      {payMethods.map((pm: any) => {
                        const cfg = PM_CONFIG[pm.method] || { label: pm.method, logo: '🏦', bgGrad: 'from-gray-400 to-gray-500', badgeColor: '' }
                        const sel = form.payment_method === pm.method
                        // Determine what to show as account preview in the card
                        const preview = pm.phone_number || (pm.account_number ? pm.account_number.slice(-6).padStart(pm.account_number.length, '•') : '')
                        return (
                          <motion.button key={pm.id}
                            onClick={() => setForm(f => ({ ...f, payment_method: pm.method, transaction_id: '' }))}
                            whileTap={{ scale: 0.97 }}
                            className={`relative p-4 rounded-2xl border-2 text-left transition-all duration-200 ${
                              sel
                                ? 'border-blue-500 shadow-lg shadow-blue-100/60 scale-[1.02] bg-blue-50'
                                : 'border-gray-200 hover:border-blue-300 hover:shadow-md bg-white'
                            }`}>
                            {sel && (
                              <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ type: 'spring', stiffness: 400 }}
                                className="absolute top-2.5 right-2.5 w-5 h-5 bg-blue-600 rounded-full flex items-center justify-center shadow-sm">
                                <Check size={11} className="text-white" />
                              </motion.div>
                            )}
                            <div className={`w-11 h-11 rounded-xl bg-gradient-to-br ${cfg.bgGrad} flex items-center justify-center mb-2.5 shadow-sm`}>
                              <span className="text-2xl">{cfg.logo}</span>
                            </div>
                            <p className={`font-bold text-sm leading-tight ${sel ? 'text-blue-700' : 'text-gray-800'}`}>{cfg.label}</p>
                            {preview && (
                              <p className={`text-[11px] mt-1 font-mono ${sel ? 'text-blue-500' : 'text-gray-400'}`}>
                                {pm.phone_number ? '📞 ' : '🔢 '}{preview}
                              </p>
                            )}
                          </motion.button>
                        )
                      })}
                    </div>
                  )}
                </div>

                {/* ── Payment account details — shown when a method is selected ── */}
                <AnimatePresence mode="wait">
                  {selectedPm && (() => {
                    const cfg = PM_CONFIG[selectedPm.method] || { label: selectedPm.method, logo: '🏦', bgGrad: 'from-gray-400 to-gray-500', badgeColor: 'bg-gray-50 border-gray-200 text-gray-800' }
                    const hasPhone  = !!selectedPm.phone_number
                    const hasAccNum = !!selectedPm.account_number

                    return (
                      <motion.div key={selectedPm.method}
                        initial={{ opacity: 0, y: 14, scale: 0.98 }}
                        animate={{ opacity: 1, y: 0,  scale: 1    }}
                        exit={{ opacity: 0, y: -10 }}
                        transition={{ duration: 0.25 }}
                        className="bg-white rounded-2xl border border-gray-100 shadow-md overflow-hidden">

                        {/* Header */}
                        <div className={`bg-gradient-to-r ${cfg.bgGrad} px-5 py-4`}>
                          <div className="flex items-center gap-3">
                            <div className="w-12 h-12 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center flex-shrink-0">
                              <span className="text-2xl">{cfg.logo}</span>
                            </div>
                            <div>
                              <p className="text-white font-extrabold text-lg">{cfg.label}</p>
                              <p className="text-white/75 text-xs">
                                Send <span className="font-bold text-white">ETB {total.toLocaleString()}</span> to the account below
                              </p>
                            </div>
                          </div>
                        </div>

                        <div className="p-5 space-y-3">

                          {/* Account name */}
                          {selectedPm.account_name && (
                            <div className={`rounded-xl px-4 py-3 border ${cfg.badgeColor} flex items-center justify-between gap-3`}>
                              <div className="min-w-0">
                                <p className="text-[10px] uppercase tracking-widest font-bold opacity-60 mb-0.5">Account Name</p>
                                <p className="font-bold text-sm truncate">{selectedPm.account_name}</p>
                              </div>
                              <button onClick={() => copy(selectedPm.account_name, 'Account name')}
                                className="p-2 rounded-xl hover:bg-black/10 transition-colors flex-shrink-0" title="Copy">
                                <Copy size={15} />
                              </button>
                            </div>
                          )}

                          {/* Phone number — BIG, prominent */}
                          {hasPhone && (
                            <div className={`rounded-xl px-4 py-3.5 border-2 ${
                              cfg.badgeColor.replace('border-', 'border-2 border-')
                            } flex items-center justify-between gap-3`}>
                              <div className="min-w-0">
                                <p className="text-[10px] uppercase tracking-widest font-bold opacity-60 mb-0.5 flex items-center gap-1">
                                  <Phone size={10} /> Phone / Wallet Number
                                </p>
                                <p className="font-black text-2xl tracking-widest font-mono">{selectedPm.phone_number}</p>
                                <p className="text-xs opacity-60 mt-0.5">Send via {cfg.label} app</p>
                              </div>
                              <button onClick={() => copy(selectedPm.phone_number, 'Phone number')}
                                className="flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-black/10 transition-colors flex-shrink-0" title="Copy phone">
                                <Copy size={18} />
                                <span className="text-[10px] font-semibold opacity-70">Copy</span>
                              </button>
                            </div>
                          )}

                          {/* Account number — shown ALWAYS if present (alongside phone) */}
                          {hasAccNum && (
                            <div className={`rounded-xl px-4 py-3 border ${cfg.badgeColor} flex items-center justify-between gap-3`}>
                              <div className="min-w-0">
                                <p className="text-[10px] uppercase tracking-widest font-bold opacity-60 mb-0.5 flex items-center gap-1">
                                  <Building size={10} /> Account Number
                                </p>
                                <p className="font-black text-xl tracking-widest font-mono">{selectedPm.account_number}</p>
                                <p className="text-xs opacity-60 mt-0.5">For bank transfer</p>
                              </div>
                              <button onClick={() => copy(selectedPm.account_number, 'Account number')}
                                className="flex flex-col items-center gap-1 p-3 rounded-xl hover:bg-black/10 transition-colors flex-shrink-0" title="Copy account">
                                <Copy size={18} />
                                <span className="text-[10px] font-semibold opacity-70">Copy</span>
                              </button>
                            </div>
                          )}

                          {/* Instructions */}
                          {selectedPm.instructions && (
                            <div className={`rounded-xl px-4 py-3 border ${cfg.badgeColor} flex items-start gap-2`}>
                              <Info size={14} className="flex-shrink-0 mt-0.5 opacity-70" />
                              <p className="text-sm leading-relaxed">{selectedPm.instructions}</p>
                            </div>
                          )}

                          {/* Amount reminder */}
                          <div className="bg-amber-50 border border-amber-200 rounded-xl px-4 py-3 flex items-center gap-2">
                            <span className="text-amber-600 text-lg flex-shrink-0">⚠️</span>
                            <p className="text-sm text-amber-800">
                              Send exactly <strong className="text-amber-900 font-extrabold">ETB {total.toLocaleString()}</strong>.
                              Include your <strong>booking reference</strong> in the transfer note.
                            </p>
                          </div>
                        </div>
                      </motion.div>
                    )
                  })()}
                </AnimatePresence>

                {/* ── Upload payment proof ── */}
                {form.payment_method && (
                  <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-5">
                    <h2 className="font-bold text-gray-800 flex items-center gap-2">
                      <Upload size={18} className="text-blue-600" /> Upload Payment Proof
                    </h2>

                    <F label="Transaction ID / Reference Number" required
                      error={touched.transaction_id ? e2.transaction_id : null}
                      hint="The reference number shown in the transfer confirmation">
                      <div className="relative">
                        <Smartphone size={15} className="absolute left-3 top-3 text-gray-400" />
                        <input value={form.transaction_id}
                          onChange={set('transaction_id')} onBlur={blur('transaction_id')}
                          placeholder="e.g. TXN123456789 or FT12345678"
                          className={inputCls(e2.transaction_id, !!touched.transaction_id) + ' pl-9 font-mono'} />
                      </div>
                    </F>

                    <div>
                      <p className="text-sm font-semibold text-gray-700 mb-2">
                        Payment Screenshot <span className="text-red-500">*</span>
                        <span className="text-xs text-gray-400 font-normal ml-2">— take a screenshot of the transfer confirmation</span>
                      </p>
                      <label className={`block border-2 border-dashed rounded-2xl p-5 text-center cursor-pointer transition-all ${
                        uploading.screenshot_url              ? 'border-blue-400 bg-blue-50 opacity-70'
                        : form.screenshot_url                 ? 'border-emerald-400 bg-emerald-50'
                        : touched.screenshot_url && e2.screenshot_url ? 'border-red-400 bg-red-50'
                        : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
                      }`}>
                        {uploading.screenshot_url ? (
                          <div className="space-y-2">
                            <div className="w-8 h-8 border-2 border-blue-400 border-t-blue-600 rounded-full animate-spin mx-auto" />
                            <p className="text-sm text-blue-600 font-medium">Processing screenshot…</p>
                          </div>
                        ) : form.screenshot_url ? (
                          <div>
                            <img src={form.screenshot_url} alt="screenshot" className="max-h-44 mx-auto rounded-xl shadow-sm mb-2 object-contain" />
                            <p className="text-xs text-emerald-600 font-semibold flex items-center justify-center gap-1">
                              <Check size={13} /> Screenshot attached
                            </p>
                            <span onClick={(e) => { e.preventDefault(); setForm(f => ({ ...f, screenshot_url: '' })); setTouched(t => ({ ...t, screenshot_url: true })) }}
                              className="text-xs text-red-400 mt-1 inline-block cursor-pointer hover:text-red-600">Remove</span>
                          </div>
                        ) : (
                          <div className="space-y-1.5">
                            <Upload size={32} className="mx-auto text-gray-400" />
                            <p className="text-sm font-medium text-gray-600">Click to upload screenshot</p>
                            <p className="text-xs text-gray-400">PNG or JPG, max 5 MB — <strong>Required</strong></p>
                          </div>
                        )}
                        <input type="file" accept="image/*" onChange={pickImg('screenshot_url')} className="hidden" disabled={uploading.screenshot_url} />
                      </label>
                      {touched.screenshot_url && e2.screenshot_url && (
                        <p className="text-red-500 text-xs mt-1.5 flex items-center gap-1">
                          <AlertCircle size={11} /> {e2.screenshot_url}
                        </p>
                      )}
                    </div>
                  </div>
                )}

                {/* ── Final summary ── */}
                <div className="bg-gradient-to-r from-emerald-50 to-blue-50 rounded-2xl p-5 border border-emerald-100">
                  <div className="flex justify-between items-center gap-4">
                    <div className="text-sm text-gray-600 space-y-0.5">
                      <p className="font-semibold text-gray-800">{hotel?.name}</p>
                      <p>{form.check_in} → {form.check_out} · {nights} night{nights > 1 ? 's' : ''}</p>
                      <p>{form.first_name} {form.last_name} · {form.adults} adult{Number(form.adults) > 1 ? 's' : ''}{Number(form.children) > 0 ? ` · ${form.children} child${Number(form.children) > 1 ? 'ren' : ''}` : ''}</p>
                      {preRoomName && <p className="text-blue-600 font-medium">{preRooms}× {preRoomName}</p>}
                      {form.payment_method && (
                        <p className="flex items-center gap-1 text-purple-700 font-medium">
                          <CreditCard size={12} /> {PM_CONFIG[form.payment_method]?.label || form.payment_method}
                        </p>
                      )}
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className="text-3xl font-extrabold text-gray-900">ETB {total.toLocaleString()}</p>
                      <p className="text-xs text-gray-400">{nights} night{nights > 1 ? 's' : ''} · {preRooms} room{preRooms > 1 ? 's' : ''}</p>
                    </div>
                  </div>
                </div>

                {/* ── Buttons ── */}
                <div className="flex gap-3 pb-6">
                  <button onClick={() => { setStep(1); window.scrollTo(0, 0) }}
                    className="flex items-center gap-2 px-5 py-3.5 rounded-2xl border-2 border-gray-200 text-gray-600 hover:bg-gray-50 font-semibold transition-all">
                    <ChevronLeft size={18} /> Back
                  </button>
                  <button onClick={submit} disabled={submitting}
                    className="flex-1 flex items-center justify-center gap-2 bg-emerald-600 text-white py-3.5 rounded-2xl font-extrabold text-base hover:bg-emerald-700 active:scale-[.98] transition-all shadow-lg hover:shadow-emerald-200 disabled:opacity-50">
                    {submitting ? (
                      <><div className="w-5 h-5 border-2 border-white/40 border-t-white rounded-full animate-spin" /> Processing…</>
                    ) : (
                      <><Check size={20} /> Confirm &amp; Submit — ETB {total.toLocaleString()}</>
                    )}
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </>
  )
}

// pages/booking/BookingConfirm.tsx — 2-step booking: Guest Info → Payment
import { useState, useEffect } from 'react'
import { useParams, useNavigate, useSearchParams } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Users, CreditCard, Upload, Check, ChevronRight, ChevronLeft,
  Bed, Copy, Phone, Building, Wallet, Smartphone, Info,
  AlertCircle, IdCard, Mail, Calendar, User, MapPin, Lock
} from 'lucide-react'
import { Link } from 'react-router-dom'
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
  hasErrors, FieldError
} from '../../utils/validate'

// ─── helpers ──────────────────────────────────────────────────────────────────
const today    = () => new Date().toISOString().split('T')[0]
const tomorrow = () => { const d = new Date(); d.setDate(d.getDate() + 1); return d.toISOString().split('T')[0] }

// ─── All Ethiopian payment methods (no cash, no card, no mobile_money) ────────
const PM_CONFIG: Record<string, {
  label: string; logo: string; bgGrad: string; badgeColor: string
}> = {
  telebirr:     { label: 'Telebirr',              logo: '📱', bgGrad: 'from-green-500 to-emerald-600',   badgeColor: 'bg-green-50 border-green-200 text-green-800'   },
  cbe_birr:     { label: 'CBE Birr',              logo: '🏦', bgGrad: 'from-amber-500 to-yellow-600',    badgeColor: 'bg-amber-50 border-amber-200 text-amber-800'   },
  chapa:        { label: 'Chapa',                 logo: '🔵', bgGrad: 'from-blue-500 to-blue-600',       badgeColor: 'bg-blue-50 border-blue-200 text-blue-800'      },
  bank_transfer:{ label: 'CBE Transfer',          logo: '🏛️', bgGrad: 'from-sky-500 to-cyan-600',        badgeColor: 'bg-sky-50 border-sky-200 text-sky-800'         },
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

  const [step, setStep]         = useState(1)  // 1 = guest + dates, 2 = payment
  const [submitting, setSub]    = useState(false)
  const [payMethods, setPayMethods] = useState<any[]>([])
  const [pmLoading, setPmLoad]  = useState(true)
  const [touched, setTouched]   = useState<Record<string, boolean>>({})

  const [form, setForm] = useState({
    first_name:   user?.first_name || '',
    last_name:    user?.last_name  || '',
    email:        user?.email      || '',
    phone:        user?.phone      || '',
    password:     '',
    nationality:  '',
    check_in:     preCheckIn,
    check_out:    preCheckOut,
    adults:       1,
    children:     0,
    rooms:        1,
    special_requests: '',
    national_id_front: '',
    national_id_back:  '',
    payment_method:    '',
    transaction_id:    '',
    screenshot_url:    '',
  })

  const nights   = Math.max(1, Math.round((new Date(form.check_out).getTime() - new Date(form.check_in).getTime()) / 86400000))
  const unitPrice = preRoomPrice || hotel?.price_per_night || 0
  const total     = unitPrice * nights * Number(form.rooms)

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
    first_name: validateName(form.first_name, 'First name'),
    last_name:  validateName(form.last_name, 'Last name'),
    email:      validateEmail(form.email, !form.phone),
    phone:      validatePhone(form.phone, !form.email),
    check_in:   validateFutureDate(form.check_in, 'Check-in'),
    check_out:  validateDateRange(form.check_in, form.check_out),
    adults:     validatePositiveNumber(form.adults, 'Adults'),
    rooms:      validatePositiveNumber(form.rooms, 'Rooms'),
  }

  // ── Step 2 validation ─────────────────────────────────────────────────────
  const e2 = {
    payment_method: !form.payment_method ? 'Select a payment method' : null,
    transaction_id: validateTransactionId(form.transaction_id),
  }

  const touchAll = (errs: Record<string, FieldError>) =>
    setTouched(t => ({ ...t, ...Object.fromEntries(Object.keys(errs).map(k => [k, true])) }))

  const goStep2 = () => {
    touchAll(e1)
    if (!hasErrors(e1)) { setStep(2); window.scrollTo(0, 0) }
    else toast.error('Please fix the errors highlighted in red')
  }

  // Image pickers
  const pickImg = (field: 'national_id_front' | 'national_id_back' | 'screenshot_url') =>
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0]
      if (!file) return
      const url = URL.createObjectURL(file)
      setForm(f => ({ ...f, [field]: url }))
      toast.success(field === 'screenshot_url' ? 'Screenshot attached ✓' : 'ID photo attached ✓')
    }

  const copy = (text: string, label: string) => {
    navigator.clipboard.writeText(text)
    toast.success(`${label} copied!`)
  }

  // Submit
  const submit = async () => {
    touchAll(e2)
    if (hasErrors(e2)) { toast.error('Please add transaction ID'); return }
    setSub(true)
    try {
      const guestEmail = form.email.trim() || undefined
      const guestPhone = form.phone.trim() || undefined
      const natFront   = form.national_id_front || undefined
      const natBack    = form.national_id_back  || undefined
      const guestFull  = `${form.first_name.trim()} ${form.last_name.trim()}`

      // If user is NOT logged in, try to auto-register or login first
      let authToken = localStorage.getItem('token')

      if (!authToken && guestEmail) {
        try {
          // Try login first (returning user)
          const loginRes = await import('../../services/auth').then(m =>
            m.authService.login(guestEmail, form.password || 'guest123')
          )
          localStorage.setItem('token', loginRes.data.data.token)
          localStorage.setItem('user', JSON.stringify(loginRes.data.data.user))
          authToken = loginRes.data.data.token
        } catch {
          // Login failed → try register as new user
          try {
            const regRes = await import('../../services/auth').then(m =>
              m.authService.register({
                first_name: form.first_name.trim(),
                last_name:  form.last_name.trim(),
                email:      guestEmail,
                phone:      guestPhone,
                password:   form.password || 'guest123',
              })
            )
            localStorage.setItem('token', regRes.data.data.token)
            localStorage.setItem('user', JSON.stringify(regRes.data.data.user))
            authToken = regRes.data.data.token
          } catch (regErr: any) {
            // If email already exists but wrong password, show error
            toast.error(regErr.response?.data?.message || 'Please sign in first')
            navigate('/login')
            return
          }
        }
      }

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
                      <p className="text-blue-200 text-xs">{form.rooms} room{Number(form.rooms) > 1 ? 's' : ''} total</p>
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

                  {/* Password field — for new users to auto-register, or returning users to verify */}
                  {!user && (
                    <F label="Create Password" error={null}
                      hint="Set a password for your account — you can use it to log in next time">
                      <div className="relative">
                        <Lock size={15} className="absolute left-3 top-3 text-gray-400" />
                        <input type="password" value={form.password} onChange={set('password')}
                          placeholder="Min 6 characters"
                          className="w-full border border-gray-200 rounded-xl px-3 py-2.5 pl-9 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
                      </div>
                    </F>
                  )}

                  {/* Login link for returning users */}
                  {!user && (
                    <div className="flex items-center justify-between bg-purple-50 rounded-xl p-3 border border-purple-100">
                      <p className="text-xs text-purple-700">
                        Already booked before? Sign in to skip the form.
                      </p>
                      <Link to="/login" className="text-xs text-purple-600 font-semibold hover:underline flex items-center gap-1">
                        Sign In <ChevronRight size={12} />
                      </Link>
                    </div>
                  )}
                </div>

                {/* ── Dates & Guests ── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-4">
                  <h2 className="font-bold text-gray-800 flex items-center gap-2">
                    <Calendar size={18} className="text-blue-600" /> Stay Details
                  </h2>
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
                  <div className="grid grid-cols-3 gap-4">
                    {([
                      { k: 'adults' as const,   label: 'Adults',   min: 1, err: e1.adults },
                      { k: 'children' as const, label: 'Children', min: 0, err: null       },
                      { k: 'rooms' as const,    label: 'Rooms',    min: 1, err: e1.rooms   },
                    ]).map(f => (
                      <F key={f.k} label={f.label} error={touched[f.k] ? f.err as FieldError : null} required={f.min > 0}>
                        <div className="flex items-center border border-gray-200 rounded-xl overflow-hidden">
                          <button type="button" onClick={() => inc(f.k, f.min)(-1)}
                            className="px-3 py-2.5 text-gray-500 hover:bg-gray-100 font-bold border-r border-gray-200 text-lg">−</button>
                          <span className="flex-1 text-center text-sm font-semibold py-2.5 bg-white">{(form as any)[f.k]}</span>
                          <button type="button" onClick={() => inc(f.k, f.min)(1)}
                            className="px-3 py-2.5 text-gray-500 hover:bg-gray-100 font-bold border-l border-gray-200 text-lg">+</button>
                        </div>
                      </F>
                    ))}
                  </div>
                  <F label="Special Requests" error={null}>
                    <textarea value={form.special_requests} onChange={e => setForm(f => ({ ...f, special_requests: e.target.value }))}
                      rows={2} placeholder="Early check-in, room preferences, allergies…"
                      className="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:ring-2 focus:ring-blue-400 outline-none resize-none" />
                  </F>
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
                      { field: 'national_id_front' as const, label: 'Front Side', icon: '🪪' },
                      { field: 'national_id_back'  as const, label: 'Back Side',  icon: '🪪' },
                    ]).map(({ field, label, icon }) => (
                      <div key={field}>
                        <p className="text-sm font-semibold text-gray-700 mb-2">{label}</p>
                        <label className={`block border-2 border-dashed rounded-xl cursor-pointer transition-all ${
                          form[field] ? 'border-emerald-400 bg-emerald-50' : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
                        }`}>
                          {form[field] ? (
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
                              <p className="text-[10px] text-gray-400">JPG or PNG</p>
                            </div>
                          )}
                          <input type="file" accept="image/*" onChange={pickImg(field)} className="hidden" />
                        </label>
                        {form[field] && (
                          <button onClick={() => setForm(f => ({ ...f, [field]: '' }))}
                            className="text-xs text-red-400 mt-1 hover:text-red-600 w-full text-center">
                            Remove
                          </button>
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

                {/* Summary banner */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 flex items-center gap-3">
                  <img src={hotel?.images?.[0] || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=80'}
                    alt="" className="w-14 h-14 rounded-xl object-cover flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-gray-800 truncate">{hotel?.name}</p>
                    {preRoomName && <p className="text-xs text-blue-600 flex items-center gap-1"><Bed size={11} /> {preRoomName}</p>}
                    <p className="text-xs text-gray-500">{form.check_in} → {form.check_out} · {nights}N · {form.adults} adults</p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-xl font-extrabold text-gray-900">ETB {total.toLocaleString()}</p>
                    <p className="text-[11px] text-gray-400">Total amount</p>
                  </div>
                </div>

                {/* Payment method grid */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                  <h2 className="font-bold text-gray-800 flex items-center gap-2 mb-4">
                    <CreditCard size={18} className="text-blue-600" /> Select Payment Method
                  </h2>

                  {pmLoading ? (
                    <div className="flex items-center justify-center py-10 gap-2 text-gray-400">
                      <div className="w-5 h-5 border-2 border-blue-300 border-t-blue-600 rounded-full animate-spin" />
                      Loading payment options…
                    </div>
                  ) : payMethods.length === 0 ? (
                    <p className="text-center text-gray-400 py-6 text-sm">No payment methods configured for this hotel.</p>
                  ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                      {payMethods.map((pm: any) => {
                        const cfg = PM_CONFIG[pm.method] || { label: pm.method, logo: '🏦', bgGrad: 'from-gray-500 to-gray-600', badgeColor: '' }
                        const sel = form.payment_method === pm.method
                        return (
                          <button key={pm.id}
                            onClick={() => setForm(f => ({ ...f, payment_method: pm.method, transaction_id: '' }))}
                            className={`relative p-4 rounded-2xl border-2 text-left transition-all duration-200 group ${
                              sel ? 'border-blue-500 shadow-md shadow-blue-100 scale-[1.03]'
                                  : 'border-gray-200 hover:border-blue-300 hover:shadow-sm'
                            }`}>
                            {sel && (
                              <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }}
                                className="absolute top-2 right-2 w-5 h-5 bg-blue-600 rounded-full flex items-center justify-center">
                                <Check size={11} className="text-white" />
                              </motion.div>
                            )}
                            <div className={`w-10 h-10 rounded-xl bg-gradient-to-br ${cfg.bgGrad} flex items-center justify-center mb-2.5 shadow-sm`}>
                              <span className="text-xl">{cfg.logo}</span>
                            </div>
                            <p className="font-bold text-gray-800 text-xs leading-tight">{cfg.label}</p>
                            {(pm.phone_number || pm.account_number) && (
                              <p className="text-[10px] text-gray-400 mt-0.5 font-mono truncate">
                                {pm.phone_number || pm.account_number?.slice(0, 10) + '…'}
                              </p>
                            )}
                          </button>
                        )
                      })}
                    </div>
                  )}
                </div>

                {/* Account details card */}
                <AnimatePresence mode="wait">
                  {selectedPm && (
                    <motion.div key={selectedPm.method}
                      initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}
                      className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                      <div className={`bg-gradient-to-r ${pmCfg.bgGrad} px-5 py-3.5 flex items-center gap-3`}>
                        <span className="text-2xl">{pmCfg.logo}</span>
                        <div>
                          <p className="text-white font-bold">{pmCfg.label}</p>
                          <p className="text-white/70 text-xs">Send the exact amount and note your Booking ID</p>
                        </div>
                      </div>
                      <div className="p-5 space-y-3">
                        {selectedPm.account_name && (
                          <div className={`flex items-center justify-between rounded-xl px-4 py-3 border ${pmCfg.badgeColor}`}>
                            <div>
                              <p className="text-[10px] uppercase tracking-wider font-semibold opacity-60">Account Name</p>
                              <p className="font-semibold text-sm mt-0.5">{selectedPm.account_name}</p>
                            </div>
                            <button onClick={() => copy(selectedPm.account_name, 'Account name')}
                              className="p-2 rounded-lg hover:bg-black/10 transition-colors"><Copy size={14} /></button>
                          </div>
                        )}
                        {selectedPm.phone_number && (
                          <div className={`flex items-center justify-between rounded-xl px-4 py-3 border ${pmCfg.badgeColor}`}>
                            <div>
                              <p className="text-[10px] uppercase tracking-wider font-semibold opacity-60">Phone / Wallet Number</p>
                              <p className="font-black text-lg tracking-widest font-mono">{selectedPm.phone_number}</p>
                            </div>
                            <button onClick={() => copy(selectedPm.phone_number, 'Phone')}
                              className="p-2 rounded-lg hover:bg-black/10 transition-colors"><Copy size={14} /></button>
                          </div>
                        )}
                        {selectedPm.account_number && !selectedPm.phone_number && (
                          <div className={`flex items-center justify-between rounded-xl px-4 py-3 border ${pmCfg.badgeColor}`}>
                            <div>
                              <p className="text-[10px] uppercase tracking-wider font-semibold opacity-60">Account Number</p>
                              <p className="font-black text-lg tracking-widest font-mono">{selectedPm.account_number}</p>
                            </div>
                            <button onClick={() => copy(selectedPm.account_number, 'Account number')}
                              className="p-2 rounded-lg hover:bg-black/10 transition-colors"><Copy size={14} /></button>
                          </div>
                        )}
                        {selectedPm.instructions && (
                          <div className={`flex items-start gap-2 rounded-xl px-4 py-3 border ${pmCfg.badgeColor}`}>
                            <Info size={14} className="mt-0.5 flex-shrink-0 opacity-70" />
                            <p className="text-sm">{selectedPm.instructions}</p>
                          </div>
                        )}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>

                {/* Transaction proof */}
                {form.payment_method && (
                  <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 space-y-5">
                    <h2 className="font-bold text-gray-800 flex items-center gap-2">
                      <Upload size={18} className="text-blue-600" /> Upload Payment Proof
                    </h2>

                    <F label="Transaction ID / Reference Number" required
                      error={touched.transaction_id ? e2.transaction_id : null}
                      hint="Enter the transaction reference shown after your transfer">
                      <input value={form.transaction_id}
                        onChange={set('transaction_id')} onBlur={blur('transaction_id')}
                        placeholder="e.g. TXN123456789"
                        className={inputCls(e2.transaction_id, !!touched.transaction_id) + ' font-mono'} />
                    </F>

                    <div>
                      <p className="text-sm font-semibold text-gray-700 mb-2">
                        Payment Screenshot <span className="text-gray-400 text-xs font-normal">(optional but recommended)</span>
                      </p>
                      <label className={`block border-2 border-dashed rounded-2xl p-5 text-center cursor-pointer transition-all ${
                        form.screenshot_url ? 'border-emerald-400 bg-emerald-50' : 'border-gray-300 hover:border-blue-400 hover:bg-blue-50'
                      }`}>
                        {form.screenshot_url ? (
                          <div>
                            <img src={form.screenshot_url} alt="screenshot" className="max-h-40 mx-auto rounded-xl shadow-sm mb-2" />
                            <p className="text-xs text-emerald-600 font-semibold flex items-center justify-center gap-1">
                              <Check size={13} /> Screenshot attached
                            </p>
                            <span onClick={() => setForm(f => ({ ...f, screenshot_url: '' }))}
                              className="text-xs text-red-400 mt-1 inline-block cursor-pointer hover:text-red-600">Remove</span>
                          </div>
                        ) : (
                          <div className="space-y-1.5">
                            <Upload size={32} className="mx-auto text-gray-400" />
                            <p className="text-sm font-medium text-gray-600">Click to upload screenshot</p>
                            <p className="text-xs text-gray-400">PNG, JPG up to 5MB</p>
                          </div>
                        )}
                        <input type="file" accept="image/*" onChange={pickImg('screenshot_url')} className="hidden" />
                      </label>
                    </div>
                  </div>
                )}

                {/* Final total */}
                <div className="bg-gradient-to-r from-emerald-50 to-blue-50 rounded-2xl p-5 border border-emerald-100">
                  <div className="flex justify-between items-center">
                    <div className="text-sm text-gray-600 space-y-0.5">
                      <p className="font-semibold text-gray-800">{hotel?.name}</p>
                      <p>{form.check_in} → {form.check_out}</p>
                      <p>{form.first_name} {form.last_name} · {form.adults} adult{Number(form.adults) > 1 ? 's' : ''}</p>
                      {preRoomName && <p className="text-blue-600">{preRoomName}</p>}
                    </div>
                    <div className="text-right">
                      <p className="text-3xl font-extrabold text-gray-900">ETB {total.toLocaleString()}</p>
                      <p className="text-xs text-gray-400">{nights} nights · {form.rooms} room{Number(form.rooms) > 1 ? 's' : ''}</p>
                    </div>
                  </div>
                </div>

                {/* Buttons */}
                <div className="flex gap-3 pb-4">
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

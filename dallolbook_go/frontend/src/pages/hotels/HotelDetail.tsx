// pages/hotels/HotelDetail.tsx
import { useState, useEffect, useCallback } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  MapPin, Heart, Check, MessageSquare, Star,
  Calendar, Bed, ChevronRight, ChevronLeft, Wifi,
  Coffee, Car, Waves, Dumbbell, UtensilsCrossed,
  Users, Lock, Clock, Plus, Minus, X, ZoomIn, Image
} from 'lucide-react'
import toast from 'react-hot-toast'
import { useTranslation } from 'react-i18next'
import { useHotel } from '../../hooks/useHotels'
import { hotelService } from '../../services/hotels'
import { wishlistService } from '../../services/wishlist'
import { useAuth } from '../../context/AuthContext'
import Navbar from '../../components/shared/Navbar'
import Footer from '../../components/shared/Footer'
import Spinner from '../../components/shared/Spinner'
import StarRating from '../../components/hotel/StarRating'

const today    = () => new Date().toISOString().split('T')[0]
const tomorrow = () => { const d = new Date(); d.setDate(d.getDate() + 1); return d.toISOString().split('T')[0] }

const AMENITY_ICONS: Record<string, any> = {
  'Free WiFi': Wifi, 'WiFi': Wifi, 'Restaurant': UtensilsCrossed,
  'Swimming Pool': Waves, 'Pool': Waves, 'Gym': Dumbbell, 'Fitness': Dumbbell,
  'Parking': Car, 'Breakfast': Coffee,
}

// Room quantity selection type
interface RoomQty { room: any; qty: number }

export default function HotelDetail() {
  const { t } = useTranslation()
  const { id } = useParams()
  const navigate = useNavigate()
  const { isAuthenticated } = useAuth()
  const { hotel, loading } = useHotel(Number(id))

  const [activeImg, setActiveImg]   = useState(0)
  const [lightbox, setLightbox]     = useState(false)
  const [slideDir, setSlideDir]     = useState(1)
  const [imgCount, setImgCount]     = useState(1)   // kept in state so hooks are stable
  const [wishlisted, setWishlisted] = useState(false)
  const [reviews, setReviews]       = useState<any[]>([])
  const [reviewForm, setReviewForm] = useState({ rating: 5, comment: '' })
  const [showReviewForm, setShowReviewForm] = useState(false)
  const [submittingReview, setSubmittingReview] = useState(false)
  const [contactPhone, setContactPhone] = useState('')

  // Dates
  const [checkIn, setCheckIn]   = useState(today())
  const [checkOut, setCheckOut] = useState(tomorrow())
  const nights = Math.max(1, Math.round(
    (new Date(checkOut).getTime() - new Date(checkIn).getTime()) / 86400000
  ))

  // ALL rooms (available + occupied)
  const [allRooms, setAllRooms]       = useState<any[]>([])
  const [roomsLoading, setRoomsLoading] = useState(false)

  // Room qty map: { roomId: qty }
  const [roomQty, setRoomQty] = useState<Record<number, number>>({})

  // Derived: selected rooms as array, total price, total rooms count
  const selectedRooms: RoomQty[] = allRooms
    .filter(r => (roomQty[r.id] || 0) > 0)
    .map(r => ({ room: r, qty: roomQty[r.id] }))

  const totalRooms = selectedRooms.reduce((s, x) => s + x.qty, 0)
  const totalPrice = selectedRooms.reduce((s, x) => s + x.room.price_per_night * x.qty * nights, 0)

  // Max capacity across selected rooms
  const maxCapacity = selectedRooms.reduce((s, x) => s + x.room.max_guests * x.qty, 0)

  const loadRooms = async (cIn: string, cOut: string) => {
    if (!id) return
    setRoomsLoading(true)
    setRoomQty({}) // reset selection on date change
    try {
      const res = await hotelService.getAvailability(Number(id), cIn, cOut)
      setAllRooms(res.data.data?.rooms || [])
    } catch { setAllRooms([]) }
    setRoomsLoading(false)
  }

  useEffect(() => {
    if (id) {
      loadRooms(checkIn, checkOut)
      hotelService.getReviews(Number(id), 6, 0)
        .then(r => setReviews(r.data.data?.reviews || []))
        .catch(() => {})
      hotelService.getPaymentMethods(Number(id))
        .then(res => {
          const m = res.data.data || []
          const t = m.find((x: any) => x.method === 'telebirr') || m.find((x: any) => x.method === 'cbe_birr')
          setContactPhone(t?.phone_number || '')
        })
        .catch(() => {})
    }
  }, [id])

  useEffect(() => { if (id) loadRooms(checkIn, checkOut) }, [checkIn, checkOut])

  const changeQty = (roomId: number, delta: number, maxGuests: number) => {
    const current = roomQty[roomId] || 0
    const next = Math.max(0, Math.min(2, current + delta)) // max 2 per room type
    setRoomQty(q => ({ ...q, [roomId]: next }))
  }

  const handleBook = () => {
    if (selectedRooms.length === 0) { toast.error('Please select at least one room'); return }
    if (!isAuthenticated) {
      // Build redirect with all selected rooms
      const primary = selectedRooms[0]
      const params = new URLSearchParams({
        check_in:   checkIn,
        check_out:  checkOut,
        nights:     String(nights),
        room_id:    String(primary.room.id),
        room_name:  primary.room.name,
        room_price: String(primary.room.price_per_night),
        rooms:      String(totalRooms),
        max_guests: String(maxCapacity),
      })
      navigate(`/login?redirect=${encodeURIComponent(`/booking/${id}?${params.toString()}`)}`)
      return
    }
    const primary = selectedRooms[0]
    const params = new URLSearchParams({
      check_in:   checkIn,
      check_out:  checkOut,
      nights:     String(nights),
      room_id:    String(primary.room.id),
      room_name:  primary.room.name,
      room_price: String(primary.room.price_per_night),
      rooms:      String(totalRooms),
      max_guests: String(maxCapacity),
    })
    navigate(`/booking/${id}?${params.toString()}`)
  }

  const toggleWishlist = async () => {
    if (!isAuthenticated) { navigate('/login'); return }
    try {
      const res = await wishlistService.toggle(hotel.id)
      setWishlisted(res.data.data.action === 'added')
      toast.success(res.data.data.action === 'added' ? 'Added to wishlist ♥' : 'Removed from wishlist')
    } catch { toast.error('Failed') }
  }

  const submitReview = async () => {
    if (!isAuthenticated) { navigate('/login'); return }
    if (reviewForm.comment.trim().length < 5) { toast.error('Comment must be at least 5 characters'); return }
    setSubmittingReview(true)
    try {
      await hotelService.postReview(hotel.id, reviewForm.rating, reviewForm.comment)
      toast.success('Review posted!')
      setReviewForm({ rating: 5, comment: '' })
      setShowReviewForm(false)
      const r = await hotelService.getReviews(Number(id), 6, 0)
      setReviews(r.data.data?.reviews || [])
    } catch (e: any) { toast.error(e.response?.data?.message || 'Failed to post review') }
    setSubmittingReview(false)
  }

  // Sync imgCount when hotel loads so gallery callbacks are stable
  useEffect(() => {
    if (hotel?.images?.length) setImgCount(hotel.images.length)
  }, [hotel])

  // ── Gallery navigation — ALL hooks must be above early returns ────────────
  const goNext = useCallback((e?: React.MouseEvent) => {
    e?.stopPropagation()
    setSlideDir(1)
    setActiveImg(i => (i + 1) % imgCount)
  }, [imgCount])

  const goPrev = useCallback((e?: React.MouseEvent) => {
    e?.stopPropagation()
    setSlideDir(-1)
    setActiveImg(i => (i - 1 + imgCount) % imgCount)
  }, [imgCount])

  const goTo = useCallback((i: number) => {
    setSlideDir(i > activeImg ? 1 : -1)
    setActiveImg(i)
  }, [activeImg])

  // Keyboard nav for lightbox
  useEffect(() => {
    if (!lightbox) return
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'ArrowRight') goNext()
      if (e.key === 'ArrowLeft')  goPrev()
      if (e.key === 'Escape')     setLightbox(false)
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [lightbox, goNext, goPrev])

  // ── Early returns (MUST be after all hooks) ───────────────────────────────
  if (loading) return <><Navbar /><div className="flex justify-center items-center min-h-screen"><Spinner size="lg" /></div></>
  if (!hotel)  return <><Navbar /><div className="text-center py-20 text-gray-400">Hotel not found</div></>

  const images = hotel.images?.length ? hotel.images : ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800']
  const availableRooms = allRooms.filter((r: any) => !r.is_occupied && r.room_status === 'available')
  const occupiedRooms  = allRooms.filter((r: any) => r.is_occupied || r.room_status !== 'available')

  return (
    <>
      {/* ── Lightbox ─────────────────────────────────────────────────── */}
      <AnimatePresence>
        {lightbox && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] bg-black/95 flex flex-col items-center justify-center"
            onClick={() => setLightbox(false)}>
            {/* Close */}
            <button onClick={() => setLightbox(false)}
              className="absolute top-4 right-4 text-white/70 hover:text-white p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors z-10">
              <X size={24} />
            </button>
            {/* Counter */}
            <p className="absolute top-4 left-1/2 -translate-x-1/2 text-white/60 text-sm">
              {activeImg + 1} / {images.length}
            </p>
            {/* Main image with slide animation */}
            <div className="w-full max-w-5xl px-16 relative" onClick={e => e.stopPropagation()}>
              <AnimatePresence mode="wait" custom={slideDir}>
                <motion.img
                  key={activeImg}
                  custom={slideDir}
                  variants={{
                    enter: (d: number) => ({ x: d > 0 ? 200 : -200, opacity: 0 }),
                    center: { x: 0, opacity: 1 },
                    exit: (d: number) => ({ x: d > 0 ? -200 : 200, opacity: 0 }),
                  }}
                  initial="enter"
                  animate="center"
                  exit="exit"
                  transition={{ duration: 0.3, ease: 'easeInOut' }}
                  src={images[activeImg]}
                  alt={`${hotel.name} ${activeImg + 1}`}
                  className="w-full max-h-[70vh] object-contain rounded-xl"
                />
              </AnimatePresence>
              {/* Prev / Next arrows */}
              {images.length > 1 && (
                <>
                  <button onClick={goPrev}
                    className="absolute left-2 top-1/2 -translate-y-1/2 bg-white/10 hover:bg-white/25 text-white p-3 rounded-full transition-all backdrop-blur-sm">
                    <ChevronLeft size={24} />
                  </button>
                  <button onClick={goNext}
                    className="absolute right-2 top-1/2 -translate-y-1/2 bg-white/10 hover:bg-white/25 text-white p-3 rounded-full transition-all backdrop-blur-sm">
                    <ChevronRight size={24} />
                  </button>
                </>
              )}
            </div>
            {/* Thumbnail strip */}
            {images.length > 1 && (
              <div className="flex gap-2 mt-4 px-4 overflow-x-auto max-w-full pb-2" onClick={e => e.stopPropagation()}>
                {images.map((img: string, i: number) => (
                  <motion.button
                    key={i}
                    onClick={() => goTo(i)}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    className={`flex-shrink-0 w-16 h-12 rounded-lg overflow-hidden border-2 transition-all ${
                      i === activeImg ? 'border-white shadow-lg shadow-white/20' : 'border-transparent opacity-50 hover:opacity-80'
                    }`}>
                    <img src={img} alt="" className="w-full h-full object-cover" />
                  </motion.button>
                ))}
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      <Navbar />
      <div className="max-w-6xl mx-auto px-4 py-8">

        {/* ── Gallery ─────────────────────────────────────────────────── */}
        <div className="relative mb-8 rounded-2xl overflow-hidden group">
          {/* Main image with slide animation */}
          <div className="relative h-80 md:h-[420px] overflow-hidden cursor-zoom-in" onClick={() => setLightbox(true)}>
            <AnimatePresence mode="wait" custom={slideDir}>
              <motion.img
                key={activeImg}
                custom={slideDir}
                variants={{
                  enter: (d: number) => ({ x: d > 0 ? 120 : -120, opacity: 0 }),
                  center: { x: 0, opacity: 1 },
                  exit: (d: number) => ({ x: d > 0 ? -120 : 120, opacity: 0 }),
                }}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{ duration: 0.4, ease: 'easeInOut' }}
                src={images[activeImg]}
                alt={hotel.name}
                className="w-full h-full object-cover absolute inset-0"
              />
            </AnimatePresence>

            {/* Gradient overlays */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent pointer-events-none" />
            <div className="absolute inset-0 bg-gradient-to-b from-black/20 via-transparent to-transparent pointer-events-none" />

            {/* Featured badge */}
            {hotel.is_featured && (
              <motion.span
                initial={{ scale: 0, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: 0.3, type: 'spring' }}
                className="absolute top-4 left-4 bg-amber-500 text-white text-sm font-bold px-4 py-1.5 rounded-full shadow-lg">
                ★ {t('detail.featured')}
              </motion.span>
            )}

            {/* Image counter */}
            <div className="absolute top-4 right-4 bg-black/40 backdrop-blur-sm text-white text-xs px-3 py-1.5 rounded-full flex items-center gap-1.5">
              <Image size={12} /> {activeImg + 1} / {images.length}
            </div>

            {/* Zoom hint */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1 }}
              className="absolute bottom-4 right-4 bg-black/40 backdrop-blur-sm text-white text-xs px-3 py-1.5 rounded-full flex items-center gap-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
              <ZoomIn size={12} /> Click to expand
            </motion.div>

            {/* Prev/Next on main image */}
            {images.length > 1 && (
              <>
                <button
                  onClick={e => { e.stopPropagation(); goPrev() }}
                  className="absolute left-3 top-1/2 -translate-y-1/2 bg-black/30 hover:bg-black/55 text-white p-2.5 rounded-full transition-all backdrop-blur-sm opacity-0 group-hover:opacity-100">
                  <ChevronLeft size={20} />
                </button>
                <button
                  onClick={e => { e.stopPropagation(); goNext() }}
                  className="absolute right-3 top-1/2 -translate-y-1/2 bg-black/30 hover:bg-black/55 text-white p-2.5 rounded-full transition-all backdrop-blur-sm opacity-0 group-hover:opacity-100">
                  <ChevronRight size={20} />
                </button>
              </>
            )}
          </div>

          {/* Thumbnail strip below main image */}
          {images.length > 1 && (
            <div className="flex gap-2 mt-2">
              {images.map((img: string, i: number) => (
                <motion.button
                  key={i}
                  onClick={() => goTo(i)}
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.97 }}
                  transition={{ duration: 0.15 }}
                  className={`flex-shrink-0 w-20 h-14 rounded-xl overflow-hidden border-2 transition-all duration-200 ${
                    i === activeImg
                      ? 'border-blue-500 shadow-md shadow-blue-200 opacity-100'
                      : 'border-gray-200 opacity-60 hover:opacity-90'
                  }`}>
                  <img src={img} alt="" className="w-full h-full object-cover" />
                </motion.button>
              ))}
            </div>
          )}

          {/* Dot indicators for mobile */}
          {images.length > 1 && (
            <div className="flex justify-center gap-1.5 mt-3 md:hidden">
              {images.map((_: string, i: number) => (
                <button key={i} onClick={() => goTo(i)}
                  className={`rounded-full transition-all duration-200 ${
                    i === activeImg ? 'w-5 h-2 bg-blue-600' : 'w-2 h-2 bg-gray-300'
                  }`} />
              ))}
            </div>
          )}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">

          {/* ── Left: Info ── */}
          <div className="lg:col-span-2 space-y-6">

            {/* Header */}
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
              <div className="flex items-start justify-between flex-wrap gap-3">
                <div className="flex-1 min-w-0">
                  <span className="inline-block bg-blue-100 text-blue-700 text-xs px-2.5 py-1 rounded-full font-medium capitalize mb-2">{hotel.type}</span>
                  <h1 className="text-3xl font-bold text-gray-900">{hotel.name}</h1>
                  <p className="text-gray-500 mt-1 flex items-center gap-1.5 text-sm">
                    <MapPin size={16} className="text-blue-500 flex-shrink-0" /> {hotel.address}, {hotel.city}
                  </p>
                  <div className="flex items-center gap-3 mt-2">
                    <StarRating rating={hotel.rating} />
                    <span className="text-sm text-gray-500">{hotel.review_count} reviews</span>
                  </div>
                  {contactPhone && (
                    <a href={`tel:${contactPhone}`} className="inline-flex items-center gap-1.5 mt-2 text-sm text-blue-600 hover:text-blue-800 font-medium">
                      📞 {contactPhone}
                    </a>
                  )}
                </div>
                <button onClick={toggleWishlist}
                  className={`p-3 rounded-xl border-2 transition-all flex-shrink-0 ${wishlisted ? 'bg-red-50 border-red-300 text-red-500' : 'border-gray-200 text-gray-400 hover:border-red-200 hover:text-red-400'}`}>
                  <Heart size={22} className={wishlisted ? 'fill-red-500' : ''} />
                </button>
              </div>
            </motion.div>

            {/* Description */}
            {hotel.description && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-2">{t('detail.about')}</h2>
                <p className="text-gray-600 leading-relaxed text-sm">{hotel.description}</p>
              </div>
            )}

            {/* Amenities */}
            {hotel.amenities?.length > 0 && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-3">{t('detail.amenities')}</h2>
                <div className="flex flex-wrap gap-2">
                  {hotel.amenities.map((a: string) => {
                    const Icon = AMENITY_ICONS[a] || Check
                    return <span key={a} className="flex items-center gap-1.5 bg-emerald-50 text-emerald-700 text-sm px-3 py-1.5 rounded-full border border-emerald-100"><Icon size={13} /> {a}</span>
                  })}
                </div>
              </div>
            )}

            {/* ── ROOMS ── */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="p-5 border-b border-gray-100 flex items-center gap-2">
                <Bed size={20} className="text-blue-600" />
                <h2 className="font-semibold text-gray-800">{t('detail.selectRooms')}</h2>
              </div>

              {/* Date pickers */}
              <div className="px-5 py-4 bg-blue-50 border-b border-blue-100">
                <p className="text-xs font-semibold text-blue-700 uppercase tracking-wide mb-2 flex items-center gap-1">
                  <Calendar size={13} /> {t('detail.checkDates')}
                </p>
                <div className="flex gap-3 flex-wrap items-end">
                  <div>
                    <label className="block text-xs text-blue-600 mb-1">{t('detail.checkIn')}</label>
                    <input type="date" value={checkIn} min={today()} max={checkOut}
                      onChange={e => setCheckIn(e.target.value)}
                      className="border border-blue-200 bg-white rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
                  </div>
                  <div>
                    <label className="block text-xs text-blue-600 mb-1">{t('detail.checkOut')}</label>
                    <input type="date" value={checkOut} min={checkIn}
                      onChange={e => setCheckOut(e.target.value)}
                      className="border border-blue-200 bg-white rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
                  </div>
                  <div className="bg-blue-600 text-white text-xs px-4 py-2 rounded-lg font-semibold">
                    {nights} {nights > 1 ? t('detail.nights') : t('detail.night')}
                  </div>
                </div>
              </div>

              <div className="p-5 space-y-3">
                {roomsLoading ? (
                  <div className="flex items-center justify-center py-8 gap-2 text-gray-400 text-sm">
                    <div className="w-5 h-5 border-2 border-blue-300 border-t-blue-600 rounded-full animate-spin" />
                    {t('detail.checking')}
                  </div>
                ) : allRooms.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="text-4xl mb-2">😔</div>
                    <p className="text-gray-600 font-medium">{t('detail.noRooms')}</p>
                    <p className="text-gray-400 text-sm mt-1">{t('detail.tryDates')}</p>
                  </div>
                ) : (
                  <>
                    {/* Available rooms — tap to select */}
                    {availableRooms.length > 0 && (
                      <div className="space-y-3">
                        <p className="text-xs font-semibold text-emerald-600 uppercase tracking-wide flex items-center gap-1.5">
                          <span className="w-2 h-2 bg-emerald-500 rounded-full inline-block" />
                          {availableRooms.length} {t('detail.tapSelect')}
                        </p>
                        {availableRooms.map((room: any) => {
                          const qty     = roomQty[room.id] || 0
                          const isActive = qty > 0
                          const rTotal  = room.price_per_night * qty * nights

                          return (
                            <motion.div key={room.id}
                              initial={{ opacity: 0, y: 8 }}
                              animate={{ opacity: 1, y: 0 }}
                              whileTap={{ scale: 0.98 }}
                              onClick={() => {
                                // Tap card to toggle: if 0 → set to 1, if already selected → deselect (set to 0)
                                if (qty === 0) {
                                  setRoomQty(q => ({ ...q, [room.id]: 1 }))
                                  toast.success(`${room.name} selected! ✓`, { duration: 1500 })
                                } else if (qty > 0) {
                                  setRoomQty(q => ({ ...q, [room.id]: 0 }))
                                }
                              }}
                              className={`cursor-pointer border-2 rounded-2xl p-4 transition-all duration-200 select-none ${
                                isActive
                                  ? 'border-blue-500 bg-blue-50 shadow-lg shadow-blue-100 ring-2 ring-blue-200'
                                  : 'border-gray-200 bg-white hover:border-blue-300 hover:bg-blue-50/50 hover:shadow-sm'
                              }`}>
                              <div className="flex gap-4">
                                {/* Room image */}
                                <div className={`w-28 h-24 rounded-xl overflow-hidden flex-shrink-0 transition-all ${isActive ? 'ring-2 ring-blue-400' : ''}`}>
                                  {room.image_url
                                    ? <img src={room.image_url} alt={room.name} className="w-full h-full object-cover" />
                                    : <div className="w-full h-full flex items-center justify-center bg-blue-50"><Bed size={32} className="text-blue-300" /></div>
                                  }
                                </div>

                                {/* Room info */}
                                <div className="flex-1 min-w-0">
                                  <div className="flex items-start justify-between gap-2">
                                    <div>
                                      <h3 className={`font-bold text-base ${isActive ? 'text-blue-700' : 'text-gray-800'}`}>{room.name}</h3>
                                      <div className="flex flex-wrap gap-2 mt-1 text-xs text-gray-500">
                                        <span className="flex items-center gap-1">🛏️ {room.bed_type}</span>
                                        <span className="flex items-center gap-1"><Users size={11} /> {t('detail.maxGuests')} {room.max_guests}</span>
                                        {room.size_sqm > 0 && <span>📐 {room.size_sqm}m²</span>}
                                      </div>
                                    </div>
                                    {/* Active checkmark */}
                                    <motion.div
                                      initial={false}
                                      animate={{ scale: isActive ? 1 : 0, opacity: isActive ? 1 : 0 }}
                                      transition={{ type: 'spring', stiffness: 400 }}
                                      className="w-7 h-7 bg-blue-600 rounded-full flex items-center justify-center flex-shrink-0 shadow-sm">
                                      <Check size={15} className="text-white" />
                                    </motion.div>
                                  </div>

                                  {/* Price + per night */}
                                  <div className="flex items-center justify-between mt-2">
                                    <div>
                                      <span className={`text-xl font-extrabold ${isActive ? 'text-blue-600' : 'text-gray-800'}`}>
                                        {t('common.etb')} {room.price_per_night?.toLocaleString()}
                                      </span>
                                      <span className="text-gray-400 text-xs ml-1">{t('common.perNight')}</span>
                                    </div>
                                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                                      isActive ? 'bg-blue-600 text-white' : 'bg-emerald-100 text-emerald-700'
                                    }`}>
                                      {isActive ? t('detail.selected') : t('detail.selectLabel')}
                                    </span>
                                  </div>

                                  {/* Quantity stepper — only shown when selected */}
                                  <AnimatePresence>
                                    {isActive && (
                                      <motion.div
                                        initial={{ opacity: 0, height: 0 }}
                                        animate={{ opacity: 1, height: 'auto' }}
                                        exit={{ opacity: 0, height: 0 }}
                                        className="overflow-hidden">
                                        <div className="flex items-center justify-between mt-3 pt-3 border-t border-blue-200">
                                          <div className="text-xs text-blue-600 font-semibold">
                                            {qty} {qty > 1 ? t('detail.nights') : t('detail.night')} × {nights} {nights > 1 ? t('detail.nights') : t('detail.night')} =
                                            <span className="text-blue-700 font-extrabold ml-1">{t('common.etb')} {rTotal.toLocaleString()}</span>
                                          </div>
                                          <div className="flex items-center gap-2" onClick={e => e.stopPropagation()}>
                                            <span className="text-xs text-blue-500">{t('detail.qty')}</span>
                                            <button
                                              onClick={() => { if (qty > 1) setRoomQty(q => ({ ...q, [room.id]: qty - 1 })) }}
                                              disabled={qty <= 1}
                                              className="w-7 h-7 rounded-full bg-white border-2 border-blue-300 flex items-center justify-center text-blue-600 hover:bg-blue-600 hover:text-white disabled:opacity-30 transition-all">
                                              <Minus size={12} />
                                            </button>
                                            <span className="w-5 text-center font-extrabold text-blue-700 text-sm">{qty}</span>
                                            <button
                                              onClick={() => { if (qty < 2) setRoomQty(q => ({ ...q, [room.id]: qty + 1 })) }}
                                              disabled={qty >= 2}
                                              className="w-7 h-7 rounded-full bg-white border-2 border-blue-300 flex items-center justify-center text-blue-600 hover:bg-blue-600 hover:text-white disabled:opacity-30 transition-all">
                                              <Plus size={12} />
                                            </button>
                                          </div>
                                        </div>
                                      </motion.div>
                                    )}
                                  </AnimatePresence>
                                </div>
                              </div>
                            </motion.div>
                          )
                        })}
                      </div>
                    )}

                    {/* Occupied rooms — shown grayed out with checkout date */}
                    {occupiedRooms.length > 0 && (
                      <div className="space-y-2 mt-5">
                        <p className="text-xs font-semibold text-gray-400 uppercase tracking-wide">{t('detail.notAvailable')}</p>
                        {occupiedRooms.map((room: any) => (
                          <div key={room.id}
                            className="border border-gray-200 rounded-xl p-3 bg-gray-50 opacity-75">
                            <div className="flex gap-3 items-center">
                              <div className="w-14 h-14 rounded-lg overflow-hidden flex-shrink-0 bg-gray-200">
                                {room.image_url
                                  ? <img src={room.image_url} alt={room.name} className="w-full h-full object-cover grayscale" />
                                  : <div className="w-full h-full flex items-center justify-center bg-gray-200"><Bed size={22} className="text-gray-400" /></div>}
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="font-semibold text-gray-500">{room.name}</p>
                                <p className="text-xs text-gray-400">{room.bed_type} · {room.max_guests} guests max</p>
                              </div>
                              <div className="text-right flex-shrink-0">
                                {room.is_occupied ? (
                                  <div>
                                    <span className="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full font-medium flex items-center gap-1">
                                      <Lock size={10} /> {t('detail.reserved')}
                                    </span>
                                    <p className="text-[10px] text-gray-400 mt-0.5 flex items-center gap-1">
                                      <Clock size={10} /> {t('detail.until')} {room.occupied_until}
                                    </p>
                                  </div>
                                ) : (
                                  <span className="text-xs bg-amber-100 text-amber-600 px-2 py-0.5 rounded-full font-medium capitalize">{room.room_status}</span>
                                )}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </>
                )}
              </div>
            </div>

            {/* Google Maps */}
            {hotel.latitude !== 0 && hotel.longitude !== 0 && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-3 flex items-center gap-2"><MapPin size={18} className="text-blue-600" /> {t('detail.location')}</h2>
                <div className="rounded-xl overflow-hidden border border-gray-200">
                  <iframe width="100%" height="260" style={{ border: 0 }} loading="lazy"
                    title={`Map of ${hotel.name}`}
                    src={`https://www.google.com/maps?q=${hotel.latitude},${hotel.longitude}&z=15&output=embed`} />
                </div>
                <p className="text-sm text-gray-500 mt-2">{hotel.address}, {hotel.city}</p>
              </div>
            )}

            {/* Reviews */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
              <div className="flex items-center justify-between mb-4">
                <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                  <MessageSquare size={18} className="text-blue-600" /> {t('detail.reviews')}
                  <span className="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">{hotel.review_count}</span>
                </h2>
                <button onClick={() => setShowReviewForm(!showReviewForm)}
                  className="text-blue-600 text-sm font-medium hover:text-blue-800">
                  {showReviewForm ? t('detail.cancelReview') : t('detail.writeReview')}
                </button>
              </div>
              <AnimatePresence>
                {showReviewForm && (
                  <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
                    className="mb-5 p-4 bg-gray-50 rounded-xl border border-gray-100 space-y-3 overflow-hidden">
                    <div className="flex gap-1">
                      {[1,2,3,4,5].map(n => (
                        <button key={n} onClick={() => setReviewForm(f => ({ ...f, rating: n }))}>
                          <Star size={26} className={n <= reviewForm.rating ? 'text-amber-400 fill-amber-400' : 'text-gray-300'} />
                        </button>
                      ))}
                    </div>
                    <textarea value={reviewForm.comment} onChange={e => setReviewForm(f => ({ ...f, comment: e.target.value }))}
                      rows={3} placeholder={t('detail.shareExp')}
                      className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none resize-none" />
                    <button onClick={submitReview} disabled={submittingReview}
                      className="bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 disabled:opacity-50">
                      {submittingReview ? t('detail.posting') : t('detail.postReview')}
                    </button>
                  </motion.div>
                )}
              </AnimatePresence>
              {reviews.length === 0 ? (
                <p className="text-gray-400 text-sm py-6 text-center">{t('detail.noReviews')}</p>
              ) : (
                <div className="space-y-4">
                  {reviews.map((rev: any) => (
                    <div key={rev.id} className="border-b border-gray-50 pb-4 last:border-0">
                      <div className="flex items-center gap-2 mb-1">
                        <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-sm">
                          {rev.user_name?.charAt(0)?.toUpperCase() || 'U'}
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800 text-sm">{rev.user_name}</p>
                          <div className="flex gap-0.5">
                            {[1,2,3,4,5].map(n => <Star key={n} size={11} className={n <= rev.rating ? 'text-amber-400 fill-amber-400' : 'text-gray-200 fill-gray-200'} />)}
                          </div>
                        </div>
                        <span className="text-xs text-gray-400 ml-auto">{new Date(rev.created_at).toLocaleDateString()}</span>
                      </div>
                      <p className="text-gray-600 text-sm pl-10">{rev.comment}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* ── Right: Sticky booking panel ── */}
          <div className="lg:col-span-1">
            <div className="sticky top-24 bg-white rounded-2xl shadow-lg border border-gray-100 overflow-hidden">
              {/* Header */}
              <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-4 text-white">
                <p className="text-blue-100 text-xs">{t('detail.startingFrom')}</p>
                <p className="text-3xl font-bold">{t('common.etb')} {hotel.price_per_night?.toLocaleString()}<span className="text-lg font-normal text-blue-200">{t('common.perNight')}</span></p>
              </div>

              <div className="p-5 space-y-4">
                {/* Date summary */}
                <div className="flex justify-between text-sm bg-gray-50 rounded-lg p-3">
                  <div><p className="text-xs text-gray-400">{t('detail.checkIn')}</p><p className="font-semibold text-gray-800">{checkIn}</p></div>
                  <div className="text-center"><p className="text-xs text-gray-400">{nights > 1 ? t('detail.nights') : t('detail.night')}</p><p className="font-semibold text-blue-600">{nights}</p></div>
                  <div className="text-right"><p className="text-xs text-gray-400">{t('detail.checkOut')}</p><p className="font-semibold text-gray-800">{checkOut}</p></div>
                </div>

                {/* Selected rooms summary */}
                {selectedRooms.length > 0 ? (
                  <div className="space-y-2">
                    <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">{t('detail.selected')}</p>
                    {selectedRooms.map(({ room, qty }) => (
                      <div key={room.id} className="flex justify-between text-sm">
                        <span className="text-gray-700">{qty}× {room.name}</span>
                        <span className="font-semibold text-blue-600">ETB {(room.price_per_night * qty * nights).toLocaleString()}</span>
                      </div>
                    ))}
                    <div className="flex justify-between text-base font-bold pt-2 border-t border-gray-100">
                      <span>{t('detail.total')}</span>
                      <span className="text-blue-600">{t('common.etb')} {totalPrice.toLocaleString()}</span>
                    </div>
                    <div className="text-xs text-gray-400 text-center">
                      {totalRooms} {totalRooms > 1 ? t('detail.nights') : t('detail.night')} · {t('detail.maxGuests')} {maxCapacity}
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-3 text-gray-400 text-sm">
                    {availableRooms.length === 0 && !roomsLoading
                      ? t('detail.noRooms')
                      : t('detail.selectRoom')}
                  </div>
                )}

                {/* Book button */}
                <button onClick={handleBook}
                  disabled={selectedRooms.length === 0 || roomsLoading}
                  className="w-full flex items-center justify-center gap-2 bg-blue-600 text-white py-3.5 rounded-xl font-bold text-base hover:bg-blue-700 active:scale-[.98] transition-all disabled:opacity-40 disabled:cursor-not-allowed shadow-md">
                  {selectedRooms.length === 0
                    ? t('detail.selectRoom')
                    : `${t('detail.bookRooms')} ${totalRooms} →`}
                </button>

                {!isAuthenticated && selectedRooms.length > 0 && (
                  <p className="text-center text-xs text-gray-400">{t('detail.signInCont')}</p>
                )}

                {/* Quick stats */}
                <div className="grid grid-cols-2 gap-2 pt-2 border-t border-gray-100">
                  <div className="text-center"><p className="text-xs text-gray-400">{t('detail.rating')}</p><p className="font-bold text-gray-800 flex items-center justify-center gap-1"><Star size={13} className="text-amber-500 fill-amber-500" /> {hotel.rating}</p></div>
                  <div className="text-center"><p className="text-xs text-gray-400">{t('detail.reviews')}</p><p className="font-bold text-gray-800">{hotel.review_count}</p></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Sticky bottom Book Now bar — appears when rooms selected ── */}
      <AnimatePresence>
        {selectedRooms.length > 0 && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            transition={{ type: 'spring', stiffness: 280, damping: 28 }}
            className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 shadow-2xl px-4 py-3 safe-area-bottom">
            <div className="max-w-2xl mx-auto flex items-center gap-4">
              {/* Summary */}
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-500 truncate">
                  {selectedRooms.map(x => `${x.qty}× ${x.room.name}`).join(', ')}
                </p>
                <p className="text-lg font-extrabold text-blue-600">
                  ETB {totalPrice.toLocaleString()}
                  <span className="text-gray-400 text-xs font-normal ml-1">· {nights} night{nights > 1 ? 's' : ''}</span>
                </p>
              </div>
              {/* Book button */}
              <button
                onClick={handleBook}
                className="flex-shrink-0 bg-blue-600 text-white px-7 py-3 rounded-xl font-bold text-base hover:bg-blue-700 active:scale-[.97] transition-all shadow-lg shadow-blue-200 flex items-center gap-2">
                {t('detail.bookNow')} <ChevronRight size={20} />
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <Footer />
    </>
  )
}

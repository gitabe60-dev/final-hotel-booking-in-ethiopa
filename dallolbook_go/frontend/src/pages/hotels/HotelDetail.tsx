// pages/hotels/HotelDetail.tsx
import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  MapPin, Heart, Check, MessageSquare, Star,
  Calendar, Bed, ChevronRight, Wifi,
  Coffee, Car, Waves, Dumbbell, UtensilsCrossed,
  Users, Lock, Clock, Plus, Minus
} from 'lucide-react'
import toast from 'react-hot-toast'
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
  const { id } = useParams()
  const navigate = useNavigate()
  const { isAuthenticated } = useAuth()
  const { hotel, loading } = useHotel(Number(id))

  const [activeImg, setActiveImg]   = useState(0)
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

  if (loading) return <><Navbar /><div className="flex justify-center items-center min-h-screen"><Spinner size="lg" /></div></>
  if (!hotel)  return <><Navbar /><div className="text-center py-20 text-gray-400">Hotel not found</div></>

  const images = hotel.images?.length ? hotel.images : ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800']
  const availableRooms = allRooms.filter(r => !r.is_occupied && r.room_status === 'available')
  const occupiedRooms  = allRooms.filter(r => r.is_occupied || r.room_status !== 'available')

  return (
    <>
      <Navbar />
      <div className="max-w-6xl mx-auto px-4 py-8">

        {/* Gallery */}
        <div className="grid grid-cols-3 gap-2 h-72 rounded-2xl overflow-hidden mb-8">
          <div className="col-span-2 relative">
            <img src={images[activeImg]} alt={hotel.name} className="w-full h-full object-cover" />
            {hotel.is_featured && (
              <span className="absolute top-3 left-3 bg-amber-500 text-white text-xs font-bold px-3 py-1 rounded-full">★ Featured</span>
            )}
          </div>
          <div className="grid grid-rows-3 gap-2">
            {images.slice(0, 3).map((img: string, i: number) => (
              <img key={i} src={img} alt="" onClick={() => setActiveImg(i)}
                className={`w-full h-full object-cover cursor-pointer transition-all ${activeImg === i ? 'ring-2 ring-blue-500' : 'opacity-80 hover:opacity-100'}`} />
            ))}
          </div>
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
                <h2 className="font-semibold text-gray-800 mb-2">About this hotel</h2>
                <p className="text-gray-600 leading-relaxed text-sm">{hotel.description}</p>
              </div>
            )}

            {/* Amenities */}
            {hotel.amenities?.length > 0 && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-3">Amenities</h2>
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
                <h2 className="font-semibold text-gray-800">Select Rooms</h2>
              </div>

              {/* Date pickers */}
              <div className="px-5 py-4 bg-blue-50 border-b border-blue-100">
                <p className="text-xs font-semibold text-blue-700 uppercase tracking-wide mb-2 flex items-center gap-1">
                  <Calendar size={13} /> Select dates to check availability
                </p>
                <div className="flex gap-3 flex-wrap items-end">
                  <div>
                    <label className="block text-xs text-blue-600 mb-1">Check-in</label>
                    <input type="date" value={checkIn} min={today()} max={checkOut}
                      onChange={e => setCheckIn(e.target.value)}
                      className="border border-blue-200 bg-white rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
                  </div>
                  <div>
                    <label className="block text-xs text-blue-600 mb-1">Check-out</label>
                    <input type="date" value={checkOut} min={checkIn}
                      onChange={e => setCheckOut(e.target.value)}
                      className="border border-blue-200 bg-white rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-400 outline-none" />
                  </div>
                  <div className="bg-blue-600 text-white text-xs px-4 py-2 rounded-lg font-semibold">
                    {nights} night{nights > 1 ? 's' : ''}
                  </div>
                </div>
              </div>

              <div className="p-5 space-y-3">
                {roomsLoading ? (
                  <div className="flex items-center justify-center py-8 gap-2 text-gray-400 text-sm">
                    <div className="w-5 h-5 border-2 border-blue-300 border-t-blue-600 rounded-full animate-spin" />
                    Checking room availability…
                  </div>
                ) : allRooms.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="text-4xl mb-2">😔</div>
                    <p className="text-gray-600 font-medium">No rooms configured</p>
                    <p className="text-gray-400 text-sm mt-1">Try different dates</p>
                  </div>
                ) : (
                  <>
                    {/* Available rooms */}
                    {availableRooms.length > 0 && (
                      <div className="space-y-3">
                        {availableRooms.map((room: any) => {
                          const qty   = roomQty[room.id] || 0
                          const rTotal = room.price_per_night * Math.max(qty, 1) * nights
                          return (
                            <motion.div key={room.id}
                              initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                              className={`border-2 rounded-xl p-4 transition-all ${qty > 0 ? 'border-blue-500 bg-blue-50 shadow-md' : 'border-gray-200 hover:border-blue-300 hover:bg-gray-50'}`}>
                              <div className="flex gap-4">
                                {/* Room image */}
                                <div className="w-24 h-20 rounded-lg overflow-hidden flex-shrink-0 bg-gray-200">
                                  {room.image_url
                                    ? <img src={room.image_url} alt={room.name} className="w-full h-full object-cover" />
                                    : <div className="w-full h-full flex items-center justify-center bg-blue-100"><Bed size={28} className="text-blue-400" /></div>}
                                </div>
                                {/* Room details */}
                                <div className="flex-1 min-w-0">
                                  <div className="flex items-start justify-between flex-wrap gap-2">
                                    <div>
                                      <h3 className="font-bold text-gray-800">{room.name}</h3>
                                      <p className="text-sm text-gray-500 mt-0.5 flex items-center gap-2">
                                        <span>{room.bed_type} bed</span>
                                        <span className="flex items-center gap-1"><Users size={13} /> max {room.max_guests} guests</span>
                                        {room.size_sqm > 0 && <span>{room.size_sqm}m²</span>}
                                      </p>
                                    </div>
                                    {/* Qty counter */}
                                    <div className="flex items-center gap-2 flex-shrink-0">
                                      <button
                                        onClick={() => changeQty(room.id, -1, room.max_guests)}
                                        disabled={qty === 0}
                                        className="w-8 h-8 rounded-full border-2 border-gray-300 flex items-center justify-center text-gray-600 hover:border-blue-500 hover:text-blue-600 disabled:opacity-30 disabled:cursor-not-allowed transition-all">
                                        <Minus size={14} />
                                      </button>
                                      <span className={`w-6 text-center font-bold text-sm ${qty > 0 ? 'text-blue-600' : 'text-gray-400'}`}>{qty}</span>
                                      <button
                                        onClick={() => changeQty(room.id, 1, room.max_guests)}
                                        disabled={qty >= 2}
                                        className="w-8 h-8 rounded-full border-2 border-gray-300 flex items-center justify-center text-gray-600 hover:border-blue-500 hover:text-blue-600 disabled:opacity-30 disabled:cursor-not-allowed transition-all">
                                        <Plus size={14} />
                                      </button>
                                    </div>
                                  </div>
                                  <div className="flex items-center justify-between mt-2 flex-wrap gap-1">
                                    <div>
                                      <span className="text-lg font-bold text-blue-600">ETB {room.price_per_night?.toLocaleString()}</span>
                                      <span className="text-gray-400 text-xs">/night</span>
                                      {qty > 0 && (
                                        <span className="ml-2 text-xs text-emerald-600 font-semibold">
                                          = ETB {(room.price_per_night * qty * nights).toLocaleString()} total
                                        </span>
                                      )}
                                    </div>
                                    <span className="text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-medium">✓ Available</span>
                                  </div>
                                </div>
                              </div>
                            </motion.div>
                          )
                        })}
                      </div>
                    )}

                    {/* Occupied rooms */}
                    {occupiedRooms.length > 0 && (
                      <div className="space-y-2 mt-4">
                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Not Available for Selected Dates</p>
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
                                      <Lock size={10} /> Reserved
                                    </span>
                                    <p className="text-[10px] text-gray-400 mt-0.5 flex items-center gap-1">
                                      <Clock size={10} /> Until {room.occupied_until}
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
                <h2 className="font-semibold text-gray-800 mb-3 flex items-center gap-2"><MapPin size={18} className="text-blue-600" /> Location</h2>
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
                  <MessageSquare size={18} className="text-blue-600" /> Guest Reviews
                  <span className="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">{hotel.review_count}</span>
                </h2>
                <button onClick={() => setShowReviewForm(!showReviewForm)}
                  className="text-blue-600 text-sm font-medium hover:text-blue-800">
                  {showReviewForm ? 'Cancel' : '+ Write review'}
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
                      rows={3} placeholder="Share your experience…"
                      className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none resize-none" />
                    <button onClick={submitReview} disabled={submittingReview}
                      className="bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 disabled:opacity-50">
                      {submittingReview ? 'Posting…' : 'Post Review'}
                    </button>
                  </motion.div>
                )}
              </AnimatePresence>
              {reviews.length === 0 ? (
                <p className="text-gray-400 text-sm py-6 text-center">No reviews yet — be the first!</p>
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
                <p className="text-blue-100 text-xs">Starting from</p>
                <p className="text-3xl font-bold">ETB {hotel.price_per_night?.toLocaleString()}<span className="text-lg font-normal text-blue-200">/night</span></p>
              </div>

              <div className="p-5 space-y-4">
                {/* Date summary */}
                <div className="flex justify-between text-sm bg-gray-50 rounded-lg p-3">
                  <div><p className="text-xs text-gray-400">Check-in</p><p className="font-semibold text-gray-800">{checkIn}</p></div>
                  <div className="text-center"><p className="text-xs text-gray-400">Nights</p><p className="font-semibold text-blue-600">{nights}</p></div>
                  <div className="text-right"><p className="text-xs text-gray-400">Check-out</p><p className="font-semibold text-gray-800">{checkOut}</p></div>
                </div>

                {/* Selected rooms summary */}
                {selectedRooms.length > 0 ? (
                  <div className="space-y-2">
                    <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Selected</p>
                    {selectedRooms.map(({ room, qty }) => (
                      <div key={room.id} className="flex justify-between text-sm">
                        <span className="text-gray-700">{qty}× {room.name}</span>
                        <span className="font-semibold text-blue-600">ETB {(room.price_per_night * qty * nights).toLocaleString()}</span>
                      </div>
                    ))}
                    <div className="flex justify-between text-base font-bold pt-2 border-t border-gray-100">
                      <span>Total</span>
                      <span className="text-blue-600">ETB {totalPrice.toLocaleString()}</span>
                    </div>
                    <div className="text-xs text-gray-400 text-center">
                      {totalRooms} room{totalRooms > 1 ? 's' : ''} · max {maxCapacity} guests total
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-3 text-gray-400 text-sm">
                    {availableRooms.length === 0 && !roomsLoading
                      ? 'No rooms available for these dates'
                      : 'Use + to select rooms below'}
                  </div>
                )}

                {/* Book button */}
                <button onClick={handleBook}
                  disabled={selectedRooms.length === 0 || roomsLoading}
                  className="w-full flex items-center justify-center gap-2 bg-blue-600 text-white py-3.5 rounded-xl font-bold text-base hover:bg-blue-700 active:scale-[.98] transition-all disabled:opacity-40 disabled:cursor-not-allowed shadow-md">
                  {selectedRooms.length === 0 ? 'Select a Room' : `Book ${totalRooms} Room${totalRooms > 1 ? 's' : ''}`}
                  <ChevronRight size={18} />
                </button>

                {!isAuthenticated && selectedRooms.length > 0 && (
                  <p className="text-center text-xs text-gray-400">You'll be asked to sign in to continue</p>
                )}

                {/* Quick stats */}
                <div className="grid grid-cols-2 gap-2 pt-2 border-t border-gray-100">
                  <div className="text-center"><p className="text-xs text-gray-400">Rating</p><p className="font-bold text-gray-800 flex items-center justify-center gap-1"><Star size={13} className="text-amber-500 fill-amber-500" /> {hotel.rating}</p></div>
                  <div className="text-center"><p className="text-xs text-gray-400">Reviews</p><p className="font-bold text-gray-800">{hotel.review_count}</p></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </>
  )
}

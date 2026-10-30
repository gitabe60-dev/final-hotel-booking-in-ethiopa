// pages/hotels/HotelDetail.tsx
import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  MapPin, Heart, Check, MessageSquare, Star,
  Calendar, Bed, Users, ChevronRight, Wifi,
  Coffee, Car, Waves, Dumbbell, UtensilsCrossed
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

// Map amenity strings to icons
const AMENITY_ICONS: Record<string, any> = {
  'Free WiFi': Wifi, 'WiFi': Wifi,
  'Restaurant': UtensilsCrossed,
  'Swimming Pool': Waves, 'Pool': Waves,
  'Gym': Dumbbell, 'Fitness': Dumbbell,
  'Parking': Car,
  'Breakfast': Coffee,
}

export default function HotelDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { isAuthenticated } = useAuth()
  const { hotel, loading } = useHotel(Number(id))

  const [activeImg, setActiveImg]       = useState(0)
  const [wishlisted, setWishlisted]     = useState(false)
  const [reviews, setReviews]           = useState<any[]>([])
  const [reviewForm, setReviewForm]     = useState({ rating: 5, comment: '' })
  const [showReviewForm, setShowReviewForm] = useState(false)
  const [submittingReview, setSubmittingReview] = useState(false)
  const [contactPhone, setContactPhone] = useState<string>('')

  // Date + availability
  const [checkIn, setCheckIn]   = useState(today())
  const [checkOut, setCheckOut] = useState(tomorrow())
  const [availRooms, setAvailRooms] = useState<any[]>([])
  const [availLoading, setAvailLoading] = useState(false)
  const [selectedRoom, setSelectedRoom] = useState<any>(null)

  const nights = Math.max(1, Math.round(
    (new Date(checkOut).getTime() - new Date(checkIn).getTime()) / 86400000
  ))

  /* ─── Load availability ──────────────────────── */
  const checkAvailability = async (cIn: string, cOut: string) => {
    if (!id) return
    setAvailLoading(true)
    setSelectedRoom(null)
    try {
      const res = await hotelService.getAvailability(Number(id), cIn, cOut)
      setAvailRooms(res.data.data?.rooms || [])
    } catch {
      setAvailRooms([])
    }
    setAvailLoading(false)
  }

  useEffect(() => {
    if (id) {
      checkAvailability(checkIn, checkOut)
      hotelService.getReviews(Number(id), 6, 0)
        .then(r => setReviews(r.data.data?.reviews || []))
        .catch(() => {})
      // Get hotel contact phone from payment methods
      hotelService.getPaymentMethods(Number(id))
        .then(res => {
          const methods = res.data.data || []
          const telebirr = methods.find((m: any) => m.method === 'telebirr')
          const cbe = methods.find((m: any) => m.method === 'cbe_birr')
          setContactPhone((telebirr || cbe)?.phone_number || '')
        })
        .catch(() => {})
    }
  }, [id])

  useEffect(() => {
    if (id && checkIn && checkOut) checkAvailability(checkIn, checkOut)
  }, [checkIn, checkOut])

  /* ─── Book selected room ──────────────────────── */
  // If not logged in → send to login with redirect back to booking page.
  // If logged in → go directly to booking form.
  const handleBook = (room?: any) => {
    const r = room || selectedRoom
    const params = new URLSearchParams({
      check_in:  checkIn,
      check_out: checkOut,
      nights:    String(nights),
    })
    if (r) {
      params.set('room_id',    String(r.id))
      params.set('room_name',  r.name)
      params.set('room_price', String(r.price_per_night))
    }
    const bookingPath = `/booking/${id}?${params.toString()}`

    if (!isAuthenticated) {
      // Send to login, then come back to booking after login/register
      navigate(`/login?redirect=${encodeURIComponent(bookingPath)}`)
    } else {
      navigate(bookingPath)
    }
  }

  /* ─── Wishlist ──────────────────────────────── */
  const toggleWishlist = async () => {
    if (!isAuthenticated) { navigate('/login'); return }
    try {
      const res = await wishlistService.toggle(hotel.id)
      setWishlisted(res.data.data.action === 'added')
      toast.success(res.data.data.action === 'added' ? 'Added to wishlist ♥' : 'Removed from wishlist')
    } catch { toast.error('Failed') }
  }

  /* ─── Review ──────────────────────────────────── */
  const submitReview = async () => {
    if (!isAuthenticated) { navigate('/login'); return }
    if (reviewForm.comment.trim().length < 5) {
      toast.error('Comment must be at least 5 characters'); return
    }
    setSubmittingReview(true)
    try {
      await hotelService.postReview(hotel.id, reviewForm.rating, reviewForm.comment)
      toast.success('Review posted!')
      setReviewForm({ rating: 5, comment: '' })
      setShowReviewForm(false)
      const r = await hotelService.getReviews(Number(id), 6, 0)
      setReviews(r.data.data?.reviews || [])
    } catch (e: any) {
      toast.error(e.response?.data?.message || 'Failed to post review')
    }
    setSubmittingReview(false)
  }

  if (loading) return <><Navbar /><div className="flex justify-center items-center min-h-screen"><Spinner size="lg" /></div></>
  if (!hotel)  return <><Navbar /><div className="text-center py-20 text-gray-400">Hotel not found</div></>

  const images = hotel.images?.length
    ? hotel.images
    : ['https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800']

  const basePrice = selectedRoom ? selectedRoom.price_per_night : hotel.price_per_night
  const totalPreview = basePrice * nights

  return (
    <>
      <Navbar />
      <div className="max-w-6xl mx-auto px-4 py-8">

        {/* ── Gallery ───────────────────────────── */}
        <div className="grid grid-cols-3 gap-2 h-72 rounded-2xl overflow-hidden mb-8">
          <div className="col-span-2 relative">
            <img src={images[activeImg]} alt={hotel.name} className="w-full h-full object-cover" />
            {/* badge */}
            {hotel.is_featured && (
              <span className="absolute top-3 left-3 bg-amber-500 text-white text-xs font-bold px-3 py-1 rounded-full">
                ★ Featured
              </span>
            )}
          </div>
          <div className="grid grid-rows-3 gap-2">
            {images.slice(0, 3).map((img: string, i: number) => (
              <img key={i} src={img} alt=""
                onClick={() => setActiveImg(i)}
                className={`w-full h-full object-cover cursor-pointer transition-all ${
                  activeImg === i ? 'ring-2 ring-blue-500 opacity-100' : 'opacity-80 hover:opacity-100'
                }`} />
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">

          {/* ── Left: Hotel Info ──────────────── */}
          <div className="lg:col-span-2 space-y-6">

            {/* Header */}
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
              <div className="flex items-start justify-between flex-wrap gap-3">
                <div className="flex-1 min-w-0">
                  <span className="inline-block bg-blue-100 text-blue-700 text-xs px-2.5 py-1 rounded-full font-medium capitalize mb-2">
                    {hotel.type}
                  </span>
                  <h1 className="text-3xl font-bold text-gray-900">{hotel.name}</h1>
                  <p className="text-gray-500 mt-1 flex items-center gap-1.5 text-sm">
                    <MapPin size={16} className="text-blue-500 flex-shrink-0" />
                    {hotel.address}, {hotel.city}
                  </p>
                  <div className="flex items-center gap-3 mt-2">
                    <StarRating rating={hotel.rating} />
                    <span className="text-sm text-gray-500">{hotel.review_count} reviews</span>
                  </div>
                  {contactPhone && (
                    <a href={`tel:${contactPhone}`}
                      className="inline-flex items-center gap-1.5 mt-2 text-sm text-blue-600 hover:text-blue-800 font-medium">
                      <span>📞</span> {contactPhone}
                    </a>
                  )}
                </div>
                <button onClick={toggleWishlist}
                  className={`p-3 rounded-xl border-2 transition-all flex-shrink-0 ${
                    wishlisted
                      ? 'bg-red-50 border-red-300 text-red-500'
                      : 'border-gray-200 text-gray-400 hover:border-red-200 hover:text-red-400'
                  }`}>
                  <Heart size={22} className={wishlisted ? 'fill-red-500' : ''} />
                </button>
              </div>
            </motion.div>

            {/* Description */}
            {hotel.description && (
              <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }}
                className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-2">About this hotel</h2>
                <p className="text-gray-600 leading-relaxed text-sm">{hotel.description}</p>
              </motion.div>
            )}

            {/* Amenities */}
            {hotel.amenities?.length > 0 && (
              <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
                className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-3">Amenities</h2>
                <div className="flex flex-wrap gap-2">
                  {hotel.amenities.map((a: string) => {
                    const Icon = AMENITY_ICONS[a] || Check
                    return (
                      <span key={a} className="flex items-center gap-1.5 bg-emerald-50 text-emerald-700 text-sm px-3 py-1.5 rounded-full border border-emerald-100">
                        <Icon size={13} /> {a}
                      </span>
                    )
                  })}
                </div>
              </motion.div>
            )}

            {/* ── Rooms section ────────────────── */}
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }}
              className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="p-5 border-b border-gray-100 flex items-center gap-2">
                <Bed size={20} className="text-blue-600" />
                <h2 className="font-semibold text-gray-800">Available Rooms</h2>
              </div>

              {/* Date pickers inside room section */}
              <div className="px-5 py-4 bg-blue-50 border-b border-blue-100">
                <p className="text-xs font-semibold text-blue-700 uppercase tracking-wide mb-2 flex items-center gap-1">
                  <Calendar size={13} /> Select your dates to see availability
                </p>
                <div className="flex gap-3 flex-wrap">
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
                  <div className="flex items-end">
                    <div className="bg-blue-600 text-white text-xs px-4 py-2 rounded-lg font-semibold">
                      {nights} night{nights > 1 ? 's' : ''}
                    </div>
                  </div>
                </div>
              </div>

              {/* Room cards */}
              <div className="p-5">
                {availLoading ? (
                  <div className="flex items-center gap-3 py-6 justify-center text-gray-400 text-sm">
                    <div className="w-5 h-5 border-2 border-blue-300 border-t-blue-600 rounded-full animate-spin" />
                    Checking availability...
                  </div>
                ) : availRooms.length === 0 ? (
                  <div className="text-center py-8">
                    <div className="text-4xl mb-2">😔</div>
                    <p className="text-gray-600 font-medium">No rooms available for these dates</p>
                    <p className="text-gray-400 text-sm mt-1">Try selecting different check-in / check-out dates</p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {availRooms.map((room: any) => {
                      const isSelected = selectedRoom?.id === room.id
                      const roomTotal  = room.price_per_night * nights

                      return (
                        <motion.div key={room.id}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          whileHover={{ scale: 1.005 }}
                          onClick={() => setSelectedRoom(isSelected ? null : room)}
                          className={`border-2 rounded-xl p-4 cursor-pointer transition-all ${
                            isSelected
                              ? 'border-blue-500 bg-blue-50 shadow-md'
                              : 'border-gray-200 hover:border-blue-300 hover:bg-gray-50'
                          }`}>
                          <div className="flex gap-4">
                            {/* Room image */}
                            <div className="w-24 h-20 rounded-lg overflow-hidden flex-shrink-0 bg-gray-200">
                              {room.image_url
                                ? <img src={room.image_url} alt={room.name} className="w-full h-full object-cover" />
                                : <div className="w-full h-full flex items-center justify-center bg-blue-100">
                                    <Bed size={28} className="text-blue-400" />
                                  </div>
                              }
                            </div>

                            {/* Room info */}
                            <div className="flex-1 min-w-0">
                              <div className="flex items-start justify-between">
                                <div>
                                  <h3 className="font-bold text-gray-800">{room.name}</h3>
                                  <p className="text-sm text-gray-500 mt-0.5">
                                    {room.bed_type} bed · max {room.max_guests} guests
                                    {room.size_sqm > 0 && ` · ${room.size_sqm}m²`}
                                  </p>
                                </div>
                                {isSelected && (
                                  <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center flex-shrink-0 ml-2">
                                    <Check size={14} className="text-white" />
                                  </div>
                                )}
                              </div>

                              <div className="flex items-center justify-between mt-3 flex-wrap gap-2">
                                <div>
                                  <span className="text-xl font-bold text-blue-600">
                                    ETB {room.price_per_night?.toLocaleString()}
                                  </span>
                                  <span className="text-gray-400 text-sm">/night</span>
                                  <p className="text-xs text-gray-500 mt-0.5">
                                    ETB {roomTotal.toLocaleString()} total for {nights} night{nights > 1 ? 's' : ''}
                                  </p>
                                </div>
                                <button
                                  onClick={e => { e.stopPropagation(); handleBook(room) }}
                                  className="flex items-center gap-1.5 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-blue-700 active:scale-95 transition-all">
                                  Book Now <ChevronRight size={16} />
                                </button>
                              </div>
                            </div>
                          </div>
                        </motion.div>
                      )
                    })}
                  </div>
                )}
              </div>
            </motion.div>

            {/* Google Maps */}
            {hotel.latitude !== 0 && hotel.longitude !== 0 && (
              <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
                className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
                <h2 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
                  <MapPin size={18} className="text-blue-600" /> Location
                </h2>
                <div className="rounded-xl overflow-hidden border border-gray-200">
                  <iframe width="100%" height="280" style={{ border: 0 }} loading="lazy"
                    title={`Map of ${hotel.name}`}
                    src={`https://www.google.com/maps?q=${hotel.latitude},${hotel.longitude}&z=15&output=embed`} />
                </div>
                <p className="text-sm text-gray-500 mt-2">{hotel.address}, {hotel.city}</p>
              </motion.div>
            )}

            {/* Reviews */}
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25 }}
              className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
              <div className="flex items-center justify-between mb-4">
                <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                  <MessageSquare size={18} className="text-blue-600" /> Guest Reviews
                  <span className="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">{hotel.review_count}</span>
                </h2>
                <button onClick={() => setShowReviewForm(!showReviewForm)}
                  className="text-blue-600 text-sm font-medium hover:text-blue-800 transition-colors">
                  {showReviewForm ? 'Cancel' : '+ Write review'}
                </button>
              </div>

              <AnimatePresence>
                {showReviewForm && (
                  <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
                    className="mb-5 p-4 bg-gray-50 rounded-xl border border-gray-100 space-y-3 overflow-hidden">
                    <div>
                      <p className="text-sm font-medium text-gray-700 mb-2">Your rating</p>
                      <div className="flex gap-1">
                        {[1, 2, 3, 4, 5].map(n => (
                          <button key={n} onClick={() => setReviewForm(f => ({ ...f, rating: n }))}
                            className="transition-transform hover:scale-110">
                            <Star size={28} className={n <= reviewForm.rating ? 'text-amber-400 fill-amber-400' : 'text-gray-300'} />
                          </button>
                        ))}
                        <span className="ml-2 text-sm text-gray-500 self-center">{reviewForm.rating}/5</span>
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Your experience</label>
                      <textarea value={reviewForm.comment}
                        onChange={e => setReviewForm(f => ({ ...f, comment: e.target.value }))}
                        rows={3} placeholder="Share details of your own experience at this hotel..."
                        className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none resize-none" />
                      <p className={`text-xs mt-1 ${reviewForm.comment.length < 5 ? 'text-gray-400' : 'text-emerald-600'}`}>
                        {reviewForm.comment.length}/500 characters (min 5)
                      </p>
                    </div>
                    <button onClick={submitReview} disabled={submittingReview}
                      className="bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 disabled:opacity-50 transition-colors">
                      {submittingReview ? 'Posting...' : 'Post Review'}
                    </button>
                  </motion.div>
                )}
              </AnimatePresence>

              {reviews.length === 0 ? (
                <div className="text-center py-8 text-gray-400">
                  <MessageSquare size={36} className="mx-auto mb-2 opacity-30" />
                  <p className="text-sm">No reviews yet — be the first to review!</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {reviews.map((rev: any) => (
                    <div key={rev.id} className="border-b border-gray-50 pb-4 last:border-0 last:pb-0">
                      <div className="flex items-center gap-3 mb-2">
                        <div className="w-9 h-9 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
                          {rev.user_name?.charAt(0)?.toUpperCase() || 'U'}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="font-semibold text-gray-800 text-sm">{rev.user_name}</p>
                          <div className="flex items-center gap-2">
                            <div className="flex gap-0.5">
                              {[1,2,3,4,5].map(n => (
                                <Star key={n} size={12} className={n <= rev.rating ? 'text-amber-400 fill-amber-400' : 'text-gray-200 fill-gray-200'} />
                              ))}
                            </div>
                            <span className="text-xs text-gray-400">{new Date(rev.created_at).toLocaleDateString()}</span>
                          </div>
                        </div>
                      </div>
                      <p className="text-gray-600 text-sm pl-12 leading-relaxed">{rev.comment}</p>
                    </div>
                  ))}
                </div>
              )}
            </motion.div>
          </div>

          {/* ── Right: Sticky booking panel ──── */}
          <div className="lg:col-span-1">
            <div className="sticky top-24">
              <div className="bg-white rounded-2xl shadow-lg border border-gray-100 overflow-hidden">

                {/* Price header */}
                <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-4 text-white">
                  <p className="text-blue-100 text-xs font-medium uppercase tracking-wide">Starting from</p>
                  <div className="flex items-baseline gap-1 mt-1">
                    <span className="text-3xl font-bold">ETB {hotel.price_per_night?.toLocaleString()}</span>
                    <span className="text-blue-200 text-sm">/night</span>
                  </div>
                  {selectedRoom && (
                    <div className="mt-2 bg-blue-500/40 rounded-lg px-3 py-1.5 text-sm">
                      Selected: <span className="font-semibold">{selectedRoom.name}</span>
                      <span className="block text-xs text-blue-100">ETB {selectedRoom.price_per_night?.toLocaleString()}/night</span>
                    </div>
                  )}
                </div>

                <div className="p-5 space-y-4">
                  {/* Summary dates */}
                  <div className="flex justify-between text-sm text-gray-600 bg-gray-50 rounded-lg p-3">
                    <div>
                      <p className="text-xs text-gray-400">Check-in</p>
                      <p className="font-semibold text-gray-800">{checkIn}</p>
                    </div>
                    <div className="text-center">
                      <p className="text-xs text-gray-400">Duration</p>
                      <p className="font-semibold text-blue-600">{nights}N</p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs text-gray-400">Check-out</p>
                      <p className="font-semibold text-gray-800">{checkOut}</p>
                    </div>
                  </div>

                  {/* Total preview */}
                  <div className="flex justify-between items-center border-t border-gray-100 pt-3">
                    <span className="text-sm text-gray-600">
                      ETB {basePrice?.toLocaleString()} × {nights} night{nights > 1 ? 's' : ''}
                    </span>
                    <span className="text-lg font-bold text-blue-600">
                      ETB {totalPreview?.toLocaleString()}
                    </span>
                  </div>

                  {/* Availability status */}
                  <div className={`text-xs text-center rounded-lg py-2 font-medium ${
                    availLoading ? 'bg-gray-50 text-gray-400'
                    : availRooms.length === 0 ? 'bg-red-50 text-red-600'
                    : 'bg-emerald-50 text-emerald-700'
                  }`}>
                    {availLoading ? 'Checking availability...'
                      : availRooms.length === 0 ? '✗ No rooms available for selected dates'
                      : `✓ ${availRooms.length} room${availRooms.length > 1 ? 's' : ''} available`}
                  </div>

                  {/* Book button */}
                  <button
                    onClick={() => handleBook()}
                    disabled={availRooms.length === 0 || availLoading}
                    className="w-full flex items-center justify-center gap-2 bg-blue-600 text-white py-3.5 rounded-xl font-bold text-base hover:bg-blue-700 active:scale-98 transition-all disabled:opacity-40 disabled:cursor-not-allowed shadow-md hover:shadow-lg">
                    {selectedRoom ? `Book ${selectedRoom.name}` : 'Reserve Now'} <ChevronRight size={18} />
                  </button>

                  <p className="text-center text-xs text-gray-400">
                    {isAuthenticated
                      ? 'Select a room above and click Book Now'
                      : 'You\'ll be asked to sign in or create a free account'}
                  </p>

                  {/* Quick stats */}
                  <div className="grid grid-cols-2 gap-2 pt-2 border-t border-gray-100">
                    <div className="text-center">
                      <p className="text-xs text-gray-400">Rating</p>
                      <p className="font-bold text-gray-800 flex items-center justify-center gap-1">
                        <Star size={14} className="text-amber-500 fill-amber-500" /> {hotel.rating}
                      </p>
                    </div>
                    <div className="text-center">
                      <p className="text-xs text-gray-400">Reviews</p>
                      <p className="font-bold text-gray-800">{hotel.review_count}</p>
                    </div>
                  </div>
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

// pages/dashboard/Wishlist.tsx
import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Heart, Star, MapPin, Trash2, ArrowRight } from 'lucide-react'
import toast from 'react-hot-toast'
import { wishlistService } from '../../services/wishlist'
import Navbar from '../../components/shared/Navbar'
import Footer from '../../components/shared/Footer'
import Spinner from '../../components/shared/Spinner'

export default function Wishlist() {
  const navigate = useNavigate()
  const [hotels, setHotels] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [removing, setRemoving] = useState<number | null>(null)

  const load = () => {
    setLoading(true)
    wishlistService.getAll()
      .then(r => setHotels(r.data.data || []))
      .catch(() => toast.error('Failed to load wishlist'))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const handleRemove = async (hotelId: number) => {
    setRemoving(hotelId)
    try {
      await wishlistService.remove(hotelId)
      setHotels(h => h.filter(x => x.hotel_id !== hotelId))
      toast.success('Removed from wishlist')
    } catch {
      toast.error('Failed to remove')
    } finally { setRemoving(null) }
  }

  return (
    <>
      <Navbar />
      <div className="max-w-5xl mx-auto px-4 py-10">
        <div className="flex items-center gap-3 mb-8">
          <div className="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center">
            <Heart size={20} className="text-red-500 fill-red-500" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">My Wishlist</h1>
            <p className="text-gray-500 text-sm">{hotels.length} saved hotel{hotels.length !== 1 ? 's' : ''}</p>
          </div>
        </div>

        {loading ? (
          <div className="flex justify-center py-16"><Spinner /></div>
        ) : hotels.length === 0 ? (
          <div className="text-center py-16">
            <Heart size={48} className="mx-auto text-gray-200 mb-4" />
            <p className="text-gray-500 font-medium text-lg">Your wishlist is empty</p>
            <p className="text-gray-400 text-sm mt-1">Save hotels you like to find them easily later</p>
            <button onClick={() => navigate('/hotels')}
              className="mt-5 inline-flex items-center gap-2 bg-blue-600 text-white px-6 py-2.5 rounded-xl font-medium hover:bg-blue-700 transition-colors">
              Browse Hotels <ArrowRight size={16} />
            </button>
          </div>
        ) : (
          <AnimatePresence>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
              {hotels.map((h: any, i: number) => {
                // API returns: id, hotel_id, hotel_name, city, rating, price, image
                const img = h.image || h.hotel_image || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400'
                return (
                  <motion.div key={h.hotel_id || h.id}
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.9 }}
                    transition={{ delay: i * 0.05 }}
                    className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow group">
                    <div className="relative h-40">
                      <img src={img} alt={h.hotel_name} className="w-full h-full object-cover" />
                      <button
                        onClick={() => handleRemove(h.hotel_id || h.id)}
                        disabled={removing === (h.hotel_id || h.id)}
                        className="absolute top-3 right-3 w-8 h-8 bg-white/90 backdrop-blur rounded-full flex items-center justify-center hover:bg-red-50 transition-colors shadow-sm">
                        {removing === (h.hotel_id || h.id) ? (
                          <div className="w-4 h-4 border-2 border-red-400 border-t-red-600 rounded-full animate-spin" />
                        ) : (
                          <Trash2 size={15} className="text-red-500" />
                        )}
                      </button>
                    </div>
                    <div className="p-4">
                      <h3 className="font-bold text-gray-800 truncate">{h.hotel_name}</h3>
                      <p className="text-sm text-gray-500 flex items-center gap-1 mt-0.5">
                        <MapPin size={13} /> {h.city}
                      </p>
                      <div className="flex items-center justify-between mt-3">
                        <div className="flex items-center gap-1.5">
                          <Star size={14} className="text-amber-500 fill-amber-500" />
                          <span className="text-sm font-medium text-gray-700">{h.rating || '—'}</span>
                        </div>
                        <div className="text-right">
                          <span className="font-bold text-blue-600 text-sm">
                            ETB {Number(h.price || h.price_per_night || 0).toLocaleString()}
                          </span>
                          <span className="text-gray-400 text-xs">/night</span>
                        </div>
                      </div>
                      <button
                        onClick={() => navigate(`/hotels/${h.hotel_id || h.id}`)}
                        className="w-full mt-3 flex items-center justify-center gap-1.5 bg-blue-50 text-blue-600 py-2 rounded-lg text-sm font-medium hover:bg-blue-100 transition-colors">
                        View Hotel <ArrowRight size={14} />
                      </button>
                    </div>
                  </motion.div>
                )
              })}
            </div>
          </AnimatePresence>
        )}
      </div>
      <Footer />
    </>
  )
}

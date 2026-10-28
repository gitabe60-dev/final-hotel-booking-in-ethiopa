// pages/dashboard/Wishlist.tsx
import { useState, useEffect } from 'react'
import toast from 'react-hot-toast'
import { wishlistService } from '../../services/wishlist'
import Navbar from '../../components/shared/Navbar'
import HotelCard from '../../components/hotel/HotelCard'
import Spinner from '../../components/shared/Spinner'

export default function Wishlist() {
  const [hotels, setHotels] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  const load = () => {
    setLoading(true)
    wishlistService.getAll()
      .then(r => setHotels(r.data.data || []))
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const toggle = async (hotelId: number) => {
    await wishlistService.remove(hotelId)
    toast.success('Removed from wishlist')
    load()
  }

  return (
    <>
      <Navbar />
      <div className="max-w-6xl mx-auto px-4 py-10">
        <h1 className="text-2xl font-bold mb-6">My Wishlist</h1>
        {loading ? <Spinner /> : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {hotels.map((h: any) => (
              <HotelCard key={h.hotel_id} hotel={{ id: h.hotel_id, name: h.hotel_name, city: h.city,
                rating: h.rating, price_per_night: h.price_per_night, images: [h.image], type: '' }}
                wishlisted onToggleWishlist={toggle} />
            ))}
            {hotels.length === 0 && (
              <div className="col-span-4 text-center py-16 text-gray-400">Your wishlist is empty.</div>
            )}
          </div>
        )}
      </div>
    </>
  )
}

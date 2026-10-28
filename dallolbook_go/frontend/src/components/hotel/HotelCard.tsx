// components/hotel/HotelCard.tsx
import { Link } from 'react-router-dom'
import StarRating from './StarRating'

interface Props { hotel: any; onToggleWishlist?: (id: number) => void; wishlisted?: boolean }

export default function HotelCard({ hotel, onToggleWishlist, wishlisted }: Props) {
  const image = hotel.images?.[0] || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600'

  return (
    <div className="bg-white rounded-xl shadow hover:shadow-lg transition-shadow overflow-hidden">
      <div className="relative">
        <img src={image} alt={hotel.name} className="w-full h-48 object-cover" />
        <span className="absolute top-2 left-2 bg-blue-600 text-white text-xs px-2 py-1 rounded-full">
          {hotel.type}
        </span>
        {onToggleWishlist && (
          <button onClick={() => onToggleWishlist(hotel.id)}
            className="absolute top-2 right-2 p-1.5 bg-white rounded-full shadow">
            <svg className={`h-5 w-5 ${wishlisted ? 'text-red-500 fill-red-500' : 'text-gray-400'}`}
              viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
          </button>
        )}
      </div>

      <div className="p-4">
        <h3 className="font-semibold text-gray-900 text-lg truncate">{hotel.name}</h3>
        <p className="text-sm text-gray-500 mt-1">📍 {hotel.city}</p>
        <div className="flex items-center gap-2 mt-2">
          <StarRating rating={hotel.rating} />
          <span className="text-sm text-gray-500">({hotel.review_count})</span>
        </div>
        <div className="flex items-center justify-between mt-3">
          <div>
            <span className="text-xl font-bold text-blue-600">ETB {hotel.price_per_night?.toLocaleString()}</span>
            <span className="text-gray-500 text-sm"> / night</span>
          </div>
          <Link to={`/hotels/${hotel.id}`}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700">
            View
          </Link>
        </div>
      </div>
    </div>
  )
}

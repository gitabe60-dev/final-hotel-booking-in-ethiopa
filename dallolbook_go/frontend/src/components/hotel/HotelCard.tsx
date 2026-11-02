// components/hotel/HotelCard.tsx — animated hotel card
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Heart, MapPin, Star, ArrowRight } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import StarRating from './StarRating'

interface Props {
  hotel: any
  onToggleWishlist?: (id: number) => void
  wishlisted?: boolean
}

// Shimmer placeholder while image loads
function ImageSkeleton() {
  return (
    <div className="w-full h-48 bg-gradient-to-r from-gray-200 via-gray-100 to-gray-200 animate-pulse" />
  )
}

export default function HotelCard({ hotel, onToggleWishlist, wishlisted }: Props) {
  const { t } = useTranslation()
  const [imgLoaded, setImgLoaded] = useState(false)
  const [imgError, setImgError]   = useState(false)
  const [hovered, setHovered]     = useState(false)

  const image = (!imgError && (hotel.images?.[0] || hotel.image_url))
    || 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=80'

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      whileHover={{ y: -6, boxShadow: '0 20px 40px rgba(0,0,0,0.12)' }}
      transition={{ duration: 0.3 }}
      onHoverStart={() => setHovered(true)}
      onHoverEnd={() => setHovered(false)}
      className="bg-white rounded-2xl shadow-md overflow-hidden cursor-pointer group">

      {/* ── Image area ── */}
      <div className="relative h-48 overflow-hidden">
        {/* Shimmer while loading */}
        {!imgLoaded && <ImageSkeleton />}

        {/* Actual image with zoom on hover */}
        <motion.img
          src={image}
          alt={hotel.name}
          onLoad={() => setImgLoaded(true)}
          onError={() => { setImgError(true); setImgLoaded(true) }}
          animate={{ scale: hovered ? 1.08 : 1 }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
          className={`w-full h-full object-cover transition-opacity duration-500 ${imgLoaded ? 'opacity-100' : 'opacity-0'} absolute inset-0`}
        />

        {/* Dark gradient overlay — subtle on normal, stronger on hover */}
        <motion.div
          animate={{ opacity: hovered ? 0.45 : 0.15 }}
          transition={{ duration: 0.3 }}
          className="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent pointer-events-none"
        />

        {/* Type badge — slides in from left */}
        <motion.span
          initial={{ x: -20, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="absolute top-3 left-3 bg-blue-600/90 backdrop-blur-sm text-white text-xs font-bold px-2.5 py-1 rounded-full capitalize shadow">
          {hotel.type}
        </motion.span>

        {/* Featured badge */}
        {hotel.is_featured && (
          <motion.span
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: 'spring', stiffness: 400, delay: 0.15 }}
            className="absolute top-3 right-12 bg-amber-500 text-white text-xs font-bold px-2.5 py-1 rounded-full shadow">
            ★ {t('detail.featured')}
          </motion.span>
        )}

        {/* Wishlist button */}
        {onToggleWishlist && (
          <motion.button
            onClick={e => { e.preventDefault(); onToggleWishlist(hotel.id) }}
            whileTap={{ scale: 0.85 }}
            className="absolute top-3 right-3 p-1.5 bg-white/90 backdrop-blur-sm rounded-full shadow hover:bg-white transition-colors">
            <Heart size={16} className={wishlisted ? 'text-red-500 fill-red-500' : 'text-gray-400'} />
          </motion.button>
        )}

        {/* Price — floats up on hover from bottom */}
        <motion.div
          animate={{ y: hovered ? 0 : 8, opacity: hovered ? 1 : 0 }}
          transition={{ duration: 0.25 }}
          className="absolute bottom-3 left-3 bg-white/95 backdrop-blur-sm rounded-xl px-3 py-1.5 shadow">
          <span className="text-blue-700 font-extrabold text-base">{t('common.etb')} {hotel.price_per_night?.toLocaleString()}</span>
          <span className="text-gray-500 text-xs ml-1">{t('common.perNight')}</span>
        </motion.div>
      </div>

      {/* ── Card body ── */}
      <div className="p-4">
        <h3 className="font-bold text-gray-900 text-base truncate">{hotel.name}</h3>

        <p className="text-sm text-gray-500 mt-1 flex items-center gap-1 truncate">
          <MapPin size={13} className="text-blue-400 flex-shrink-0" /> {hotel.city}
        </p>

        {/* Rating row */}
        <div className="flex items-center gap-2 mt-2">
          <StarRating rating={hotel.rating} />
          <span className="text-xs text-gray-400">({hotel.review_count} {t('card.reviews')})</span>
        </div>

        {/* Price + CTA */}
        <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-50">
          <div>
            <span className="text-xl font-extrabold text-blue-600">
              {t('common.etb')} {hotel.price_per_night?.toLocaleString()}
            </span>
            <span className="text-gray-400 text-xs ml-1">{t('common.perNight')}</span>
          </div>

          <Link
            to={`/hotels/${hotel.id}`}
            onClick={e => e.stopPropagation()}
            className="flex items-center gap-1 bg-blue-600 text-white px-3.5 py-2 rounded-xl text-sm font-semibold hover:bg-blue-700 active:scale-[.96] transition-all shadow-sm shadow-blue-100">
            {t('card.view')} <ArrowRight size={14} />
          </Link>
        </div>
      </div>
    </motion.div>
  )
}

// pages/home/Home.tsx
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, MapPin, Star, ArrowRight, Sparkles } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import Navbar from '../../components/shared/Navbar'
import Footer from '../../components/shared/Footer'
import HotelCard from '../../components/hotel/HotelCard'
import Spinner from '../../components/shared/Spinner'
import { hotelService, getCities } from '../../services/hotels'

// ── Vertical-flip badge: alternates EN ↔ AM every 3 s ──────────────────────
const BADGE_TEXTS = [
  "Ethiopia's Premier Hotel Booking Platform",
  'የኢትዮጵያ ቀዳሚ የሆቴል ቦኪንግ መድረክ',
]

function AnimatingBadge() {
  const [idx, setIdx] = useState(0)
  const [visible, setVisible] = useState(true)

  useEffect(() => {
    const id = setInterval(() => {
      // Slide out → swap text → slide in
      setVisible(false)
      setTimeout(() => {
        setIdx(i => (i + 1) % BADGE_TEXTS.length)
        setVisible(true)
      }, 350)
    }, 3200)
    return () => clearInterval(id)
  }, [])

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="flex justify-center mb-6">
      {/* Outer square-ish box */}
      <div className="relative overflow-hidden bg-white/10 backdrop-blur-md border border-white/30 rounded-2xl px-6 py-3 shadow-lg shadow-black/20 min-w-[260px] max-w-sm text-center">
        {/* Animated text */}
        <AnimatePresence mode="wait">
          <motion.span
            key={idx}
            initial={{ y: 24, opacity: 0 }}
            animate={{ y: 0,  opacity: 1 }}
            exit={{ y: -24, opacity: 0 }}
            transition={{ duration: 0.35, ease: 'easeInOut' }}
            className={`block font-extrabold tracking-wide leading-tight text-white drop-shadow-sm ${
              idx === 0 ? 'text-sm uppercase' : 'text-base'
            }`}>
            {idx === 0 && <span className="mr-1.5">✨</span>}
            {BADGE_TEXTS[idx]}
            {idx === 0 && <span className="ml-1.5">✨</span>}
          </motion.span>
        </AnimatePresence>

        {/* Bottom accent line that shifts color */}
        <motion.div
          key={`line-${idx}`}
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ duration: 0.4, ease: 'easeOut' }}
          className={`absolute bottom-0 left-0 right-0 h-0.5 origin-left ${
            idx === 0 ? 'bg-amber-400' : 'bg-emerald-400'
          }`}
        />
      </div>
    </motion.div>
  )
}

export default function Home() {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [featured, setFeatured]       = useState<any[]>([])
  const [allHotels, setAllHotels]     = useState<any[]>([])
  const [cities, setCities]           = useState<any[]>([])
  const [loading, setLoading]         = useState(true)
  const [search, setSearch]           = useState('')
  const [selectedCity, setSelectedCity] = useState('')
  const [cityHotels, setCityHotels]   = useState<any[]>([])
  const [cityLoading, setCityLoading] = useState(false)

  useEffect(() => {
    const load = async () => {
      try {
        const [featRes, allRes, cityRes] = await Promise.all([
          hotelService.getFeatured(),
          hotelService.search({ limit: 50 }),
          getCities(),
        ])
        const allHotelData = allRes.data.data?.hotels || []
        setFeatured(featRes.data.data || [])
        setAllHotels(allHotelData)
        setCities(cityRes && cityRes.length > 0 ? cityRes : [])
        setCityHotels(allHotelData)
      } catch { /* ignore */ }
      setLoading(false)
    }
    load()
  }, [])

  const handleCityFilter = async (city: string) => {
    setSelectedCity(city)
    if (!city) { setCityHotels(allHotels); return }
    setCityLoading(true)
    try {
      const res = await hotelService.search({ city, limit: 50 })
      setCityHotels(res.data.data?.hotels || [])
    } catch { setCityHotels([]) }
    setCityLoading(false)
  }

  const handleSearch = () => {
    const params = new URLSearchParams()
    if (search)       params.set('name', search)
    if (selectedCity) params.set('city', selectedCity)
    navigate(`/hotels?${params.toString()}`)
  }

  return (
    <>
      <Navbar />

      {/* ── Hero ─────────────────────────────────────── */}
      <div className="relative overflow-hidden bg-gradient-to-br from-blue-700 via-blue-600 to-indigo-700 text-white">
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-10 left-10 w-64 h-64 bg-white rounded-full blur-3xl" />
          <div className="absolute bottom-0 right-10 w-96 h-96 bg-indigo-300 rounded-full blur-3xl" />
        </div>
        <div className="relative max-w-5xl mx-auto text-center py-24 px-4">
          {/* ── Vertical flip badge ── */}
          <AnimatingBadge />

          <motion.h1 initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, delay: 0.1 }}
            className="text-4xl md:text-6xl font-extrabold mb-4 leading-tight whitespace-pre-line">
            {t('home.heroTitle')}
          </motion.h1>
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, delay: 0.2 }}
            className="text-blue-100 text-lg mb-10">
            {t('home.heroSub')}
          </motion.p>

          {/* Search bar */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 }}
            className="flex flex-col md:flex-row gap-2 max-w-2xl mx-auto">
            <div className="relative flex-1">
              <Search size={20} className="absolute left-3 top-3 text-gray-400" />
              <input value={search} onChange={e => setSearch(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && handleSearch()}
                placeholder={t('home.searchName')}
                className="w-full pl-10 pr-4 py-3 rounded-xl text-gray-900 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none shadow-lg" />
            </div>
            <div className="relative">
              <MapPin size={18} className="absolute left-3 top-3.5 text-gray-400" />
              <select value={selectedCity} onChange={e => setSelectedCity(e.target.value)}
                className="pl-9 pr-4 py-3 rounded-xl text-gray-900 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none shadow-lg appearance-none bg-white min-w-[160px]">
                <option value="">{t('home.allCities')}</option>
                {cities.map((c: any) => (
                  <option key={c.id} value={c.name}>{c.name}</option>
                ))}
              </select>
            </div>
            <button onClick={handleSearch}
              className="bg-amber-500 hover:bg-amber-600 active:scale-95 text-white px-6 py-3 rounded-xl font-semibold text-sm shadow-lg transition-all">
              {t('home.searchBtn')}
            </button>
          </motion.div>
        </div>
      </div>

      {/* ── Featured Hotels ─────────────────────────── */}
      <div className="max-w-7xl mx-auto px-4 py-16">
        <motion.div initial={{ opacity: 0, x: -20 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }}
          className="flex items-center gap-2 mb-8">
          <Star size={22} className="text-amber-500 fill-amber-500" />
          <h2 className="text-2xl font-bold text-gray-900">{t('home.featured')}</h2>
        </motion.div>
        {loading ? <Spinner /> : featured.length === 0 ? (
          <p className="text-gray-400 text-center py-8">{t('home.noFeatured')}</p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {featured.map((h, i) => (
              <motion.div key={h.id} initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }} transition={{ delay: i * 0.07 }}>
                <HotelCard hotel={h} />
              </motion.div>
            ))}
          </div>
        )}
      </div>

      {/* ── Browse by City ──────────────────────────── */}
      <div className="bg-gradient-to-b from-gray-50 to-gray-100 py-16">
        <div className="max-w-7xl mx-auto px-4">
          <motion.div initial={{ opacity: 0, x: -20 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }}
            className="flex items-center justify-between mb-6 flex-wrap gap-3">
            <div className="flex items-center gap-2">
              <MapPin size={22} className="text-blue-600" />
              <h2 className="text-2xl font-bold text-gray-900">{t('home.browseCity')}</h2>
            </div>
            <button onClick={() => navigate('/hotels')}
              className="flex items-center gap-2 text-blue-600 text-sm font-medium hover:text-blue-800">
              {t('home.viewAll')} <ArrowRight size={16} />
            </button>
          </motion.div>

          {/* City filter chips */}
          <div className="flex flex-wrap gap-2 mb-8">
            <button onClick={() => handleCityFilter('')}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                selectedCity === '' ? 'bg-blue-600 text-white shadow-sm' : 'bg-white text-gray-600 hover:bg-blue-50 border border-gray-200'
              }`}>
              {t('home.allCities')}
              <span className="ml-2 text-xs opacity-70">{allHotels.length}</span>
            </button>
            {cities.map((c: any) => {
              const count = allHotels.filter((h: any) => h.city?.toLowerCase() === c.name?.toLowerCase()).length
              return (
                <button key={c.id} onClick={() => handleCityFilter(c.name)}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                    selectedCity === c.name ? 'bg-blue-600 text-white shadow-sm' : 'bg-white text-gray-600 hover:bg-blue-50 border border-gray-200'
                  }`}>
                  {c.name}
                  {count > 0 && <span className="ml-2 text-xs opacity-70">{count}</span>}
                </button>
              )
            })}
          </div>

          {/* Hotels grid */}
          <AnimatePresence mode="wait">
            <motion.div key={selectedCity} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
              {cityLoading ? <Spinner /> : cityHotels.length === 0 ? (
                <div className="text-center py-16 text-gray-400">
                  <MapPin size={40} className="mx-auto mb-2 opacity-40" />
                  <p>{t('home.noHotels')} {selectedCity ? `in ${selectedCity}` : ''}.</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  {cityHotels.slice(0, 8).map((h, i) => (
                    <motion.div key={h.id} initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: i * 0.05 }}>
                      <HotelCard hotel={h} />
                    </motion.div>
                  ))}
                </div>
              )}
            </motion.div>
          </AnimatePresence>

          {cityHotels.length > 8 && (
            <div className="text-center mt-8">
              <button onClick={() => navigate(`/hotels?city=${encodeURIComponent(selectedCity)}`)}
                className="inline-flex items-center gap-2 border-2 border-blue-600 text-blue-600 px-8 py-3 rounded-xl font-semibold hover:bg-blue-50 transition-colors">
                {t('home.viewAllIn')} {selectedCity || t('home.viewAll')} <ArrowRight size={18} />
              </button>
            </div>
          )}
        </div>
      </div>

      <Footer />
    </>
  )
}

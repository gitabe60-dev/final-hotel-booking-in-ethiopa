// pages/home/Home.tsx
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, MapPin, Star, ArrowRight, Sparkles } from 'lucide-react'
import Navbar from '../../components/shared/Navbar'
import Footer from '../../components/shared/Footer'
import HotelCard from '../../components/hotel/HotelCard'
import Spinner from '../../components/shared/Spinner'
import { hotelService, getCities } from '../../services/hotels'

export default function Home() {
  const navigate = useNavigate()
  const [featured, setFeatured] = useState<any[]>([])
  const [allHotels, setAllHotels] = useState<any[]>([])
  const [cities, setCities] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [selectedCity, setSelectedCity] = useState('')
  const [cityHotels, setCityHotels] = useState<any[]>([])
  const [cityLoading, setCityLoading] = useState(false)

  useEffect(() => {
    const load = async () => {
      try {
        const [featRes, allRes, cityRes] = await Promise.all([
          hotelService.getFeatured(),
          hotelService.search({ limit: 50 }),
          getCities(),
        ])
        setFeatured(featRes.data.data || [])
        setAllHotels(allRes.data.data?.hotels || [])
        setCities(cityRes || [])
        setCityHotels(allRes.data.data?.hotels || [])
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
    if (search) params.set('name', search)
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
          <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 bg-white/20 backdrop-blur px-4 py-1.5 rounded-full text-sm mb-6">
            <Sparkles size={15} /> Ethiopia's Premier Hotel Booking Platform
          </motion.div>
          <motion.h1 initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, delay: 0.1 }}
            className="text-4xl md:text-6xl font-extrabold mb-4 leading-tight">
            Discover Ethiopia's<br />Best Hotels
          </motion.h1>
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, delay: 0.2 }}
            className="text-blue-100 text-lg mb-10">
            From Addis Ababa to Bahir Dar — find and book your perfect stay in seconds.
          </motion.p>

          {/* Search bar */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 }}
            className="flex flex-col md:flex-row gap-2 max-w-2xl mx-auto">
            <div className="relative flex-1">
              <Search size={20} className="absolute left-3 top-3 text-gray-400" />
              <input value={search} onChange={e => setSearch(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && handleSearch()}
                placeholder="Search hotel name..."
                className="w-full pl-10 pr-4 py-3 rounded-xl text-gray-900 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none shadow-lg" />
            </div>
            <div className="relative">
              <MapPin size={18} className="absolute left-3 top-3.5 text-gray-400" />
              <select value={selectedCity} onChange={e => { setSelectedCity(e.target.value) }}
                className="pl-9 pr-4 py-3 rounded-xl text-gray-900 text-sm focus:ring-2 focus:ring-amber-400 focus:outline-none shadow-lg appearance-none bg-white min-w-[160px]">
                <option value="">All Cities</option>
                {cities.map((c: any) => (
                  <option key={c.id} value={c.name}>{c.name}</option>
                ))}
              </select>
            </div>
            <button onClick={handleSearch}
              className="bg-amber-500 hover:bg-amber-600 active:scale-95 text-white px-6 py-3 rounded-xl font-semibold text-sm shadow-lg transition-all">
              Search Hotels
            </button>
          </motion.div>
        </div>
      </div>

      {/* ── Featured Hotels ─────────────────────────── */}
      <div className="max-w-7xl mx-auto px-4 py-16">
        <motion.div initial={{ opacity: 0, x: -20 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }}
          className="flex items-center gap-2 mb-8">
          <Star size={22} className="text-amber-500 fill-amber-500" />
          <h2 className="text-2xl font-bold text-gray-900">Featured Hotels</h2>
        </motion.div>
        {loading ? <Spinner /> : featured.length === 0 ? (
          <p className="text-gray-400 text-center py-8">No featured hotels available.</p>
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
              <h2 className="text-2xl font-bold text-gray-900">Browse by City</h2>
            </div>
            <button onClick={() => navigate('/hotels')}
              className="flex items-center gap-2 text-blue-600 text-sm font-medium hover:text-blue-800">
              View All Hotels <ArrowRight size={16} />
            </button>
          </motion.div>

          {/* City filter chips from API */}
          <div className="flex flex-wrap gap-2 mb-8">
            <button onClick={() => handleCityFilter('')}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                selectedCity === '' ? 'bg-blue-600 text-white shadow-sm' : 'bg-white text-gray-600 hover:bg-blue-50 border border-gray-200'
              }`}>
              All Cities
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

          {/* Hotels for selected city */}
          <AnimatePresence mode="wait">
            <motion.div key={selectedCity} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
              {cityLoading ? <Spinner /> : cityHotels.length === 0 ? (
                <div className="text-center py-16 text-gray-400">
                  <MapPin size={40} className="mx-auto mb-2 opacity-40" />
                  <p>No hotels found in {selectedCity || 'any city'}.</p>
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
                View All {selectedCity ? `Hotels in ${selectedCity}` : 'Hotels'} <ArrowRight size={18} />
              </button>
            </div>
          )}
        </div>
      </div>

      <Footer />
    </>
  )
}

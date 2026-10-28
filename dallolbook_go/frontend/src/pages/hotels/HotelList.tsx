// pages/hotels/HotelList.tsx
import { useState, useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Search, SlidersHorizontal, X } from 'lucide-react'
import { hotelService, getCities } from '../../services/hotels'
import HotelCard from '../../components/hotel/HotelCard'
import Spinner from '../../components/shared/Spinner'
import Navbar from '../../components/shared/Navbar'
import Footer from '../../components/shared/Footer'
import EmptyState from '../../components/shared/EmptyState'

const TYPES  = ['hotel', 'resort', 'boutique', 'lodge']
const SORTS  = [
  { label: 'Best Rating', value: 'rating' },
  { label: 'Price ↑', value: 'price_asc' },
  { label: 'Price ↓', value: 'price_desc' },
  { label: 'Name A-Z', value: 'name' },
]

export default function HotelList() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const [hotels, setHotels] = useState<any[]>([])
  const [total, setTotal] = useState(0)
  const [loading, setLoading] = useState(true)
  const [offset, setOffset] = useState(0)
  const [cities, setCities] = useState<any[]>([])
  const [showFilters, setShowFilters] = useState(false)
  const limit = 12

  // Initialize filters from URL query params
  const [filters, setFilters] = useState({
    city:       searchParams.get('city')      || '',
    name:       searchParams.get('name')      || '',
    type:       searchParams.get('type')      || '',
    min_price:  searchParams.get('min_price') || '',
    max_price:  searchParams.get('max_price') || '',
    min_rating: searchParams.get('rating')    || '',
    sort: 'rating',
    dir: 'desc',
  })

  const doSearch = async (off = 0, f = filters) => {
    setLoading(true)
    try {
      const params: any = { limit, offset: off }
      if (f.city)       params.city      = f.city
      if (f.name)       params.name      = f.name
      if (f.type)       params.type      = f.type
      if (f.min_price)  params.min_price = Number(f.min_price)
      if (f.max_price)  params.max_price = Number(f.max_price)
      if (f.min_rating) params.min_rating = Number(f.min_rating)

      let sort = f.sort, dir = f.dir
      if (sort === 'price_asc')  { sort = 'price_per_night'; dir = 'asc' }
      if (sort === 'price_desc') { sort = 'price_per_night'; dir = 'desc' }
      params.sort = sort; params.dir = dir

      const res = await hotelService.search(params)
      setHotels(res.data.data.hotels || [])
      setTotal(res.data.data.total   || 0)
      setOffset(off)
    } finally { setLoading(false) }
  }

  useEffect(() => {
    getCities().then(list => setCities(list || []))
    doSearch(0)
  }, [])

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setFilters(f => ({ ...f, [k]: e.target.value }))

  const clearFilters = () => {
    const empty = { city: '', name: '', type: '', min_price: '', max_price: '', min_rating: '', sort: 'rating', dir: 'desc' }
    setFilters(empty)
    doSearch(0, empty)
    navigate('/hotels', { replace: true })
  }

  const hasFilters = filters.city || filters.name || filters.type || filters.min_price || filters.max_price || filters.min_rating

  return (
    <>
      <Navbar />
      <div className="min-h-screen bg-gray-50">
        {/* Top search bar */}
        <div className="bg-white shadow-sm border-b border-gray-100 sticky top-16 z-10">
          <div className="max-w-7xl mx-auto px-4 py-3">
            <div className="flex gap-2 items-center">
              <div className="relative flex-1 max-w-sm">
                <Search size={17} className="absolute left-3 top-2.5 text-gray-400" />
                <input className="w-full border border-gray-200 rounded-lg pl-9 pr-4 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  placeholder="Search hotels..."
                  value={filters.name} onChange={set('name')}
                  onKeyDown={e => e.key === 'Enter' && doSearch(0)} />
              </div>
              <select className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                value={filters.city} onChange={e => { set('city')(e); doSearch(0, { ...filters, city: e.target.value }) }}>
                <option value="">All Cities</option>
                {cities.map((c: any) => <option key={c.id} value={c.name}>{c.name}</option>)}
              </select>
              <button onClick={() => setShowFilters(!showFilters)}
                className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium border transition-colors ${showFilters ? 'bg-blue-600 text-white border-blue-600' : 'border-gray-200 text-gray-600 hover:bg-gray-50'}`}>
                <SlidersHorizontal size={16} /> Filters
                {hasFilters && <span className="bg-amber-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">!</span>}
              </button>
              <button onClick={() => doSearch(0)}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
                Search
              </button>
              {hasFilters && (
                <button onClick={clearFilters} className="text-gray-400 hover:text-gray-600 p-2 rounded-lg hover:bg-gray-100" title="Clear filters">
                  <X size={18} />
                </button>
              )}
            </div>

            {/* Expandable filters */}
            {showFilters && (
              <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }}
                className="mt-3 grid grid-cols-2 md:grid-cols-5 gap-3 pt-3 border-t border-gray-100">
                <select className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  value={filters.type} onChange={set('type')}>
                  <option value="">All Types</option>
                  {TYPES.map(t => <option key={t} value={t}>{t.charAt(0).toUpperCase() + t.slice(1)}</option>)}
                </select>
                <input className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  type="number" placeholder="Min price (ETB)"
                  value={filters.min_price} onChange={set('min_price')} />
                <input className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  type="number" placeholder="Max price (ETB)"
                  value={filters.max_price} onChange={set('max_price')} />
                <select className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  value={filters.min_rating} onChange={set('min_rating')}>
                  <option value="">Any Rating</option>
                  {['3','3.5','4','4.5'].map(r => <option key={r} value={r}>⭐ {r}+</option>)}
                </select>
                <select className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  value={filters.sort} onChange={set('sort')}>
                  {SORTS.map(s => <option key={s.value} value={s.value}>{s.label}</option>)}
                </select>
              </motion.div>
            )}
          </div>
        </div>

        {/* Results */}
        <div className="max-w-7xl mx-auto px-4 py-8">
          <div className="flex items-center justify-between mb-6">
            <p className="text-gray-600 text-sm">
              {loading ? 'Searching...' : (
                <span><span className="font-semibold text-gray-800">{total}</span> hotel{total !== 1 ? 's' : ''} found
                {filters.city && <span className="text-blue-600"> in {filters.city}</span>}</span>
              )}
            </p>
          </div>

          {loading ? <Spinner /> : hotels.length === 0 ? (
            <EmptyState title="No hotels found" subtitle="Try adjusting your search filters" icon="🏨" />
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {hotels.map((h, i) => (
                <motion.div key={h.id} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.04 }}>
                  <HotelCard hotel={h} />
                </motion.div>
              ))}
            </div>
          )}

          {/* Pagination */}
          {total > limit && (
            <div className="flex justify-center items-center gap-3 mt-10">
              <button disabled={offset === 0} onClick={() => doSearch(offset - limit)}
                className="px-5 py-2 border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed">
                ← Previous
              </button>
              <span className="text-sm text-gray-600 font-medium">
                Page {Math.floor(offset / limit) + 1} of {Math.ceil(total / limit)}
              </span>
              <button disabled={offset + limit >= total} onClick={() => doSearch(offset + limit)}
                className="px-5 py-2 border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed">
                Next →
              </button>
            </div>
          )}
        </div>
      </div>
      <Footer />
    </>
  )
}

// pages/admin/super/HotelsPage.tsx
import { useEffect, useState } from 'react'
import { Plus, Pencil, Power, Search } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import Spinner from '../../../components/shared/Spinner'
import EmptyState from '../../../components/shared/EmptyState'
import { adminService } from '../../../services/admin'
import { hotelService } from '../../../services/hotels'
import toast from 'react-hot-toast'
import { motion } from 'framer-motion'

export default function HotelsPage() {
  const [hotels, setHotels] = useState<any[]>([])
  const [cities, setCities] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [showCreate, setShowCreate] = useState(false)
  const [editing, setEditing] = useState<any>(null)
  const [form, setForm] = useState({
    name: '', city: '', address: '', description: '', type: 'hotel',
    price_per_night: 0, latitude: 0, longitude: 0, is_featured: false,
  })

  const load = async () => {
    setLoading(true)
    try {
      const [res, citiesRes] = await Promise.all([
        adminService.superHotels(search),
        adminService.getCities(),
      ])
      setHotels(res.data.data || [])
      setCities(citiesRes.data.data || [])
    } catch { toast.error('Failed to load hotels') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleSearch = () => load()

  const openEdit = (h: any) => {
    setEditing(h)
    setForm({
      name: h.name, city: h.city, address: '', description: '', type: h.type,
      price_per_night: h.price_per_night, latitude: 0, longitude: 0, is_featured: false,
    })
  }

  const handleCreate = async () => {
    if (!form.name || !form.city) { toast.error('Name and city are required'); return }
    try {
      await adminService.addHotel(form)
      toast.success('Hotel created')
      setShowCreate(false)
      setForm({ name: '', city: '', address: '', description: '', type: 'hotel', price_per_night: 0, latitude: 0, longitude: 0, is_featured: false })
      load()
    } catch { toast.error('Failed to create hotel') }
  }

  const handleEdit = async () => {
    if (!editing) return
    try {
      await adminService.editHotel(editing.id, {
        name: form.name, city: form.city, address: form.address,
        description: form.description, type: form.type,
        price_per_night: form.price_per_night, is_active: true,
      })
      toast.success('Hotel updated')
      setEditing(null)
      load()
    } catch { toast.error('Failed to update hotel') }
  }

  const handleToggle = async (id: number) => {
    try {
      await adminService.toggleHotel(id)
      toast.success('Hotel status toggled')
      load()
    } catch { toast.error('Failed to toggle') }
  }

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="super_admin">
      <PageHeader
        title="Hotels"
        subtitle="Manage all registered hotels"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <Plus size={18} /> Add Hotel
          </button>
        }
      />

      <div className="flex gap-2 mb-6">
        <div className="relative flex-1">
          <Search size={18} className="absolute left-3 top-2.5 text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSearch()}
            placeholder="Search hotels..."
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
        </div>
        <button onClick={handleSearch} className="bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors text-sm font-medium">
          Search
        </button>
      </div>

      {hotels.length === 0 ? (
        <EmptyState title="No hotels found" icon="🏨" />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {hotels.map((h, i) => (
            <motion.div
              key={h.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.05 }}
              className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow"
            >
              <div className="h-32 bg-gradient-to-br from-blue-400 to-blue-600 relative">
                {h.image && <img src={h.image} alt={h.name} className="w-full h-full object-cover" />}
                <div className="absolute top-2 right-2"><Badge status={h.is_active ? 'active' : 'inactive'} /></div>
              </div>
              <div className="p-4">
                <h3 className="font-semibold text-gray-800">{h.name}</h3>
                <p className="text-sm text-gray-500">{h.city} · {h.type}</p>
                <div className="flex items-center justify-between mt-3">
                  <span className="text-blue-600 font-bold">ETB {h.price_per_night}<span className="text-gray-400 text-xs font-normal">/night</span></span>
                  <div className="flex gap-1">
                    <button onClick={() => openEdit(h)} className="p-1.5 rounded-lg hover:bg-blue-50 text-blue-600" title="Edit">
                      <Pencil size={16} />
                    </button>
                    <button onClick={() => handleToggle(h.id)} className="p-1.5 rounded-lg hover:bg-amber-50 text-amber-600" title="Toggle">
                      <Power size={16} />
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Create Hotel Modal */}
      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="Add Hotel" size="lg">
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Hotel Name *</label>
              <input value={form.name} onChange={e => setForm({...form, name: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">City *</label>
              <select value={form.city} onChange={e => setForm({...form, city: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
                <option value="">Select city...</option>
                {cities.map((c: any) => <option key={c.id} value={c.name}>{c.name}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
            <input value={form.address} onChange={e => setForm({...form, address: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})} rows={3}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <select value={form.type} onChange={e => setForm({...form, type: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
                <option value="hotel">Hotel</option>
                <option value="resort">Resort</option>
                <option value="boutique">Boutique</option>
                <option value="lodge">Lodge</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Price/Night (ETB)</label>
              <input type="number" value={form.price_per_night} onChange={e => setForm({...form, price_per_night: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Featured</label>
              <select value={form.is_featured ? 'yes' : 'no'} onChange={e => setForm({...form, is_featured: e.target.value === 'yes'})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
                <option value="no">No</option>
                <option value="yes">Yes</option>
              </select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Latitude (Google Maps)</label>
              <input type="number" step="any" value={form.latitude} onChange={e => setForm({...form, latitude: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
                placeholder="e.g. 9.0192" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Longitude (Google Maps)</label>
              <input type="number" step="any" value={form.longitude} onChange={e => setForm({...form, longitude: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
                placeholder="e.g. 38.7525" />
            </div>
          </div>
          <button onClick={handleCreate}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Create Hotel
          </button>
        </div>
      </Modal>

      {/* Edit Hotel Modal */}
      <Modal open={!!editing} onClose={() => setEditing(null)} title="Edit Hotel" size="lg">
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Hotel Name</label>
              <input value={form.name} onChange={e => setForm({...form, name: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">City</label>
              <select value={form.city} onChange={e => setForm({...form, city: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
                <option value="">Select city...</option>
                {cities.map((c: any) => <option key={c.id} value={c.name}>{c.name}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
            <input value={form.address} onChange={e => setForm({...form, address: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea value={form.description} onChange={e => setForm({...form, description: e.target.value})} rows={3}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <select value={form.type} onChange={e => setForm({...form, type: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
                <option value="hotel">Hotel</option>
                <option value="resort">Resort</option>
                <option value="boutique">Boutique</option>
                <option value="lodge">Lodge</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Price/Night (ETB)</label>
              <input type="number" value={form.price_per_night} onChange={e => setForm({...form, price_per_night: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
          </div>
          <button onClick={handleEdit}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Save Changes
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

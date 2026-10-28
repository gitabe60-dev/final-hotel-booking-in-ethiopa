// pages/admin/manager/RoomsPage.tsx
import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { Bed, Plus, Power, Trash2 } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import Spinner from '../../../components/shared/Spinner'
import EmptyState from '../../../components/shared/EmptyState'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function ManagerRoomsPage() {
  const [rooms, setRooms] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', bed_type: '', price_per_night: 0, max_guests: 2 })

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.managerRooms()
      setRooms(res.data.data || [])
    } catch { toast.error('Failed to load rooms') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleSave = async () => {
    if (!form.name || !form.bed_type || form.price_per_night <= 0) {
      toast.error('Room name, bed type and price are required'); return
    }
    try {
      await adminService.managerAddRoom(form)
      toast.success('Room added')
      setShowForm(false)
      setForm({ name: '', bed_type: '', price_per_night: 0, max_guests: 2 })
      load()
    } catch { toast.error('Failed to add room') }
  }

  const handleToggle = async (roomId: number) => {
    try {
      await adminService.managerToggleRoom(roomId)
      toast.success('Room availability toggled')
      load()
    } catch { toast.error('Failed to toggle room') }
  }

  const handleDelete = async (roomId: number) => {
    if (!confirm('Delete this room?')) return
    try {
      await adminService.managerDeleteRoom(roomId)
      toast.success('Room deleted')
      load()
    } catch { toast.error('Failed to delete room') }
  }

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="hotel_manager">
      <PageHeader
        title="My Rooms"
        subtitle="Manage rooms in your hotel"
        action={
          <button onClick={() => { setForm({ name: '', bed_type: '', price_per_night: 0, max_guests: 2 }); setShowForm(true) }}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <Plus size={18} /> Add Room
          </button>
        }
      />

      {rooms.length === 0 ? (
        <EmptyState title="No rooms yet" subtitle="Add rooms for guests to book" icon="🛏️" />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {rooms.map((r, i) => (
            <motion.div
              key={r.id}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: i * 0.05 }}
              className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 hover:shadow-md transition-shadow"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-2">
                  <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center">
                    <Bed size={18} className="text-blue-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-800">{r.name}</h3>
                    <p className="text-xs text-gray-500">{r.bed_type}</p>
                  </div>
                </div>
                <Badge status={r.is_available ? 'available' : 'inactive'} />
              </div>
              <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-50">
                <div>
                  <span className="text-blue-600 font-bold">ETB {r.price_per_night}</span>
                  <span className="text-gray-400 text-xs"> /night</span>
                  <p className="text-xs text-gray-500 mt-0.5">{r.max_guests} guests max</p>
                </div>
                <div className="flex gap-1">
                  <button onClick={() => handleToggle(r.id)} className="p-1.5 rounded-lg hover:bg-amber-50 text-amber-600" title="Toggle availability">
                    <Power size={15} />
                  </button>
                  <button onClick={() => handleDelete(r.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500" title="Delete">
                    <Trash2 size={15} />
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      <Modal open={showForm} onClose={() => setShowForm(false)} title="Add Room">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Room Name *</label>
            <input value={form.name} onChange={e => setForm({...form, name: e.target.value})}
              placeholder="e.g. Deluxe Room" className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Bed Type *</label>
            <select value={form.bed_type} onChange={e => setForm({...form, bed_type: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
              <option value="">Select...</option>
              <option value="Single">Single</option>
              <option value="Double">Double</option>
              <option value="Twin">Twin</option>
              <option value="Queen">Queen</option>
              <option value="King">King</option>
            </select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Price/Night (ETB) *</label>
              <input type="number" value={form.price_per_night} onChange={e => setForm({...form, price_per_night: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Max Guests</label>
              <input type="number" value={form.max_guests} onChange={e => setForm({...form, max_guests: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
          </div>
          <button onClick={handleSave}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Add Room
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

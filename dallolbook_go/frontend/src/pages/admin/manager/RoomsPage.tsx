// pages/admin/manager/RoomsPage.tsx — full room management with status control
import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { Bed, Plus, Trash2, Pencil, Wrench, CheckCircle, XCircle, DollarSign } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Spinner from '../../../components/shared/Spinner'
import EmptyState from '../../../components/shared/EmptyState'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

const STATUS_CONFIG: Record<string, { label: string; color: string; icon: any; bg: string }> = {
  available:    { label: 'Available',    color: 'text-emerald-700', icon: CheckCircle, bg: 'bg-emerald-100' },
  maintenance:   { label: 'Maintenance',  color: 'text-amber-700',  icon: Wrench,      bg: 'bg-amber-100' },
  unavailable:   { label: 'Unavailable',  color: 'text-red-700',    icon: XCircle,     bg: 'bg-red-100' },
}

const EMPTY = { name: '', bed_type: '', price_per_night: 0, max_guests: 2, image_url: '', room_status: 'available' }

export default function ManagerRoomsPage() {
  const [rooms, setRooms] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing]   = useState<any>(null)
  const [form, setForm] = useState({ ...EMPTY })

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
      if (editing) {
        await adminService.managerEditRoom(editing.id, form)
        toast.success('Room updated')
      } else {
        await adminService.managerAddRoom(form)
        toast.success('Room added')
      }
      setShowForm(false)
      setEditing(null)
      setForm({ ...EMPTY })
      load()
    } catch { toast.error('Failed to save room') }
  }

  const openEdit = (r: any) => {
    setForm({ name: r.name, bed_type: r.bed_type, price_per_night: r.price_per_night, max_guests: r.max_guests, image_url: r.image_url || '', room_status: r.room_status || 'available' })
    setEditing(r)
    setShowForm(true)
  }

  const handleDelete = async (roomId: number) => {
    if (!confirm('Delete this room? This cannot be undone.')) return
    try {
      await adminService.managerDeleteRoom(roomId)
      toast.success('Room deleted')
      load()
    } catch { toast.error('Failed to delete room') }
  }

  const handleStatusChange = async (roomId: number, status: string) => {
    try {
      await adminService.managerSetRoomStatus(roomId, status)
      toast.success(`Room status: ${STATUS_CONFIG[status]?.label || status}`)
      load()
    } catch { toast.error('Failed to update status') }
  }

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="hotel_manager">
      <PageHeader
        title="My Rooms"
        subtitle="Manage rooms, status, and availability"
        action={
          <button onClick={() => { setForm({ ...EMPTY }); setEditing(null); setShowForm(true) }}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <Plus size={18} /> Add Room
          </button>
        }
      />

      {rooms.length === 0 ? (
        <EmptyState title="No rooms yet" subtitle="Add rooms for guests to book" icon="🛏️" />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {rooms.map((r, i) => {
            const status = r.room_status || (r.is_available ? 'available' : 'unavailable')
            const sc = STATUS_CONFIG[status] || STATUS_CONFIG.available
            const StatusIcon = sc.icon

            return (
              <motion.div key={r.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: i * 0.05 }}
                className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">

                {/* Room image */}
                <div className="h-32 bg-gray-100 relative overflow-hidden">
                  {r.image_url
                    ? <img src={r.image_url} alt={r.name} className="w-full h-full object-cover" />
                    : <div className="w-full h-full flex items-center justify-center bg-blue-50">
                        <Bed size={32} className="text-blue-300" />
                      </div>
                  }
                  {/* Status badge on image */}
                  <div className={`absolute top-2 right-2 ${sc.bg} ${sc.color} text-xs font-semibold px-2.5 py-1 rounded-full flex items-center gap-1 shadow-sm`}>
                    <StatusIcon size={11} /> {sc.label}
                  </div>
                </div>

                {/* Room info */}
                <div className="p-4">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="font-semibold text-gray-800">{r.name}</h3>
                      <p className="text-xs text-gray-500 mt-0.5">{r.bed_type} · max {r.max_guests} guests</p>
                    </div>
                    <div className="flex gap-1">
                      <button onClick={() => openEdit(r)} className="p-1.5 rounded-lg hover:bg-blue-50 text-blue-600" title="Edit">
                        <Pencil size={14} />
                      </button>
                      <button onClick={() => handleDelete(r.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-red-500" title="Delete">
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </div>

                  {/* Price */}
                  <div className="flex items-center gap-1 mt-2">
                    <DollarSign size={14} className="text-blue-500" />
                    <span className="text-blue-600 font-bold">{r.price_per_night}</span>
                    <span className="text-gray-400 text-xs">/night</span>
                  </div>

                  {/* Status dropdown */}
                  <div className="mt-3 pt-3 border-t border-gray-50">
                    <label className="text-xs text-gray-400 font-medium uppercase tracking-wide mb-1.5 block">Room Status</label>
                    <select
                      value={status}
                      onChange={e => handleStatusChange(r.id, e.target.value)}
                      className={`w-full border rounded-lg px-3 py-2 text-sm font-medium cursor-pointer outline-none transition ${sc.bg} ${sc.color} border-transparent hover:border-gray-300`}>
                      <option value="available" className="bg-white text-gray-700">✅ Available</option>
                      <option value="maintenance" className="bg-white text-gray-700">🔧 Maintenance</option>
                      <option value="unavailable" className="bg-white text-gray-700">❌ Unavailable</option>
                    </select>
                  </div>
                </div>
              </motion.div>
            )
          })}
        </div>
      )}

      {/* Add/Edit Room Modal */}
      <Modal open={showForm} onClose={() => { setShowForm(false); setEditing(null) }}
        title={editing ? 'Edit Room' : 'Add New Room'} size="lg">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Room Name *</label>
            <input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
              placeholder="e.g. Deluxe King Room"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Bed Type *</label>
              <select value={form.bed_type} onChange={e => setForm(f => ({ ...f, bed_type: e.target.value }))}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none">
                <option value="">Select...</option>
                {['Single', 'Double', 'Twin', 'Queen', 'King'].map(b => <option key={b} value={b}>{b}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Room Status</label>
              <select value={form.room_status} onChange={e => setForm(f => ({ ...f, room_status: e.target.value }))}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none">
                <option value="available">✅ Available</option>
                <option value="maintenance">🔧 Maintenance</option>
                <option value="unavailable">❌ Unavailable</option>
              </select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Price/Night (ETB) *</label>
              <input type="number" value={form.price_per_night} onChange={e => setForm(f => ({ ...f, price_per_night: +e.target.value }))}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Max Guests</label>
              <input type="number" value={form.max_guests} onChange={e => setForm(f => ({ ...f, max_guests: +e.target.value }))}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Room Image URL</label>
            <input value={form.image_url} onChange={e => setForm(f => ({ ...f, image_url: e.target.value }))}
              placeholder="https://example.com/room.jpg"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            {form.image_url && <img src={form.image_url} alt="" className="mt-2 h-20 rounded-lg object-cover w-full" onError={e => (e.currentTarget.style.display = 'none')} />}
          </div>
          <button onClick={handleSave}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            {editing ? 'Save Changes' : 'Add Room'}
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

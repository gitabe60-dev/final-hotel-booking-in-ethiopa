// pages/admin/subadmin/HotelsPage.tsx — hotel + room management with full validation
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Plus, ChevronDown, ChevronRight, Power, Trash2, Pencil, Bed } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import Spinner from '../../../components/shared/Spinner'
import EmptyState from '../../../components/shared/EmptyState'
import { validateRequired, validatePositiveNumber, hasErrors, type FieldError } from '../../../utils/validate'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

// ── helpers ───────────────────────────────────────────────────────────────────
const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

const validateLatLng = (v: number, label: string): FieldError => {
  if (v === 0) return null // 0 = not entered, treated as optional
  if (isNaN(v)) return `${label} must be a valid number`
  if (label === 'Latitude'  && (v < -90  || v > 90))  return 'Latitude must be between -90 and 90'
  if (label === 'Longitude' && (v < -180 || v > 180)) return 'Longitude must be between -180 and 180'
  return null
}

// ── initial states ─────────────────────────────────────────────────────────────
const EMPTY_HOTEL = {
  name: '', address: '', description: '', type: 'hotel',
  price_per_night: 0, latitude: 0, longitude: 0, is_featured: false, image_url: '',
}
const EMPTY_HOTEL_ERRS = {
  name:            null as FieldError,
  address:         null as FieldError,
  price_per_night: null as FieldError,
  latitude:        null as FieldError,
  longitude:       null as FieldError,
}

const EMPTY_ROOM = { name: '', bed_type: '', price_per_night: 0, max_guests: 2, image_url: '' }
const EMPTY_ROOM_ERRS = {
  name:            null as FieldError,
  bed_type:        null as FieldError,
  price_per_night: null as FieldError,
  max_guests:      null as FieldError,
}

export default function SubHotelsPage() {
  const navigate = useNavigate()
  const [hotels, setHotels]   = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [expanded, setExpanded] = useState<number | null>(null)
  const [rooms, setRooms] = useState<Record<number, any[]>>({})

  // hotel form
  const [showHotel, setShowHotel] = useState(false)
  const [editHotel, setEditHotel] = useState<any>(null)
  const [hotelForm, setHotelForm] = useState({ ...EMPTY_HOTEL })
  const [hotelErrs, setHotelErrs] = useState({ ...EMPTY_HOTEL_ERRS })
  const [savingHotel, setSavingHotel] = useState(false)

  // room form
  const [showRoom, setShowRoom]   = useState(false)
  const [selectedHotel, setSelectedHotel] = useState<number>(0)
  const [editRoom, setEditRoom]   = useState<any>(null)
  const [roomForm, setRoomForm]   = useState({ ...EMPTY_ROOM })
  const [roomErrs, setRoomErrs]   = useState({ ...EMPTY_ROOM_ERRS })
  const [savingRoom, setSavingRoom] = useState(false)

  // ── data loaders ─────────────────────────────────────────────────────────────
  const load = async () => {
    setLoading(true)
    try { const res = await adminService.subHotels(); setHotels(res.data.data || []) }
    catch { toast.error('Failed to load hotels') }
    setLoading(false)
  }

  const loadRooms = async (hotelId: number) => {
    try {
      const res = await adminService.getRooms(hotelId)
      setRooms(p => ({ ...p, [hotelId]: res.data.data || [] }))
    } catch { toast.error('Failed to load rooms') }
  }

  useEffect(() => { load() }, [])

  const toggleExpand = async (id: number) => {
    if (expanded === id) { setExpanded(null); return }
    setExpanded(id)
    if (!rooms[id]) await loadRooms(id)
  }

  // ── hotel field helpers ───────────────────────────────────────────────────────
  const setHotelField = <K extends keyof typeof hotelForm>(key: K, val: typeof hotelForm[K]) => {
    setHotelForm(f => ({ ...f, [key]: val }))
    setHotelErrs(e => ({ ...e, [key]: null }))
  }

  const validateHotel = () => {
    const next = {
      name:            validateRequired(hotelForm.name, 'Hotel name'),
      address:         validateRequired(hotelForm.address, 'Address'),
      price_per_night: validatePositiveNumber(hotelForm.price_per_night, 'Price'),
      latitude:        validateLatLng(hotelForm.latitude,  'Latitude'),
      longitude:       validateLatLng(hotelForm.longitude, 'Longitude'),
    }
    setHotelErrs(next)
    return !hasErrors(next)
  }

  // ── hotel CRUD ────────────────────────────────────────────────────────────────
  const handleAddHotel = async () => {
    if (!validateHotel()) return
    setSavingHotel(true)
    try {
      await adminService.subAddHotel(hotelForm)
      toast.success('Hotel created!')
      setShowHotel(false); setHotelForm({ ...EMPTY_HOTEL }); setHotelErrs({ ...EMPTY_HOTEL_ERRS }); load()
    } catch (err: any) { toast.error(err.response?.data?.message || 'Failed to create hotel') }
    setSavingHotel(false)
  }

  const handleEditHotel = async () => {
    if (!editHotel || !validateHotel()) return
    setSavingHotel(true)
    try {
      await adminService.subEditHotel(editHotel.id, { ...hotelForm, is_active: true })
      toast.success('Hotel updated!')
      setEditHotel(null); setHotelErrs({ ...EMPTY_HOTEL_ERRS }); load()
    } catch (err: any) { toast.error(err.response?.data?.message || 'Failed to update hotel') }
    setSavingHotel(false)
  }

  const openEditHotel = (h: any) => {
    setHotelForm({
      name: h.name, address: h.address || '', description: h.description || '',
      type: h.type, price_per_night: h.price_per_night,
      latitude: h.latitude || 0, longitude: h.longitude || 0,
      is_featured: h.is_featured || false, image_url: h.image || '',
    })
    setHotelErrs({ ...EMPTY_HOTEL_ERRS })
    setEditHotel(h)
  }

  const handleToggleHotel = async (id: number) => {
    try { await adminService.subToggleHotel(id); toast.success('Hotel status toggled'); load() }
    catch { toast.error('Failed') }
  }

  // ── room field helpers ────────────────────────────────────────────────────────
  const setRoomField = <K extends keyof typeof roomForm>(key: K, val: typeof roomForm[K]) => {
    setRoomForm(f => ({ ...f, [key]: val }))
    setRoomErrs(e => ({ ...e, [key]: null }))
  }

  const validateRoom = () => {
    const next = {
      name:            validateRequired(roomForm.name, 'Room name'),
      bed_type:        roomForm.bed_type ? null : 'Please select a bed type',
      price_per_night: validatePositiveNumber(roomForm.price_per_night, 'Price'),
      max_guests:      roomForm.max_guests < 1 ? 'Max guests must be at least 1' : null,
    }
    setRoomErrs(next)
    return !hasErrors(next)
  }

  // ── room CRUD ─────────────────────────────────────────────────────────────────
  const handleAddRoom = async () => {
    if (!validateRoom()) return
    setSavingRoom(true)
    try {
      await adminService.addRoom(selectedHotel, roomForm)
      toast.success('Room added!')
      setShowRoom(false); setRoomForm({ ...EMPTY_ROOM }); setRoomErrs({ ...EMPTY_ROOM_ERRS })
      await loadRooms(selectedHotel)
    } catch (err: any) { toast.error(err.response?.data?.message || 'Failed to add room') }
    setSavingRoom(false)
  }

  const handleEditRoom = async () => {
    if (!editRoom || !validateRoom()) return
    setSavingRoom(true)
    try {
      await adminService.editRoom(selectedHotel, editRoom.id, roomForm)
      toast.success('Room updated!')
      setEditRoom(null); setRoomErrs({ ...EMPTY_ROOM_ERRS })
      await loadRooms(selectedHotel)
    } catch (err: any) { toast.error(err.response?.data?.message || 'Failed to update room') }
    setSavingRoom(false)
  }

  const handleToggleRoom = async (hotelId: number, roomId: number) => {
    try { await adminService.toggleRoom(hotelId, roomId); await loadRooms(hotelId) }
    catch { toast.error('Failed to toggle room') }
  }

  const handleDeleteRoom = async (hotelId: number, roomId: number) => {
    if (!confirm('Delete this room?')) return
    try { await adminService.deleteRoom(hotelId, roomId); await loadRooms(hotelId) }
    catch { toast.error('Failed to delete room') }
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader title="Hotels" subtitle="Manage hotels and rooms in your city"
        action={
          <button onClick={() => { setHotelForm({ ...EMPTY_HOTEL }); setHotelErrs({ ...EMPTY_HOTEL_ERRS }); setShowHotel(true) }}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 text-sm font-medium">
            <Plus size={18} /> Add Hotel
          </button>
        }
      />

      {hotels.length === 0 ? (
        <EmptyState title="No hotels in your city yet" subtitle="Add your first hotel" icon="🏨" />
      ) : (
        <div className="space-y-3">
          {hotels.map((h, i) => (
            <motion.div key={h.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.05 }}
              className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
              <div className="flex items-center gap-3 p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                onClick={() => toggleExpand(h.id)}>
                {expanded === h.id
                  ? <ChevronDown size={18} className="text-gray-400" />
                  : <ChevronRight size={18} className="text-gray-400" />}
                <div className="w-14 h-14 rounded-lg overflow-hidden bg-gradient-to-br from-blue-400 to-blue-600 flex-shrink-0">
                  {h.image ? <img src={h.image} alt="" className="w-full h-full object-cover" /> : null}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-gray-800">{h.name}</h3>
                  <p className="text-sm text-gray-500">{h.type} · ETB {h.price_per_night?.toLocaleString()}/night</p>
                </div>
                <div className="flex items-center gap-2">
                  <Badge status={h.is_active ? 'active' : 'inactive'} />
                  <button onClick={e => { e.stopPropagation(); openEditHotel(h) }}
                    className="p-1.5 rounded-lg text-blue-600 hover:bg-blue-50"><Pencil size={15} /></button>
                  <button onClick={e => { e.stopPropagation(); handleToggleHotel(h.id) }}
                    className="p-1.5 rounded-lg text-amber-600 hover:bg-amber-50"><Power size={15} /></button>
                </div>
              </div>

              <AnimatePresence>
                {expanded === h.id && (
                  <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }} exit={{ height: 0, opacity: 0 }}
                    className="border-t border-gray-100">
                    <div className="p-4">
                      <div className="flex items-center justify-between mb-3">
                        <h4 className="text-sm font-semibold text-gray-600 flex items-center gap-2"><Bed size={16} /> Rooms</h4>
                        <button onClick={() => {
                          setSelectedHotel(h.id); setRoomForm({ ...EMPTY_ROOM })
                          setRoomErrs({ ...EMPTY_ROOM_ERRS }); setEditRoom(null); setShowRoom(true)
                        }}
                          className="flex items-center gap-1.5 bg-blue-50 text-blue-600 px-3 py-1.5 rounded-lg hover:bg-blue-100 text-sm font-medium">
                          <Plus size={15} /> Add Room
                        </button>
                      </div>
                      {(rooms[h.id] || []).length === 0 ? (
                        <p className="text-gray-400 text-sm text-center py-4">No rooms yet — add the first room.</p>
                      ) : (
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                          {(rooms[h.id] || []).map((r: any) => (
                            <div key={r.id} className="flex items-center gap-3 bg-gray-50 rounded-lg p-3">
                              {r.image_url
                                ? <img src={r.image_url} alt="" className="w-12 h-12 rounded-lg object-cover flex-shrink-0" />
                                : <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center flex-shrink-0">
                                    <Bed size={18} className="text-blue-500" />
                                  </div>
                              }
                              <div className="flex-1 min-w-0">
                                <p className="font-medium text-gray-700 text-sm">{r.name}</p>
                                <p className="text-xs text-gray-500">{r.bed_type} · ETB {r.price_per_night} · {r.max_guests} guests</p>
                              </div>
                              <div className="flex gap-1">
                                <button onClick={() => {
                                  setSelectedHotel(h.id)
                                  setRoomForm({ name: r.name, bed_type: r.bed_type, price_per_night: r.price_per_night, max_guests: r.max_guests, image_url: r.image_url || '' })
                                  setRoomErrs({ ...EMPTY_ROOM_ERRS }); setEditRoom(r); setShowRoom(true)
                                }} className="p-1 rounded hover:bg-blue-100 text-blue-600"><Pencil size={14} /></button>
                                <button onClick={() => handleToggleRoom(h.id, r.id)}
                                  className={`p-1 rounded ${r.is_available ? 'text-emerald-600 hover:bg-emerald-50' : 'text-gray-400 hover:bg-gray-100'}`}>
                                  <Power size={14} />
                                </button>
                                <button onClick={() => handleDeleteRoom(h.id, r.id)}
                                  className="p-1 rounded text-red-500 hover:bg-red-50"><Trash2 size={14} /></button>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                      <div className="mt-4 pt-4 border-t border-gray-100">
                        <div className="flex items-center justify-between mb-3">
                          <h4 className="text-sm font-semibold text-gray-600">💳 Payment Methods</h4>
                          <button onClick={() => navigate(`/admin/subadmin/hotels/${h.id}/payment-methods`)}
                            className="flex items-center gap-1.5 bg-purple-50 text-purple-600 px-3 py-1.5 rounded-lg hover:bg-purple-100 text-sm font-medium">
                            ⚙️ Configure
                          </button>
                        </div>
                        <p className="text-xs text-gray-400">Configure payment methods (Telebirr, CBE, Chapa, etc.) and account details for this hotel.</p>
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </div>
      )}

      {/* ── Add / Edit Hotel Modal ──────────────────────────────────────────── */}
      <Modal
        open={showHotel || !!editHotel}
        onClose={() => { setShowHotel(false); setEditHotel(null); setHotelErrs({ ...EMPTY_HOTEL_ERRS }) }}
        title={editHotel ? `Edit: ${editHotel.name}` : 'Add New Hotel'}
        size="lg">
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            {/* name — full width */}
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Hotel Name *</label>
              <input
                value={hotelForm.name}
                onChange={e => setHotelField('name', e.target.value)}
                onBlur={() => setHotelErrs(e => ({ ...e, name: validateRequired(hotelForm.name, 'Hotel name') }))}
                placeholder="e.g. Sheraton Addis"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${hotelErrs.name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={hotelErrs.name} />
            </div>

            {/* type */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <select value={hotelForm.type} onChange={e => setHotelField('type', e.target.value)}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none">
                <option value="hotel">Hotel</option>
                <option value="resort">Resort</option>
                <option value="boutique">Boutique</option>
                <option value="lodge">Lodge</option>
              </select>
            </div>

            {/* price */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Price/Night (ETB) *</label>
              <input
                type="number" min={1}
                value={hotelForm.price_per_night}
                onChange={e => setHotelField('price_per_night', +e.target.value)}
                onBlur={() => setHotelErrs(e => ({ ...e, price_per_night: validatePositiveNumber(hotelForm.price_per_night, 'Price') }))}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${hotelErrs.price_per_night ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={hotelErrs.price_per_night} />
              <p className="text-xs text-gray-400 mt-0.5">Must be greater than 0</p>
            </div>
          </div>

          {/* address */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Address *</label>
            <input
              value={hotelForm.address}
              onChange={e => setHotelField('address', e.target.value)}
              onBlur={() => setHotelErrs(e => ({ ...e, address: validateRequired(hotelForm.address, 'Address') }))}
              placeholder="e.g. Taitu St, Addis Ababa"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${hotelErrs.address ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={hotelErrs.address} />
          </div>

          {/* description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Description <span className="text-gray-400 font-normal">(optional)</span></label>
            <textarea value={hotelForm.description} onChange={e => setHotelField('description', e.target.value)} rows={3}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
          </div>

          {/* image url */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Hotel Image URL <span className="text-gray-400 font-normal">(optional)</span></label>
            <input value={hotelForm.image_url} onChange={e => setHotelField('image_url', e.target.value)}
              placeholder="https://example.com/image.jpg"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            {hotelForm.image_url && (
              <img src={hotelForm.image_url} alt="" className="mt-2 h-24 rounded-lg object-cover"
                onError={e => (e.currentTarget.style.display = 'none')} />
            )}
          </div>

          {/* lat/lng */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Latitude <span className="text-gray-400 font-normal">(optional)</span></label>
              <input type="number" step="any"
                value={hotelForm.latitude}
                onChange={e => setHotelField('latitude', +e.target.value)}
                onBlur={() => setHotelErrs(e => ({ ...e, latitude: validateLatLng(hotelForm.latitude, 'Latitude') }))}
                placeholder="e.g. 9.0192"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${hotelErrs.latitude ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={hotelErrs.latitude} />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Longitude <span className="text-gray-400 font-normal">(optional)</span></label>
              <input type="number" step="any"
                value={hotelForm.longitude}
                onChange={e => setHotelField('longitude', +e.target.value)}
                onBlur={() => setHotelErrs(e => ({ ...e, longitude: validateLatLng(hotelForm.longitude, 'Longitude') }))}
                placeholder="e.g. 38.7525"
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${hotelErrs.longitude ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={hotelErrs.longitude} />
            </div>
          </div>

          <div className="bg-blue-50 rounded-lg p-3 text-sm text-blue-700">
            <p className="font-medium mb-1">How to get Google Maps coordinates:</p>
            <ol className="list-decimal ml-4 space-y-0.5 text-xs text-blue-600">
              <li>Open <a href="https://maps.google.com" target="_blank" rel="noreferrer" className="underline">Google Maps</a></li>
              <li>Search for the hotel location → right-click → copy coordinates</li>
              <li>Paste latitude and longitude above</li>
            </ol>
            {hotelForm.latitude !== 0 && hotelForm.longitude !== 0 && (
              <a href={`https://www.google.com/maps?q=${hotelForm.latitude},${hotelForm.longitude}`}
                target="_blank" rel="noreferrer" className="mt-2 inline-flex items-center gap-1 text-blue-700 font-medium underline text-xs">
                Preview on Google Maps →
              </a>
            )}
          </div>

          <div className="flex items-center gap-2">
            <input type="checkbox" id="featured" checked={hotelForm.is_featured}
              onChange={e => setHotelField('is_featured', e.target.checked)} className="rounded" />
            <label htmlFor="featured" className="text-sm text-gray-700">Mark as Featured Hotel</label>
          </div>

          <button
            onClick={editHotel ? handleEditHotel : handleAddHotel}
            disabled={savingHotel}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {savingHotel ? 'Saving…' : editHotel ? 'Save Changes' : 'Create Hotel'}
          </button>
        </div>
      </Modal>

      {/* ── Add / Edit Room Modal ───────────────────────────────────────────── */}
      <Modal
        open={showRoom}
        onClose={() => { setShowRoom(false); setEditRoom(null); setRoomErrs({ ...EMPTY_ROOM_ERRS }) }}
        title={editRoom ? 'Edit Room' : 'Add Room'}>
        <div className="space-y-4">
          {/* room name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Room Name *</label>
            <input
              value={roomForm.name}
              onChange={e => setRoomField('name', e.target.value)}
              onBlur={() => setRoomErrs(e => ({ ...e, name: validateRequired(roomForm.name, 'Room name') }))}
              placeholder="e.g. Deluxe King Suite"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${roomErrs.name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={roomErrs.name} />
          </div>

          {/* bed type */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Bed Type *</label>
            <select
              value={roomForm.bed_type}
              onChange={e => setRoomField('bed_type', e.target.value)}
              onBlur={() => setRoomErrs(e => ({ ...e, bed_type: roomForm.bed_type ? null : 'Please select a bed type' }))}
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${roomErrs.bed_type ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}>
              <option value="">Select...</option>
              {['Single', 'Double', 'Twin', 'Queen', 'King'].map(b => <option key={b} value={b}>{b}</option>)}
            </select>
            <Err msg={roomErrs.bed_type} />
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* price */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Price/Night (ETB) *</label>
              <input
                type="number" min={1}
                value={roomForm.price_per_night}
                onChange={e => setRoomField('price_per_night', +e.target.value)}
                onBlur={() => setRoomErrs(e => ({ ...e, price_per_night: validatePositiveNumber(roomForm.price_per_night, 'Price') }))}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${roomErrs.price_per_night ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={roomErrs.price_per_night} />
              <p className="text-xs text-gray-400 mt-0.5">Must be greater than 0</p>
            </div>

            {/* max guests */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Max Guests *</label>
              <input
                type="number" min={1}
                value={roomForm.max_guests}
                onChange={e => setRoomField('max_guests', +e.target.value)}
                onBlur={() => setRoomErrs(e => ({ ...e, max_guests: roomForm.max_guests < 1 ? 'Max guests must be at least 1' : null }))}
                className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none transition ${roomErrs.max_guests ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
              />
              <Err msg={roomErrs.max_guests} />
            </div>
          </div>

          {/* image url */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Room Image URL <span className="text-gray-400 font-normal">(optional)</span></label>
            <input value={roomForm.image_url} onChange={e => setRoomField('image_url', e.target.value)}
              placeholder="https://example.com/room.jpg or paste local URL"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            {roomForm.image_url && (
              <img src={roomForm.image_url} alt="" className="mt-2 h-24 rounded-lg object-cover w-full"
                onError={e => (e.currentTarget.style.display = 'none')} />
            )}
          </div>

          <button
            onClick={editRoom ? handleEditRoom : handleAddRoom}
            disabled={savingRoom}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {savingRoom ? 'Saving…' : editRoom ? 'Save Room' : 'Add Room'}
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

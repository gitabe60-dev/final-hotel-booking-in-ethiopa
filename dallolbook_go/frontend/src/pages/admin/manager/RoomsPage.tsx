// pages/admin/manager/RoomsPage.tsx
// Hotel managers can VIEW all rooms added by the sub-admin and UPDATE their
// status (available / maintenance / unavailable).
// Rooms are ADDED and DELETED only by the sub-admin who owns the hotel.
import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Bed, CheckCircle, Wrench, XCircle, Info,
  Users, DollarSign, RefreshCw, Eye
} from 'lucide-react'
import toast from 'react-hot-toast'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'

// ── Status config ──────────────────────────────────────────────────────────────
type RoomStatus = 'available' | 'maintenance' | 'unavailable'

const STATUS: Record<RoomStatus, {
  label: string; icon: any; textColor: string; bgColor: string
  badgeBg: string; badgeText: string; dotColor: string
}> = {
  available: {
    label: 'Available',
    icon: CheckCircle,
    textColor: 'text-emerald-700',
    bgColor:   'bg-emerald-50',
    badgeBg:   'bg-emerald-100',
    badgeText: 'text-emerald-800',
    dotColor:  'bg-emerald-500',
  },
  maintenance: {
    label: 'Maintenance',
    icon: Wrench,
    textColor: 'text-amber-700',
    bgColor:   'bg-amber-50',
    badgeBg:   'bg-amber-100',
    badgeText: 'text-amber-800',
    dotColor:  'bg-amber-500',
  },
  unavailable: {
    label: 'Unavailable',
    icon: XCircle,
    textColor: 'text-red-700',
    bgColor:   'bg-red-50',
    badgeBg:   'bg-red-100',
    badgeText: 'text-red-800',
    dotColor:  'bg-red-500',
  },
}

const BED_ICONS: Record<string, string> = {
  Single: '🛏',
  Double: '🛏',
  Twin:   '🛏🛏',
  Queen:  '👑',
  King:   '👑',
}

// ── Component ──────────────────────────────────────────────────────────────────
export default function ManagerRoomsPage() {
  const [rooms,    setRooms]    = useState<any[]>([])
  const [loading,  setLoading]  = useState(true)
  const [updating, setUpdating] = useState<number | null>(null)   // room id being updated
  const [preview,  setPreview]  = useState<any | null>(null)      // room image preview

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.managerRooms()
      setRooms(res.data.data || [])
    } catch { toast.error('Failed to load rooms') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  // ── Change status ────────────────────────────────────────────────────────────
  const changeStatus = async (room: any, newStatus: RoomStatus) => {
    if (room.room_status === newStatus) return
    setUpdating(room.id)
    const prev = room.room_status
    // Optimistic update
    setRooms(rs => rs.map(r => r.id === room.id ? { ...r, room_status: newStatus } : r))
    try {
      await adminService.managerSetRoomStatus(room.id, newStatus)
      const sc = STATUS[newStatus]
      toast.success(
        `${room.name}: ${sc.label}`,
        { icon: newStatus === 'available' ? '✅' : newStatus === 'maintenance' ? '🔧' : '❌' }
      )
    } catch {
      // Roll back on failure
      setRooms(rs => rs.map(r => r.id === room.id ? { ...r, room_status: prev } : r))
      toast.error('Failed to update status — please try again')
    }
    setUpdating(null)
  }

  // ── Counters ─────────────────────────────────────────────────────────────────
  const counts = {
    available:   rooms.filter(r => r.room_status === 'available').length,
    maintenance: rooms.filter(r => r.room_status === 'maintenance').length,
    unavailable: rooms.filter(r => r.room_status === 'unavailable').length,
  }

  if (loading) return <AdminLayout role="hotel_manager"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="hotel_manager">
      <PageHeader
        title="Room Status Management"
        subtitle="Update room availability for your hotel — rooms are added by your sub-admin"
        action={
          <button onClick={load}
            className="flex items-center gap-2 border border-gray-200 bg-white text-gray-600 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors text-sm font-medium">
            <RefreshCw size={15} /> Refresh
          </button>
        }
      />

      {/* ── Info banner ── */}
      <div className="flex items-start gap-3 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 mb-6 text-sm text-blue-700">
        <Info size={16} className="flex-shrink-0 mt-0.5" />
        <div>
          <p className="font-semibold">Room statuses explained:</p>
          <ul className="mt-1 space-y-0.5 text-xs text-blue-600">
            <li><strong className="text-emerald-700">✅ Available</strong> — visible and bookable by guests</li>
            <li><strong className="text-amber-700">🔧 Maintenance</strong> — hidden from guests, cannot be booked</li>
            <li><strong className="text-red-700">❌ Unavailable</strong> — hidden from guests, cannot be booked</li>
          </ul>
          <p className="text-xs text-blue-500 mt-1.5">
            To add or delete rooms, contact your city sub-admin.
          </p>
        </div>
      </div>

      {/* ── Summary cards ── */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        {(Object.entries(STATUS) as [RoomStatus, typeof STATUS[RoomStatus]][]).map(([key, sc]) => {
          const Icon = sc.icon
          return (
            <div key={key} className={`${sc.bgColor} border ${
              key === 'available' ? 'border-emerald-200' : key === 'maintenance' ? 'border-amber-200' : 'border-red-200'
            } rounded-xl p-4 flex items-center gap-3`}>
              <div className={`w-10 h-10 rounded-xl ${sc.badgeBg} flex items-center justify-center flex-shrink-0`}>
                <Icon size={20} className={sc.textColor} />
              </div>
              <div>
                <p className={`text-2xl font-extrabold ${sc.textColor}`}>{counts[key]}</p>
                <p className={`text-xs font-medium ${sc.textColor} opacity-80`}>{sc.label}</p>
              </div>
            </div>
          )
        })}
      </div>

      {/* ── Rooms table ── */}
      {rooms.length === 0 ? (
        <div className="text-center py-20 bg-white rounded-xl border border-gray-100 shadow-sm">
          <Bed size={48} className="mx-auto text-gray-300 mb-3" />
          <p className="text-gray-500 font-semibold text-lg">No rooms yet</p>
          <p className="text-gray-400 text-sm mt-1">Your sub-admin needs to add rooms to this hotel first.</p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
          {/* Desktop table */}
          <div className="hidden md:block overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-100">
                  <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray-500 uppercase tracking-wide">Room</th>
                  <th className="text-left px-4 py-3.5 text-xs font-semibold text-gray-500 uppercase tracking-wide">Bed Type</th>
                  <th className="text-left px-4 py-3.5 text-xs font-semibold text-gray-500 uppercase tracking-wide">Price/Night</th>
                  <th className="text-left px-4 py-3.5 text-xs font-semibold text-gray-500 uppercase tracking-wide">Capacity</th>
                  <th className="text-left px-4 py-3.5 text-xs font-semibold text-gray-500 uppercase tracking-wide w-52">Current Status</th>
                  <th className="text-left px-4 py-3.5 text-xs font-semibold text-gray-500 uppercase tracking-wide w-64">Change Status</th>
                  <th className="px-4 py-3.5 w-12" />
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                <AnimatePresence>
                  {rooms.map((room, i) => {
                    const status   = (room.room_status || 'available') as RoomStatus
                    const sc       = STATUS[status] || STATUS.available
                    const Icon     = sc.icon
                    const busy     = updating === room.id

                    return (
                      <motion.tr key={room.id}
                        initial={{ opacity: 0, y: 6 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: i * 0.04 }}
                        className={`transition-colors ${busy ? 'opacity-60' : 'hover:bg-gray-50/60'}`}>

                        {/* Room name + image */}
                        <td className="px-5 py-4">
                          <div className="flex items-center gap-3">
                            <div className="relative w-12 h-12 rounded-xl overflow-hidden flex-shrink-0 bg-gray-100 cursor-pointer"
                              onClick={() => room.image_url && setPreview(room)}>
                              {room.image_url
                                ? <img src={room.image_url} alt={room.name} className="w-full h-full object-cover" />
                                : <div className="w-full h-full flex items-center justify-center bg-blue-50">
                                    <Bed size={20} className="text-blue-300" />
                                  </div>
                              }
                              {room.image_url && (
                                <div className="absolute inset-0 bg-black/30 opacity-0 hover:opacity-100 flex items-center justify-center transition-opacity">
                                  <Eye size={14} className="text-white" />
                                </div>
                              )}
                            </div>
                            <div>
                              <p className="font-semibold text-gray-800">{room.name}</p>
                              {room.size_sqm > 0 && (
                                <p className="text-xs text-gray-400">📐 {room.size_sqm} m²</p>
                              )}
                            </div>
                          </div>
                        </td>

                        {/* Bed type */}
                        <td className="px-4 py-4">
                          <span className="flex items-center gap-1.5 text-gray-600">
                            {BED_ICONS[room.bed_type] || '🛏'} {room.bed_type}
                          </span>
                        </td>

                        {/* Price */}
                        <td className="px-4 py-4">
                          <div className="flex items-center gap-1 text-blue-700 font-bold">
                            <DollarSign size={13} className="text-blue-400" />
                            {Number(room.price_per_night).toLocaleString()}
                            <span className="text-gray-400 font-normal text-xs">/night</span>
                          </div>
                        </td>

                        {/* Max guests */}
                        <td className="px-4 py-4">
                          <span className="flex items-center gap-1.5 text-gray-600">
                            <Users size={13} className="text-gray-400" /> {room.max_guests} guests
                          </span>
                        </td>

                        {/* Current status badge */}
                        <td className="px-4 py-4">
                          <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold ${sc.badgeBg} ${sc.badgeText}`}>
                            <span className={`w-1.5 h-1.5 rounded-full ${sc.dotColor}`} />
                            {busy ? (
                              <span className="flex items-center gap-1">
                                <div className="w-3 h-3 border border-current border-t-transparent rounded-full animate-spin" />
                                Updating…
                              </span>
                            ) : sc.label}
                          </span>
                        </td>

                        {/* Status selector */}
                        <td className="px-4 py-4">
                          <div className="flex gap-1.5">
                            {(['available', 'maintenance', 'unavailable'] as RoomStatus[]).map(s => {
                              const ssc = STATUS[s]
                              const SIcon = ssc.icon
                              const isActive = status === s
                              return (
                                <button key={s}
                                  onClick={() => changeStatus(room, s)}
                                  disabled={busy || isActive}
                                  title={ssc.label}
                                  className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-semibold transition-all duration-150 border ${
                                    isActive
                                      ? `${ssc.badgeBg} ${ssc.badgeText} border-transparent cursor-default`
                                      : `bg-white ${ssc.textColor} border-gray-200 hover:${ssc.badgeBg} hover:border-transparent disabled:opacity-40 hover:scale-105 active:scale-95`
                                  }`}>
                                  <SIcon size={11} />
                                  <span className="hidden lg:inline">
                                    {s === 'available' ? 'Available' : s === 'maintenance' ? 'Maint.' : 'Unavail.'}
                                  </span>
                                </button>
                              )
                            })}
                          </div>
                        </td>

                        {/* Eye / preview */}
                        <td className="px-4 py-4 text-right">
                          {room.image_url && (
                            <button onClick={() => setPreview(room)}
                              className="p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                              <Eye size={16} />
                            </button>
                          )}
                        </td>
                      </motion.tr>
                    )
                  })}
                </AnimatePresence>
              </tbody>
            </table>
          </div>

          {/* Mobile cards */}
          <div className="md:hidden divide-y divide-gray-100">
            {rooms.map((room, i) => {
              const status = (room.room_status || 'available') as RoomStatus
              const sc     = STATUS[status] || STATUS.available
              const busy   = updating === room.id

              return (
                <motion.div key={room.id}
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.04 }}
                  className="p-4 space-y-3">

                  {/* Room header */}
                  <div className="flex items-center gap-3">
                    <div className="w-14 h-14 rounded-xl overflow-hidden flex-shrink-0 bg-gray-100">
                      {room.image_url
                        ? <img src={room.image_url} alt={room.name} className="w-full h-full object-cover" />
                        : <div className="w-full h-full flex items-center justify-center bg-blue-50">
                            <Bed size={24} className="text-blue-300" />
                          </div>
                      }
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-gray-800 truncate">{room.name}</p>
                      <p className="text-xs text-gray-500">{BED_ICONS[room.bed_type]} {room.bed_type} · {room.max_guests} guests · ETB {Number(room.price_per_night).toLocaleString()}/night</p>
                    </div>
                    <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold ${sc.badgeBg} ${sc.badgeText} flex-shrink-0`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${sc.dotColor}`} />
                      {sc.label}
                    </span>
                  </div>

                  {/* Status buttons */}
                  <div className="flex gap-2">
                    {(['available', 'maintenance', 'unavailable'] as RoomStatus[]).map(s => {
                      const ssc = STATUS[s]
                      const SIcon = ssc.icon
                      const isActive = status === s
                      return (
                        <button key={s}
                          onClick={() => changeStatus(room, s)}
                          disabled={busy || isActive}
                          className={`flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-semibold transition-all border ${
                            isActive
                              ? `${ssc.badgeBg} ${ssc.badgeText} border-transparent`
                              : `bg-white ${ssc.textColor} border-gray-200 hover:${ssc.badgeBg} active:scale-95 disabled:opacity-40`
                          }`}>
                          {busy && status !== s
                            ? <div className="w-3 h-3 border border-current border-t-transparent rounded-full animate-spin" />
                            : <SIcon size={12} />
                          }
                          {s === 'available' ? 'Available' : s === 'maintenance' ? 'Maintenance' : 'Unavailable'}
                        </button>
                      )
                    })}
                  </div>
                </motion.div>
              )
            })}
          </div>
        </div>
      )}

      {/* ── Image preview lightbox ── */}
      <AnimatePresence>
        {preview && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/80 flex items-center justify-center p-4"
            onClick={() => setPreview(null)}>
            <motion.div
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              exit={{ scale: 0.9 }}
              className="bg-white rounded-2xl overflow-hidden max-w-lg w-full shadow-2xl"
              onClick={e => e.stopPropagation()}>
              <img src={preview.image_url} alt={preview.name} className="w-full max-h-72 object-cover" />
              <div className="p-4">
                <p className="font-bold text-gray-800">{preview.name}</p>
                <p className="text-sm text-gray-500">{preview.bed_type} · {preview.max_guests} guests max · ETB {Number(preview.price_per_night).toLocaleString()}/night</p>
                <div className="mt-3 flex gap-2">
                  {(['available', 'maintenance', 'unavailable'] as RoomStatus[]).map(s => {
                    const ssc = STATUS[s]
                    const SIcon = ssc.icon
                    const isActive = (preview.room_status || 'available') === s
                    return (
                      <button key={s}
                        onClick={() => { changeStatus(preview, s); setPreview(null) }}
                        disabled={isActive}
                        className={`flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl text-xs font-semibold border transition-all ${
                          isActive
                            ? `${ssc.badgeBg} ${ssc.badgeText} border-transparent`
                            : `bg-white ${ssc.textColor} border-gray-200 hover:${ssc.badgeBg} active:scale-95 disabled:opacity-50`
                        }`}>
                        <SIcon size={12} /> {ssc.label}
                      </button>
                    )
                  })}
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </AdminLayout>
  )
}

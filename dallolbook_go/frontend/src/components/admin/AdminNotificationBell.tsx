// components/admin/AdminNotificationBell.tsx — hotel manager notification bell
import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Bell, Check, CheckCheck, Calendar, CreditCard } from 'lucide-react'
import { notificationService } from '../../services/notifications'
import { useAuth } from '../../context/AuthContext'
import toast from 'react-hot-toast'

export default function AdminNotificationBell() {
  const { isAdminAuthenticated, adminUser } = useAuth()
  const navigate = useNavigate()
  const [open, setOpen] = useState(false)
  const [notifications, setNotifications] = useState<any[]>([])
  const [unread, setUnread] = useState(0)
  const ref = useRef<HTMLDivElement>(null)

  const load = async () => {
    if (!isAdminAuthenticated || adminUser?.role !== 'hotel_manager') return
    try {
      const res = await notificationService.listAdmin()
      setNotifications(res.data.data?.notifications || [])
      setUnread(res.data.data?.unread || 0)
    } catch { /* ignore */ }
  }

  useEffect(() => {
    load()
    const interval = setInterval(load, 15000) // poll every 15s for manager
    return () => clearInterval(interval)
  }, [isAdminAuthenticated, adminUser?.role])

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [])

  const handleRead = async (id: number) => {
    try {
      await notificationService.readAdmin(id)
      setNotifications(n => n.map(x => x.id === id ? { ...x, is_read: true } : x))
      setUnread(u => Math.max(0, u - 1))
    } catch { /* ignore */ }
  }

  const handleReadAll = async () => {
    try {
      await notificationService.readAllAdmin()
      setNotifications(n => n.map(x => ({ ...x, is_read: true })))
      setUnread(0)
      toast.success('All marked as read')
    } catch { /* ignore */ }
  }

  if (!isAdminAuthenticated || adminUser?.role !== 'hotel_manager') return null

  const getIcon = (type: string) => {
    if (type === 'booking_new') return <Calendar size={16} className="text-blue-500" />
    if (type === 'payment_approved' || type === 'payment_rejected')
      return <CreditCard size={16} className="text-emerald-500" />
    return <Bell size={16} className="text-gray-400" />
  }

  return (
    <div className="relative" ref={ref}>
      <button onClick={() => { setOpen(!open); if (!open) load() }}
        className="relative p-1.5 rounded-lg hover:bg-gray-700 transition-colors">
        <Bell size={18} className="text-gray-300" />
        {unread > 0 && (
          <span className="absolute -top-0.5 -right-0.5 bg-red-500 text-white text-[10px] font-bold rounded-full min-w-[16px] h-[16px] flex items-center justify-center px-1">
            {unread > 9 ? '9+' : unread}
          </span>
        )}
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.15 }}
            className="absolute right-0 top-full mt-2 w-80 bg-white rounded-xl shadow-xl border border-gray-100 z-50 overflow-hidden">
            <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100">
              <h3 className="font-semibold text-gray-800 text-sm">Notifications</h3>
              {unread > 0 && (
                <button onClick={handleReadAll}
                  className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-800 font-medium">
                  <CheckCheck size={14} /> Mark all read
                </button>
              )}
            </div>

            <div className="max-h-80 overflow-y-auto">
              {notifications.length === 0 ? (
                <div className="p-8 text-center text-gray-400 text-sm">
                  <Bell size={32} className="mx-auto mb-2 opacity-30" />
                  No notifications
                </div>
              ) : (
                notifications.map((n: any) => (
                  <div key={n.id}
                    onClick={() => { if (!n.is_read) handleRead(n.id); if (n.type === 'booking_new') navigate('/admin/manager/payments') }}
                    className={`flex gap-3 p-3 border-b border-gray-50 cursor-pointer hover:bg-gray-50 transition-colors ${!n.is_read ? 'bg-blue-50' : ''}`}>
                    <div className="mt-0.5 flex-shrink-0">{getIcon(n.type)}</div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-800 text-sm">{n.title}</p>
                      <p className="text-xs text-gray-500 mt-0.5 line-clamp-2">{n.message}</p>
                      <p className="text-[10px] text-gray-400 mt-1">{new Date(n.created_at).toLocaleString()}</p>
                    </div>
                    {!n.is_read && <span className="w-2 h-2 rounded-full bg-blue-500 flex-shrink-0 mt-2" />}
                  </div>
                ))
              )}
            </div>

            {notifications.length > 0 && (
              <button onClick={() => { navigate('/admin/manager/payments'); setOpen(false) }}
                className="w-full text-center py-2.5 text-sm text-blue-600 hover:bg-blue-50 font-medium border-t border-gray-100">
                View Payments to Verify
              </button>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

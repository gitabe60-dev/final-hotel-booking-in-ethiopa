// hooks/useBooking.ts
import { useState, useEffect } from 'react'
import { bookingService } from '../services/booking'

export function useBookings() {
  const [bookings, setBookings] = useState<any[]>([])
  const [counts, setCounts]     = useState<any>({ pending: 0, confirmed: 0, completed: 0, cancelled: 0 })
  const [loading, setLoading]   = useState(true)
  const [error, setError]       = useState<string | null>(null)

  const load = () => {
    setLoading(true)
    setError(null)
    bookingService.getAll()
      .then(r => {
        const data = r.data?.data
        if (data) {
          setBookings(data.bookings || [])
          setCounts(data.counts || { pending: 0, confirmed: 0, completed: 0, cancelled: 0 })
        }
      })
      .catch((err) => {
        console.error('[useBookings] Error:', err)
        setError('Failed to load bookings')
        setBookings([])
        setCounts({ pending: 0, confirmed: 0, completed: 0, cancelled: 0 })
      })
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])
  return { bookings, counts, loading, error, reload: load }
}

export function useBooking(id: number) {
  const [booking, setBooking] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!id) { setLoading(false); return }
    bookingService.getById(id)
      .then(r => setBooking(r.data?.data || null))
      .catch(() => setBooking(null))
      .finally(() => setLoading(false))
  }, [id])

  return { booking, loading }
}

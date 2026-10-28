// hooks/useBooking.ts
import { useState, useEffect } from 'react'
import { bookingService } from '../services/booking'

export function useBookings() {
  const [bookings, setBookings] = useState<any[]>([])
  const [counts, setCounts]     = useState<any>({})
  const [loading, setLoading]   = useState(true)

  const load = () => {
    setLoading(true)
    bookingService.getAll()
      .then(r => { setBookings(r.data.data.bookings); setCounts(r.data.data.counts) })
      .finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])
  return { bookings, counts, loading, reload: load }
}

export function useBooking(id: number) {
  const [booking, setBooking] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!id) return
    bookingService.getById(id)
      .then(r => setBooking(r.data.data))
      .finally(() => setLoading(false))
  }, [id])

  return { booking, loading }
}

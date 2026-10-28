// hooks/useHotels.ts
import { useState, useEffect } from 'react'
import { hotelService, SearchParams } from '../services/hotels'

export function useFeaturedHotels() {
  const [hotels, setHotels] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    hotelService.getFeatured()
      .then(r => setHotels(r.data.data))
      .finally(() => setLoading(false))
  }, [])

  return { hotels, loading }
}

export function useHotelSearch(params: SearchParams) {
  const [hotels, setHotels] = useState<any[]>([])
  const [total, setTotal]   = useState(0)
  const [loading, setLoading] = useState(false)

  const search = async (p: SearchParams) => {
    setLoading(true)
    try {
      const r = await hotelService.search(p)
      setHotels(r.data.data.hotels)
      setTotal(r.data.data.total)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { search(params) }, [])

  return { hotels, total, loading, search }
}

export function useHotel(id: number) {
  const [hotel, setHotel]   = useState<any>(null)
  const [rooms, setRooms]   = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!id) return
    hotelService.getById(id)
      .then(r => { setHotel(r.data.data.hotel); setRooms(r.data.data.rooms) })
      .finally(() => setLoading(false))
  }, [id])

  return { hotel, rooms, loading }
}

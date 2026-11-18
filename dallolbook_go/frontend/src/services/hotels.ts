// services/hotels.ts
import api from './api'

export interface SearchParams {
  city?: string; name?: string; type?: string
  min_price?: number; max_price?: number; min_rating?: number
  sort?: string; dir?: string; limit?: number; offset?: number
}

export const hotelService = {
  getFeatured: () => api.get('/hotels/featured'),

  search: (params: SearchParams) => api.get('/hotels/search', { params }),

  getById: (id: number) => api.get(`/hotels/${id}`),

  getAvailability: (hotelId: number, checkIn: string, checkOut: string) =>
    api.get(`/hotels/${hotelId}/availability`, { params: { check_in: checkIn, check_out: checkOut } }),

  getPaymentMethods: (hotelId: number) =>
    api.get(`/hotels/${hotelId}/payment-methods`),

  getReviews: (hotelId: number, limit = 10, offset = 0) =>
    api.get(`/hotels/${hotelId}/reviews`, { params: { limit, offset } }),

  postReview: (hotelId: number, rating: number, comment: string) =>
    api.post(`/hotels/${hotelId}/reviews`, { rating, comment }),
}

// Fetch publicly registered cities (no auth needed) — falls back to deriving from hotel data
import axios from 'axios'
export const getCities = () =>
  axios.get('/api/public/cities').then(r => r.data.data || []).catch(() => [])

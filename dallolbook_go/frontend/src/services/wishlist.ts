// services/wishlist.ts
import api from './api'

export const wishlistService = {
  getAll: ()            => api.get('/wishlist'),
  toggle: (hotel_id: number) => api.post('/wishlist', { hotel_id }),
  remove: (hotelId: number)  => api.delete(`/wishlist/${hotelId}`),
}

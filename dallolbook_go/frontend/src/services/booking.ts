// services/booking.ts
import api from './api'

export const bookingService = {
  getAll: () => api.get('/bookings'),

  getById: (id: number) => api.get(`/bookings/${id}`),

  create: (data: {
    hotel_id: number; room_type_id?: number
    check_in: string; check_out: string
    adults: number; children?: number; rooms: number
    payment_method: string; special_requests?: string
    guest_full_name?: string; guest_email?: string; guest_phone?: string
    national_id_front?: string; national_id_back?: string
  }) => api.post('/bookings', data),

  cancel: (id: number) => api.post(`/bookings/${id}/cancel`),
}

// services/payment.ts
import api from './api'

export const paymentService = {
  initiate: (booking_id: number, method?: string) =>
    api.post('/payments/initiate', { booking_id, method }),

  getStatus: (id: number) => api.get(`/payments/${id}/status`),

  submit: (id: number, transaction_id: string, screenshot_url: string) =>
    api.post(`/payments/${id}/submit`, { transaction_id, screenshot_url }),

  retry: (bookingId: number) => api.post(`/payments/retry/${bookingId}`),
}

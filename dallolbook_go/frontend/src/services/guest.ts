// services/guest.ts
import api from './api'

export const guestService = {
  getProfile: () => api.get('/guest/profile'),

  updateProfile: (data: {
    first_name: string; last_name: string
    phone?: string; nationality?: string
  }) => api.put('/guest/profile', data),

  changePassword: (current_password: string, new_password: string) =>
    api.post('/guest/change-password', { current_password, new_password }),
}

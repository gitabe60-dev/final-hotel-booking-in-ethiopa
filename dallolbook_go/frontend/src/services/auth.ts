// services/auth.ts
import api from './api'

export const authService = {
  register: (data: {
    first_name: string; last_name: string; email?: string
    phone?: string; password: string; nationality?: string
  }) => api.post('/auth/register', data),

  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }),

  sendOtp: (phone: string, purpose = 'login') =>
    api.post('/auth/otp/send', { phone, purpose }),

  verifyOtp: (phone: string, otp: string, purpose = 'login') =>
    api.post('/auth/otp/verify', { phone, otp, purpose }),

  forgotPassword: (email?: string, phone?: string) =>
    api.post('/auth/forgot-password', { email, phone }),

  resetPassword: (phone: string, otp: string, password: string) =>
    api.post('/auth/reset-password', { phone, otp, password }),

  logout: () => api.post('/auth/logout'),
}

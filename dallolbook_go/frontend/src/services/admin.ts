// services/admin.ts
import { adminApi } from './api'

export const adminService = {
  // Auth
  login: (email: string, password: string) =>
    adminApi.post('/login', { email, password }),

  getProfile: () => adminApi.get('/profile'),
  updateProfile: (data: { full_name: string; phone?: string }) =>
    adminApi.put('/profile', data),
  changePassword: (current_password: string, new_password: string) =>
    adminApi.post('/change-password', { current_password, new_password }),

  // Super Admin
  superDashboard:  () => adminApi.get('/super/dashboard'),
  getSubAdmins:    () => adminApi.get('/super/sub-admins'),
  createSubAdmin:  (data: any) => adminApi.post('/super/sub-admins', data),
  editSubAdmin:    (id: number, data: any) => adminApi.put(`/super/sub-admins/${id}`, data),
  deleteSubAdmin:  (id: number) => adminApi.delete(`/super/sub-admins/${id}`),
  assignCity:      (id: number, city: string) => adminApi.post(`/super/sub-admins/${id}/assign-city`, { city }),
  revokeCity:      (id: number, city: string) => adminApi.delete(`/super/sub-admins/${id}/revoke-city/${city}`),
  superHotels:     (search?: string) => adminApi.get('/super/hotels', { params: { search } }),
  addHotel:        (data: any) => adminApi.post('/super/hotels', data),
  editHotel:       (id: number, data: any) => adminApi.put(`/super/hotels/${id}`, data),
  toggleHotel:     (id: number) => adminApi.post(`/super/hotels/${id}/toggle`),
  superBookings:   (status?: string) => adminApi.get('/super/bookings', { params: { status } }),
  getUsers:        (search?: string) => adminApi.get('/super/users', { params: { search } }),
  getSuperBrokers: () => adminApi.get('/super/brokers'),
  getSuperManagers:() => adminApi.get('/super/managers'),
  getCities:       () => adminApi.get('/super/cities'),
  addCity:         (name: string, region: string) => adminApi.post('/super/cities', { name, region }),
  deleteCity:      (id: number) => adminApi.delete(`/super/cities/${id}`),

  // Sub Admin
  subDashboard:   () => adminApi.get('/subadmin/dashboard'),
  subHotels:      (search?: string) => adminApi.get('/subadmin/hotels', { params: { search } }),
  subAddHotel:    (data: any) => adminApi.post('/subadmin/hotels/create', data),
  subEditHotel:   (id: number, data: any) => adminApi.put(`/subadmin/hotels/${id}`, data),
  subToggleHotel: (id: number) => adminApi.post(`/subadmin/hotels/${id}/toggle`),
  getHotelPaymentMethods: (hotelId: number) => adminApi.get(`/subadmin/hotels/${hotelId}/payment-methods`),
  addPaymentMethod: (hotelId: number, data: any) => adminApi.post(`/subadmin/hotels/${hotelId}/payment-methods`, data),
  updatePaymentMethod: (id: number, data: any) => adminApi.put(`/subadmin/payment-methods/${id}`, data),
  getRooms:       (hotelId: number) => adminApi.get(`/subadmin/hotels/${hotelId}/rooms`),
  addRoom:        (hotelId: number, data: any) => adminApi.post(`/subadmin/hotels/${hotelId}/rooms`, data),
  editRoom:       (hotelId: number, rid: number, data: any) => adminApi.put(`/subadmin/hotels/${hotelId}/rooms/${rid}`, data),
  deleteRoom:     (hotelId: number, rid: number) => adminApi.delete(`/subadmin/hotels/${hotelId}/rooms/${rid}`),
  toggleRoom:     (hotelId: number, rid: number) => adminApi.post(`/subadmin/hotels/${hotelId}/rooms/${rid}/toggle`),
  subBookings:    (status?: string) => adminApi.get('/subadmin/bookings', { params: { status } }),
  getSubBrokers:  () => adminApi.get('/subadmin/brokers'),
  createBroker:   (data: any) => adminApi.post('/subadmin/brokers', data),
  getSubManagers: () => adminApi.get('/subadmin/managers'),
  createManager:  (data: any) => adminApi.post('/subadmin/managers', data),
  deleteManager:  (id: number) => adminApi.delete(`/subadmin/managers/${id}`),

  // Broker
  brokerDashboard: () => adminApi.get('/broker/dashboard'),
  brokerBookings:  (status?: string) => adminApi.get('/broker/bookings', { params: { status } }),
  getInbox:        () => adminApi.get('/broker/inbox'),
  getSent:         () => adminApi.get('/broker/sent'),
  getMessage:      (id: number) => adminApi.get(`/broker/messages/${id}`),
  sendMessage:     (data: any) => adminApi.post('/broker/messages', data),

  // Hotel Manager
  managerDashboard:   () => adminApi.get('/manager/dashboard'),
  managerRooms:       () => adminApi.get('/manager/rooms'),
  managerAddRoom:     (data: any) => adminApi.post('/manager/rooms', data),
  managerEditRoom:    (rid: number, data: any) => adminApi.put(`/manager/rooms/${rid}`, data),
  managerDeleteRoom:  (rid: number) => adminApi.delete(`/manager/rooms/${rid}`),
  managerToggleRoom:  (rid: number) => adminApi.post(`/manager/rooms/${rid}/toggle`),
  managerBookings:    (status?: string) => adminApi.get('/manager/bookings', { params: { status } }),
  updateBookingStatus:(id: number, status: string) => adminApi.post(`/manager/bookings/${id}/status`, { status }),
  managerPayments:    () => adminApi.get('/manager/payments'),
  verifyPayment:      (id: number, status: 'approved' | 'rejected') => adminApi.post(`/manager/payments/${id}/verify`, { status }),
  managerInbox:       () => adminApi.get('/manager/inbox'),
  managerMessage:     (id: number) => adminApi.get(`/manager/messages/${id}`),
  managerSendMessage: (data: any) => adminApi.post('/manager/messages', data),
}

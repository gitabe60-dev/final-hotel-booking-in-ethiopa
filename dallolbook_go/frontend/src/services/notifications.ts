// services/notifications.ts
import api from './api'
import { adminApi } from './api'

export const notificationService = {
  // User notifications
  listUser:    () => api.get('/notifications'),
  readUser:    (id: number) => api.post(`/notifications/${id}/read`),
  readAllUser: () => api.post('/notifications/read-all'),

  // Admin (hotel manager) notifications
  listAdmin:    () => adminApi.get('/manager/notifications'),
  readAdmin:    (id: number) => adminApi.post(`/manager/notifications/${id}/read`),
  readAllAdmin: () => adminApi.post('/manager/notifications/read-all'),
}

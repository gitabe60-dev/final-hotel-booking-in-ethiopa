// pages/admin/BrokerDashboard.tsx
import { useState, useEffect } from 'react'
import { adminService } from '../../services/admin'
import AdminLayout from '../../components/admin/AdminLayout'
import Spinner from '../../components/shared/Spinner'

export default function BrokerDashboard() {
  const [data, setData]   = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    adminService.brokerDashboard()
      .then(r => setData(r.data.data))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <AdminLayout role="broker"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="broker">
      <h1 className="text-2xl font-bold mb-6">Broker Dashboard</h1>

      <div className="grid grid-cols-2 gap-4 mb-8">
        <div className="bg-white rounded-xl shadow p-4">
          <div className="text-2xl font-bold text-blue-600">{data?.unread_messages || 0}</div>
          <div className="text-sm text-gray-500 mt-1">Unread Messages</div>
        </div>
        <div className="bg-white rounded-xl shadow p-4">
          <div className="text-2xl font-bold text-blue-600">{data?.inbox?.length || 0}</div>
          <div className="text-sm text-gray-500 mt-1">Inbox Messages</div>
        </div>
      </div>

      <h2 className="text-lg font-semibold mb-4">Inbox</h2>
      <div className="space-y-3">
        {(data?.inbox || []).slice(0, 5).map((m: any) => (
          <div key={m.id} className={`bg-white border rounded-xl p-4 ${!m.is_read ? 'border-blue-300' : ''}`}>
            <div className="flex justify-between">
              <span className="font-semibold text-sm">{m.subject}</span>
              <span className="text-xs text-gray-400">{new Date(m.created_at).toLocaleDateString()}</span>
            </div>
            <p className="text-sm text-gray-500 mt-1">From: {m.from_name}</p>
          </div>
        ))}
        {(!data?.inbox?.length) && <p className="text-gray-400 text-center py-8">No messages.</p>}
      </div>
    </AdminLayout>
  )
}

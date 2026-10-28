// pages/admin/subadmin/ManagersPage.tsx
import { useEffect, useState } from 'react'
import { UserPlus, Trash2, Hotel } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function ManagersPage() {
  const [managers, setManagers] = useState<any[]>([])
  const [hotels, setHotels] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ full_name: '', email: '', phone: '', password: '', hotel_id: 0 })

  const load = async () => {
    setLoading(true)
    try {
      const [mgrRes, hotelRes] = await Promise.all([
        adminService.getSubManagers(),
        adminService.subHotels(),
      ])
      setManagers(mgrRes.data.data || [])
      setHotels(hotelRes.data.data || [])
    } catch { toast.error('Failed to load managers') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleCreate = async () => {
    if (!form.full_name || !form.email || !form.password || !form.hotel_id) {
      toast.error('All fields including hotel assignment are required'); return
    }
    try {
      await adminService.createManager(form)
      toast.success('Hotel manager created')
      setForm({ full_name: '', email: '', phone: '', password: '', hotel_id: 0 })
      setShowCreate(false)
      load()
    } catch { toast.error('Failed to create manager') }
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Remove this hotel manager?')) return
    try {
      await adminService.deleteManager(id)
      toast.success('Manager removed')
      load()
    } catch { toast.error('Failed to remove manager') }
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Hotel Managers"
        subtitle="Assign managers to hotels in your city"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Manager
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email', label: 'Email' },
          { key: 'phone', label: 'Phone', render: (r) => r.phone || '-' },
          { key: 'hotel_name', label: 'Hotel', render: (r) => (
            <span className="flex items-center gap-1.5"><Hotel size={14} className="text-blue-500" /> {r.hotel_name}</span>
          ) },
          { key: 'hotel_city', label: 'City' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'actions', label: '', render: (r) => (
            <button onClick={() => handleDelete(r.id)} className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
              <Trash2 size={16} />
            </button>
          ) },
        ]}
        data={managers}
        emptyTitle="No managers assigned"
        emptySubtitle="Create hotel managers to manage rooms and verify payments"
      />

      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="Add Hotel Manager">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
            <input value={form.full_name} onChange={e => setForm({...form, full_name: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input type="email" value={form.email} onChange={e => setForm({...form, email: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
              <input value={form.phone} onChange={e => setForm({...form, phone: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
              <input type="password" value={form.password} onChange={e => setForm({...form, password: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Assign to Hotel *</label>
            <select value={form.hotel_id} onChange={e => setForm({...form, hotel_id: +e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
              <option value={0}>Select hotel...</option>
              {hotels.map((h: any) => <option key={h.id} value={h.id}>{h.name}</option>)}
            </select>
          </div>
          <button onClick={handleCreate}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Create & Assign Manager
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

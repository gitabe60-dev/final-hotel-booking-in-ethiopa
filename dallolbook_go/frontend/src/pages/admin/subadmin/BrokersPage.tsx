// pages/admin/subadmin/BrokersPage.tsx
import { useEffect, useState } from 'react'
import { UserPlus } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function BrokersPage() {
  const [brokers, setBrokers] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ full_name: '', email: '', phone: '', password: '', city: '', commission_pct: 0 })

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.getSubBrokers()
      setBrokers(res.data.data || [])
    } catch { toast.error('Failed to load brokers') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleCreate = async () => {
    if (!form.full_name || !form.email || !form.password) {
      toast.error('Name, email and password are required'); return
    }
    try {
      await adminService.createBroker(form)
      toast.success('Broker created')
      setForm({ full_name: '', email: '', phone: '', password: '', city: '', commission_pct: 0 })
      setShowCreate(false)
      load()
    } catch { toast.error('Failed to create broker') }
  }

  if (loading) return <AdminLayout role="sub_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="sub_admin">
      <PageHeader
        title="Brokers"
        subtitle="Manage brokers in your city"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Broker
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email', label: 'Email' },
          { key: 'phone', label: 'Phone', render: (r) => r.phone || '-' },
          { key: 'city', label: 'City' },
          { key: 'commission_pct', label: 'Commission', render: (r) => `${r.commission_pct}%` },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'hotel_count', label: 'Hotels', render: (r) => (
            <span className="bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full text-xs font-medium">{r.hotel_count}</span>
          ) },
        ]}
        data={brokers}
        emptyTitle="No brokers yet"
        emptySubtitle="Add brokers to link with hotels"
      />

      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="Add Broker">
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
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">City</label>
              <input value={form.city} onChange={e => setForm({...form, city: e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Commission %</label>
              <input type="number" step="0.1" value={form.commission_pct} onChange={e => setForm({...form, commission_pct: +e.target.value})}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
            </div>
          </div>
          <button onClick={handleCreate}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Create Broker
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

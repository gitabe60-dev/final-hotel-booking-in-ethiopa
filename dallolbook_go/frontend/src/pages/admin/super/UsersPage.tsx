// pages/admin/super/UsersPage.tsx
import { useEffect, useState } from 'react'
import { Search } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function UsersPage() {
  const [users, setUsers] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.getUsers(search)
      setUsers(res.data.data || [])
    } catch { toast.error('Failed to load users') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleSearch = () => load()

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="super_admin">
      <PageHeader title="Users" subtitle="View all registered users/guests" />

      <div className="flex gap-2 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search size={18} className="absolute left-3 top-2.5 text-gray-400" />
          <input value={search} onChange={e => setSearch(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSearch()}
            placeholder="Search users..."
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none" />
        </div>
        <button onClick={handleSearch} className="bg-gray-100 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors text-sm font-medium">
          Search
        </button>
      </div>

      <DataTable
        columns={[
          { key: 'id', label: 'ID', render: (r) => <span className="font-mono text-xs">#{r.id}</span> },
          { key: 'first_name', label: 'First Name' },
          { key: 'last_name', label: 'Last Name' },
          { key: 'email', label: 'Email', render: (r) => r.email || '-' },
          { key: 'phone', label: 'Phone', render: (r) => r.phone || '-' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'booking_count', label: 'Bookings', render: (r) => (
            <span className="bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full text-xs font-medium">{r.booking_count}</span>
          ) },
          { key: 'registered_date', label: 'Joined', render: (r) => new Date(r.registered_date).toLocaleDateString() },
        ]}
        data={users}
        emptyTitle="No users found"
        emptySubtitle="Registered guests will appear here"
      />
    </AdminLayout>
  )
}

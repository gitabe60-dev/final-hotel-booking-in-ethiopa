// pages/admin/super/CitiesPage.tsx
import { useEffect, useState } from 'react'
import { Plus, Trash2, Building2 } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

export default function CitiesPage() {
  const [cities, setCities] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ name: '', region: '' })

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.getCities()
      setCities(res.data.data || [])
    } catch { toast.error('Failed to load cities') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleCreate = async () => {
    if (!form.name) { toast.error('City name is required'); return }
    try {
      await adminService.addCity(form.name, form.region)
      toast.success('City added')
      setForm({ name: '', region: '' })
      setShowCreate(false)
      load()
    } catch { toast.error('Failed to add city') }
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this city? Hotels in this city will remain but unassigned.')) return
    try {
      await adminService.deleteCity(id)
      toast.success('City deleted')
      load()
    } catch { toast.error('Failed to delete city') }
  }

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="super_admin">
      <PageHeader
        title="Cities"
        subtitle="Manage cities for hotel and sub-admin assignments"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <Plus size={18} /> Add City
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'name', label: 'City', render: (r) => (
            <span className="flex items-center gap-2 font-medium text-gray-800">
              <Building2 size={16} className="text-blue-500" /> {r.name}
            </span>
          ) },
          { key: 'region', label: 'Region' },
          { key: 'is_active', label: 'Status', render: (r) => <Badge status={r.is_active ? 'active' : 'inactive'} /> },
          { key: 'hotel_count', label: 'Hotels', render: (r) => (
            <span className="bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full text-xs font-medium">{r.hotel_count}</span>
          ) },
          { key: 'actions', label: '', render: (r) => (
            <button onClick={() => handleDelete(r.id)} className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
              <Trash2 size={16} />
            </button>
          ) },
        ]}
        data={cities}
        emptyTitle="No cities yet"
        emptySubtitle="Add cities to assign to sub-admins"
      />

      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="Add City" size="sm">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">City Name *</label>
            <input value={form.name} onChange={e => setForm({...form, name: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
              placeholder="e.g. Addis Ababa" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Region</label>
            <input value={form.region} onChange={e => setForm({...form, region: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
              placeholder="e.g. Addis Ababa City Administration" />
          </div>
          <button onClick={handleCreate}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Add City
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

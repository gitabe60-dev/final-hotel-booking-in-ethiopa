// pages/admin/super/SubAdminsPage.tsx
import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { UserPlus, Trash2, MapPin, X } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import EmptyState from '../../../components/shared/EmptyState'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

interface SubAdmin {
  id: number; full_name: string; email: string; phone?: string
  role: string; status: string; created_at: string
}

export default function SubAdminsPage() {
  const [subAdmins, setSubAdmins] = useState<SubAdmin[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [cities, setCities] = useState<any[]>([])
  const [selectedAdmin, setSelectedAdmin] = useState<SubAdmin | null>(null)
  const [adminCities, setAdminCities] = useState<string[]>([])
  const [showAssign, setShowAssign] = useState(false)
  const [form, setForm] = useState({ full_name: '', email: '', phone: '', password: '', city: '' })
  const [assignCity, setAssignCity] = useState('')

  const load = async () => {
    setLoading(true)
    try {
      const [res, citiesRes] = await Promise.all([
        adminService.getSubAdmins(),
        adminService.getCities(),
      ])
      setSubAdmins(res.data.data || [])
      setCities(citiesRes.data.data || [])
    } catch { toast.error('Failed to load sub-admins') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const handleCreate = async () => {
    if (!form.full_name || !form.email || !form.password) {
      toast.error('Full name, email and password are required'); return
    }
    try {
      await adminService.createSubAdmin(form)
      toast.success('Sub-admin created')
      setForm({ full_name: '', email: '', phone: '', password: '', city: '' })
      setShowCreate(false)
      load()
    } catch { toast.error('Failed to create sub-admin') }
  }

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this sub-admin?')) return
    try {
      await adminService.deleteSubAdmin(id)
      toast.success('Sub-admin deleted')
      load()
    } catch { toast.error('Failed to delete') }
  }

  const openAssign = async (admin: SubAdmin) => {
    setSelectedAdmin(admin)
    try {
      // Get admin cities — we need to fetch from sub-admins list
      // The API returns sub-admins but not their cities directly
      // We'll use a workaround: fetch all cities and show assignment UI
      setAdminCities([])
      setShowAssign(true)
    } catch { toast.error('Failed to load cities') }
  }

  const handleAssign = async () => {
    if (!selectedAdmin || !assignCity) return
    try {
      await adminService.assignCity(selectedAdmin.id, assignCity)
      toast.success(`Assigned ${assignCity} to ${selectedAdmin.full_name}`)
      setAssignCity('')
      setAdminCities([...adminCities, assignCity])
    } catch { toast.error('Failed to assign city') }
  }

  const handleRevoke = async (city: string) => {
    if (!selectedAdmin) return
    try {
      await adminService.revokeCity(selectedAdmin.id, city)
      toast.success(`Revoked ${city}`)
      setAdminCities(adminCities.filter(c => c !== city))
    } catch { toast.error('Failed to revoke city') }
  }

  if (loading) return <AdminLayout role="super_admin"><Spinner /></AdminLayout>

  return (
    <AdminLayout role="super_admin">
      <PageHeader
        title="Sub-Admins"
        subtitle="Manage sub-administrators and city assignments"
        action={
          <button onClick={() => setShowCreate(true)}
            className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium">
            <UserPlus size={18} /> Add Sub-Admin
          </button>
        }
      />

      <DataTable
        columns={[
          { key: 'full_name', label: 'Name' },
          { key: 'email', label: 'Email' },
          { key: 'phone', label: 'Phone', render: (r) => r.phone || '-' },
          { key: 'status', label: 'Status', render: (r) => <Badge status={r.status} /> },
          { key: 'created_at', label: 'Created', render: (r) => new Date(r.created_at).toLocaleDateString() },
          { key: 'actions', label: 'Actions', render: (r) => (
            <div className="flex items-center gap-2">
              <button onClick={() => openAssign(r)} className="text-blue-600 hover:text-blue-800 p-1.5 rounded-lg hover:bg-blue-50 transition-colors" title="Assign City">
                <MapPin size={16} />
              </button>
              <button onClick={() => handleDelete(r.id)} className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors" title="Delete">
                <Trash2 size={16} />
              </button>
            </div>
          ) },
        ]}
        data={subAdmins}
        emptyTitle="No sub-admins yet"
        emptySubtitle="Create one to assign cities and manage hotels"
      />

      {/* Create Modal */}
      <Modal open={showCreate} onClose={() => setShowCreate(false)} title="Add Sub-Admin">
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
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Assign City (optional)</label>
            <select value={form.city} onChange={e => setForm({...form, city: e.target.value})}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
              <option value="">Select city to assign...</option>
              {cities.map((c: any) => (
                <option key={c.id} value={c.name}>{c.name}</option>
              ))}
            </select>
          </div>
          <button onClick={handleCreate}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium">
            Create Sub-Admin
          </button>
        </div>
      </Modal>

      {/* Assign City Modal */}
      <Modal open={showAssign} onClose={() => setShowAssign(false)} title={`Assign City — ${selectedAdmin?.full_name || ''}`}>
        <div className="space-y-4">
          <div className="flex gap-2">
            <select value={assignCity} onChange={e => setAssignCity(e.target.value)}
              className="flex-1 border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none">
              <option value="">Select a city...</option>
              {cities.map((c: any) => (
                <option key={c.id} value={c.name}>{c.name}</option>
              ))}
            </select>
            <button onClick={handleAssign} disabled={!assignCity}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 text-sm font-medium">
              Assign
            </button>
          </div>
          <div className="space-y-2">
            {adminCities.length === 0 ? (
              <p className="text-gray-400 text-sm text-center py-4">No cities assigned yet</p>
            ) : (
              adminCities.map(city => (
                <div key={city} className="flex items-center justify-between bg-gray-50 rounded-lg px-3 py-2">
                  <span className="text-sm text-gray-700 flex items-center gap-2">
                    <MapPin size={14} className="text-blue-500" /> {city}
                  </span>
                  <button onClick={() => handleRevoke(city)} className="text-red-400 hover:text-red-600">
                    <X size={16} />
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      </Modal>
    </AdminLayout>
  )
}

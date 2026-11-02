// pages/admin/super/CitiesPage.tsx
import { useEffect, useState } from 'react'
import { Plus, Trash2, Building2 } from 'lucide-react'
import AdminLayout from '../../../components/admin/AdminLayout'
import PageHeader from '../../../components/shared/PageHeader'
import Modal from '../../../components/shared/Modal'
import Badge from '../../../components/shared/Badge'
import DataTable from '../../../components/shared/DataTable'
import Spinner from '../../../components/shared/Spinner'
import { validateRequired, type FieldError } from '../../../utils/validate'
import { adminService } from '../../../services/admin'
import toast from 'react-hot-toast'

const Err = ({ msg }: { msg: FieldError }) =>
  msg ? <p className="text-red-500 text-xs mt-1">{msg}</p> : null

// city name: letters, spaces, hyphens only
const validateCityName = (v: string): FieldError => {
  if (!v.trim()) return 'City name is required'
  if (v.trim().length < 2) return 'City name must be at least 2 characters'
  if (!/^[A-Za-z\u00C0-\u024F\u1200-\u137F\s'-]+$/.test(v.trim()))
    return 'City name must contain letters only (no numbers or symbols)'
  return null
}

export default function CitiesPage() {
  const [cities, setCities] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreate, setShowCreate] = useState(false)
  const [form, setForm] = useState({ name: '', region: '' })
  const [errs, setErrs] = useState({ name: null as FieldError, region: null as FieldError })
  const [submitting, setSubmitting] = useState(false)

  const load = async () => {
    setLoading(true)
    try {
      const res = await adminService.getCities()
      setCities(res.data.data || [])
    } catch { toast.error('Failed to load cities') }
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const setField = (key: 'name' | 'region', val: string) => {
    setForm(f => ({ ...f, [key]: val }))
    setErrs(e => ({ ...e, [key]: null }))
  }

  const validate = () => {
    const next = {
      name:   validateCityName(form.name),
      region: null as FieldError,           // region is optional
    }
    setErrs(next)
    return !next.name
  }

  const handleCreate = async () => {
    if (!validate()) return
    setSubmitting(true)
    try {
      await adminService.addCity(form.name.trim(), form.region.trim())
      toast.success('City added')
      setForm({ name: '', region: '' })
      setErrs({ name: null, region: null })
      setShowCreate(false)
      load()
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to add city')
    }
    setSubmitting(false)
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
          {
            key: 'name', label: 'City', render: (r) => (
              <span className="flex items-center gap-2 font-medium text-gray-800">
                <Building2 size={16} className="text-blue-500" /> {r.name}
              </span>
            ),
          },
          { key: 'region', label: 'Region', render: (r) => r.region || <span className="text-gray-400">—</span> },
          { key: 'is_active', label: 'Status', render: (r) => <Badge status={r.is_active ? 'active' : 'inactive'} /> },
          {
            key: 'hotel_count', label: 'Hotels', render: (r) => (
              <span className="bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full text-xs font-medium">{r.hotel_count}</span>
            ),
          },
          {
            key: 'actions', label: '', render: (r) => (
              <button onClick={() => handleDelete(r.id)}
                className="text-red-500 hover:text-red-700 p-1.5 rounded-lg hover:bg-red-50 transition-colors">
                <Trash2 size={16} />
              </button>
            ),
          },
        ]}
        data={cities}
        emptyTitle="No cities yet"
        emptySubtitle="Add cities to assign to sub-admins"
      />

      <Modal open={showCreate} onClose={() => { setShowCreate(false); setErrs({ name: null, region: null }) }} title="Add City" size="sm">
        <div className="space-y-4">
          {/* city name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">City Name *</label>
            <input
              value={form.name}
              onChange={e => setField('name', e.target.value)}
              onBlur={() => setErrs(e => ({ ...e, name: validateCityName(form.name) }))}
              placeholder="e.g. Addis Ababa"
              className={`w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition ${errs.name ? 'border-red-400 bg-red-50' : 'border-gray-200'}`}
            />
            <Err msg={errs.name} />
            <p className="text-xs text-gray-400 mt-0.5">Letters and spaces only — no numbers or symbols</p>
          </div>

          {/* region (optional) */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Region <span className="text-gray-400 font-normal">(optional)</span></label>
            <input
              value={form.region}
              onChange={e => setField('region', e.target.value)}
              placeholder="e.g. Addis Ababa City Administration"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
            />
          </div>

          <button
            onClick={handleCreate}
            disabled={submitting}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-60">
            {submitting ? 'Adding…' : 'Add City'}
          </button>
        </div>
      </Modal>
    </AdminLayout>
  )
}

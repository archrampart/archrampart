import { useState, useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import { useAuthStore } from '../store/authStore'
import { organizationsApi, Organization, OrganizationCreate } from '../api/organizations'
import { Plus, Edit, Trash2, Building2 } from 'lucide-react'

export default function Organizations() {
  const { t } = useTranslation()
  const { user } = useAuthStore()
  const [organizations, setOrganizations] = useState<Organization[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editing, setEditing] = useState<Organization | null>(null)
  const [formData, setFormData] = useState<OrganizationCreate>({
    name: '',
    description: '',
    logo_url: '',
  })

  useEffect(() => {
    loadOrganizations()
  }, [])

  const loadOrganizations = async () => {
    try {
      setLoading(true)
      const response = await organizationsApi.getAll()
      setOrganizations(response.data)
    } catch (error: any) {
      console.error('Error loading organizations:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (editing) {
        await organizationsApi.update(editing.id, formData)
      } else {
        await organizationsApi.create(formData)
      }
      setShowModal(false)
      setEditing(null)
      setFormData({ name: '', description: '', logo_url: '' })
      loadOrganizations()
    } catch (error: any) {
      console.error('Error saving organization:', error)
      alert(error.response?.data?.detail || 'Hata oluştu')
    }
  }

  const handleDelete = async (id: number) => {
    if (!confirm(t('organizations.deleteConfirm'))) return
    try {
      await organizationsApi.delete(id)
      loadOrganizations()
    } catch (error: any) {
      console.error('Error deleting organization:', error)
      alert(error.response?.data?.detail || t('organizations.deleteError'))
    }
  }

  const handleEdit = (org: Organization) => {
    setEditing(org)
    setFormData({
      name: org.name,
      description: org.description || '',
      logo_url: org.logo_url || '',
    })
    setShowModal(true)
  }

  if (user?.role !== 'platform_admin') {
    return (
      <div className="rounded-lg bg-warning-50 p-4 text-warning-800">
        Bu sayfaya erişim yetkiniz yok.
      </div>
    )
  }

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-4xl font-bold bg-gradient-to-r from-neutral-900 via-neutral-800 to-neutral-900 bg-clip-text text-transparent">
            {t('nav.organizations')}
          </h1>
        </div>
        <button
          onClick={() => {
            setEditing(null)
            setFormData({ name: '', description: '', logo_url: '' })
            setShowModal(true)
          }}
          className="btn-primary flex items-center space-x-2 shadow-md hover:shadow-lg"
        >
          <Plus className="h-5 w-5" />
          <span>{t('common.create')}</span>
        </button>
      </div>

      {loading ? (
        <div className="text-center py-12">{t('common.loading')}</div>
      ) : organizations.length === 0 ? (
        <div className="rounded-lg bg-neutral-50 p-12 text-center">
          <Building2 className="mx-auto h-12 w-12 text-neutral-400 mb-4" />
          <p className="text-neutral-600">{t('common.noData')}</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {organizations.map((org) => (
            <div key={org.id} className="rounded-lg border border-neutral-200 bg-white p-6 shadow-soft">
              <div className="mb-4 flex items-start justify-between">
                <div>
                  <h3 className="text-lg font-semibold text-neutral-900">{org.name}</h3>
                  {org.description && (
                    <p className="mt-1 text-sm text-neutral-600">{org.description}</p>
                  )}
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleEdit(org)}
                    className="rounded p-1 text-neutral-600 hover:bg-neutral-100"
                  >
                    <Edit className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(org.id)}
                    className="rounded p-1 text-error-600 hover:bg-error-50"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
              <div className="flex items-center justify-between text-sm text-neutral-500">
                <span className={org.is_active ? 'text-success-600' : 'text-neutral-400'}>
                  {org.is_active ? 'Aktif' : 'Pasif'}
                </span>
              </div>
            </div>
          ))}
        </div>
      )}

      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
          <div className="w-full max-w-md rounded-lg bg-white p-6 shadow-large">
            <h2 className="mb-4 text-xl font-bold">
              {editing ? t('organizations.edit') : t('organizations.create')}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-neutral-700">{t('organizations.name')}</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="mt-1 block w-full rounded-lg border border-neutral-300 px-3 py-2"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-700">{t('common.description')}</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="mt-1 block w-full rounded-lg border border-neutral-300 px-3 py-2"
                  rows={3}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-neutral-700">Logo URL</label>
                <input
                  type="url"
                  value={formData.logo_url}
                  onChange={(e) => setFormData({ ...formData, logo_url: e.target.value })}
                  className="mt-1 block w-full rounded-lg border border-neutral-300 px-3 py-2"
                />
              </div>
              <div className="flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false)
                    setEditing(null)
                  }}
                  className="rounded-lg border border-neutral-300 px-4 py-2 text-neutral-700 hover:bg-neutral-50"
                >
                  {t('common.cancel')}
                </button>
                <button
                  type="submit"
                  className="rounded-lg bg-accent-600 px-4 py-2 text-white hover:bg-accent-700"
                >
                  {t('common.save')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

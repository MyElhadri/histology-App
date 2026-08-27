import axios from 'axios'

const api = axios.create({
  // URL de l'API .NET (si lancée en local, c'est généralement http://localhost:5008/api)
  baseURL: 'http://localhost:5008/api',
  headers: {
    'Content-Type': 'application/json'
  }
})

// Intercepteur pour attacher le token JWT automatiquement
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

export default api

// API Methods
export const getStats = () => api.get('/stats')
export const getTissus = () => api.get('/tissus')
export const createTissu = (data) => api.post('/tissus', data)
export const updateTissu = (id, data) => api.put(`/tissus/${id}`, data)
export const deleteTissu = (id) => api.delete(`/tissus/${id}`)

export const getOrganes = () => api.get('/organes')
export const createOrgane = (data) => api.post('/organes', data)
export const updateOrgane = (id, data) => api.put(`/organes/${id}`, data)
export const deleteOrgane = (id) => api.delete(`/organes/${id}`)

export const getQuestionsByTissu = (tissuId) => api.get(`/questions/tissu/${tissuId}`)
export const createQuestion = (data) => api.post('/questions', data)
export const deleteQuestion = (id) => api.delete(`/questions/${id}`)

export const getEtudiants = () => api.get('/etudiants')
export const createEtudiant = (data) => api.post('/etudiants', data)
export const updateEtudiant = (id, data) => api.put(`/etudiants/${id}`, data)
export const deleteEtudiant = (id) => api.delete(`/etudiants/${id}`)
export const toggleActifEtudiant = (id) => api.patch(`/etudiants/${id}/toggle-actif`)
export const resetPasswordEtudiant = (id, data) => api.post(`/etudiants/${id}/reset-password`, data)
export const importEtudiants = (file) => {
  const formData = new FormData()
  formData.append('file', file)
  return api.post('/etudiants/import', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}
export const getEtudiantScans = (id) => api.get(`/etudiants/${id}/scans`)

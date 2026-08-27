import { defineStore } from 'pinia'
import api from '../services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    userRole: null
  }),

  getters: {
    isAuthenticated: (state) => !!state.token
  },

  actions: {
    async login(email, password) {
      try {
        const response = await api.post('/auth/login', { 
          email: email.trim(), 
          motDePasse: password.trim()
        })
        
        this.token = response.data.token
        localStorage.setItem('token', this.token)
        return null // Return null when success
      } catch (error) {
        console.error('Erreur de connexion:', error.response?.data || error.message)
        // Return exact message from backend if available
        if (error.response && error.response.data && typeof error.response.data === 'string') {
          return error.response.data
        }
        return 'Erreur réseau ou identifiants incorrects.'
      }
    },
    
    logout() {
      this.token = null
      this.userRole = null
      localStorage.removeItem('token')
    }
  }
})

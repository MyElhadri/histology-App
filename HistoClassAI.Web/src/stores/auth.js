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
          email: email, 
          motDePasse: password // Le backend C# attend "MotDePasse"
        })
        
        this.token = response.data.token
        localStorage.setItem('token', this.token)
        
        // On pourrait aussi décoder le JWT pour lire le rôle exact,
        // mais on va s'appuyer sur la sécurité du backend .NET pour l'instant.
        return true
      } catch (error) {
        console.error('Erreur de connexion:', error.response?.data || error.message)
        return false
      }
    },
    
    logout() {
      this.token = null
      this.userRole = null
      localStorage.removeItem('token')
    }
  }
})

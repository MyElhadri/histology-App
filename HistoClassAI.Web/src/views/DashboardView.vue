<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import Sidebar from '../components/layout/Sidebar.vue'
import { getStats, getEtudiants } from '../services/api'

const router = useRouter()
const authStore = useAuthStore()

const stats = ref({
  totalStudents: 0,
  totalTissus: 0,
  totalOrganes: 0,
  totalQuestions: 0,
  totalScans: 0
})
const recentStudents = ref([])
const isLoading = ref(true)

const fetchDashboardData = async () => {
  isLoading.value = true
  try {
    const statsRes = await getStats()
    stats.value = statsRes.data

    const etudiantsRes = await getEtudiants()
    // Prendre les 5 derniers inscrits
    recentStudents.value = etudiantsRes.data
      .sort((a, b) => new Date(b.dateCreation) - new Date(a.dateCreation))
      .slice(0, 5)
  } catch (error) {
    if (error.response?.status === 401) {
      authStore.logout()
      router.push('/')
    }
    console.error(error)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}
</script>

<template>
  <div class="app-shell">
    <Sidebar />

    <div class="main-area">
      <!-- ── Top App Bar ──────────────────── -->
      <header class="topbar">
        <div></div>
        <div class="topbar-actions">
          <button class="topbar-btn"><span class="material-symbols-outlined">notifications</span></button>
          <button class="topbar-btn"><span class="material-symbols-outlined">settings</span></button>
          <div class="avatar">P</div>
        </div>
      </header>

      <!-- ── Page Content ─────────────────── -->
      <main class="page-content">
        <!-- Header -->
        <div class="content-header-card">
          <div class="header-bg-gradient"></div>
          <div class="header-text">
            <h2 class="page-title">
              <span class="material-symbols-outlined header-icon">bar_chart</span>
              Vue d'ensemble
            </h2>
            <p class="page-subtitle">Suivez l'activité de votre plateforme et les données d'apprentissage du modèle IA.</p>
          </div>
        </div>

        <!-- Loading -->
        <div v-if="isLoading" class="empty-state">
          <div class="spinner"></div>
          <p>Chargement des données...</p>
        </div>

        <div v-else class="dashboard-content">
          <!-- Stats Grid -->
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-icon-wrapper student-icon"><span class="material-symbols-outlined">group</span></div>
              <div class="stat-details">
                <p class="stat-label">Total Étudiants</p>
                <h3 class="stat-value">{{ stats.totalStudents }}</h3>
              </div>
            </div>
            
            <div class="stat-card">
              <div class="stat-icon-wrapper scan-icon"><span class="material-symbols-outlined">center_focus_strong</span></div>
              <div class="stat-details">
                <p class="stat-label">Scans Effectués</p>
                <h3 class="stat-value">{{ stats.totalScans }}</h3>
              </div>
            </div>

            <div class="stat-card">
              <div class="stat-icon-wrapper tissu-icon"><span class="material-symbols-outlined">account_tree</span></div>
              <div class="stat-details">
                <p class="stat-label">Tissus Enregistrés</p>
                <h3 class="stat-value">{{ stats.totalTissus }}</h3>
              </div>
            </div>

            <div class="stat-card">
              <div class="stat-icon-wrapper qcm-icon"><span class="material-symbols-outlined">quiz</span></div>
              <div class="stat-details">
                <p class="stat-label">Base de QCM</p>
                <h3 class="stat-value">{{ stats.totalQuestions }}</h3>
              </div>
            </div>
          </div>

          <!-- Section: Derniers Étudiants -->
          <div class="recent-students-card">
            <div class="card-header">
              <h3>Derniers Inscrits</h3>
              <router-link to="/students" class="btn-text">Voir tous</router-link>
            </div>
            <div class="table-container">
              <table class="students-table">
                <thead>
                  <tr>
                    <th>Étudiant</th>
                    <th>Email</th>
                    <th>Date d'inscription</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="recentStudents.length === 0">
                    <td colspan="3" class="empty-text">Aucun étudiant récent.</td>
                  </tr>
                  <tr v-for="s in recentStudents" :key="s.id">
                    <td>
                      <div class="student-name">
                        <div class="s-avatar">{{ s.prenom.charAt(0) }}{{ s.nom.charAt(0) }}</div>
                        <span>{{ s.prenom }} {{ s.nom }}</span>
                      </div>
                    </td>
                    <td class="text-secondary">{{ s.email }}</td>
                    <td class="text-secondary">{{ formatDate(s.dateCreation) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
/* ── Shell ───────────────────────────── */
.app-shell { display: flex; min-height: 100vh; background: var(--md-surface); }
.main-area { flex: 1; margin-left: var(--sidebar-width); display: flex; flex-direction: column; min-height: 100vh; position: relative; }

/* ── Top App Bar ─────────────────────── */
.topbar { position: fixed; top: 0; right: 0; width: calc(100% - var(--sidebar-width)); height: var(--topbar-height); background: var(--md-surface); border-bottom: 1px solid var(--md-surface-variant); display: flex; justify-content: space-between; align-items: center; padding: 0 var(--gutter); z-index: 10; }
.topbar-actions { display: flex; align-items: center; gap: 16px; }
.topbar-btn { background: none; border: none; color: var(--md-secondary); padding: 0; transition: var(--transition); display: flex; cursor: pointer; }
.topbar-btn:hover { color: var(--md-primary); }
.avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--md-secondary-container); color: var(--md-primary); font-weight: 700; font-size: 13px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--md-surface-variant); }

/* ── Page Content ────────────────────── */
.page-content { flex: 1; padding-top: calc(var(--topbar-height) + var(--gutter)); padding-left: var(--container-pad); padding-right: var(--container-pad); padding-bottom: var(--container-pad); display: flex; flex-direction: column; gap: var(--stack-lg); }

/* ── Content Header ──────────────────── */
.content-header-card { display: flex; justify-content: space-between; align-items: flex-end; background: var(--md-surface-container-lowest); padding: 24px; border-radius: 16px; border: 1px solid var(--md-surface-variant); box-shadow: var(--shadow-sm); position: relative; overflow: hidden; }
.header-bg-gradient { position: absolute; right: 0; top: 0; width: 256px; height: 100%; background: linear-gradient(to left, rgba(79, 70, 229, 0.05), transparent); pointer-events: none; }
.header-text { position: relative; z-index: 10; }
.page-title { font-size: 24px; font-weight: 600; line-height: 32px; letter-spacing: -0.01em; color: var(--md-on-surface); display: flex; align-items: center; gap: 8px; margin: 0; }
.header-icon { color: var(--md-primary); font-size: 28px; }
.page-subtitle { font-size: 14px; line-height: 20px; color: var(--md-secondary); margin-top: 4px; margin-bottom: 0; max-width: 42rem; }

/* ── Dashboard Layout ────────────────── */
.dashboard-content { display: flex; flex-direction: column; gap: 24px; }
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: var(--gutter); }

.stat-card { background: var(--md-surface-container-lowest); border: 1px solid var(--md-surface-variant); border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 16px; box-shadow: var(--shadow-sm); transition: transform 0.2s, box-shadow 0.2s; }
.stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }

.stat-icon-wrapper { width: 56px; height: 56px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.stat-icon-wrapper .material-symbols-outlined { font-size: 28px; }
.student-icon { background: rgba(79, 70, 229, 0.1); color: var(--md-primary); }
.scan-icon { background: rgba(16, 185, 129, 0.1); color: #10b981; }
.tissu-icon { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
.qcm-icon { background: rgba(236, 72, 153, 0.1); color: #ec4899; }

.stat-details { display: flex; flex-direction: column; gap: 4px; }
.stat-label { font-size: 14px; font-weight: 500; color: var(--md-secondary); margin: 0; }
.stat-value { font-size: 28px; font-weight: 700; color: var(--md-on-surface); margin: 0; line-height: 1; }

.recent-students-card { background: var(--md-surface-container-lowest); border: 1px solid var(--md-surface-variant); border-radius: 16px; box-shadow: var(--shadow-sm); overflow: hidden; display: flex; flex-direction: column; }
.card-header { padding: 20px 24px; border-bottom: 1px solid var(--md-surface-variant); display: flex; justify-content: space-between; align-items: center; }
.card-header h3 { font-size: 18px; font-weight: 600; color: var(--md-on-surface); margin: 0; }

.btn-text { color: var(--md-primary); font-size: 14px; font-weight: 600; text-decoration: none; cursor: pointer; padding: 6px 12px; border-radius: 8px; transition: background 0.2s; }
.btn-text:hover { background: var(--md-primary-fixed); }

.table-container { overflow-x: auto; }
.students-table { width: 100%; border-collapse: collapse; }
.students-table th, .students-table td { padding: 16px 24px; text-align: left; border-bottom: 1px solid var(--md-surface-variant); }
.students-table th { background: rgba(0,0,0,0.02); font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--md-secondary); }
.students-table tbody tr { transition: background 0.2s; }
.students-table tbody tr:hover { background: var(--md-surface-container-low); }
.students-table tbody tr:last-child td { border-bottom: none; }
.empty-text { text-align: center; color: var(--md-secondary); padding: 32px !important; }

.student-name { display: flex; align-items: center; gap: 12px; font-weight: 600; color: var(--md-on-surface); }
.s-avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--md-primary-fixed); color: var(--md-primary); display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; text-transform: uppercase; }
.text-secondary { color: var(--md-secondary); }

/* ── Spinner ─────────────────────────── */
.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 64px 24px; text-align: center; gap: 12px; }
.spinner { width: 28px; height: 28px; border: 3px solid var(--md-surface-variant); border-top-color: var(--md-primary); border-radius: 50%; animation: spin 0.7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>

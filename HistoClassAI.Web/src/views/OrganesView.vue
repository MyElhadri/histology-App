<script setup>
import { ref, onMounted } from 'vue'
import { getOrganes, createOrgane, deleteOrgane } from '../services/api'
import Sidebar from '../components/layout/Sidebar.vue'

const organes = ref([])
const isLoading = ref(false)

const showAddModal = ref(false)
const newOrgane = ref({ nom: '' })
const isSubmitting = ref(false)

const notification = ref({ type: '', message: '' })

const fetchOrganes = async () => {
  isLoading.value = true
  try {
    const res = await getOrganes()
    organes.value = res.data
  } catch (error) {
    console.error(error)
  } finally {
    isLoading.value = false
  }
}

const openAddModal = () => {
  newOrgane.value.nom = ''
  showAddModal.value = true
}

const handleAdd = async () => {
  if (!newOrgane.value.nom) return
  isSubmitting.value = true
  try {
    await createOrgane({ nom: newOrgane.value.nom })
    showNotification('success', 'Organe ajouté avec succès.')
    showAddModal.value = false
    await fetchOrganes()
  } catch (error) {
    showNotification('error', "Erreur lors de l'ajout de l'organe.")
  } finally {
    isSubmitting.value = false
  }
}

const handleDelete = async (organe) => {
  if (!confirm(`Voulez-vous vraiment supprimer l'organe ${organe.nom} ?`)) return
  try {
    await deleteOrgane(organe.id)
    showNotification('success', 'Organe supprimé.')
    await fetchOrganes()
  } catch (error) {
    showNotification('error', "Erreur lors de la suppression.")
  }
}

const showNotification = (type, message) => {
  notification.value = { type, message }
  setTimeout(() => { notification.value = { type: '', message: '' } }, 4000)
}

onMounted(() => {
  fetchOrganes()
})
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

      <!-- ── Toast ────────────────────────── -->
      <Transition name="toast">
        <div v-if="notification.message" :class="['toast', `toast--${notification.type}`]">
          <span class="material-symbols-outlined toast-icon">{{ notification.type === 'success' ? 'check_circle' : 'error' }}</span>
          {{ notification.message }}
        </div>
      </Transition>

      <main class="page-content">
        <!-- Header -->
        <div class="content-header-card">
          <div class="header-bg-gradient"></div>
          <div class="header-text">
            <h2 class="page-title">
              <span class="material-symbols-outlined header-icon">accessibility_new</span>
              Gestion des Organes
            </h2>
            <p class="page-subtitle">Gérez la taxonomie anatomique de base pour l'association avec les tissus.</p>
          </div>
          <button class="btn-add" @click="openAddModal">
            <span class="material-symbols-outlined" style="font-size:20px">add</span>
            Ajouter un Organe
          </button>
        </div>

        <!-- Grid -->
        <div v-if="isLoading" class="empty-state">
          <div class="spinner"></div>
          <p>Chargement des organes...</p>
        </div>
        <div v-else-if="organes.length === 0" class="empty-state">
          <span class="material-symbols-outlined empty-icon">accessibility_new</span>
          <h3>Aucun organe défini</h3>
          <p>Commencez par ajouter les organes principaux du corps humain.</p>
        </div>
        <div v-else class="cards-grid">
          <div class="organe-card" v-for="o in organes" :key="o.id">
            <div class="organe-icon-wrapper">
              <span class="material-symbols-outlined">body_system</span>
            </div>
            <div class="organe-content">
              <h3>{{ o.nom }}</h3>
            </div>
            <button class="action-btn action-delete" @click="handleDelete(o)">
              <span class="material-symbols-outlined">delete</span>
            </button>
          </div>
        </div>
      </main>
    </div>

    <!-- Modale Ajout Organe -->
    <Transition name="fade">
      <div v-if="showAddModal" class="modal-backdrop" @click.self="showAddModal = false">
        <div class="modal-content">
          <div class="modal-header">
            <h3>Ajouter un Organe</h3>
            <button class="btn-close" @click="showAddModal = false"><span class="material-symbols-outlined">close</span></button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label>Nom de l'organe</label>
              <input type="text" v-model="newOrgane.nom" class="input-field" placeholder="Ex: Cœur, Foie, Épiderme" @keyup.enter="handleAdd" autofocus />
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-secondary" @click="showAddModal = false">Annuler</button>
            <button class="btn-primary" @click="handleAdd" :disabled="isSubmitting || !newOrgane.nom">
              <span v-if="isSubmitting" class="spinner-small"></span>
              <span v-else>Ajouter</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
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

/* ── Toast ───────────────────────────── */
.toast { position: fixed; top: 80px; right: var(--gutter); display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-radius: var(--radius-xl); font-size: 14px; font-weight: 500; box-shadow: var(--shadow-lg); z-index: 2000; }
.toast--success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
.toast--error { background: var(--md-error-container); color: #93000a; border: 1px solid #fecaca; }
.toast-icon { font-size: 20px; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from { opacity: 0; transform: translateY(-12px); }
.toast-leave-to { opacity: 0; transform: translateX(12px); }

/* ── Page Content ────────────────────── */
.page-content { flex: 1; padding-top: calc(var(--topbar-height) + var(--gutter)); padding-left: var(--container-pad); padding-right: var(--container-pad); padding-bottom: var(--container-pad); display: flex; flex-direction: column; gap: var(--stack-lg); }

/* ── Content Header ──────────────────── */
.content-header-card { display: flex; justify-content: space-between; align-items: flex-end; background: var(--md-surface-container-lowest); padding: 24px; border-radius: 16px; border: 1px solid var(--md-surface-variant); box-shadow: var(--shadow-sm); position: relative; overflow: hidden; }
.header-bg-gradient { position: absolute; right: 0; top: 0; width: 256px; height: 100%; background: linear-gradient(to left, rgba(79, 70, 229, 0.05), transparent); pointer-events: none; }
.header-text { position: relative; z-index: 10; }
.page-title { font-size: 24px; font-weight: 600; line-height: 32px; letter-spacing: -0.01em; color: var(--md-on-surface); display: flex; align-items: center; gap: 8px; margin: 0; }
.header-icon { color: var(--md-primary); font-size: 28px; }
.page-subtitle { font-size: 14px; line-height: 20px; color: var(--md-secondary); margin-top: 4px; margin-bottom: 0; max-width: 42rem; }

.btn-add { display: flex; align-items: center; gap: 8px; background: var(--md-primary); color: var(--md-on-primary); border: none; border-radius: var(--radius-lg); padding: 8px 16px; font-size: 14px; font-weight: 500; line-height: 20px; box-shadow: var(--shadow-sm); transition: var(--transition); white-space: nowrap; cursor: pointer; z-index: 10; }
.btn-add:hover { background: var(--md-primary-hover); }

/* ── Cards Grid ──────────────────────── */
.cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: var(--gutter); }

.organe-card { background: var(--md-surface-container-lowest); border: 1px solid var(--md-surface-variant); border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 16px; box-shadow: var(--shadow-sm); transition: transform 0.2s, box-shadow 0.2s; }
.organe-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }

.organe-icon-wrapper { width: 48px; height: 48px; border-radius: 12px; background: rgba(79, 70, 229, 0.1); color: var(--md-primary); display: flex; align-items: center; justify-content: center; }
.organe-icon-wrapper .material-symbols-outlined { font-size: 24px; }

.organe-content { flex: 1; }
.organe-content h3 { margin: 0; font-size: 16px; font-weight: 600; color: var(--md-on-surface); }

.action-btn { padding: 8px; background: transparent; border: 1px solid transparent; border-radius: 8px; color: var(--md-secondary); transition: all 0.2s; cursor: pointer; display: flex; align-items: center; justify-content: center; }
.action-delete:hover { color: var(--md-error); background: rgba(186, 26, 26, 0.1); border-color: rgba(186, 26, 26, 0.2); }

/* ── Empty State ─────────────────────── */
.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 64px 24px; text-align: center; gap: 12px; }
.empty-icon { font-size: 48px; color: var(--md-outline-variant); margin-bottom: 8px; }
.empty-state h3 { font-size: 18px; font-weight: 600; color: var(--md-on-surface); margin: 0; }
.empty-state p { font-size: 14px; color: var(--md-secondary); max-width: 360px; margin: 0; }

.spinner { width: 28px; height: 28px; border: 3px solid var(--md-surface-variant); border-top-color: var(--md-primary); border-radius: 50%; animation: spin 0.7s linear infinite; }
.spinner-small { width: 16px; height: 16px; border: 2px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

/* ── Modal ───────────────────────────── */
.modal-backdrop { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; backdrop-filter: blur(4px); }
.modal-content { background: var(--md-surface-container-lowest); width: 100%; max-width: 400px; border-radius: 20px; box-shadow: var(--shadow-xl); overflow: hidden; display: flex; flex-direction: column; }
.modal-header { padding: 20px 24px; border-bottom: 1px solid var(--md-surface-variant); display: flex; justify-content: space-between; align-items: center; }
.modal-header h3 { margin: 0; font-size: 18px; font-weight: 600; color: var(--md-on-surface); }
.btn-close { background: none; border: none; color: var(--md-secondary); display: flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 50%; cursor: pointer; transition: background 0.2s; }
.btn-close:hover { background: var(--md-surface-variant); }

.modal-body { padding: 24px; }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label { font-size: 14px; font-weight: 600; color: var(--md-on-surface); }
.input-field { padding: 12px 16px; border: 1px solid var(--md-surface-variant); border-radius: 12px; font-size: 14px; outline: none; transition: all 0.2s; background: var(--md-surface); color: var(--md-on-surface); font-family: inherit; }
.input-field:focus { border-color: var(--md-primary); box-shadow: 0 0 0 1px var(--md-primary); }

.modal-footer { padding: 16px 24px; border-top: 1px solid var(--md-surface-variant); display: flex; justify-content: flex-end; gap: 12px; background: var(--md-surface); }
.btn-secondary { padding: 10px 16px; border-radius: 8px; border: 1px solid var(--md-outline); background: transparent; color: var(--md-on-surface); font-weight: 500; cursor: pointer; transition: background 0.2s; }
.btn-secondary:hover { background: var(--md-surface-variant); }
.btn-primary { padding: 10px 20px; border-radius: 8px; border: none; background: var(--md-primary); color: var(--md-on-primary); font-weight: 600; cursor: pointer; transition: background 0.2s; display: flex; align-items: center; justify-content: center; min-width: 80px; }
.btn-primary:hover:not(:disabled) { background: var(--md-primary-hover); }
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>

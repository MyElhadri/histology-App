<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { getTissus, createTissu, updateTissu, deleteTissu, getOrganes } from '../services/api'
import Sidebar from '../components/layout/Sidebar.vue'
import TissuCard from '../components/tissus/TissuCard.vue'
import AddTissuModal from '../components/tissus/AddTissuModal.vue'

const router = useRouter()
const authStore = useAuthStore()

const tissus = ref([])
const organes = ref([])
const isLoading = ref(false)
const isSubmitting = ref(false)
const showPanel = ref(false)
const searchQuery = ref('')
const selectedOrganeFilter = ref(null)
const notification = ref({ type: '', message: '' })

// Add state for editing
const editingTissu = ref(null)

const filteredTissus = computed(() => {
  let list = tissus.value
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(t =>
      t.nom.toLowerCase().includes(q) || t.codeLabelIa.toLowerCase().includes(q)
    )
  }
  if (selectedOrganeFilter.value) {
    list = list.filter(t =>
      t.organes && t.organes.some(o => o.id === selectedOrganeFilter.value)
    )
  }
  return list
})

const fetchTissus = async () => {
  isLoading.value = true
  try {
    const response = await getTissus()
    tissus.value = response.data
  } catch (error) {
    if (error.response?.status === 401) {
      authStore.logout()
      router.push('/')
    }
    showNotification('error', "Impossible de charger les tissus.")
  } finally {
    isLoading.value = false
  }
}

const fetchOrganes = async () => {
  try {
    const response = await getOrganes()
    organes.value = response.data
  } catch (error) {
    console.error("Erreur chargement organes", error)
  }
}

const handleAddTissu = async (formData) => {
  isSubmitting.value = true
  try {
    if (editingTissu.value) {
      await updateTissu(editingTissu.value.id, formData)
      showNotification('success', `Le tissu a été modifié.`)
    } else {
      await createTissu(formData)
      showNotification('success', `Le tissu « ${formData.nom} » a été ajouté.`)
    }
    showPanel.value = false
    editingTissu.value = null
    await fetchTissus()
  } catch (error) {
    showNotification('error', error.response?.data || "Erreur lors de l'enregistrement.")
  } finally {
    isSubmitting.value = false
  }
}

const handleEdit = (tissu) => {
  editingTissu.value = tissu
  showPanel.value = true
}

const handleDelete = async (tissu) => {
  if (!confirm(`Voulez-vous vraiment supprimer le tissu ${tissu.nom} ?`)) return
  try {
    await deleteTissu(tissu.id)
    showNotification('success', "Le tissu a été supprimé.")
    await fetchTissus()
  } catch (error) {
    showNotification('error', "Erreur lors de la suppression.")
  }
}

const openAddPanel = () => {
  editingTissu.value = null
  showPanel.value = true
}

const showNotification = (type, message) => {
  notification.value = { type, message }
  setTimeout(() => { notification.value = { type: '', message: '' } }, 4000)
}

onMounted(() => {
  fetchTissus()
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

      <!-- ── Page Content ─────────────────── -->
      <main class="page-content">
        <!-- Header -->
        <div class="content-header-card">
          <div class="header-bg-gradient"></div>
          <div class="header-text">
            <h2 class="page-title">
              <span class="material-symbols-outlined header-icon">account_tree</span>
              Gestion des Tissus
            </h2>
            <p class="page-subtitle">Consultez et gérez la taxonomie histologique et les liaisons avec les organes correspondants.</p>
          </div>
          <button class="btn-add" @click="openAddPanel">
            <span class="material-symbols-outlined" style="font-size:20px">add</span>
            Ajouter un Tissu
          </button>
        </div>

        <!-- Filter Bar -->
        <div class="filter-bar">
          <div class="search-field">
            <span class="material-symbols-outlined search-icon">search</span>
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Rechercher par nom de tissu ou code IA..."
              class="search-input"
            />
          </div>
          <div class="filter-divider"></div>
          <div class="select-field">
            <select class="filter-select" v-model="selectedOrganeFilter">
              <option :value="null">Tous les organes</option>
              <option v-for="org in organes" :key="org.id" :value="org.id">{{ org.nom }}</option>
            </select>
            <span class="material-symbols-outlined select-icon">filter_list</span>
          </div>
        </div>

        <!-- Loading -->
        <div v-if="isLoading" class="empty-state">
          <div class="spinner"></div>
          <p>Chargement des tissus...</p>
        </div>

        <!-- Empty -->
        <div v-else-if="filteredTissus.length === 0" class="empty-state">
          <span class="material-symbols-outlined empty-icon">category</span>
          <h3>Aucun tissu trouvé</h3>
          <p>Aucun type de tissu ne correspond aux critères de recherche.</p>
          <button class="btn-add btn-add--outline" @click="openAddPanel">
            <span class="material-symbols-outlined" style="font-size:20px">add</span>
            Ajouter un tissu
          </button>
        </div>

        <!-- Grid -->
        <div v-else class="cards-grid">
          <TissuCard 
            v-for="t in filteredTissus" 
            :key="t.id" 
            :tissu="t" 
            @edit="handleEdit" 
            @delete="handleDelete" 
          />
        </div>
      </main>
    </div>

    <!-- Slide-over -->
    <AddTissuModal
      :visible="showPanel"
      :is-submitting="isSubmitting"
      :initial-data="editingTissu"
      :organes="organes"
      @close="showPanel = false"
      @submit="handleAddTissu"
    />
  </div>
</template>

<style scoped>
/* ── Shell ───────────────────────────── */
.app-shell {
  display: flex;
  min-height: 100vh;
  background: var(--md-surface);
}

.main-area {
  flex: 1;
  margin-left: var(--sidebar-width);
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  position: relative;
}

/* ── Top App Bar ─────────────────────── */
.topbar {
  position: fixed;
  top: 0;
  right: 0;
  width: calc(100% - var(--sidebar-width));
  height: var(--topbar-height);
  background: var(--md-surface);
  border-bottom: 1px solid var(--md-surface-variant);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 var(--gutter);
  z-index: 10;
}

.topbar-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.topbar-btn {
  background: none;
  border: none;
  color: var(--md-secondary);
  padding: 0;
  transition: var(--transition);
  display: flex;
}

.topbar-btn:hover {
  color: var(--md-primary);
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--md-secondary-container);
  color: var(--md-primary);
  font-weight: 700;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--md-surface-variant);
}

/* ── Toast ───────────────────────────── */
.toast {
  position: fixed;
  top: 80px;
  right: var(--gutter);
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border-radius: var(--radius-xl);
  font-size: 14px;
  font-weight: 500;
  box-shadow: var(--shadow-lg);
  z-index: 2000;
}

.toast--success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
.toast--error { background: var(--md-error-container); color: #93000a; border: 1px solid #fecaca; }
.toast-icon { font-size: 20px; }

.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from { opacity: 0; transform: translateY(-12px); }
.toast-leave-to { opacity: 0; transform: translateX(12px); }

/* ── Page Content ────────────────────── */
.page-content {
  flex: 1;
  padding-top: calc(var(--topbar-height) + var(--gutter));
  padding-left: var(--container-pad);
  padding-right: var(--container-pad);
  padding-bottom: var(--container-pad);
  display: flex;
  flex-direction: column;
  gap: var(--stack-lg);
}

/* ── Content Header ──────────────────── */
.content-header-card {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  background: var(--md-surface-container-lowest);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--md-surface-variant);
  box-shadow: var(--shadow-sm);
  position: relative;
  overflow: hidden;
}

.header-bg-gradient {
  position: absolute;
  right: 0;
  top: 0;
  width: 256px;
  height: 100%;
  background: linear-gradient(to left, rgba(79, 70, 229, 0.05), transparent);
  pointer-events: none;
}

.header-text {
  position: relative;
  z-index: 10;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  line-height: 32px;
  letter-spacing: -0.01em;
  color: var(--md-on-surface);
  display: flex;
  align-items: center;
  gap: 8px;
}

.header-icon {
  color: var(--md-primary);
  font-size: 28px;
}

.page-subtitle {
  font-size: 14px;
  line-height: 20px;
  color: var(--md-secondary);
  margin-top: 4px;
  max-width: 42rem;
}

.btn-add {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--md-primary);
  color: var(--md-on-primary);
  border: none;
  border-radius: var(--radius-lg);
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);
  white-space: nowrap;
}

.btn-add:hover {
  background: var(--md-primary-hover);
}

.btn-add--outline {
  background: var(--md-surface-container-lowest);
  color: var(--md-primary);
  border: 1px solid var(--md-outline-variant);
  box-shadow: none;
}

.btn-add--outline:hover {
  background: var(--md-primary-fixed);
}

/* ── Filter Bar ──────────────────────── */
.filter-bar {
  display: flex;
  gap: 16px;
  align-items: center;
  background: var(--md-surface-container-lowest);
  padding: 12px;
  border-radius: 12px;
  border: 1px solid var(--md-surface-variant);
  box-shadow: var(--shadow-sm);
}

.search-field {
  position: relative;
  flex: 1;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 20px;
  color: rgba(79, 70, 229, 0.7); /* primary/70 */
}

.search-input {
  width: 100%;
  padding: 8px 16px 8px 40px;
  background: var(--md-surface);
  border: 1px solid var(--md-surface-variant);
  border-radius: 8px;
  outline: none;
  font-size: 14px;
  line-height: 20px;
  color: var(--md-on-surface);
  transition: all 0.2s;
}

.search-input:focus {
  border-color: var(--md-primary);
  box-shadow: 0 0 0 1px var(--md-primary);
}

.search-input::placeholder {
  color: var(--md-secondary);
}

.filter-divider {
  width: 1px;
  height: 32px;
  background: var(--md-surface-variant);
}

.select-field {
  position: relative;
  min-width: 200px;
}

.filter-select {
  width: 100%;
  padding: 8px 32px 8px 12px;
  background: var(--md-surface);
  border: 1px solid var(--md-surface-variant);
  border-radius: 8px;
  outline: none;
  font-size: 14px;
  font-weight: 500;
  color: var(--md-on-surface);
  cursor: pointer;
  appearance: none;
  transition: all 0.2s;
}

.filter-select:focus {
  border-color: var(--md-primary);
  box-shadow: 0 0 0 1px var(--md-primary);
}

.select-icon {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 20px;
  color: var(--md-secondary);
  pointer-events: none;
}

/* ── Cards Grid ──────────────────────── */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--gutter);
}

@media (max-width: 1100px) {
  .cards-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 800px) {
  .cards-grid { grid-template-columns: 1fr; }
  .main-area { margin-left: 0; }
  .topbar { width: 100%; }
}

/* ── Empty State ─────────────────────── */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 64px 24px;
  text-align: center;
  gap: 12px;
}

.empty-icon {
  font-size: 48px;
  color: var(--md-outline-variant);
  margin-bottom: 8px;
}

.empty-state h3 {
  font-size: 18px;
  font-weight: 600;
  color: var(--md-on-surface);
}

.empty-state p {
  font-size: 14px;
  color: var(--md-secondary);
  max-width: 360px;
}

/* ── Spinner ─────────────────────────── */
.spinner {
  width: 28px;
  height: 28px;
  border: 3px solid var(--md-surface-variant);
  border-top-color: var(--md-primary);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }
</style>

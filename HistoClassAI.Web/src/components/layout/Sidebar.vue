<script setup>
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const route = useRoute()

const navItems = [
  { label: 'Tableau de bord', icon: 'bar_chart', route: '/dashboard' },
  { label: 'Tissus', icon: 'account_tree', route: '/tissus' },
  { label: 'Organes', icon: 'accessibility_new', route: '/organes' },
  { label: 'Banque QCM', icon: 'quiz', route: '/mcq' },
  { label: 'Étudiants', icon: 'group', route: '/students' },
]

const handleLogout = () => {
  authStore.logout()
  router.push('/')
}
</script>

<template>
  <aside class="sidebar">
    <!-- Brand & Institutional Logos -->
    <div class="sidebar-brand">
      <div class="brand-institution-card">
        <img
          src="/logos/logo_labo_histologie.png"
          alt="Laboratoire d'Histologie - FMPT Tanger"
          class="brand-logo-img"
        />
      </div>
      <div class="brand-text-block">
        <h1 class="brand-title">HistoClass AI</h1>
        <p class="brand-subtitle">Laboratoire d'Histologie • FMPT</p>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="sidebar-nav">
      <router-link
        v-for="item in navItems"
        :key="item.label"
        :to="item.route"
        :class="['nav-item', { 'nav-item--active': route.path === item.route }]"
      >
        <span
          class="material-symbols-outlined nav-icon"
          :style="route.path === item.route ? `font-variation-settings: 'FILL' 1` : ''"
        >{{ item.icon }}</span>
        {{ item.label }}
      </router-link>
    </nav>

    <!-- Footer -->
    <div class="sidebar-footer">
      <div class="footer-institution-card">
        <img
          src="/logos/logo_faculte_medecine.png"
          alt="Faculté de Médecine et de Pharmacie de Tanger"
          class="footer-logo-img"
        />
      </div>
      <button class="nav-item btn-logout" @click="handleLogout">
        <span class="material-symbols-outlined nav-icon">logout</span>
        Déconnexion
      </button>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  width: var(--sidebar-width);
  height: 100vh;
  background: var(--md-surface-container-lowest);
  border-right: 1px solid var(--md-surface-variant);
  display: flex;
  flex-direction: column;
  padding: 16px 0;
  z-index: 20;
}

/* ── Brand ───────────────────────────── */
.sidebar-brand {
  padding: 0 14px;
  margin-bottom: 20px;
}

.brand-institution-card {
  background: #ffffff;
  border-radius: 10px;
  padding: 8px 10px;
  border: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
}

.brand-logo-img {
  max-width: 100%;
  height: auto;
  max-height: 48px;
  object-fit: contain;
}

.brand-text-block {
  padding-left: 2px;
}

.brand-title {
  font-size: 17px;
  font-weight: 700;
  line-height: 22px;
  color: var(--md-primary);
  margin: 0;
}

.brand-subtitle {
  font-size: 11px;
  font-weight: 500;
  line-height: 16px;
  color: var(--md-secondary);
  margin: 2px 0 0 0;
}

/* ── Nav ─────────────────────────────── */
.sidebar-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 3px;
  padding: 0 8px;
  overflow-y: auto;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 14px;
  font-size: 13.5px;
  font-weight: 500;
  line-height: 20px;
  color: var(--md-secondary);
  text-decoration: none;
  border: none;
  background: none;
  border-left: 3px solid transparent;
  border-radius: 0 var(--radius-lg, 8px) var(--radius-lg, 8px) 0;
  transition: var(--transition);
  width: 100%;
  text-align: left;
  cursor: pointer;
}

.nav-item:hover {
  background: var(--md-surface-container-low);
  color: var(--md-on-surface);
}

.nav-item:active {
  transform: scale(0.98);
}

.nav-item--active {
  background: var(--md-secondary-container);
  color: var(--md-primary);
  font-weight: 700;
  border-left-color: var(--md-primary);
}

.nav-icon {
  font-size: 22px;
}

/* ── Footer ──────────────────────────── */
.sidebar-footer {
  margin-top: auto;
  padding: 8px 10px 0 10px;
  border-top: 1px solid var(--md-surface-variant);
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.footer-institution-card {
  background: #ffffff;
  border-radius: 8px;
  padding: 6px 8px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
}

.footer-logo-img {
  max-width: 100%;
  height: auto;
  max-height: 38px;
  object-fit: contain;
}

.btn-logout {
  border-radius: var(--radius-lg, 8px);
  border-left: none;
  padding: 8px 12px;
  color: var(--md-secondary);
}

.btn-logout:hover {
  color: var(--md-error, #ef4444);
  background: rgba(239, 68, 68, 0.08);
}
</style>

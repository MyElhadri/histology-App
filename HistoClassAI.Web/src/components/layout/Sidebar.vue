<script setup>
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const route = useRoute()

const navItems = [
  { label: 'Dashboard', icon: 'bar_chart', route: '/dashboard' },
  { label: 'Tissues', icon: 'account_tree', route: '/tissus' },
  { label: 'Organs', icon: 'accessibility_new', route: '/organes' },
  { label: 'MCQ Base', icon: 'quiz', route: '/mcq' },
  { label: 'Students', icon: 'group', route: '/students' },
]

const handleLogout = () => {
  authStore.logout()
  router.push('/')
}
</script>

<template>
  <aside class="sidebar">
    <!-- Brand -->
    <div class="sidebar-brand">
      <h1 class="brand-title">HistoClassAI</h1>
      <p class="brand-subtitle">Clinical Precision AI</p>
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

    <!-- Logout -->
    <div class="sidebar-footer">
      <button class="nav-item" @click="handleLogout">
        <span class="material-symbols-outlined nav-icon">logout</span>
        Logout
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
  padding: var(--stack-lg) 0;
  z-index: 20;
}

/* ── Brand ───────────────────────────── */
.sidebar-brand {
  padding: 0 16px;
  margin-bottom: 32px;
}

.brand-title {
  font-size: 18px;
  font-weight: 700;
  line-height: 28px;
  color: var(--md-primary);
}

.brand-subtitle {
  font-size: 14px;
  line-height: 20px;
  color: var(--md-secondary);
}

/* ── Nav ─────────────────────────────── */
.sidebar-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 0 8px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
  color: var(--md-secondary);
  text-decoration: none;
  border: none;
  background: none;
  border-left: 4px solid transparent;
  border-radius: 0 var(--radius-lg) var(--radius-lg) 0;
  transition: var(--transition);
  width: 100%;
  text-align: left;
  cursor: pointer;
}

.nav-item:hover {
  background: var(--md-surface-container-low);
}

.nav-item:active {
  transform: scale(0.97);
}

.nav-item--active {
  background: var(--md-secondary-container);
  color: var(--md-primary);
  font-weight: 700;
  border-left-color: var(--md-primary);
}

.nav-icon {
  font-size: 24px;
}

/* ── Footer ──────────────────────────── */
.sidebar-footer {
  margin-top: auto;
  padding: 0 8px;
}

.sidebar-footer .nav-item {
  border-radius: var(--radius-lg);
  border-left: none;
}
</style>

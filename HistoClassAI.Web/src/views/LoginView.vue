<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const errorMessage = ref('')
const isLoading = ref(false)

const handleLogin = async () => {
  isLoading.value = true
  errorMessage.value = ''

  const apiError = await authStore.login(email.value, password.value)

  if (apiError === null) {
    router.push('/dashboard')
  } else {
    errorMessage.value = apiError
  }

  isLoading.value = false
}
</script>

<template>
  <div class="login-layout">
    <!-- Left Column - Visual -->
    <div class="login-visual">
      <img
        class="visual-image"
        src="https://lh3.googleusercontent.com/aida-public/AB6AXuBYxe7ZUCY3us-UXwBqVbPLr7TnyRszVjcBOA4CrY20zWoGCDlEfSBSlaVXm_8RILOO1-Hb6spsRrGoidru2f0Dacr88TCyexg3qbvoEHnSbK1jL-IebRZVKqy47soswXiblfDmPB59XarQU4tKCj5OHCb_ZzRy_VcBvoKljJeA157-sQ5prK5Yrt0CTKsYxYJnCkmr8C6HUrBSLdU7WOvjTk5vNoyKTp0hLbSGbkQ-FApsU9KMxECe"
        alt="Abstract medical technology visualization"
      />
      <div class="visual-overlay"></div>
    </div>

    <!-- Right Column - Login -->
    <div class="login-panel">
      <main class="login-main">
        <!-- Logo Header with Institutional Logos -->
        <div class="login-header">
          <div class="institutional-banner">
            <img
              src="/logos/logo_faculte_medecine.png"
              alt="Faculté de Médecine et de Pharmacie de Tanger"
              class="login-inst-logo"
            />
            <div class="banner-divider"></div>
            <img
              src="/logos/logo_labo_histologie.png"
              alt="Laboratoire d'Histologie de Tanger"
              class="login-inst-logo"
            />
          </div>
          <div class="app-branding">
            <span class="material-symbols-outlined logo-icon" style="font-variation-settings: 'FILL' 1;">biotech</span>
            <h1 class="logo-title">HistoClass AI</h1>
          </div>
        </div>

        <!-- Login Card -->
        <div class="login-card">
          <div class="card-header">
            <h2>Portail Enseignant</h2>
            <p>Faculté de Médecine et de Pharmacie • Laboratoire d'Histologie</p>
          </div>

          <form @submit.prevent="handleLogin" class="login-form">
            <!-- Email Field -->
            <div class="form-group">
              <label for="email">Adresse email</label>
              <input
                type="email"
                id="email"
                v-model="email"
                placeholder="professeur@universite.edu"
                required
                autocomplete="email"
              />
            </div>

            <!-- Password Field -->
            <div class="form-group">
              <div class="password-header">
                <label for="password">Mot de passe</label>
                <a href="#" class="forgot-link">Mot de passe oublié ?</a>
              </div>
              <input
                type="password"
                id="password"
                v-model="password"
                placeholder="••••••••"
                required
                autocomplete="current-password"
              />
            </div>

            <!-- Error Message -->
            <Transition name="fade">
              <div v-if="errorMessage" class="error-banner">
                <span class="material-symbols-outlined error-icon">error</span>
                {{ errorMessage }}
              </div>
            </Transition>

            <!-- Submit Button -->
            <button type="submit" class="submit-btn" :disabled="isLoading">
              <span v-if="isLoading" class="spinner"></span>
              <span v-else>Se connecter</span>
              <span v-if="!isLoading" class="material-symbols-outlined btn-icon">arrow_forward</span>
            </button>
          </form>
        </div>

        <!-- Footer -->
        <div class="login-footer">
          <p>Pas encore de compte ? <a href="#">Contactez l'administration</a></p>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
/* ── Layout ──────────────────────────────── */
.login-layout {
  display: flex;
  min-height: 100vh;
  background: var(--md-surface);
  color: var(--md-on-surface);
}

/* ── Visual Left Column ──────────────────── */
.login-visual {
  display: none;
  position: relative;
  background: var(--md-surface-container);
}

@media (min-width: 1024px) {
  .login-visual {
    display: block;
    width: 60%;
  }
}

.visual-image {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.visual-overlay {
  position: absolute;
  inset: 0;
  background: rgba(79, 70, 229, 0.1);
  mix-blend-mode: multiply;
}

/* ── Login Right Column ──────────────────── */
.login-panel {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px;
  min-height: 100vh;
}

@media (min-width: 1024px) {
  .login-panel {
    width: 40%;
    padding: 48px;
  }
}

.login-main {
  width: 100%;
  max-width: 448px;
}

/* ── Header ──────────────────────────────── */
.login-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  margin-bottom: var(--stack-lg);
}

.institutional-banner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
  background: #ffffff;
  padding: 10px 18px;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
  width: 100%;
}

.login-inst-logo {
  max-height: 44px;
  width: auto;
  max-width: 46%;
  object-fit: contain;
}

.banner-divider {
  width: 1px;
  height: 36px;
  background: rgba(0, 0, 0, 0.12);
}

.app-branding {
  display: flex;
  align-items: center;
  gap: 8px;
}

.logo-icon {
  font-size: 28px;
  color: var(--md-primary);
}

.logo-title {
  font-size: 22px;
  font-weight: 700;
  line-height: 30px;
  letter-spacing: -0.01em;
  color: var(--md-primary);
}

/* ── Card ────────────────────────────────── */
.login-card {
  background: var(--md-surface-container-lowest);
  border: 1px solid var(--md-surface-variant);
  border-radius: var(--radius-xl);
  box-shadow: 0 10px 20px -5px rgba(0, 0, 0, 0.05);
  padding: 32px;
}

.card-header {
  text-align: center;
  margin-bottom: var(--stack-lg);
}

.card-header h2 {
  font-size: 24px;
  font-weight: 600;
  line-height: 32px;
  letter-spacing: -0.01em;
  color: var(--md-on-surface);
  margin-bottom: var(--stack-sm);
}

.card-header p {
  font-size: 14px;
  line-height: 20px;
  color: var(--md-on-surface-variant);
}

/* ── Form ────────────────────────────────── */
.login-form {
  display: flex;
  flex-direction: column;
  gap: var(--stack-md);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--unit);
}

.form-group label {
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
  color: var(--md-on-surface);
}

.password-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.forgot-link {
  font-size: 12px;
  font-weight: 600;
  line-height: 16px;
  letter-spacing: 0.02em;
  color: var(--md-secondary);
  transition: var(--transition);
}

.forgot-link:hover {
  color: var(--md-primary-container);
}

input {
  width: 100%;
  background: var(--md-surface-container-lowest);
  border: 1px solid var(--md-surface-variant);
  border-radius: var(--radius-lg);
  padding: 8px 12px;
  font-size: 14px;
  line-height: 20px;
  color: var(--md-on-surface);
  outline: none;
  transition: box-shadow 0.2s ease, border-color 0.2s ease;
}

input::placeholder {
  color: var(--md-outline-variant);
}

input:focus {
  border-color: var(--md-primary-container);
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.2);
}

/* ── Button ──────────────────────────────── */
.submit-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: var(--md-primary-container);
  color: var(--md-on-primary);
  border: 1px solid transparent;
  border-radius: var(--radius-lg);
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
  transition: var(--transition);
  margin-top: 8px;
}

.submit-btn:hover:not(:disabled) {
  background: #4338ca;
}

.submit-btn:active:not(:disabled) {
  background: #3730a3;
}

.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.btn-icon {
  font-size: 18px;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* ── Error Banner ────────────────────────── */
.error-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  background: var(--md-error-container);
  color: #93000a;
  border: 1px solid #fecaca;
  border-radius: var(--radius-md);
  font-size: 13px;
  font-weight: 500;
}

.error-icon {
  font-size: 18px;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* ── Footer ──────────────────────────────── */
.login-footer {
  margin-top: var(--stack-lg);
  text-align: center;
}

.login-footer p {
  font-size: 14px;
  line-height: 20px;
  color: var(--md-on-surface-variant);
}

.login-footer a {
  color: var(--md-primary-container);
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
}

.login-footer a:hover {
  text-decoration: underline;
}
</style>

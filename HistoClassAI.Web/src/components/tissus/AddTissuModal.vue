<script setup>
import { ref } from 'vue'

const props = defineProps({
  visible: { type: Boolean, default: false },
  isSubmitting: { type: Boolean, default: false }
})

const emit = defineEmits(['close', 'submit'])

const form = ref({ nom: '', description: '', codeLabelIa: '' })

const handleSubmit = () => {
  emit('submit', { ...form.value })
  form.value = { nom: '', description: '', codeLabelIa: '' }
}
</script>

<template>
  <Teleport to="body">
    <Transition name="slideover">
      <div v-if="visible" class="overlay" @click.self="emit('close')">
        <!-- Slide-over Panel -->
        <div class="panel">
          <!-- Header -->
          <div class="panel-header">
            <h3 class="panel-title">Ajouter un Tissu</h3>
            <button class="close-btn" @click="emit('close')">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>

          <!-- Body -->
          <form @submit.prevent="handleSubmit" class="panel-body">
            <div class="field">
              <label for="slide-nom">Nom du Tissu</label>
              <input
                type="text" id="slide-nom"
                v-model="form.nom"
                placeholder="Ex: Tissu Osseux"
                required autocomplete="off"
              />
            </div>

            <div class="field">
              <label for="slide-code">Code Label IA</label>
              <input
                type="text" id="slide-code"
                v-model="form.codeLabelIa"
                placeholder="Ex: classe_15"
                required autocomplete="off"
              />
              <span class="field-hint">Doit correspondre au modèle PyTorch</span>
            </div>

            <div class="field">
              <label for="slide-desc">Description</label>
              <textarea
                id="slide-desc"
                v-model="form.description"
                placeholder="Description courte des caractéristiques histologiques..."
                rows="4"
              ></textarea>
            </div>
          </form>

          <!-- Footer -->
          <div class="panel-footer">
            <button type="button" class="btn btn-ghost" @click="emit('close')">Annuler</button>
            <button
              type="button"
              class="btn btn-primary"
              :disabled="isSubmitting || !form.nom || !form.codeLabelIa"
              @click="handleSubmit"
            >
              {{ isSubmitting ? 'Sauvegarde...' : 'Sauvegarder' }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
/* ── Overlay ─────────────────────────── */
.overlay {
  position: fixed;
  inset: 0;
  z-index: 50;
  display: flex;
  justify-content: flex-end;
  background: rgba(25, 28, 30, 0.2);
  backdrop-filter: blur(4px);
}

/* ── Panel ───────────────────────────── */
.panel {
  width: 400px;
  max-width: 100%;
  height: 100%;
  background: var(--md-surface-container-lowest);
  border-left: 1px solid var(--md-surface-variant);
  box-shadow: var(--shadow-panel);
  display: flex;
  flex-direction: column;
}

.panel-header {
  padding: var(--stack-md);
  border-bottom: 1px solid var(--md-surface-variant);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-title {
  font-size: 18px;
  font-weight: 600;
  line-height: 28px;
  color: var(--md-on-surface);
}

.close-btn {
  background: none;
  border: none;
  color: var(--md-secondary);
  padding: 4px;
  border-radius: 50%;
  transition: var(--transition);
  display: flex;
}

.close-btn:hover {
  color: var(--md-on-surface);
  background: var(--md-surface-container-low);
}

/* ── Body ────────────────────────────── */
.panel-body {
  flex: 1;
  overflow-y: auto;
  padding: var(--stack-md);
  display: flex;
  flex-direction: column;
  gap: var(--stack-md);
}

.field {
  display: flex;
  flex-direction: column;
  gap: var(--unit);
}

.field label {
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
  color: var(--md-on-surface);
}

.field input,
.field textarea {
  background: var(--md-surface-container-lowest);
  border: 1px solid var(--md-surface-variant);
  border-radius: var(--radius-lg);
  padding: 8px 12px;
  font-size: 14px;
  line-height: 20px;
  color: var(--md-on-surface);
  outline: none;
  transition: var(--transition);
}

.field input::placeholder,
.field textarea::placeholder {
  color: var(--md-secondary);
}

.field input:focus,
.field textarea:focus {
  border-color: var(--md-primary);
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.15);
}

.field textarea {
  resize: none;
}

.field-hint {
  font-size: 12px;
  color: var(--md-secondary);
}

/* ── Footer ──────────────────────────── */
.panel-footer {
  padding: var(--stack-md);
  border-top: 1px solid var(--md-surface-variant);
  background: var(--md-surface-bright);
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn {
  padding: 8px 16px;
  border-radius: var(--radius-lg);
  font-size: 14px;
  font-weight: 500;
  line-height: 20px;
  border: none;
  transition: var(--transition);
}

.btn-ghost {
  background: var(--md-surface-container-lowest);
  border: 1px solid var(--md-surface-variant);
  color: var(--md-on-surface);
}

.btn-ghost:hover {
  background: var(--md-surface-container-low);
}

.btn-primary {
  background: var(--md-primary);
  color: var(--md-on-primary);
}

.btn-primary:hover {
  background: var(--md-primary-hover);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ── Transition ──────────────────────── */
.slideover-enter-active { transition: opacity 0.2s ease; }
.slideover-leave-active { transition: opacity 0.2s ease 0.1s; }
.slideover-enter-active .panel { transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); }
.slideover-leave-active .panel { transition: transform 0.2s ease; }
.slideover-enter-from { opacity: 0; }
.slideover-enter-from .panel { transform: translateX(100%); }
.slideover-leave-to { opacity: 0; }
.slideover-leave-to .panel { transform: translateX(100%); }
</style>

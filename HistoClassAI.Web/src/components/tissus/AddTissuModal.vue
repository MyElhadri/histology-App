<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  visible: { type: Boolean, default: false },
  isSubmitting: { type: Boolean, default: false },
  initialData: { type: Object, default: null },
  organes: { type: Array, default: () => [] }
})

const emit = defineEmits(['close', 'submit'])

const form = ref({
  nom: '',
  description: '',
  fonctions: '',
  codeLabelIa: '',
  organeIds: []
})

// Mettre à jour les champs dès que le modal s'ouvre ou que initialData change
watch(() => [props.visible, props.initialData], ([isVisible, data]) => {
  if (isVisible) {
    if (data) {
      form.value = {
        nom: data.nom || '',
        description: data.description || '',
        fonctions: data.fonctions || '',
        codeLabelIa: data.codeLabelIa || '',
        organeIds: data.organes && Array.isArray(data.organes) 
          ? data.organes.map(o => o.id) 
          : []
      }
    } else {
      form.value = {
        nom: '',
        description: '',
        fonctions: '',
        codeLabelIa: '',
        organeIds: []
      }
    }
  }
}, { immediate: true })

const handleSubmit = () => {
  emit('submit', { 
    nom: form.value.nom.trim(),
    description: form.value.description.trim(),
    fonctions: form.value.fonctions.trim(),
    codeLabelIa: form.value.codeLabelIa.trim(),
    organeIds: form.value.organeIds || []
  })
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
            <h3 class="panel-title">{{ initialData ? 'Modifier le Tissu' : 'Ajouter un Tissu' }}</h3>
            <button class="close-btn" @click="emit('close')">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>

          <!-- Body -->
          <form @submit.prevent="handleSubmit" class="panel-body">
            <div class="field">
              <label for="slide-nom">Nom du Tissu *</label>
              <input
                type="text" id="slide-nom"
                v-model="form.nom"
                placeholder="Ex: Tissu Conjonctif Dense"
                required autocomplete="off"
              />
            </div>

            <div class="field">
              <label for="slide-code">Code Label IA *</label>
              <input
                type="text" id="slide-code"
                v-model="form.codeLabelIa"
                placeholder="Ex: classe_04"
                required autocomplete="off"
              />
            </div>

            <div class="field">
              <label>Organes Associés</label>
              <v-select
                v-model="form.organeIds"
                :items="organes"
                item-title="nom"
                item-value="id"
                label="Sélectionner les organes hôtes"
                multiple
                chips
                closable-chips
                variant="outlined"
                density="compact"
                hide-details
                clearable
                no-data-text="Aucun organe disponible"
                class="organes-select"
              ></v-select>
            </div>

            <div class="field">
              <label for="slide-desc">Description</label>
              <textarea
                id="slide-desc"
                v-model="form.description"
                placeholder="Description des caractéristiques histologiques..."
                rows="3"
              ></textarea>
            </div>

            <div class="field">
              <label for="slide-fonctions">Fonctions</label>
              <textarea
                id="slide-fonctions"
                v-model="form.fonctions"
                placeholder="Propriétés et fonctions physiologiques..."
                rows="3"
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
              {{ isSubmitting ? 'Enregistrement...' : (initialData ? 'Mettre à jour' : 'Enregistrer') }}
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
  z-index: 500;
  display: flex;
  justify-content: flex-end;
  background: rgba(25, 28, 30, 0.3);
  backdrop-filter: blur(4px);
}

/* ── Panel ───────────────────────────── */
.panel {
  width: 440px;
  max-width: 100%;
  height: 100%;
  background: var(--md-surface-container-lowest);
  border-left: 1px solid var(--md-surface-variant);
  box-shadow: var(--shadow-panel);
  display: flex;
  flex-direction: column;
}

.panel-header {
  padding: 20px 24px;
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
  margin: 0;
}

.close-btn {
  background: none;
  border: none;
  color: var(--md-secondary);
  padding: 4px;
  border-radius: 50%;
  transition: var(--transition);
  display: flex;
  cursor: pointer;
}

.close-btn:hover {
  color: var(--md-on-surface);
  background: var(--md-surface-container-low);
}

/* ── Body ────────────────────────────── */
.panel-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field label {
  font-size: 13px;
  font-weight: 600;
  color: var(--md-on-surface);
}

.field input,
.field textarea {
  background: var(--md-surface);
  border: 1px solid var(--md-surface-variant);
  border-radius: var(--radius-lg, 8px);
  padding: 9px 12px;
  font-size: 14px;
  font-family: inherit;
  color: var(--md-on-surface);
  outline: none;
  transition: var(--transition);
}

.field input::placeholder,
.field textarea::placeholder {
  color: var(--md-secondary);
  opacity: 0.7;
}

.field input:focus,
.field textarea:focus {
  border-color: var(--md-primary);
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.15);
}

.field textarea {
  resize: vertical;
}

.organes-select :deep(.v-field) {
  border-radius: 8px !important;
}

/* ── Footer ──────────────────────────── */
.panel-footer {
  padding: 16px 24px;
  border-top: 1px solid var(--md-surface-variant);
  background: var(--md-surface-container-low);
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn {
  padding: 9px 18px;
  border-radius: var(--radius-lg, 8px);
  font-size: 14px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: var(--transition);
}

.btn-ghost {
  background: var(--md-surface-container-lowest);
  border: 1px solid var(--md-surface-variant);
  color: var(--md-on-surface);
}

.btn-ghost:hover {
  background: var(--md-surface-container-high);
}

.btn-primary {
  background: var(--md-primary);
  color: var(--md-on-primary);
}

.btn-primary:hover:not(:disabled) {
  background: var(--md-primary-hover);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ── Transition ──────────────────────── */
.slideover-enter-active { transition: opacity 0.25s ease; }
.slideover-leave-active { transition: opacity 0.2s ease 0.1s; }
.slideover-enter-active .panel { transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1); }
.slideover-leave-active .panel { transition: transform 0.2s ease; }
.slideover-enter-from { opacity: 0; }
.slideover-enter-from .panel { transform: translateX(100%); }
.slideover-leave-to { opacity: 0; }
.slideover-leave-to .panel { transform: translateX(100%); }
</style>

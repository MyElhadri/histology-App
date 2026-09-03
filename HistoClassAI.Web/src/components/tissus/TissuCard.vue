<script setup>
import { computed } from 'vue'

const props = defineProps({
  tissu: { type: Object, required: true }
})

const emit = defineEmits(['edit', 'delete'])

// Define a dynamic style based on an index or hash of the tissu name
// so different tissues have different icon colors (primary, secondary, tertiary)
const themeData = computed(() => {
  const hash = props.tissu.nom.charCodeAt(0) % 3
  if (hash === 0) return { icon: 'layers', color: 'primary', barWidth1: '25%', barWidth2: '45%' }
  if (hash === 1) return { icon: 'favorite', color: 'tertiary', barWidth1: '25%', barWidth2: '75%' }
  return { icon: 'water_drop', color: 'secondary', barWidth1: '50%', barWidth2: '60%' }
})
</script>

<template>
  <div :class="['tissue-card', `theme-${themeData.color}`]">
    <!-- Background Gradient (Top right) -->
    <div class="card-gradient"></div>

    <!-- Header Area -->
    <div class="card-header">
      <div class="header-content">
        <div class="icon-box">
          <span class="material-symbols-outlined theme-icon">{{ themeData.icon }}</span>
        </div>
        <div>
          <h3 class="card-title">{{ tissu.nom }}</h3>
          <p class="card-subtitle">{{ tissu.organes && tissu.organes.length > 0 ? tissu.organes.map(o => o.nom).join(', ') : 'Aucun organe associé' }}</p>
        </div>
      </div>
    </div>

    <!-- Badge Area -->
    <div class="badge-area">
      <span class="ia-badge">
        <span class="pulse-dot"></span>
        Code IA: <span class="ia-code">{{ tissu.codeLabelIa }}</span>
      </span>
    </div>

    <!-- Organes Tags -->
    <div v-if="tissu.organes && tissu.organes.length > 0" class="organes-chips">
      <span v-for="org in tissu.organes" :key="org.id" class="organe-chip">
        <span class="material-symbols-outlined" style="font-size: 13px;">biotech</span>
        {{ org.nom }}
      </span>
    </div>

    <!-- Metrics Grid -->
    <div class="metrics-grid">
      <div class="metric-box">
        <div class="metric-header">
          <span class="material-symbols-outlined">biotech</span>
          <span class="metric-label">Organes</span>
        </div>
        <div class="metric-value">
          {{ tissu.organes ? tissu.organes.length : 0 }} <span>lié{{ (tissu.organes?.length || 0) > 1 ? 's' : '' }}</span>
        </div>
        <div class="progress-track">
          <div class="progress-fill" :style="{ width: themeData.barWidth1 }"></div>
        </div>
      </div>
      
      <div class="metric-box">
        <div class="metric-header">
          <span class="material-symbols-outlined">quiz</span>
          <span class="metric-label">QCMs</span>
        </div>
        <div class="metric-value">
          {{ tissu.nombreQuestions }} <span>items</span>
        </div>
        <div class="progress-track">
          <div class="progress-fill" :style="{ width: themeData.barWidth2 }"></div>
        </div>
      </div>
    </div>

    <!-- Actions Area -->
    <div class="card-actions">
      <button class="action-btn action-edit" title="Modifier" @click.stop="emit('edit', tissu)">
        <span class="material-symbols-outlined">edit</span>
      </button>
      <button class="action-btn action-delete" title="Supprimer" @click.stop="emit('delete', tissu)">
        <span class="material-symbols-outlined">delete</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
/* Base Card */
.tissue-card {
  background: var(--md-surface-container-lowest);
  border: 1px solid var(--md-surface-variant);
  border-radius: 16px;
  padding: var(--stack-md);
  display: flex;
  flex-direction: column;
  gap: 20px;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  cursor: pointer;
}

.tissue-card:hover {
  box-shadow: var(--shadow-md);
  border-color: rgba(79, 70, 229, 0.3); /* primary/30 */
}

/* Background Gradient */
.card-gradient {
  position: absolute;
  top: 0;
  right: 0;
  width: 96px;
  height: 96px;
  background: linear-gradient(to bottom left, rgba(79, 70, 229, 0.1), transparent);
  border-bottom-left-radius: 9999px;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.tissue-card:hover .card-gradient {
  opacity: 1;
}

/* Header */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-content {
  display: flex;
  gap: 12px;
  align-items: center;
}

.icon-box {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: var(--md-surface);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--md-surface-variant);
  box-shadow: inset 0 2px 4px 0 rgba(0, 0, 0, 0.05);
}

.theme-icon {
  font-size: 24px;
}

.theme-primary .theme-icon { color: var(--md-primary); }
.theme-secondary .theme-icon { color: var(--md-secondary); }
.theme-tertiary .theme-icon { color: #a44100; /* tertiary-container in stitch */ }

.card-title {
  font-size: 18px;
  font-weight: 600;
  line-height: 1.2;
  color: var(--md-on-surface);
}

.card-subtitle {
  font-size: 11px;
  color: var(--md-secondary);
  margin-top: 2px;
}

/* IA Badge */
.badge-area {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.ia-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: var(--md-surface);
  color: var(--md-on-surface-variant);
  font-size: 11px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 6px;
  border: 1px solid var(--md-surface-variant);
  box-shadow: var(--shadow-sm);
}

.pulse-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
.theme-primary .pulse-dot { background: rgba(53, 37, 205, 0.7); }
.theme-secondary .pulse-dot { background: var(--md-secondary); }
.theme-tertiary .pulse-dot { background: #a44100; }

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: .5; }
}

.ia-code {
  font-family: monospace;
  font-weight: 600;
  color: var(--md-primary);
}

/* Organes Chips */
.organes-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.organe-chip {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: var(--md-surface-container-low, #f1f5f9);
  color: #4F46E5;
  font-size: 11px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: 6px;
  border: 1px solid var(--md-surface-variant);
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Metrics Grid */
.metrics-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 8px;
  border-top: 1px solid var(--md-surface-variant);
  padding-top: 16px;
}

.metric-box {
  background: var(--md-surface);
  padding: 8px;
  border-radius: 8px;
  border: 1px solid rgba(224, 227, 229, 0.5); /* surface-variant/50 */
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--md-secondary);
}
.metric-header .material-symbols-outlined { font-size: 16px; }
.metric-label {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 600;
}

.metric-value {
  font-size: 16px;
  font-weight: 600;
  color: var(--md-on-surface);
}
.metric-value span {
  font-size: 12px;
  font-weight: 400;
  color: var(--md-secondary);
}

.progress-track {
  width: 100%;
  background: var(--md-surface-variant);
  height: 4px;
  border-radius: 9999px;
  margin-top: 4px;
}

.progress-fill {
  height: 4px;
  border-radius: 9999px;
}
.theme-primary .progress-fill { background: rgba(53, 37, 205, 0.4); }
.theme-secondary .progress-fill { background: rgba(80, 95, 118, 0.4); }
.theme-tertiary .progress-fill { background: rgba(164, 65, 0, 0.4); }

/* Actions */
.card-actions {
  margin-top: auto;
  padding-top: 16px;
  border-top: 1px solid var(--md-surface-variant);
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  position: relative;
  z-index: 10;
}

.action-btn {
  padding: 8px;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 8px;
  color: var(--md-secondary);
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn .material-symbols-outlined { font-size: 20px; }

.action-edit:hover {
  color: var(--md-primary);
  background: var(--md-surface-container-low);
  border-color: var(--md-surface-variant);
}

.action-delete:hover {
  color: var(--md-error);
  background: rgba(255, 218, 214, 0.3); /* error-container/30 */
  border-color: rgba(186, 26, 26, 0.2); /* error/20 */
}
</style>

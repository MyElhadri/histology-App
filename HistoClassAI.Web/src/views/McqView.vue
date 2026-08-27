<script setup>
import { ref, onMounted } from 'vue'
import { getTissus, getQuestionsByTissu, createQuestion, deleteQuestion } from '../services/api'
import Sidebar from '../components/layout/Sidebar.vue'

const tissus = ref([])
const selectedTissu = ref('')
const questions = ref([])
const isLoading = ref(false)

const newQuestion = ref({ texte: '', choix: [{ texte: '', estCorrect: true }, { texte: '', estCorrect: false }] })
const isSubmitting = ref(false)
const notification = ref({ type: '', message: '' })

const fetchTissus = async () => {
  try {
    const res = await getTissus()
    tissus.value = res.data
    if (tissus.value.length > 0) {
      selectedTissu.value = tissus.value[0].id
      await fetchQuestions()
    }
  } catch (error) { console.error(error) }
}

const fetchQuestions = async () => {
  if (!selectedTissu.value) return
  isLoading.value = true
  try {
    const res = await getQuestionsByTissu(selectedTissu.value)
    questions.value = res.data
  } catch (error) { console.error(error) } finally { isLoading.value = false }
}

const setCorrectChoice = (idx) => {
  newQuestion.value.choix.forEach((c, i) => {
    c.estCorrect = i === idx
  })
}

const addChoice = () => {
  newQuestion.value.choix.push({ texte: '', estCorrect: false })
}
const removeChoice = (index) => {
  if (newQuestion.value.choix.length > 2) {
    // If we remove the correct choice, set the first one as correct
    const wasCorrect = newQuestion.value.choix[index].estCorrect
    newQuestion.value.choix.splice(index, 1)
    if (wasCorrect) newQuestion.value.choix[0].estCorrect = true
  } else {
    showNotification('error', 'Il faut au moins 2 choix.')
  }
}

const handleAddQuestion = async () => {
  if (!newQuestion.value.texte) return showNotification('error', 'La question est obligatoire.')
  if (newQuestion.value.choix.some(c => !c.texte)) return showNotification('error', 'Tous les choix doivent avoir un texte.')
  
  isSubmitting.value = true
  try {
    await createQuestion({ tissuId: selectedTissu.value, ...newQuestion.value })
    newQuestion.value = { texte: '', choix: [{ texte: '', estCorrect: true }, { texte: '', estCorrect: false }] }
    showNotification('success', 'Question ajoutée avec succès.')
    await fetchQuestions()
  } catch (error) {
    showNotification('error', "Erreur lors de l'ajout.")
  } finally {
    isSubmitting.value = false
  }
}

const handleDelete = async (question) => {
  if (!confirm('Voulez-vous vraiment supprimer cette question ?')) return
  try {
    await deleteQuestion(question.id)
    showNotification('success', 'Question supprimée.')
    await fetchQuestions()
  } catch (error) { showNotification('error', 'Erreur lors de la suppression.') }
}

const showNotification = (type, message) => {
  notification.value = { type, message }
  setTimeout(() => { notification.value = { type: '', message: '' } }, 4000)
}

onMounted(() => fetchTissus())
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
              <span class="material-symbols-outlined header-icon">quiz</span>
              Base de QCM
            </h2>
            <p class="page-subtitle">Gérez les questions à choix multiples pour l'évaluation des étudiants.</p>
          </div>
        </div>

        <div class="mcq-layout">
          <!-- Formulaire Ajout -->
          <div class="form-card">
            <h3>Ajouter un QCM</h3>
            <div class="form-group">
              <label>Tissu cible</label>
              <div class="select-wrapper">
                <select v-model="selectedTissu" @change="fetchQuestions" class="input-field select-field">
                  <option v-for="t in tissus" :key="t.id" :value="t.id">{{ t.nom }}</option>
                </select>
                <span class="material-symbols-outlined select-icon">expand_more</span>
              </div>
            </div>
            
            <div class="form-group">
              <label>Texte de la question</label>
              <textarea v-model="newQuestion.texte" class="input-field" rows="3" placeholder="Quelle est la principale fonction de ce tissu ?"></textarea>
            </div>

            <div class="choices-list">
              <label>Choix (Cochez la bonne réponse)</label>
              <div v-for="(choix, idx) in newQuestion.choix" :key="idx" :class="['choice-item', { 'is-correct-bg': choix.estCorrect }]">
                <button 
                  type="button"
                  :class="['radio-btn', { 'radio-checked': choix.estCorrect }]"
                  @click="setCorrectChoice(idx)"
                  title="Marquer comme bonne réponse"
                >
                  <span class="material-symbols-outlined">{{ choix.estCorrect ? 'check_circle' : 'radio_button_unchecked' }}</span>
                </button>
                <input type="text" v-model="choix.texte" class="input-field choice-input" placeholder="Saisir la réponse..." />
                <button type="button" class="btn-icon" @click="removeChoice(idx)" title="Supprimer le choix" :disabled="newQuestion.choix.length <= 2">
                  <span class="material-symbols-outlined">close</span>
                </button>
              </div>
              <button class="btn-text" @click="addChoice"><span class="material-symbols-outlined">add</span> Ajouter un choix</button>
            </div>

            <button class="btn-primary mt-4" @click="handleAddQuestion" :disabled="isSubmitting">
              <span v-if="isSubmitting" class="spinner-small"></span>
              <span v-else>Créer la question</span>
            </button>
          </div>

          <!-- Liste Questions -->
          <div class="questions-list">
            <div v-if="isLoading" class="empty-state">
              <div class="spinner"></div>
              <p>Chargement des QCM...</p>
            </div>
            <div v-else-if="questions.length === 0" class="empty-state">
              <span class="material-symbols-outlined empty-icon">quiz</span>
              <h3>Aucun QCM</h3>
              <p>Ce tissu n'a pas encore de questions associées.</p>
            </div>
            <div v-else class="question-card" v-for="q in questions" :key="q.id">
              <div class="q-header">
                <h4>{{ q.texte }}</h4>
                <button class="action-btn action-delete" @click="handleDelete(q)" title="Supprimer la question">
                  <span class="material-symbols-outlined">delete</span>
                </button>
              </div>
              <ul class="q-choices">
                <li v-for="c in q.choix" :key="c.id" :class="{'is-correct': c.estCorrect}">
                  <span class="material-symbols-outlined icon-status">{{ c.estCorrect ? 'check_circle' : 'radio_button_unchecked' }}</span>
                  {{ c.texte }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<style scoped>
/* ── Shell & Topbar ───────────────────── */
.app-shell { display: flex; min-height: 100vh; background: var(--md-surface); }
.main-area { flex: 1; margin-left: var(--sidebar-width); display: flex; flex-direction: column; min-height: 100vh; position: relative; }
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

.content-header-card { display: flex; justify-content: space-between; align-items: flex-end; background: var(--md-surface-container-lowest); padding: 24px; border-radius: 16px; border: 1px solid var(--md-surface-variant); box-shadow: var(--shadow-sm); position: relative; overflow: hidden; }
.header-bg-gradient { position: absolute; right: 0; top: 0; width: 256px; height: 100%; background: linear-gradient(to left, rgba(79, 70, 229, 0.05), transparent); pointer-events: none; }
.header-text { position: relative; z-index: 10; }
.page-title { font-size: 24px; font-weight: 600; line-height: 32px; letter-spacing: -0.01em; color: var(--md-on-surface); display: flex; align-items: center; gap: 8px; margin: 0; }
.header-icon { color: var(--md-primary); font-size: 28px; }
.page-subtitle { font-size: 14px; line-height: 20px; color: var(--md-secondary); margin-top: 4px; margin-bottom: 0; max-width: 42rem; }

/* ── Layout ──────────────────────────── */
.mcq-layout { display: grid; grid-template-columns: 1fr 1.5fr; gap: var(--gutter); align-items: start; }
@media(max-width: 900px) { .mcq-layout { grid-template-columns: 1fr; } }

/* ── Formulaire Ajout ────────────────── */
.form-card { background: var(--md-surface-container-lowest); border: 1px solid var(--md-surface-variant); border-radius: 16px; padding: 24px; box-shadow: var(--shadow-sm); display: flex; flex-direction: column; gap: 20px; }
.form-card h3 { font-size: 18px; font-weight: 600; margin: 0; color: var(--md-on-surface); }
.form-group { display: flex; flex-direction: column; gap: 8px; }
.form-group label, .choices-list label { font-size: 14px; font-weight: 600; color: var(--md-on-surface); }

.select-wrapper { position: relative; }
.select-field { appearance: none; padding-right: 40px !important; }
.select-icon { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--md-secondary); pointer-events: none; }

.input-field { width: 100%; padding: 12px 16px; border: 1px solid var(--md-surface-variant); border-radius: 12px; background: var(--md-surface); color: var(--md-on-surface); font-size: 14px; font-family: inherit; transition: all 0.2s; }
.input-field:focus { outline: none; border-color: var(--md-primary); box-shadow: 0 0 0 1px var(--md-primary); }
textarea.input-field { resize: vertical; min-height: 80px; }

/* ── Choix (Custom Radio & Inputs) ───── */
.choices-list { display: flex; flex-direction: column; gap: 12px; }
.choice-item { display: flex; align-items: center; gap: 12px; padding: 8px; border-radius: 12px; border: 1px solid transparent; transition: all 0.2s; }
.choice-item.is-correct-bg { background: rgba(16, 185, 129, 0.05); border-color: rgba(16, 185, 129, 0.2); }

.radio-btn { background: none; border: none; cursor: pointer; color: var(--md-outline); display: flex; padding: 4px; border-radius: 50%; transition: all 0.2s; }
.radio-btn:hover { background: var(--md-surface-variant); color: var(--md-secondary); }
.radio-checked { color: #10b981; }
.radio-checked:hover { background: rgba(16, 185, 129, 0.1); color: #10b981; }

.choice-input { flex: 1; padding: 10px 14px; }
.choice-item.is-correct-bg .choice-input { border-color: #10b981; box-shadow: 0 0 0 1px #10b981; }

.btn-icon { background: none; border: none; color: var(--md-secondary); cursor: pointer; display: flex; padding: 8px; border-radius: 8px; transition: all 0.2s; }
.btn-icon:hover:not(:disabled) { background: rgba(186, 26, 26, 0.1); color: var(--md-error); }
.btn-icon:disabled { opacity: 0.3; cursor: not-allowed; }

.btn-text { background: none; border: none; color: var(--md-primary); font-size: 14px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px; padding: 8px 12px; border-radius: 8px; transition: background 0.2s; align-self: flex-start; }
.btn-text:hover { background: var(--md-primary-fixed); }

.btn-primary { background: var(--md-primary); color: var(--md-on-primary); padding: 12px 20px; border-radius: 12px; border: none; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; min-height: 44px; }
.btn-primary:hover:not(:disabled) { background: var(--md-primary-hover); }
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; }

/* ── Liste Questions ─────────────────── */
.questions-list { display: flex; flex-direction: column; gap: 16px; }
.question-card { background: var(--md-surface-container-lowest); border: 1px solid var(--md-surface-variant); border-radius: 16px; padding: 20px; box-shadow: var(--shadow-sm); transition: transform 0.2s, box-shadow 0.2s; }
.question-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }

.q-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; margin-bottom: 16px; }
.q-header h4 { font-size: 16px; font-weight: 600; line-height: 1.5; color: var(--md-on-surface); margin: 0; }
.action-btn { padding: 8px; background: transparent; border: 1px solid transparent; border-radius: 8px; color: var(--md-secondary); transition: all 0.2s; cursor: pointer; display: flex; }
.action-delete:hover { color: var(--md-error); background: rgba(186, 26, 26, 0.1); border-color: rgba(186, 26, 26, 0.2); }

.q-choices { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px; }
.q-choices li { display: flex; align-items: center; gap: 12px; font-size: 14px; color: var(--md-secondary); padding: 10px 16px; background: var(--md-surface); border-radius: 12px; border: 1px solid var(--md-surface-variant); transition: all 0.2s; }
.q-choices li.is-correct { background: rgba(16, 185, 129, 0.05); border-color: rgba(16, 185, 129, 0.2); color: #065f46; font-weight: 600; }
.icon-status { font-size: 20px; }

/* ── Spinner / Empty ─────────────────── */
.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 64px 24px; text-align: center; gap: 12px; }
.empty-icon { font-size: 48px; color: var(--md-outline-variant); margin-bottom: 8px; }
.empty-state h3 { font-size: 18px; font-weight: 600; color: var(--md-on-surface); margin: 0; }
.empty-state p { font-size: 14px; color: var(--md-secondary); max-width: 360px; margin: 0; }
.spinner { width: 28px; height: 28px; border: 3px solid var(--md-surface-variant); border-top-color: var(--md-primary); border-radius: 50%; animation: spin 0.7s linear infinite; }
.spinner-small { width: 16px; height: 16px; border: 2px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>

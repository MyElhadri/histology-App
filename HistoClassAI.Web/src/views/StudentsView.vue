<script setup>
import { ref, watch, onMounted } from 'vue'
import { 
  getEtudiants, 
  getEtudiantScans, 
  createEtudiant, 
  updateEtudiant, 
  deleteEtudiant, 
  toggleActifEtudiant, 
  resetPasswordEtudiant, 
  importEtudiants 
} from '../services/api'
import Sidebar from '../components/layout/Sidebar.vue'

const students = ref([])
const isLoading = ref(false)

const showPanel = ref(false)
const selectedStudent = ref(null)
const scans = ref([])
const isLoadingScans = ref(false)

// Ajouter un étudiant
const showAddPanel = ref(false)
const newStudent = ref({ nom: '', prenom: '', email: '' })
const isCustomEmail = ref(false)
const isSubmittingStudent = ref(false)

// Modifier un étudiant
const showEditPanel = ref(false)
const editingStudent = ref({ id: '', nom: '', prenom: '', email: '', estActif: true })
const isSubmittingEdit = ref(false)

// Réinitialiser le mot de passe
const showResetModal = ref(false)
const resetTargetStudent = ref(null)
const customResetPassword = ref('')
const sendResetEmail = ref(true)
const isSubmittingReset = ref(false)
const resetResult = ref(null)

// Supprimer un étudiant
const showDeleteModal = ref(false)
const studentToDelete = ref(null)
const isSubmittingDelete = ref(false)

const isImporting = ref(false)
const fileInput = ref(null)
const notification = ref({ type: '', message: '' })

// Modal de confirmation avec identifiants générés
const createdCredentials = ref(null)
const showCredentialsModal = ref(false)

const normalizeString = (str) => {
  if (!str) return ''
  return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]/g, '')
}

const updateAutoEmail = () => {
  if (!isCustomEmail.value) {
    const prenomClean = normalizeString(newStudent.value.prenom)
    const nomClean = normalizeString(newStudent.value.nom)
    if (prenomClean && nomClean) {
      newStudent.value.email = `${prenomClean}.${nomClean}@etu.uae.ac.ma`
    } else if (prenomClean) {
      newStudent.value.email = `${prenomClean}@etu.uae.ac.ma`
    } else if (nomClean) {
      newStudent.value.email = `${nomClean}@etu.uae.ac.ma`
    } else {
      newStudent.value.email = ''
    }
  }
}

watch(() => newStudent.value.prenom, updateAutoEmail)
watch(() => newStudent.value.nom, updateAutoEmail)

const onEmailInput = () => {
  isCustomEmail.value = true
}

const fetchStudents = async () => {
  isLoading.value = true
  try {
    const res = await getEtudiants()
    students.value = res.data
  } catch (error) { console.error(error) } finally { isLoading.value = false }
}

const openStudentScans = async (student) => {
  selectedStudent.value = student
  showPanel.value = true
  isLoadingScans.value = true
  scans.value = []
  try {
    const res = await getEtudiantScans(student.id)
    scans.value = res.data
  } catch (error) { console.error(error) } finally { isLoadingScans.value = false }
}

const closePanel = () => {
  showPanel.value = false
  selectedStudent.value = null
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

const showNotification = (type, message) => {
  notification.value = { type, message }
  setTimeout(() => { notification.value = { type: '', message: '' } }, 5000)
}

const openAddStudent = () => {
  newStudent.value = { nom: '', prenom: '', email: '' }
  isCustomEmail.value = false
  showAddPanel.value = true
}

const handleAddStudent = async () => {
  if (!newStudent.value.nom || !newStudent.value.prenom) {
    showNotification('error', 'Veuillez saisir le nom et le prénom.')
    return
  }

  isSubmittingStudent.value = true
  try {
    const res = await createEtudiant(newStudent.value)
    const data = res.data

    createdCredentials.value = {
      nom: data.nom,
      prenom: data.prenom,
      email: data.email,
      motDePasse: data.motDePasseGenere,
      emailEnvoye: data.emailEnvoye
    }

    if (data.emailEnvoye) {
      showNotification('success', `Compte créé avec succès ! Un email a été envoyé à ${data.email}.`)
    } else {
      showNotification('error', `Compte créé, mais l'envoi de l'email à ${data.email} a échoué. Identifiants affichés ci-dessous.`)
    }

    showAddPanel.value = false
    showCredentialsModal.value = true
    await fetchStudents()
  } catch (error) {
    showNotification('error', error.response?.data || "Erreur lors de l'ajout.")
  } finally {
    isSubmittingStudent.value = false
  }
}

// ── Modifier un étudiant ──────────────────────────────────────
const openEditStudent = (student) => {
  editingStudent.value = {
    id: student.id,
    nom: student.nom,
    prenom: student.prenom,
    email: student.email,
    estActif: student.estActif
  }
  showEditPanel.value = true
}

const handleUpdateStudent = async () => {
  if (!editingStudent.value.nom || !editingStudent.value.prenom || !editingStudent.value.email) {
    showNotification('error', 'Veuillez remplir tous les champs obligatoires.')
    return
  }

  isSubmittingEdit.value = true
  try {
    await updateEtudiant(editingStudent.value.id, editingStudent.value)
    showNotification('success', 'Les informations de l\'étudiant ont été mises à jour.')
    showEditPanel.value = false
    await fetchStudents()
  } catch (error) {
    showNotification('error', error.response?.data || "Erreur lors de la modification.")
  } finally {
    isSubmittingEdit.value = false
  }
}

// ── Basculer le statut Actif / Inactif ──────────────────────
const handleToggleActif = async (student) => {
  try {
    const res = await toggleActifEtudiant(student.id)
    showNotification('success', res.data.message || 'Statut mis à jour.')
    await fetchStudents()
  } catch (error) {
    showNotification('error', error.response?.data || 'Erreur lors du changement de statut.')
  }
}

// ── Réinitialiser le mot de passe ────────────────────────────
const openResetPassword = (student) => {
  resetTargetStudent.value = student
  customResetPassword.value = ''
  sendResetEmail.value = true
  resetResult.value = null
  showResetModal.value = true
}

const handleResetPassword = async () => {
  if (!resetTargetStudent.value) return

  isSubmittingReset.value = true
  try {
    const res = await resetPasswordEtudiant(resetTargetStudent.value.id, {
      nouveauMotDePasse: customResetPassword.value || null,
      envoyerEmail: sendResetEmail.value
    })
    resetResult.value = res.data
    showNotification('success', 'Mot de passe réinitialisé avec succès.')
  } catch (error) {
    showNotification('error', error.response?.data || 'Erreur lors de la réinitialisation.')
  } finally {
    isSubmittingReset.value = false
  }
}

// ── Supprimer un étudiant ────────────────────────────────────
const openDeleteStudent = (student) => {
  studentToDelete.value = student
  showDeleteModal.value = true
}

const handleDeleteStudent = async () => {
  if (!studentToDelete.value) return

  isSubmittingDelete.value = true
  try {
    await deleteEtudiant(studentToDelete.value.id)
    showNotification('success', `L'étudiant ${studentToDelete.value.prenom} ${studentToDelete.value.nom} a été supprimé.`)
    showDeleteModal.value = false
    studentToDelete.value = null
    await fetchStudents()
  } catch (error) {
    showNotification('error', error.response?.data || 'Erreur lors de la suppression.')
  } finally {
    isSubmittingDelete.value = false
  }
}

const copyToClipboard = (text) => {
  navigator.clipboard.writeText(text)
  showNotification('success', 'Identifiants copiés dans le presse-papier !')
}

const triggerFileInput = () => {
  if (fileInput.value) {
    fileInput.value.click()
  }
}

const handleFileUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  isImporting.value = true
  try {
    const res = await importEtudiants(file)
    showNotification('success', res.data.message || "Importation réussie.")
    await fetchStudents()
  } catch (error) {
    showNotification('error', error.response?.data || "Erreur lors de l'importation.")
  } finally {
    isImporting.value = false
    if (fileInput.value) fileInput.value.value = ''
  }
}

onMounted(() => fetchStudents())
</script>

<template>
  <div class="app-shell">
    <Sidebar />

    <div class="main-area">
      <header class="topbar">
        <div></div>
        <div class="topbar-actions">
          <div class="avatar">P</div>
        </div>
      </header>

      <main class="page-content">
        <!-- ── Toast ────────────────────────── -->
        <Transition name="toast">
          <div v-if="notification.message" :class="['toast', `toast--${notification.type}`]">
            <span class="material-symbols-outlined toast-icon">{{ notification.type === 'success' ? 'check_circle' : 'error' }}</span>
            {{ notification.message }}
          </div>
        </Transition>

        <!-- Header -->
        <div class="content-header-card">
          <div class="header-bg-gradient"></div>
          <div class="header-text">
            <h2 class="page-title">
              <span class="material-symbols-outlined header-icon">group</span>
              Étudiants
            </h2>
            <p class="page-subtitle">Consultez la liste des étudiants et suivez leur progression et leur historique d'analyse de lames.</p>
          </div>
          <div class="header-actions">
            <button class="btn-import-csv" @click="triggerFileInput" :disabled="isImporting" title="Importer une liste d'étudiants (Format: Nom,Prenom,Email ou Nom,Prenom)">
              <span v-if="!isImporting" class="material-symbols-outlined" style="font-size:20px">upload_file</span>
              <span v-else class="spinner-small"></span>
              Importer CSV
            </button>
            <input type="file" ref="fileInput" @change="handleFileUpload" accept=".csv" style="display: none" />

            <button class="btn-add" @click="openAddStudent">
              <span class="material-symbols-outlined" style="font-size:20px">person_add</span>
              Ajouter un Étudiant
            </button>
          </div>
        </div>

        <!-- Table -->
        <div class="table-card">
          <div v-if="isLoading" class="spinner mx-auto my-8"></div>
          <table v-else class="students-table">
            <thead>
              <tr>
                <th>Nom Complet</th>
                <th>Email</th>
                <th>Statut</th>
                <th>Date d'inscription</th>
                <th style="text-align: right;">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="students.length === 0">
                <td colspan="5" class="text-center py-8 text-secondary">Aucun étudiant inscrit.</td>
              </tr>
              <tr v-for="s in students" :key="s.id" :class="{ 'row-disabled': !s.estActif }">
                <td>
                  <div class="student-name">
                    <div class="s-avatar" :class="{ 'avatar-disabled': !s.estActif }">{{ s.prenom.charAt(0) }}{{ s.nom.charAt(0) }}</div>
                    <span>{{ s.prenom }} {{ s.nom }}</span>
                  </div>
                </td>
                <td>{{ s.email }}</td>
                <td>
                  <span :class="['badge-status', s.estActif ? 'badge-active' : 'badge-inactive']">
                    <span class="status-dot"></span>
                    {{ s.estActif ? 'Actif' : 'Désactivé' }}
                  </span>
                </td>
                <td>{{ formatDate(s.dateCreation) }}</td>
                <td style="text-align: right;">
                  <div class="action-buttons">
                    <button class="btn-icon" @click.stop="openStudentScans(s)" title="Historique de scans">
                      <span class="material-symbols-outlined">history</span>
                    </button>
                    <button class="btn-icon" @click.stop="openEditStudent(s)" title="Modifier les informations">
                      <span class="material-symbols-outlined">edit</span>
                    </button>
                    <button class="btn-icon" :class="{ 'text-warning': s.estActif, 'text-success': !s.estActif }" @click.stop="handleToggleActif(s)" :title="s.estActif ? 'Désactiver le compte' : 'Activer le compte'">
                      <span class="material-symbols-outlined">{{ s.estActif ? 'block' : 'check_circle' }}</span>
                    </button>
                    <button class="btn-icon" @click.stop="openResetPassword(s)" title="Réinitialiser le mot de passe">
                      <span class="material-symbols-outlined">key</span>
                    </button>
                    <button class="btn-icon text-danger" @click.stop="openDeleteStudent(s)" title="Supprimer l'étudiant">
                      <span class="material-symbols-outlined">delete</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </main>
    </div>

    <!-- Slide-over : Scans -->
    <div :class="['slide-over', { 'slide-over--open': showPanel }]">
      <div class="slide-over-backdrop" @click="closePanel"></div>
      <div class="slide-over-panel">
        <div class="panel-header">
          <h2 class="panel-title">Historique de Scans</h2>
          <p class="panel-subtitle" v-if="selectedStudent">{{ selectedStudent.prenom }} {{ selectedStudent.nom }}</p>
          <button type="button" class="btn-close" @click="closePanel">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>

        <div class="panel-body">
          <div v-if="isLoadingScans" class="spinner mx-auto my-8"></div>
          <div v-else-if="scans.length === 0" class="empty-state">
            <span class="material-symbols-outlined" style="font-size: 32px; color: var(--md-outline-variant);">history</span>
            <p>Cet étudiant n'a effectué aucun scan.</p>
          </div>
          <div v-else class="scans-list">
            <div class="scan-card" v-for="scan in scans" :key="scan.id">
              <div class="scan-info">
                <h4>{{ scan.tissuNom }}</h4>
                <span class="scan-date">{{ formatDate(scan.dateScan) }}</span>
              </div>
              <div class="scan-score" :class="{ 'high-score': scan.scoreConfiance > 0.8, 'low-score': scan.scoreConfiance < 0.5 }">
                {{ Math.round(scan.scoreConfiance * 100) }}% certitude
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Slide-over : Ajouter un étudiant -->
    <div :class="['slide-over', { 'slide-over--open': showAddPanel }]">
      <div class="slide-over-backdrop" @click="showAddPanel = false"></div>
      <div class="slide-over-panel">
        <div class="panel-header">
          <h2 class="panel-title">Ajouter un Étudiant</h2>
          <p class="panel-subtitle">Saisissez les informations. Un mot de passe sera généré et envoyé à l'adresse email réelle de l'étudiant.</p>
          <button type="button" class="btn-close" @click="showAddPanel = false" :disabled="isSubmittingStudent">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>

        <div class="panel-body">
          <div class="info-alert">
            <span class="material-symbols-outlined">info</span>
            <p>Format CSV pris en charge : <strong>Nom,Prenom,Email</strong> ou <strong>Nom,Prenom</strong></p>
          </div>
          <div class="form-group mt-3">
            <label>Prénom *</label>
            <input type="text" v-model="newStudent.prenom" class="input-field" placeholder="Ex: Mohamed Yassine" />
          </div>
          <div class="form-group mt-3">
            <label>Nom *</label>
            <input type="text" v-model="newStudent.nom" class="input-field" placeholder="Ex: El Hadri" />
          </div>
          <div class="form-group mt-3">
            <label>Email (Réel) *</label>
            <input type="email" v-model="newStudent.email" @input="onEmailInput" class="input-field" placeholder="Ex: elhadri.mohamedyassine@etu.uae.ac.ma" />
            <small style="color: var(--md-secondary); font-size: 11px; margin-top: 2px;">Vous pouvez saisir n'importe quelle adresse email réelle pour recevoir le mot de passe de test.</small>
          </div>
          
          <button class="btn-primary mt-4 w-full" @click="handleAddStudent" :disabled="isSubmittingStudent">
            <span v-if="!isSubmittingStudent">Créer et Envoyer l'Email Réel</span>
            <span v-else class="spinner-small"></span>
          </button>
        </div>
      </div>
    </div>

    <!-- Slide-over : Modifier un étudiant -->
    <div :class="['slide-over', { 'slide-over--open': showEditPanel }]">
      <div class="slide-over-backdrop" @click="showEditPanel = false"></div>
      <div class="slide-over-panel">
        <div class="panel-header">
          <h2 class="panel-title">Modifier l'Étudiant</h2>
          <p class="panel-subtitle">Mettre à jour le profil de l'étudiant.</p>
          <button type="button" class="btn-close" @click="showEditPanel = false" :disabled="isSubmittingEdit">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>

        <div class="panel-body">
          <div class="form-group">
            <label>Prénom *</label>
            <input type="text" v-model="editingStudent.prenom" class="input-field" />
          </div>
          <div class="form-group mt-3">
            <label>Nom *</label>
            <input type="text" v-model="editingStudent.nom" class="input-field" />
          </div>
          <div class="form-group mt-3">
            <label>Email *</label>
            <input type="email" v-model="editingStudent.email" class="input-field" />
          </div>
          <div class="form-group mt-3" style="flex-direction: row; align-items: center; justify-content: space-between; background: var(--md-surface); padding: 12px; border-radius: 8px; border: 1px solid var(--md-surface-variant);">
            <label style="cursor: pointer;" for="checkbox-actif">Compte Actif</label>
            <input id="checkbox-actif" type="checkbox" v-model="editingStudent.estActif" style="width: 20px; height: 20px; accent-color: var(--md-primary); cursor: pointer;" />
          </div>
          
          <button class="btn-primary mt-4 w-full" @click="handleUpdateStudent" :disabled="isSubmittingEdit">
            <span v-if="!isSubmittingEdit">Enregistrer les Modifications</span>
            <span v-else class="spinner-small"></span>
          </button>
        </div>
      </div>
    </div>

    <!-- Modal : Réinitialiser le mot de passe -->
    <div v-if="showResetModal" class="credentials-modal-backdrop">
      <div class="credentials-modal">
        <div class="cred-header">
          <span class="material-symbols-outlined cred-icon" style="color: #4f46e5;">key</span>
          <h3>Réinitialiser le mot de passe</h3>
        </div>

        <div v-if="!resetResult">
          <p class="cred-desc">
            Réinitialisez le mot de passe de l'étudiant <strong>{{ resetTargetStudent?.prenom }} {{ resetTargetStudent?.nom }}</strong>.
          </p>
          <div class="form-group mt-3">
            <label>Nouveau mot de passe (optionnel)</label>
            <input type="text" v-model="customResetPassword" class="input-field" placeholder="Laisser vide pour générer automatiquement" />
          </div>
          <div class="form-group mt-3" style="flex-direction: row; align-items: center; gap: 8px;">
            <input id="chk-email" type="checkbox" v-model="sendResetEmail" style="width: 18px; height: 18px; accent-color: var(--md-primary);" />
            <label for="chk-email" style="font-size: 13px; font-weight: normal; cursor: pointer;">Envoyer le nouveau mot de passe par email réel à l'étudiant</label>
          </div>

          <div class="cred-actions mt-4">
            <button class="btn-primary" @click="handleResetPassword" :disabled="isSubmittingReset">
              <span v-if="!isSubmittingReset">Réinitialiser</span>
              <span v-else class="spinner-small"></span>
            </button>
            <button class="btn-secondary" @click="showResetModal = false" :disabled="isSubmittingReset">
              Annuler
            </button>
          </div>
        </div>

        <div v-else>
          <p class="cred-desc" v-if="resetResult.emailEnvoye">
            Le mot de passe a été mis à jour et envoyé par email à <strong>{{ resetResult.email }}</strong>.
          </p>
          <p class="cred-desc text-danger" v-else>
            Le mot de passe a été mis à jour, mais l'envoi de l'email a échoué. Voici le nouveau mot de passe :
          </p>

          <div class="cred-box mt-3">
            <div class="cred-line">
              <span class="cred-label">Email :</span>
              <span class="cred-val highlight">{{ resetResult.email }}</span>
            </div>
            <div class="cred-line">
              <span class="cred-label">Nouveau mot de passe :</span>
              <span class="cred-val pwd">{{ resetResult.nouveauMotDePasse }}</span>
            </div>
          </div>

          <div class="cred-actions mt-4">
            <button class="btn-primary" @click="copyToClipboard(`Email: ${resetResult.email}\nMot de passe: ${resetResult.nouveauMotDePasse}`)">
              <span class="material-symbols-outlined" style="font-size:18px">content_copy</span>
              Copier
            </button>
            <button class="btn-secondary" @click="showResetModal = false">
              Fermer
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal : Confirmer la suppression -->
    <div v-if="showDeleteModal" class="credentials-modal-backdrop">
      <div class="credentials-modal">
        <div class="cred-header">
          <span class="material-symbols-outlined cred-icon" style="color: #ef4444;">delete_forever</span>
          <h3>Confirmer la suppression</h3>
        </div>
        <p class="cred-desc">
          Êtes-vous sûr de vouloir supprimer définitivement l'étudiant <strong>{{ studentToDelete?.prenom }} {{ studentToDelete?.nom }}</strong> (`{{ studentToDelete?.email }}`) ?
        </p>
        <p style="font-size: 12px; color: #ef4444; margin: 0;">
          Cette action est irréversible et supprimera également son historique de scans.
        </p>
        <div class="cred-actions mt-4">
          <button class="btn-danger" @click="handleDeleteStudent" :disabled="isSubmittingDelete">
            <span v-if="!isSubmittingDelete">Supprimer Définitivement</span>
            <span v-else class="spinner-small"></span>
          </button>
          <button class="btn-secondary" @click="showDeleteModal = false" :disabled="isSubmittingDelete">
            Annuler
          </button>
        </div>
      </div>
    </div>

    <!-- Modal : Affichage des identifiants créés -->
    <div v-if="showCredentialsModal" class="credentials-modal-backdrop">
      <div class="credentials-modal">
        <div class="cred-header">
          <span class="material-symbols-outlined cred-icon" :style="{ color: createdCredentials?.emailEnvoye ? '#10b981' : '#ef4444' }">
            {{ createdCredentials?.emailEnvoye ? 'mark_email_read' : 'warning' }}
          </span>
          <h3>Compte Étudiant Créé !</h3>
        </div>
        <p class="cred-desc" v-if="createdCredentials?.emailEnvoye">
          Un email réel contenant les identifiants a été transmis à <strong>{{ createdCredentials.email }}</strong>.
        </p>
        <p class="cred-desc text-danger" v-else>
          Le compte a été créé, mais l'envoi de l'email a rencontré un problème. Voici les identifiants de connexion :
        </p>

        <div class="cred-box">
          <div class="cred-line">
            <span class="cred-label">Nom complet :</span>
            <span class="cred-val">{{ createdCredentials?.prenom }} {{ createdCredentials?.nom }}</span>
          </div>
          <div class="cred-line">
            <span class="cred-label">Email de connexion :</span>
            <span class="cred-val highlight">{{ createdCredentials?.email }}</span>
          </div>
          <div class="cred-line">
            <span class="cred-label">Mot de passe mobile :</span>
            <span class="cred-val pwd">{{ createdCredentials?.motDePasse }}</span>
          </div>
        </div>

        <div class="cred-actions">
          <button class="btn-primary" @click="copyToClipboard(`Email: ${createdCredentials?.email}\nMot de passe: ${createdCredentials?.motDePasse}`)">
            <span class="material-symbols-outlined" style="font-size:18px">content_copy</span>
            Copier les Identifiants
          </button>
          <button class="btn-secondary" @click="showCredentialsModal = false">
            Fermer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.app-shell { display: flex; min-height: 100vh; background: var(--md-surface); }
.main-area { flex: 1; margin-left: var(--sidebar-width); display: flex; flex-direction: column; min-height: 100vh; position: relative; }
.topbar { position: fixed; top: 0; right: 0; width: calc(100% - var(--sidebar-width)); height: var(--topbar-height); background: var(--md-surface); border-bottom: 1px solid var(--md-surface-variant); display: flex; justify-content: space-between; align-items: center; padding: 0 var(--gutter); z-index: 10; }
.topbar-actions { display: flex; align-items: center; gap: 16px; }
.avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--md-secondary-container); color: var(--md-primary); font-weight: 700; font-size: 13px; display: flex; align-items: center; justify-content: center; border: 1px solid var(--md-surface-variant); }
.page-content { flex: 1; padding-top: calc(var(--topbar-height) + var(--gutter)); padding-left: var(--container-pad); padding-right: var(--container-pad); padding-bottom: var(--container-pad); display: flex; flex-direction: column; gap: var(--stack-lg); }

.content-header-card { display: flex; justify-content: space-between; align-items: flex-end; background: var(--md-surface-container-lowest); padding: 24px; border-radius: 16px; border: 1px solid var(--md-surface-variant); box-shadow: var(--shadow-sm); position: relative; overflow: hidden; }
.header-bg-gradient { position: absolute; right: 0; top: 0; width: 256px; height: 100%; background: linear-gradient(to left, rgba(79, 70, 229, 0.05), transparent); pointer-events: none; }
.header-text { position: relative; z-index: 10; }
.page-title { font-size: 24px; font-weight: 600; line-height: 32px; letter-spacing: -0.01em; color: var(--md-on-surface); display: flex; align-items: center; gap: 8px; }
.header-icon { color: var(--md-primary); font-size: 28px; }
.page-subtitle { font-size: 14px; line-height: 20px; color: var(--md-secondary); margin-top: 4px; max-width: 42rem; }
.header-actions { display: flex; gap: 12px; align-items: center; z-index: 10; position: relative; }

.btn-import-csv { display: flex; align-items: center; gap: 8px; background: #10b981; color: #fff; border: none; border-radius: var(--radius-lg); padding: 8px 16px; font-size: 14px; font-weight: 600; line-height: 20px; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2); transition: var(--transition); cursor: pointer; }
.btn-import-csv:hover:not(:disabled) { background: #059669; transform: translateY(-1px); box-shadow: 0 6px 8px -1px rgba(16, 185, 129, 0.3); }
.btn-import-csv:disabled { opacity: 0.7; cursor: not-allowed; }

.btn-add { display: flex; align-items: center; gap: 8px; background: var(--md-primary); color: var(--md-on-primary); border: none; border-radius: var(--radius-lg); padding: 8px 16px; font-size: 14px; font-weight: 500; line-height: 20px; box-shadow: var(--shadow-sm); transition: var(--transition); white-space: nowrap; cursor: pointer; position: relative; z-index: 10; }
.btn-add:hover { background: var(--md-primary-hover); transform: translateY(-1px); box-shadow: var(--shadow-md); }

.info-alert { background: rgba(79, 70, 229, 0.1); border: 1px solid rgba(79, 70, 229, 0.2); border-radius: 8px; padding: 12px; display: flex; gap: 12px; align-items: flex-start; color: var(--md-primary); font-size: 13px; line-height: 1.5; }
.info-alert .material-symbols-outlined { font-size: 20px; }
.info-alert p { margin: 0; }

/* ── Toast ───────────────────────────── */
.toast { position: fixed; top: 80px; right: var(--gutter); display: flex; align-items: center; gap: 8px; padding: 12px 20px; border-radius: 12px; font-size: 14px; font-weight: 500; box-shadow: var(--shadow-lg); z-index: 2000; }
.toast--success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
.toast--error { background: var(--md-error-container); color: #93000a; border: 1px solid #fecaca; }
.toast-icon { font-size: 20px; }
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from { opacity: 0; transform: translateY(-12px); }
.toast-leave-to { opacity: 0; transform: translateX(12px); }

.table-card { background: var(--md-surface-container-lowest); border: 1px solid var(--md-surface-variant); border-radius: 16px; box-shadow: var(--shadow-sm); overflow: hidden; }
.students-table { width: 100%; border-collapse: collapse; }
.students-table th, .students-table td { padding: 16px; text-align: left; border-bottom: 1px solid var(--md-surface-variant); }
.students-table th { background: rgba(0,0,0,0.02); font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--md-secondary); }
.students-table tbody tr { transition: background 0.2s; }
.students-table tbody tr:hover { background: var(--md-surface-container-low); }
.students-table tbody tr.row-disabled { opacity: 0.65; background: rgba(0,0,0,0.02); }
.students-table tbody tr:last-child td { border-bottom: none; }

.student-name { display: flex; align-items: center; gap: 12px; font-weight: 600; color: var(--md-on-surface); }
.s-avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--md-primary-fixed); color: var(--md-on-primary-fixed); display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; text-transform: uppercase; }
.s-avatar.avatar-disabled { background: #cbd5e1; color: #64748b; }

/* Badges Status */
.badge-status { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }
.badge-active { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
.badge-inactive { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
.status-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }

/* Action Buttons */
.action-buttons { display: flex; items: center; justify-content: flex-end; gap: 6px; }
.btn-icon { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--md-surface-variant); background: var(--md-surface); color: var(--md-secondary); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s; }
.btn-icon:hover { background: var(--md-surface-container-low); color: var(--md-primary); border-color: var(--md-primary); }
.btn-icon .material-symbols-outlined { font-size: 18px; }
.btn-icon.text-danger:hover { color: #dc2626; border-color: #dc2626; background: #fef2f2; }
.btn-icon.text-warning:hover { color: #d97706; border-color: #d97706; background: #fffbeb; }
.btn-icon.text-success:hover { color: #10b981; border-color: #10b981; background: #ecfdf5; }

/* Slide-over */
.slide-over { position: fixed; inset: 0; z-index: 100; pointer-events: none; }
.slide-over--open { pointer-events: auto; }
.slide-over-backdrop { position: absolute; inset: 0; background: rgba(0, 0, 0, 0.2); opacity: 0; transition: opacity 0.3s ease; }
.slide-over--open .slide-over-backdrop { opacity: 1; }

.slide-over-panel { position: absolute; top: 0; right: 0; height: 100vh; width: 400px; max-width: 100vw; background: var(--md-surface-container-lowest); box-shadow: var(--shadow-xl); transform: translateX(100%); transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1); display: flex; flex-direction: column; }
.slide-over--open .slide-over-panel { transform: translateX(0); }

.panel-header { padding: 24px; border-bottom: 1px solid var(--md-surface-variant); position: relative; }
.panel-title { font-size: 20px; font-weight: 600; color: var(--md-on-surface); margin: 0; }
.panel-subtitle { font-size: 14px; color: var(--md-secondary); margin-top: 4px; }
.btn-close { position: absolute; top: 24px; right: 24px; width: 32px; height: 32px; border-radius: 50%; border: none; background: transparent; color: var(--md-secondary); display: flex; align-items: center; justify-content: center; cursor: pointer; transition: background 0.2s; }
.btn-close:hover { background: var(--md-surface-variant); }

.panel-body { flex: 1; padding: 24px; overflow-y: auto; display: flex; flex-direction: column; gap: 16px; }

.scans-list { display: flex; flex-direction: column; gap: 12px; }
.scan-card { background: var(--md-surface); border: 1px solid var(--md-surface-variant); border-radius: 8px; padding: 12px 16px; display: flex; justify-content: space-between; align-items: center; }
.scan-info h4 { font-size: 14px; font-weight: 600; color: var(--md-on-surface); margin: 0; }
.scan-date { font-size: 12px; color: var(--md-secondary); }
.scan-score { font-size: 12px; font-weight: 600; padding: 4px 8px; border-radius: 12px; background: rgba(0,0,0,0.05); color: var(--md-secondary); }
.scan-score.high-score { background: rgba(6,95,70,0.1); color: #065f46; }
.scan-score.low-score { background: rgba(186,26,26,0.1); color: #ba1a1a; }

.empty-state { display: flex; flex-direction: column; align-items: center; gap: 8px; color: var(--md-secondary); margin-top: 32px; text-align: center; }

/* Form styles for Slide-over */
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 14px; font-weight: 600; color: var(--md-on-surface); }
.input-field { width: 100%; padding: 10px 12px; border: 1px solid var(--md-surface-variant); border-radius: 8px; background: var(--md-surface); color: var(--md-on-surface); font-size: 14px; font-family: inherit; transition: border-color 0.2s; }
.input-field:focus { outline: none; border-color: var(--md-primary); }
.btn-primary { background: var(--md-primary); color: var(--md-on-primary); padding: 10px 16px; border-radius: 8px; border: none; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; justify-content: center; align-items: center; gap: 8px; }
.btn-primary:hover:not(:disabled) { background: var(--md-primary-hover); }
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; }

.btn-danger { background: #dc2626; color: #fff; padding: 10px 16px; border-radius: 8px; border: none; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; justify-content: center; align-items: center; gap: 8px; }
.btn-danger:hover:not(:disabled) { background: #b91c1c; }
.btn-danger:disabled { opacity: 0.7; cursor: not-allowed; }

.w-full { width: 100%; }
.mt-3 { margin-top: 12px; }
.mt-4 { margin-top: 16px; }
.spinner-small { width: 20px; height: 20px; border: 2px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.7s linear infinite; }
.spinner-dark { border: 2px solid rgba(0,0,0,0.1); border-top-color: var(--md-primary); }

.text-center { text-align: center; }
.py-8 { padding-top: 32px; padding-bottom: 32px; }
.my-8 { margin-top: 32px; margin-bottom: 32px; }
.mx-auto { margin-left: auto; margin-right: auto; }
.spinner { width: 28px; height: 28px; border: 3px solid var(--md-surface-variant); border-top-color: var(--md-primary); border-radius: 50%; animation: spin 0.7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

/* Credentials Modal */
.credentials-modal-backdrop { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 3000; padding: 16px; }
.credentials-modal { background: var(--md-surface-container-lowest); border-radius: 16px; border: 1px solid var(--md-surface-variant); box-shadow: var(--shadow-xl); padding: 24px; max-width: 480px; width: 100%; display: flex; flex-direction: column; gap: 16px; animation: modalIn 0.3s cubic-bezier(0.16, 1, 0.3, 1); }
@keyframes modalIn { from { opacity: 0; transform: scale(0.95); } to { opacity: 1; transform: scale(1); } }

.cred-header { display: flex; align-items: center; gap: 12px; }
.cred-icon { font-size: 32px; }
.cred-header h3 { font-size: 18px; font-weight: 700; color: var(--md-on-surface); margin: 0; }

.cred-desc { font-size: 14px; color: var(--md-secondary); line-height: 1.5; margin: 0; }
.cred-desc.text-danger { color: #dc2626; }

.cred-box { background: var(--md-surface); border: 1px solid var(--md-surface-variant); border-radius: 12px; padding: 16px; display: flex; flex-direction: column; gap: 10px; }
.cred-line { display: flex; justify-content: space-between; align-items: center; font-size: 13px; }
.cred-label { color: var(--md-secondary); font-weight: 500; }
.cred-val { font-weight: 600; color: var(--md-on-surface); }
.cred-val.highlight { color: var(--md-primary); font-family: monospace; font-size: 14px; }
.cred-val.pwd { color: #4f46e5; font-family: monospace; font-size: 15px; background: rgba(79, 70, 229, 0.1); padding: 2px 8px; border-radius: 6px; letter-spacing: 1px; }

.cred-actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; }
.btn-secondary { background: var(--md-surface-variant); color: var(--md-on-surface-variant); padding: 10px 16px; border-radius: 8px; border: none; font-weight: 600; cursor: pointer; transition: all 0.2s; }
.btn-secondary:hover { background: #e2e8f0; }
</style>

# HistoClassAI 🔬🤖

HistoClassAI est une plateforme complète (Web & Mobile) propulsée par l'Intelligence Artificielle, conçue pour l'apprentissage et la classification de tissus histologiques. Le système intègre un modèle de Deep Learning (TensorFlow/Keras) capable de reconnaître 9 classes de tissus et de proposer un parcours pédagogique dynamique avec des quiz (QCM) adaptés à l'étudiant.

## 🌟 Fonctionnalités Principales

- **Classification par IA** : Analyse d'images histologiques via un service IA (TensorFlow/Keras) pour identifier 9 classes spécifiques de tissus.
- **Portail Professeur (Web - Vue.js / .NET 8)** :
  - Dashboard interactif.
  - Gestion de la base de données de tissus, des organes et des quiz.
  - Outil d'importation massive des étudiants (Excel/CSV) avec génération automatique des identifiants et emails.
- **Application Étudiant (Mobile - Flutter)** :
  - Scanner intégré pour capturer et uploader des images de tissus.
  - Feedback immédiat de l'IA (nom du tissu, taux de confiance).
  - Lancement automatique de QCMs pédagogiques post-analyse pour valider les acquis.
- **Architecture Modulaire et Conteneurisée** : Orchestrée via Docker-Compose.

## 🏗️ Architecture du Projet

Le projet est divisé en plusieurs composants indépendants :

- `/HistoClassAI.IaService` : Microservice Python (FastAPI + TensorFlow) responsable de l'inférence IA.
- `/HistoClassAI.Api` : Backend principal en C# (.NET 8) gérant la logique métier, la base de données, et l'authentification.
- `/HistoClassAI.Web` : Frontend Web en Vue.js / Vuetify pour le portail d'administration (Professeurs).
- `/histoclassai_mobile` : Application Mobile en Flutter pour les étudiants.
- **Base de données & Stockage** : PostgreSQL (données) et MinIO (stockage S3 des images).

## 🚀 Démarrage Rapide (Développement Local)

### Prérequis
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)
- [Node.js](https://nodejs.org/) (pour le portail web)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (pour l'application mobile)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (optionnel, si exécution hors Docker)

### Lancement avec Docker
Le moyen le plus simple de démarrer l'ensemble de l'infrastructure backend (API, Base de données, Stockage S3, Service IA) est d'utiliser Docker Compose :

```bash
docker-compose up --build -d
```

### Initialisation de la base de données
Un script d'initialisation (Seed) est disponible pour peupler la base de données avec le mapping des 9 classes d'IA et les questions QCM de base :

```bash
# S'assurer d'autoriser l'exécution de scripts PowerShell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\seed_data.ps1
```

## 🧠 Modèle d'IA et Mapping des Tissus

L'application supporte la classification des 9 classes histologiques suivantes :

| Code IA | Description |
| :--- | :--- |
| **ADI** | Tissu adipeux |
| **BACK** | Fond de lame / hors tissu (0 question) |
| **DEB** | Débris cellulaires (0 question) |
| **LYM** | Lymphocytes |
| **MUC** | Mucus |
| **MUS** | Muscle lisse |
| **NORM**| Muqueuse colique normale |
| **STR** | Stroma associé au cancer |
| **TUM** | Épithélium d'adénocarcinome colorectal |

*Note: Le système gère dynamiquement l'absence de QCM pour les classes `BACK` et `DEB`.*

## 🔒 Authentification
Le backend utilise des jetons JWT pour sécuriser l'accès aux endpoints.
Les identifiants par défaut pour le portail Professeur sont configurés lors du lancement de l'application via les migrations Entity Framework.

## 🛠️ Stack Technique

- **Backend** : C# .NET 8 (ASP.NET Core Web API), Entity Framework Core
- **Intelligence Artificielle** : Python 3.10, FastAPI, TensorFlow / Keras, NumPy, Pillow
- **Frontend (Web)** : Vue 3, Vite, Vuetify 3
- **Mobile** : Flutter, Dart
- **Base de données** : PostgreSQL 15
- **Stockage de fichiers** : MinIO (Compatible Amazon S3)

---
*Projet développé dans le cadre d'un stage de fin d'études.*

# ── Étape 1 : Image de base légère ────────────────────────────────────
FROM python:3.10-slim

# ── Étape 2 : Répertoire de travail ──────────────────────────────────
WORKDIR /app

# ── Étape 3 : Installation des dépendances système (pour Pillow) ─────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ── Étape 4 : Copie et installation des dépendances Python ──────────
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Étape 5 : Copie du code source et du modèle ─────────────────────
COPY . .

# ── Étape 6 : Exposition du port et lancement ───────────────────────
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

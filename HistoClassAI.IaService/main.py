import io
from contextlib import asynccontextmanager
import os
os.environ["TF_USE_LEGACY_KERAS"] = "1"

import numpy as np
import tensorflow as tf
from fastapi import FastAPI, File, UploadFile, HTTPException
from PIL import Image

# ── Variables globales ────────────────────────────────────────────────
model = None

# ── Mapping des classes (à adapter selon le modèle de votre binôme) ──
CLASS_NAMES = [
    "classe_00",
    "classe_01",
    "classe_02",
    "classe_03",
    "classe_04",
    "classe_05",
    "classe_06",
    "classe_07",
]

# ── Patch Keras 3 ──────────────────────────────────────────────────────
# Fix pour l'erreur "Unrecognized keyword arguments passed to Dense: {'quantization_config': None}"
class SafeDense(tf.keras.layers.Dense):
    def __init__(self, *args, **kwargs):
        kwargs.pop("quantization_config", None)
        super().__init__(*args, **kwargs)

# ── Lifespan : chargement du modèle au démarrage ─────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    global model

    model_path = "model.keras"
    if os.path.exists(model_path):
        try:
            model = tf.keras.models.load_model(
                model_path, 
                custom_objects={'Dense': SafeDense}
            )
            print("✅ Modèle chargé avec succès.")
            
            # Afficher quelques infos utiles au démarrage
            if hasattr(model, 'input_shape'):
                print(f"ℹ️  Input shape attendue : {model.input_shape}")
        except Exception as e:
            print(f"❌ Erreur lors du chargement du modèle : {e}")
            model = None
    else:
        print(f"⚠️  Fichier {model_path} introuvable. Le service démarre sans modèle.")
        model = None

    yield  # L'application tourne

    # Nettoyage
    del model
    print("🧹 Modèle déchargé.")


# ── Application FastAPI ──────────────────────────────────────────────
app = FastAPI(
    title="HistoClassAI - Service IA",
    description="Microservice de classification de tissus histologiques (TensorFlow/Keras).",
    version="1.0.0",
    lifespan=lifespan,
)


@app.get("/health")
async def health():
    """Vérifie que le service IA est opérationnel."""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "backend": "tensorflow",
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Reçoit une image histologique et retourne la prédiction du modèle.
    """
    if model is None:
        raise HTTPException(
            status_code=503,
            detail="Le modèle IA n'est pas chargé. Vérifiez que model.keras est présent.",
        )

    # ── Validation du type de fichier ─────────────────────────────────
    if file.content_type not in ["image/png", "image/jpeg", "image/tiff"]:
        raise HTTPException(
            status_code=400,
            detail=f"Type de fichier non supporté : {file.content_type}. "
                   f"Formats acceptés : PNG, JPEG, TIFF.",
        )

    try:
        # ── Lecture et prétraitement de l'image ───────────────────────
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Redimensionnement standard (à adapter si nécessaire)
        target_size = (224, 224) 
        if hasattr(model, 'input_shape') and len(model.input_shape) >= 3 and model.input_shape[1] is not None:
            target_size = (model.input_shape[1], model.input_shape[2])
            
        image = image.resize(target_size)
        
        # Conversion en array et normalisation [0, 1]
        img_array = tf.keras.preprocessing.image.img_to_array(image)
        img_array = img_array / 255.0
        
        # Ajout de la dimension batch : (1, height, width, channels)
        img_array = tf.expand_dims(img_array, 0)

        # ── Inférence ─────────────────────────────────────────────────
        predictions = model.predict(img_array)
        
        # predictions contient les probabilités (softmax généralement)
        predicted_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_idx])

        # Gestion du label (fallback si plus de classes que prévu)
        if predicted_idx < len(CLASS_NAMES):
            code_label = CLASS_NAMES[predicted_idx]
        else:
            code_label = f"classe_{predicted_idx:02d}"

        return {
            "code_label_ia": code_label,
            "confiance": round(confidence, 4),
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de l'inférence : {str(e)}",
        )

import io
from contextlib import asynccontextmanager
import os

# ── Patch Keras 3 pour compatibilité de sérialisation ────────────────
# Fix pour "Unrecognized keyword arguments passed to Dense/Layer: {'quantization_config': None}"
import keras
orig_layer_init = keras.layers.Layer.__init__
def patched_layer_init(self, *args, **kwargs):
    kwargs.pop("quantization_config", None)
    return orig_layer_init(self, *args, **kwargs)
keras.layers.Layer.__init__ = patched_layer_init

orig_dense_init = keras.layers.Dense.__init__
def patched_dense_init(self, *args, **kwargs):
    kwargs.pop("quantization_config", None)
    return orig_dense_init(self, *args, **kwargs)
keras.layers.Dense.__init__ = patched_dense_init

import numpy as np
import tensorflow as tf
from fastapi import FastAPI, File, UploadFile, HTTPException
from PIL import Image

# ── Variables globales ────────────────────────────────────────────────
model = None

# ── Mapping des classes (9 classes du modèle) ─────────────────────────
CLASS_NAMES = [
    "classe_00",
    "classe_01",
    "classe_02",
    "classe_03",
    "classe_04",
    "classe_05",
    "classe_06",
    "classe_07",
    "classe_08",
]

# ── Lifespan : chargement du modèle au démarrage ─────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    global model

    model_path = "model.keras"
    if os.path.exists(model_path):
        try:
            model = keras.models.load_model(model_path)
            print("✅ Modèle IA chargé avec succès.")
            if hasattr(model, 'input_shape'):
                print(f"ℹ️  Input shape attendue : {model.input_shape}")
            if hasattr(model, 'output_shape'):
                print(f"ℹ️  Output shape : {model.output_shape}")
        except Exception as e:
            print(f"❌ Erreur lors du chargement du modèle : {e}")
            import traceback
            traceback.print_exc()
            model = None
    else:
        print(f"⚠️  Fichier {model_path} introuvable. Le service démarre sans modèle.")
        model = None

    yield

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
        "backend": "keras-tensorflow",
        "num_classes": len(CLASS_NAMES),
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

    try:
        # ── Lecture et prétraitement de l'image ───────────────────────
        image_bytes = await file.read()
        try:
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception:
            raise HTTPException(
                status_code=400,
                detail="Le fichier envoyé n'est pas une image valide.",
            )

        # Redimensionnement vers la dimension attendue (224x224)
        target_size = (224, 224)
        if hasattr(model, 'input_shape') and len(model.input_shape) >= 3 and model.input_shape[1] is not None:
            target_size = (model.input_shape[1], model.input_shape[2])

        image = image.resize(target_size)

        # Le modèle intègre sa propre couche de rescaling (rescaling_1),
        # on lui passe donc les valeurs de pixels brutes [0, 255] en float32
        img_array = tf.keras.preprocessing.image.img_to_array(image)
        img_array = tf.expand_dims(img_array, 0)

        # ── Inférence ─────────────────────────────────────────────────
        predictions = model.predict(img_array)

        # predictions contient les probabilités softmax
        predicted_idx = int(np.argmax(predictions[0]))
        confidence = float(predictions[0][predicted_idx])

        # Mapping du label
        if predicted_idx < len(CLASS_NAMES):
            code_label = CLASS_NAMES[predicted_idx]
        else:
            code_label = f"classe_{predicted_idx:02d}"

        print(f"🎯 Inférence réussie : {code_label} (confiance: {confidence:.2%})")

        return {
            "code_label_ia": code_label,
            "confiance": round(confidence, 4),
        }

    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de l'inférence : {str(e)}",
        )

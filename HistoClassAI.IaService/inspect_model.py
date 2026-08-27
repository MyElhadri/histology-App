import tensorflow as tf
import json

try:
    model = tf.keras.models.load_model('model.keras')
    print("MODEL LOADED SUCCESSFULLY")
    
    info = {
        "input_shape": str(model.input_shape),
        "output_shape": str(model.output_shape),
        "num_classes": model.output_shape[-1] if model.output_shape else "Unknown",
        "model_name": model.name
    }
    print(json.dumps(info, indent=4))
except Exception as e:
    print(f"ERROR: {e}")

import sys
import os
import numpy as np

# Add IaService to path so we can import it
sys.path.append(os.path.join(os.path.dirname(__file__), ""))

from main import CLASS_NAMES

def test_mapping_exact():
    assert len(CLASS_NAMES) == 9
    expected_mapping = {
        0: "ADI",
        1: "BACK",
        2: "DEB",
        3: "LYM",
        4: "MUC",
        5: "MUS",
        6: "NORM",
        7: "STR",
        8: "TUM"
    }
    
    for idx, expected in expected_mapping.items():
        assert CLASS_NAMES[idx] == expected, f"Expected {expected} at index {idx}, got {CLASS_NAMES[idx]}"
    print("✅ Mapping de base (CLASS_NAMES) correct.")

def test_mock_inference():
    expected_mapping = [
        "ADI", "BACK", "DEB", "LYM", "MUC", "MUS", "NORM", "STR", "TUM"
    ]
    
    for i in range(9):
        # Create a mock vector [0,0, ..., 1, ..., 0]
        vec = np.zeros((1, 9), dtype=np.float32)
        vec[0, i] = 1.0
        
        pred_idx = int(np.argmax(vec[0]))
        predicted_class = CLASS_NAMES[pred_idx]
        assert predicted_class == expected_mapping[i], f"Expected {expected_mapping[i]}, got {predicted_class}"
        
    print("✅ Inférence sur vecteurs artificiels correcte.")

if __name__ == "__main__":
    test_mapping_exact()
    test_mock_inference()
    print("Tous les tests de mapping sont passés.")

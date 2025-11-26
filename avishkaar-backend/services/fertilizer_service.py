# services/fertilizer_service.py

import numpy as np
import joblib
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent

FERT_MODEL_PATH = BASE / "models" / "fertilizer prediction" / "rf_model_fertilizer.joblib"
LE_Y_PATH = BASE / "models" / "fertilizer prediction" / "le_y.joblib"
SOIL_LE_PATH = BASE / "models" / "fertilizer prediction" / "soil_type_le.joblib"
CROP_LE_PATH = BASE / "models" / "fertilizer prediction" / "crop_type_le.joblib"
CROPTYPE_DICT_PATH = BASE / "models" / "fertilizer prediction" / "croptype_dict.joblib"
SOILTYPE_DICT_PATH = BASE / "models" / "fertilizer prediction" / "soiltype_dict.joblib"

fert_model = joblib.load(FERT_MODEL_PATH)
le_y = joblib.load(LE_Y_PATH)
soil_type_le = joblib.load(SOIL_LE_PATH)
crop_type_le = joblib.load(CROP_LE_PATH)
croptype_dict = joblib.load(CROPTYPE_DICT_PATH)
soiltype_dict = joblib.load(SOILTYPE_DICT_PATH)


def predict_fertilizer(features: dict) -> dict:
    """
    features must include:
      temperature, humidity, moisture, soil_type, crop_type,
      nitrogen, phosphorus, potassium

    soil_type and crop_type are expected to be ENCODED ints, consistent
    with your training script.
    """
    X = np.array([[
        features["temperature"],
        features["humidity"],
        features["moisture"],
        features["soil_type"],
        features["crop_type"],
        features["nitrogen"],
        features["phosphorus"],
        features["potassium"],
    ]])

    fert_idx = fert_model.predict(X)[0]
    fert_name = le_y.inverse_transform([fert_idx])[0]

    soil_name = soiltype_dict.get(features["soil_type"], "Unknown soil")
    crop_name = croptype_dict.get(features["crop_type"], "Unknown crop")

    return {
        "fertilizer_index": int(fert_idx),
        "fertilizer_name": fert_name,
        "soil_type_index": int(features["soil_type"]),
        "soil_type_name": soil_name,
        "crop_type_index": int(features["crop_type"]),
        "crop_name": crop_name,
        "inputs": features,
    }

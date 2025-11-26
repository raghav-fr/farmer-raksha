# services/crop_service.py

import numpy as np
import joblib
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent

CROP_MODEL_PATH = BASE / "models" / "crop recomendation" / "rf_model_crop_recommendation.joblib"
CROP_ENCODER_PATH = BASE / "models" / "crop recomendation" / "label_encoder_cprecom.joblib"

crop_model = joblib.load(CROP_MODEL_PATH)
crop_encoder = joblib.load(CROP_ENCODER_PATH)


def predict_crop(env: dict) -> dict:
    """
    env expected keys:
      temperature, humidity, ph, rainfall
    """
    X = np.array([[
        env["temperature"],
        env["humidity"],
        env["ph"],
        env["rainfall"],
    ]])
    pred_idx = crop_model.predict(X)[0]
    crop_name = crop_encoder.inverse_transform([pred_idx])[0]

    return {
        "crop_index": int(pred_idx),
        "crop_name": crop_name,
        "inputs": env,
    }

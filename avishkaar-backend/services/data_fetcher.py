# services/data_fetcher.py

import os
import requests
from functools import lru_cache
from typing import Dict, Any, Union

from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

# ----------------------------------------------------
# Firebase initialization
# ----------------------------------------------------
if not firebase_admin._apps:
    cred = credentials.Certificate(os.getenv("FIREBASE_SERVICE_ACCOUNT"))
    firebase_admin.initialize_app(cred)

db = firestore.client()


API_KEY = os.getenv("WEATHER_API_KEY")
BASE_URL = "http://api.weatherapi.com/v1/current.json"


# ----------------------------------------------------
# Helpers
# ----------------------------------------------------
def safe_float(value: Union[str, float, int, None], default=0.0) -> float:
    try:
        if value is None:
            return default
        return float(value)
    except:
        return default


# ----------------------------------------------------
# Fetch ONLY current weather
# ----------------------------------------------------
@lru_cache(maxsize=200)
def get_current_weather(location: str) -> Dict[str, Any]:
    if not API_KEY:
        raise Exception("Missing WEATHER_API_KEY")

    resp = requests.get(BASE_URL, params={"key": API_KEY, "q": location, "aqi": "no"}, timeout=8)
    if resp.status_code != 200:
        raise Exception(f"WeatherAPI Error: {resp.text}")

    data = resp.json()
    cur = data.get("current", {})
    loc = data.get("location", {})

    return {
        "temperature": safe_float(cur.get("temp_c")),
        "humidity": safe_float(cur.get("humidity")),
        "rainfall": safe_float(cur.get("precip_mm")),
        "region": loc.get("region"),
    }


# ----------------------------------------------------
# Fetch soil & NPK values from Firebase
# ----------------------------------------------------
def get_soil_from_firebase(uid: str) -> Dict[str, Any]:
    """
    Read soil details from Firestore for the user.
    Path used:
       users/{uid}/soil_profile/latest
    """

    doc_ref = db.collection("users").document(uid).collection("soil_profile").document("latest")
    doc = doc_ref.get()

    if not doc.exists:
        # No soil profile available
        return {}

    data = doc.to_dict()

    return {
        "moisture": data.get("moisture"),
        "soil_type": data.get("soil_type"),
        "nitrogen": data.get("nitrogen"),
        "phosphorus": data.get("phosphorus"),
        "potassium": data.get("potassium"),
        "ph": data.get("ph"),          # override default pH
        "crop_type": data.get("crop_type"),
    }


# ----------------------------------------------------
# FULL ENVIRONMENT BUILDER
# ----------------------------------------------------
async def fetch_environment(uid: str, lat: float, lon: float) -> Dict[str, Any]:
    """
    Returns ALL data needed for:
        - Crop Recommendation
        - Fertilizer Prediction
        - LLM reasoning
    Automatically pulls soil attributes from Firebase.
    """

    # 1. Weather
    loc_string = f"{lat},{lon}"
    weather = get_current_weather(loc_string)

    temperature = weather["temperature"]
    humidity = weather["humidity"]
    rainfall = weather["rainfall"]
    ph_default = 6.5

    # 2. Soil attributes from Firebase
    soil = get_soil_from_firebase(uid)

    # If Firebase soil missing → Partial environment for crop model
    ph = soil.get("ph", ph_default)
    moisture = soil.get("moisture")
    soil_type = soil.get("soil_type")
    nitrogen = soil.get("nitrogen")
    phosphorus = soil.get("phosphorus")
    potassium = soil.get("potassium")
    crop_type = soil.get("crop_type")

    return {
        # Crop model minimal inputs
        "temperature": temperature,
        "humidity": humidity,
        "ph": ph,
        "rainfall": rainfall,

        # Fertilizer model inputs
        "moisture": moisture,
        "soil_type": soil_type,
        "nitrogen": nitrogen,
        "phosphorus": phosphorus,
        "potassium": potassium,
        "crop_type": crop_type,
    }

import requests
from fastapi import HTTPException

API_URL = "https://api.data.gov.in/resource/35985678-0d79-46b4-9ed6-6f13308a1d24"
API_KEY = "579b464db66ec23bdd000001ab24152f9a3240ba78c7701025b2337e"

def fetch_market_data(state: str, commodity: str, date: str):
    """
    Fetch market rates from data.gov.in API for a specific state, commodity, and date.
    Returns only State, District, Market, Arrival_Date, Min_Price, Max_Price, Modal_Price.
    """
    params = {
        "api-key": API_KEY,
        "format": "json",
        "filters[State]": state,
        "filters[Commodity]": commodity,
        "filters[Arrival_Date]": date,
    }

    try:
        response = requests.get(API_URL, params=params)
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch data from source")
        data = response.json()
        if "records" not in data or not data["records"]:
            return []

        filtered_records = []
        for rec in data["records"]:
            filtered_records.append({
                "State": rec.get("State"),
                "District": rec.get("District"),
                "Market": rec.get("Market"),
                "Arrival_Date": rec.get("Arrival_Date"),
                "Min_Price": rec.get("Min_Price"),
                "Max_Price": rec.get("Max_Price"),
                "Modal_Price": rec.get("Modal_Price")
            })
        return filtered_records

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

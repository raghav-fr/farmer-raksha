from functools import lru_cache
import os
import requests
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("WEATHER_API_KEY")
BASE_URL = "http://api.weatherapi.com/v1/forecast.json"


@lru_cache(maxsize=100)
def get_weather_forecast(location: str, days: int = 5):
    """
    Fetch current weather + hourly forecast for today (next hours)
    + 5-day forecast summary in one call.
    """
    if not API_KEY:
        raise Exception("Missing WEATHER_API_KEY in environment.")

    params = {
        "key": API_KEY,
        "q": location,
        "days": days,
        "aqi": "no",
        "alerts": "no"
    }

    response = requests.get(BASE_URL, params=params)
    if response.status_code != 200:
        raise Exception(f"Weather API error: {response.text}")

    data = response.json()

    # Extract info
    location_info = data.get("location", {})
    current = data.get("current", {})
    forecast_days = data.get("forecast", {}).get("forecastday", [])

    # Current weather
    current_data = {
        "temperature_c": current.get("temp_c"),
        "condition": current.get("condition", {}).get("text"),
        "humidity": current.get("humidity"),
        "wind_kph": current.get("wind_kph"),
        "feelslike_c": current.get("feelslike_c"),
        "last_updated": current.get("last_updated"),
    }

    # Hourly forecast for today (from next hour till midnight)
    upcoming_hours = []
    if forecast_days:
        today_forecast = forecast_days[0]
        hours = today_forecast.get("hour", [])
        current_time_str = location_info.get("localtime")
        current_time = datetime.strptime(current_time_str, "%Y-%m-%d %H:%M") if current_time_str else datetime.now()

        for hour in hours:
            hour_time = datetime.strptime(hour.get("time"), "%Y-%m-%d %H:%M")
            if hour_time > current_time:
                upcoming_hours.append({
                    "time": hour.get("time"),
                    "temp_c": hour.get("temp_c"),
                    "condition": hour["condition"]["text"],
                    "humidity": hour.get("humidity"),
                    "wind_kph": hour.get("wind_kph"),
                    "chance_of_rain": hour.get("chance_of_rain"),
                    "feelslike_c": hour.get("feelslike_c")
                })

    # 5-day forecast summaries
    daily_forecasts = []
    for day in forecast_days:
        daily_forecasts.append({
            "date": day.get("date"),
            "max_temp_c": day["day"].get("maxtemp_c"),
            "min_temp_c": day["day"].get("mintemp_c"),
            "avg_temp_c": day["day"].get("avgtemp_c"),
            "condition": day["day"]["condition"]["text"],
            "humidity": day["day"].get("avghumidity"),
            "rain_chance": day["day"].get("daily_chance_of_rain"),
        })

    # Final unified JSON
    return {
        "location": {
            "name": location_info.get("name"),
            "region": location_info.get("region"),
            "country": location_info.get("country")
        },
        "current": current_data,
        "hourly_today": {
            "current_time": location_info.get("localtime"),
            "remaining_hours": len(upcoming_hours),
            "data": upcoming_hours
        },
        "five_day_forecast": daily_forecasts
    }

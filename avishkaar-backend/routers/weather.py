from fastapi import APIRouter, HTTPException, Query
from services.weather_service import get_weather_forecast

router = APIRouter(prefix="/weather", tags=["Weather"])

@router.get("/forecast")
async def weather_forecast(
    location: str = Query(..., description="City or place name, e.g., Bhubaneswar"),
    days: int = Query(5, ge=1, le=10, description="Number of days for forecast (1-10)")
):
    """Get current, hourly, and 5-day forecast weather data."""
    try:
        result = get_weather_forecast(location, days)
        return {"query": location, "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# http://127.0.0.1:8000/weather/forecast?location=khordha
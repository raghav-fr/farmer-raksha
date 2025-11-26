from fastapi import APIRouter, Query
from services.market_service import fetch_market_data

router = APIRouter(prefix="/market", tags=["Market Rates"])

@router.get("/")
def get_market_rates(
    state: str = Query(..., description="State name, e.g., Odisha"),
    commodity: str = Query(..., description="Commodity name, e.g., Rice"),
    date: str = Query(..., description="Arrival date in DD/MM/YYYY format, e.g., 16/10/2025")
):
    """
    Get filtered market rates for a given state, commodity, and date.
    """
    records = fetch_market_data(state, commodity, date)
    if not records:
        return {"message": "No data found for the given filters."}
    return {"records": records}


# usgae   -    http://127.0.0.1:8000/market/?state=Odisha&commodity=Rice&date=16/10/2025
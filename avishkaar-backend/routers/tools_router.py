# routers/tools_router.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from services.data_fetcher import fetch_environment
from services.crop_service import predict_crop
from services.fertilizer_service import predict_fertilizer

router = APIRouter(prefix="/tool", tags=["Tools"])


class EnvRequest(BaseModel):
    latitude: float
    longitude: float


class CropRequest(BaseModel):
    temperature: float
    humidity: float
    ph: float
    rainfall: float


class FertilizerRequest(BaseModel):
    temperature: float
    humidity: float
    moisture: float
    soil_type: int
    crop_type: int
    nitrogen: float
    phosphorus: float
    potassium: float


@router.post("/fetch_environment")
async def fetch_env(req: EnvRequest):
    try:
        env = await fetch_environment(req.latitude, req.longitude)
        return env
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/predict_crop")
def crop_predict(req: CropRequest):
    try:
        return predict_crop(req.dict())
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/predict_fertilizer")
def fertilizer_predict(req: FertilizerRequest):
    try:
        return predict_fertilizer(req.dict())
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

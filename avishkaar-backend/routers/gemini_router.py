# routers/gemini_router.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from llm_clients.gemini_client import gemini_mediator
from services.session_store import session_store


router = APIRouter(prefix="/llm", tags=["Gemini Chat"])


# ---------------------------
# REQUEST BODY
# ---------------------------
class GeminiChatRequest(BaseModel):
    session_id: str
    user_id: str               # <-- NEW
    message: str
    latitude: float            # <-- from frontend
    longitude: float           # <-- from frontend


# ---------------------------
# MAIN ROUTE
# ---------------------------
@router.post("/gemini_chat")
async def gemini_chat(req: GeminiChatRequest):

    # Load old session
    session = session_store.get(req.session_id)

    # Extract stored data
    last_crop = session.get("last_crop")
    last_env = session.get("last_env")
    partial_args = session.get("partial_args")
    fertilizer_ready = session.get("fertilizer_ready")
    last_location = session.get("last_location")

    # Update last_location every time
    session["last_location"] = {
        "lat": req.latitude,
        "lon": req.longitude,
    }
    session_store.save(req.session_id, session)

    try:
        # -------------- CALL MEDIATOR --------------
        result = await gemini_mediator(
            user_message=req.message,
            session_id=req.session_id,
            user_id=req.user_id,          # <-- passes UID to fetch_environment
            latitude=req.latitude,
            longitude=req.longitude,
            partial_args=partial_args,
            last_crop=last_crop,
            last_env=last_env,
            fertilizer_ready=fertilizer_ready,
        )

        # -------------- HANDLE "missing_attributes" --------------
        if result["type"] == "missing_attributes":
            # Store extracted args into partial_args
            extracted = result.get("extracted_args", {}) or {}
            merged = partial_args.copy() if partial_args else {}
            merged.update(extracted)

            session["partial_args"] = merged
            session_store.save(req.session_id, session)

            return result


        # -------------- HANDLE TOOL SUCCESS --------------
        if result["type"] == "final":
            # Clear partial args
            session["partial_args"] = None

            # Update last crop/environment
            if "last_crop" in result:
                session["last_crop"] = result["last_crop"]

            if "last_env" in result:
                session["last_env"] = result["last_env"]

            # If it is fertilizer final response → set ready flag
            session["fertilizer_ready"] = (result["tool"] == "predict_fertilizer")

            session_store.save(req.session_id, session)

            return result


        # -------------- DIRECT CHAT RESPONSE --------------
        return result


    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

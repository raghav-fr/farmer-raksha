# llm_clients/gemini_client.py

import os
import json
from typing import Dict, Any, Optional

from dotenv import load_dotenv
import httpx
from google import genai
from google.genai import types

load_dotenv()

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
BACKEND_URL = os.getenv("BACKEND_URL", "http://127.0.0.1:8000")


# -------------------------------------------------------------------
# SAFE TEXT EXTRACTOR
# -------------------------------------------------------------------
def extract_text(msg):
    try:
        if hasattr(msg, "text") and msg.text:
            return msg.text.strip()
        if hasattr(msg, "parts") and msg.parts:
            return "".join(
                part.text for part in msg.parts if hasattr(part, "text")
            ).strip()
        return str(msg).strip()
    except:
        return "I'm here to help. Could you repeat that?"


# -------------------------------------------------------------------
# FUNCTION DECLARATIONS FOR GEMINI
# -------------------------------------------------------------------
fetch_environment_fn = types.FunctionDeclaration(
    name="fetch_environment",
    description="Fetch full environment (weather + soil).",
    parameters=types.Schema(
        type=types.Type.OBJECT,
        properties={
            "user_id": types.Schema(type=types.Type.STRING),
            "latitude": types.Schema(type=types.Type.NUMBER),
            "longitude": types.Schema(type=types.Type.NUMBER),
        },
        required=["user_id", "latitude", "longitude"]
    )
)

predict_crop_fn = types.FunctionDeclaration(
    name="predict_crop",
    description="Predict the best crop for the environment.",
    parameters=types.Schema(
        type=types.Type.OBJECT,
        properties={
            "temperature": types.Schema(type=types.Type.NUMBER),
            "humidity": types.Schema(type=types.Type.NUMBER),
            "ph": types.Schema(type=types.Type.NUMBER),
            "rainfall": types.Schema(type=types.Type.NUMBER),
        },
        required=["temperature", "humidity", "ph", "rainfall"]
    )
)

predict_fertilizer_fn = types.FunctionDeclaration(
    name="predict_fertilizer",
    description="Recommend fertilizer.",
    parameters=types.Schema(
        type=types.Type.OBJECT,
        properties={
            "temperature": types.Schema(type=types.Type.NUMBER),
            "humidity": types.Schema(type=types.Type.NUMBER),
            "moisture": types.Schema(type=types.Type.NUMBER),
            "soil_type": types.Schema(type=types.Type.INTEGER),
            "crop_type": types.Schema(type=types.Type.INTEGER),
            "nitrogen": types.Schema(type=types.Type.NUMBER),
            "phosphorus": types.Schema(type=types.Type.NUMBER),
            "potassium": types.Schema(type=types.Type.NUMBER),
        },
        required=["temperature", "humidity", "moisture", "soil_type", "crop_type"]
    )
)

TOOLS = [
    types.Tool(
        function_declarations=[
            fetch_environment_fn,
            predict_crop_fn,
            predict_fertilizer_fn,
        ]
    )
]


# -------------------------------------------------------------------
# BACKEND TOOL CALLER
# -------------------------------------------------------------------
async def call_tool(tool: str, args: Dict[str, Any]):
    routes = {
        "fetch_environment": "/tool/fetch_environment",
        "predict_crop": "/tool/predict_crop",
        "predict_fertilizer": "/tool/predict_fertilizer",
    }
    async with httpx.AsyncClient(timeout=30) as client_http:
        res = await client_http.post(BACKEND_URL + routes[tool], json=args)
        res.raise_for_status()
        return res.json()


# -------------------------------------------------------------------
# MAIN MEDIATOR
# -------------------------------------------------------------------
async def gemini_mediator(
    user_message: str,
    session_id: str,
    last_location: Optional[Dict[str, float]],
    partial_args: Optional[Dict[str, Any]] = None,
    last_crop: Optional[Dict[str, Any]] = None,
    last_env: Optional[Dict[str, Any]] = None,
    fertilizer_ready: bool = False
):

    # Build conversational context
    context = ""
    if last_location:
        context += f"(location={last_location})\n"
    if last_crop:
        context += f"(last_crop={last_crop.get('crop_name')})\n"

    config = types.GenerateContentConfig(
        temperature=0.55,
        max_output_tokens=500,
        tools=TOOLS,
        system_instruction=(
            "You are an agricultural assistant.\n"
            "AUTO-CHAIN RULES:\n"
            "• For crop queries → fetch_environment → predict_crop.\n"
            "• For fertilizer queries → require soil attributes from dashboard.\n"
            "• Do NOT accept fertilizer values in chat.\n"
            "• Missing attributes → tell user to complete the dashboard.\n"
            "• After prediction, answer follow-ups naturally.\n"
            "• Never show raw JSON.\n"
        )
    )

    # Intent detection
    u = user_message.lower()
    wants_crop = any(k in u for k in ["grow", "crop", "plant"])
    wants_fert = any(k in u for k in ["fertilizer", "fertiliser", "nutrient"])
    follow_crop = any(k in u for k in ["how", "care", "maintain", "look", "describe"])
    follow_fert = any(k in u for k in ["dose", "apply", "how much", "use this"])

    # Follow-up crop questions
    if follow_crop and last_crop:
        explanation = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=f"User asked: {user_message}\nDescribe crop {last_crop['crop_name']} in detail.",
        )
        return {"type": "direct", "gemini_text": extract_text(explanation)}

    # Follow-up fertilizer questions
    if follow_fert and fertilizer_ready and last_crop:
        explanation = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=f"User asked: {user_message}\nGive fertilizer advice for crop {last_crop['crop_name']}.",
        )
        return {"type": "direct", "gemini_text": extract_text(explanation)}

    # First pass LLM call
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=context + user_message,
        config=config,
    )

    candidate = response.candidates[0]
    parts = candidate.content.parts if candidate.content else []
    function_call = parts[0].function_call if parts and hasattr(parts[0], "function_call") else None

    if function_call:
        tool = function_call.name
        args = dict(function_call.args or {})

        # Always add user_id
        args["user_id"] = session_id

        # ---- fetch_environment ----
        if tool == "fetch_environment":
            env = await call_tool("fetch_environment", args)
            last_env = env

            if wants_crop:
                crop_args = {
                    "temperature": env["temperature"],
                    "humidity": env["humidity"],
                    "ph": env["ph"],
                    "rainfall": env["rainfall"],
                }
                crop = await call_tool("predict_crop", crop_args)
                last_crop = crop

                final_text = extract_text(
                    client.models.generate_content(
                        model="gemini-2.5-flash",
                        contents=(
                            f"Explain why {crop['crop_name']} is recommended "
                            f"based on environment: {env}."
                        )
                    )
                )

                return {
                    "type": "final",
                    "tool": "predict_crop",
                    "args": crop_args,
                    "tool_result": crop,
                    "last_crop": last_crop,
                    "last_env": last_env,
                    "gemini_text": final_text
                }

            if wants_fert:
                # Check missing dashboard fields
                missing = [
                    k for k in ["moisture", "soil_type", "nitrogen", "phosphorus", "potassium", "crop_type"]
                    if env.get(k) is None
                ]
                if missing:
                    return {
                        "type": "missing_attributes",
                        "tool": "predict_fertilizer",
                        "missing": missing,
                        "message": "Some soil attributes are missing. Please fill them in your dashboard."
                    }

                fert_args = {
                    "temperature": env["temperature"],
                    "humidity": env["humidity"],
                    "moisture": env["moisture"],
                    "soil_type": env["soil_type"],
                    "crop_type": env["crop_type"],
                    "nitrogen": env["nitrogen"],
                    "phosphorus": env["phosphorus"],
                    "potassium": env["potassium"],
                }

                fert = await call_tool("predict_fertilizer", fert_args)

                explanation = client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=(
                        f"Explain the fertilizer recommendation for crop {last_crop['crop_name']} "
                        "in simple language."
                    )
                )

                return {
                    "type": "final",
                    "tool": "predict_fertilizer",
                    "args": fert_args,
                    "tool_result": fert,
                    "last_crop": last_crop,
                    "last_env": last_env,
                    "gemini_text": extract_text(explanation)
                }

        # ---- fallback tool call ----
        result = await call_tool(tool, args)
        return {
            "type": "final",
            "tool": tool,
            "args": args,
            "tool_result": result,
            "gemini_text": extract_text(response)
        }

    # No tool used → direct chat
    return {"type": "direct", "gemini_text": extract_text(response)}
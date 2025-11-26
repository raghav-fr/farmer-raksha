from fastapi import FastAPI
from routers import gemini_router, tools_router, weather,rates

app = FastAPI(
    title="FarmAssist API",
    description="the whole backend for the deepshiva hackathon project...",
    version="1.0.0"
)

# Routers
app.include_router(weather.router)
app.include_router(rates.router)
app.include_router(tools_router.router)
app.include_router(gemini_router.router)

@app.get("/")
def home():
    return {"message": "Welcome to FarmAssist API 🌾"}

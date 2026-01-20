from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import api_router
from app.core.scheduler import scheduler, update_all_stations

app = FastAPI(title="FuelUp API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # pozwala na wszystkie originy (do testów)
    allow_credentials=True,
    allow_methods=["*"],  # GET, POST, itp.
    allow_headers=["*"],  # nagłówki
)

app.include_router(api_router)

@app.get("/")
def root():
    return {"message": "Witaj w FuelUp, spróbuj endpoint /docs."}

@app.on_event("startup")
def start_scheduler():
    # 🔥 Uruchom jednorazową aktualizację przy starcie
    update_all_stations()

    # 🚀 Start cyklicznego schedulera
    scheduler.start()

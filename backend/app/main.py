from fastapi import FastAPI
from app.api import api_router
from app.core.scheduler import scheduler, update_all_stations

app = FastAPI(title="FuelUp API")

app.include_router(api_router)

@app.get("/")
def root():
    return {"message": "Witaj w FuelUp"}

@app.on_event("startup")
def start_scheduler():
    # 🔥 Uruchom jednorazową aktualizację przy starcie
    update_all_stations()

    # 🚀 Start cyklicznego schedulera
    scheduler.start()

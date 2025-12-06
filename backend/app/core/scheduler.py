# app/core/scheduler.py

from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
from sqlalchemy.orm import Session
from app.core.db import SessionLocal
from app.models.station import Station
from app.models.fuel_price import FuelPrice
from app.core.scraper import scrape_station_prices

def update_all_stations():
    db: Session = SessionLocal()
    try:
        stations = db.query(Station).all()
        for station in stations:
            if station.website_url:
                # Pobranie cen ze scrapera
                prices = scrape_station_prices(station.website_url)
                
                # Zapis każdej ceny do bazy
                for p in prices:
                    fp = FuelPrice(
                        station_id=station.id,
                        fuel_type=p["fuel"],  # np. "ON" lub "PB95"
                        price=p["price"]
                    )
                    db.add(fp)
                
                # Aktualizacja czasu ostatniej aktualizacji stacji
                station.last_updated = datetime.now()
        
        db.commit()
        print(f"[{datetime.now()}] Updated all stations")
    finally:
        db.close()

# Tworzenie schedulera globalnego
scheduler = BackgroundScheduler()
scheduler.add_job(update_all_stations, 'cron', hour=12, minute=0)  # codziennie o 12:00

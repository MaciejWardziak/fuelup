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
        stations = db.query(Station).filter(Station.website_url.isnot(None)).all()
        for station in stations:
            try:
                if not station.scraper_config:
                    print(f"Pominięto {station.name} - brak scraper_config")
                    continue
                prices = scrape_station_prices(
                    station.website_url,
                    station.scraper_config,
                    station.address
                )
                if not prices:
                    print(f"Brak cen dla {station.name}")
                    continue

                for p in prices:
                    fp = FuelPrice(
                        station_id=station.id,
                        fuel_type=p["fuel"],
                        price=p["price"]
                    )
                    db.add(fp)
                station.last_updated = datetime.utcnow()
                db.commit()
                print(f"Zaktualizowano {station.name}")
            except Exception as e:
                print(f"Błąd dla {station.name}: {e}")
                db.rollback()  # Cofnij zmiany dla tej stacji
        print(f"[{datetime.now()}] Updated all stations")
    finally:
        db.close()

scheduler = BackgroundScheduler()
scheduler.add_job(update_all_stations, 'cron', hour=12, minute=0)
# app/core/scheduler.py

from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.db import SessionLocal
from app.models.station import Station
from app.models.fuel_price import FuelPrice
from app.models.fuel_price_archive import FuelPriceArchive
from app.core.scraper import scrape_station_prices

scheduler = BackgroundScheduler()

def archive_old_prices(days_to_keep: int = 30):
    db: Session = SessionLocal()
    try:
        cutoff_date = datetime.utcnow() - timedelta(days=days_to_keep)

        old_prices = (
            db.query(FuelPrice)
            .filter(FuelPrice.created_at < cutoff_date)
            .all()
        )

        if not old_prices:
            print(f"[Archiwizacja] Brak cen starszych niż {days_to_keep} dni – nic do przeniesienia")
            return

        archived_count = 0
        for price in old_prices:
            archive_record = FuelPriceArchive(
                station_id=price.station_id,
                fuel_type=price.fuel_type,
                price=price.price,
                created_at=price.created_at
            )
            db.add(archive_record)
            db.delete(price)
            archived_count += 1

        db.commit()
        print(f"[Archiwizacja] Przeniesiono {archived_count} rekordów do archiwum (starsze niż {days_to_keep} dni)")

    except Exception as e:
        db.rollback()
        print(f"[Archiwizacja] Błąd podczas przenoszenia danych: {e}")
    finally:
        db.close()

def update_all_stations():
    db: Session = SessionLocal()
    try:
        stations = db.query(Station).filter(Station.website_url.isnot(None)).all()

        total_updated = 0
        total_added = 0

        for station in stations:
            try:
                if not station.scraper_config:
                    print(f"[Scraper] Pominięto {station.name} – brak scraper_config")
                    continue

                prices = scrape_station_prices(
                    station.website_url,
                    station.scraper_config,
                    station.address
                )

                if not prices:
                    print(f"[Scraper] Brak nowych cen dla {station.name}")
                    continue

                # Początek dzisiejszego dnia w strefie bazy
                today_start = func.date_trunc('day', func.now())

                station_updated = 0
                station_added = 0

                for p in prices:
                    # Szukamy rekordu z tego samego dnia
                    existing_today = (
                        db.query(FuelPrice)
                        .filter(
                            FuelPrice.station_id == station.id,
                            FuelPrice.fuel_type == p["fuel"],
                            FuelPrice.created_at >= today_start,
                        )
                        .order_by(FuelPrice.created_at.desc())
                        .first()
                    )

                    if existing_today:
                        # Aktualizacja istniejącego rekordu
                        existing_today.price = p["price"]
                        existing_today.updated_at = datetime.utcnow()
                        station_updated += 1
                    else:
                        # Dodanie nowego rekordu
                        new_price = FuelPrice(
                            station_id=station.id,
                            fuel_type=p["fuel"],
                            price=p["price"]
                        )
                        db.add(new_price)
                        station_added += 1

                # Aktualizacja znacznika ostatniej aktualizacji stacji
                station.last_updated = datetime.utcnow()
                db.commit()

                print(f"[Scraper] {station.name}: {station_updated} aktualizacji, {station_added} nowych cen")

                total_updated += station_updated
                total_added += station_added

            except Exception as e:
                print(f"[Scraper] Błąd dla {station.name}: {e}")
                db.rollback()

        # Archiwizacja starych cen (na końcu całego cyklu)
        archive_old_prices(days_to_keep=30)

        print(f"[{datetime.now()}] Scheduler zakończył pracę – dodano {total_added}, zaktualizowano {total_updated} cen")

    except Exception as e:
        print(f"[Scheduler] Krytyczny błąd: {e}")
    finally:
        db.close()

# Zadanie uruchamiane codziennie o 12:00
scheduler.add_job(update_all_stations, 'cron', hour=12, minute=0, id='daily_fuel_update')
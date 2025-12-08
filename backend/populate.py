from datetime import time
from sqlalchemy.orm import Session
from app.core.db import SessionLocal, Base, engine
from app.models.station import Station
from app.models.station_opening_hours import StationOpeningHours

# Tworzymy tabele jeśli nie istnieją
Base.metadata.create_all(bind=engine)

db: Session = SessionLocal()

try:
    # Sprawdzenie czy stacja już istnieje
    existing_station = db.query(Station).filter(Station.name == "E.Leclerc").first()
    if not existing_station:
        station = Station(
            name="E.Leclerc",
            address="Szczecińska 36k, 76-200 Słupsk",
            website_url="https://slupsk.leclerc.pl/",
        )
        db.add(station)
        db.commit()
        db.refresh(station)

        opening_hours = [
            {"day": "mon", "open": time(6, 0), "close": time(21, 0)},
            {"day": "tue", "open": time(6, 0), "close": time(21, 0)},
            {"day": "wed", "open": time(6, 0), "close": time(21, 0)},
            {"day": "thu", "open": time(6, 0), "close": time(21, 0)},
            {"day": "fri", "open": time(6, 0), "close": time(21, 0)},
            {"day": "sat", "open": time(6, 0), "close": time(21, 0)},
            {"day": "sun", "open": time(10, 0), "close": time(18, 0)},
            {"day": "holiday", "open": time(10, 0), "close": time(18, 0)},
        ]

        for oh in opening_hours:
            db.add(StationOpeningHours(
                station_id=station.id,
                day_of_week=oh["day"],
                open_time=oh["open"],
                close_time=oh["close"],
            ))
        db.commit()
        print("Stacja i godziny otwarcia dodane do bazy.")
    else:
        print("Stacja już istnieje. Nic nie dodajemy.")

finally:
    db.close()

from datetime import time
from sqlalchemy.orm import Session
from app.core.db import SessionLocal
from app.models.station import Station
from app.models.station_opening_hours import StationOpeningHours

db: Session = SessionLocal()

try:
    # Tworzymy stację
    station = Station(
        name="E.Leclecr",
        address="Szczecińska 36k, 76-200 Słupsk",
        website_url="https://slupsk.leclerc.pl/",
    )
    db.add(station)
    db.commit()  # commitujemy, żeby mieć station.id
    db.refresh(station)

    # Godziny otwarcia (przykład z Twojej stacji)
    opening_hours = [
        # Poniedziałek - Sobota
        {"day": "mon", "open": time(6, 0), "close": time(21, 0)},
        {"day": "tue", "open": time(6, 0), "close": time(21, 0)},
        {"day": "wed", "open": time(6, 0), "close": time(21, 0)},
        {"day": "thu", "open": time(6, 0), "close": time(21, 0)},
        {"day": "fri", "open": time(6, 0), "close": time(21, 0)},
        {"day": "sat", "open": time(6, 0), "close": time(21, 0)},
        # Niedziela
        {"day": "sun", "open": time(10, 0), "close": time(18, 0)},
        # Niehandlowa
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

finally:
    db.close()

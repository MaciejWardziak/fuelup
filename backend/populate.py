# backend/populate.py

from datetime import time
from sqlalchemy.orm import Session
from app.core.db import SessionLocal, Base, engine
from app.models.station import Station
from app.models.station_opening_hours import StationOpeningHours

Base.metadata.create_all(bind=engine)

db: Session = SessionLocal()

try:
    stations_data = [
        {
            "name": "E.Leclerc",
            "address": "Szczecińska 36k, 76-200 Słupsk",
            "website_url": "https://slupsk.leclerc.pl/",
            "scraper_config": {"type": "list"},
            "opening_hours": [
                {"day": "mon", "open": time(6, 0), "close": time(21, 0)},
                {"day": "tue", "open": time(6, 0), "close": time(21, 0)},
                {"day": "wed", "open": time(6, 0), "close": time(21, 0)},
                {"day": "thu", "open": time(6, 0), "close": time(21, 0)},
                {"day": "fri", "open": time(6, 0), "close": time(21, 0)},
                {"day": "sat", "open": time(6, 0), "close": time(21, 0)},
                {"day": "sun", "open": time(10, 0), "close": time(18, 0)},
                {"day": "holiday", "open": time(10, 0), "close": time(18, 0)},
            ]
        },
        {
            "name": "Rolmasz Słupsk",
            "address": "Fabryczna 1, 76-200 Słupsk",
            "website_url": "https://rolmasz.pl/",
            "scraper_config": {"type": "text", "filter_by_city": True},
            "opening_hours": [
                {"day": "mon", "open": time(6, 0), "close": time(18, 0)},
                {"day": "tue", "open": time(6, 0), "close": time(18, 0)},
                {"day": "wed", "open": time(6, 0), "close": time(18, 0)},
                {"day": "thu", "open": time(6, 0), "close": time(18, 0)},
                {"day": "fri", "open": time(6, 0), "close": time(18, 0)},
                {"day": "sat", "open": time(7, 0), "close": time(17, 0)},
            ]
        },
        {
            "name": "Rolmasz Darłowo",
            "address": "Dąbrowskiego 2, 76-150 Darłowo",
            "website_url": "https://rolmasz.pl/",
            "scraper_config": {"type": "text", "filter_by_city": True},
            "opening_hours": [
                {"day": "mon", "open": time(6, 0), "close": time(20, 0)},
                {"day": "tue", "open": time(6, 0), "close": time(20, 0)},
                {"day": "wed", "open": time(6, 0), "close": time(20, 0)},
                {"day": "thu", "open": time(6, 0), "close": time(20, 0)},
                {"day": "fri", "open": time(6, 0), "close": time(20, 0)},
                {"day": "sat", "open": time(6, 0), "close": time(20, 0)},
                {"day": "sun", "open": time(6, 0), "close": time(20, 0)},
            ]
        },
        {
            "name": "Rolmasz Główczyce",
            "address": "DW213 2, 76-220 Główczyce",
            "website_url": "https://rolmasz.pl/",
            "scraper_config": {"type": "text", "filter_by_city": True},
            "opening_hours": [
                {"day": "mon", "open": time(6, 0), "close": time(22, 0)},
                {"day": "tue", "open": time(6, 0), "close": time(22, 0)},
                {"day": "wed", "open": time(6, 0), "close": time(22, 0)},
                {"day": "thu", "open": time(6, 0), "close": time(22, 0)},
                {"day": "fri", "open": time(6, 0), "close": time(22, 0)},
                {"day": "sat", "open": time(6, 0), "close": time(22, 0)},
                {"day": "sun", "open": time(7, 0), "close": time(19, 0)},
            ]
        },
        {
            "name": "MZK Słupsk",
            "address": "Jolanty Szczypińskiej 36, 76-251 Kobylnica",
            "website_url": "https://www.mzk.slupsk.pl/pl/page/nasza-oferta/stacja-paliw.html",
            "scraper_config": {"type": "table"},
            "opening_hours": [
                {"day": "mon", "open": time(6, 0), "close": time(21, 30)},
                {"day": "tue", "open": time(6, 0), "close": time(21, 30)},
                {"day": "wed", "open": time(6, 0), "close": time(21, 30)},
                {"day": "thu", "open": time(6, 0), "close": time(21, 30)},
                {"day": "fri", "open": time(6, 0), "close": time(21, 30)},
                {"day": "sat", "open": time(6, 0), "close": time(21, 30)},
                {"day": "sun", "open": time(6, 0), "close": time(21, 30)},
                {"day": "holiday", "open": time(9, 0), "close": time(15, 0)},
            ]
        },
    ]

    added_count = 0
    for data in stations_data:
        existing = db.query(Station).filter(
            Station.name == data["name"],
            Station.address == data["address"]
        ).first()

        if existing:
            print(f"Stacja '{data['name']}' już istnieje – pomijam.")
            continue

        station = Station(
            name=data["name"],
            address=data["address"],
            website_url=data["website_url"],
            scraper_config=data["scraper_config"]
        )
        db.add(station)
        db.flush()

        for oh in data["opening_hours"]:
            db.add(StationOpeningHours(
                station_id=station.id,
                day_of_week=oh["day"],
                open_time=oh["open"],
                close_time=oh["close"]
            ))

        added_count += 1

    db.commit()
    print(f"\nDodano {added_count} nowych stacji z godzinami otwarcia.")
    print("Ceny paliw zostaną dodane automatycznie przez scraper przy pierwszym uruchomieniu schedulera.")
    print("Baza gotowa – możesz uruchomić aplikację!")

except Exception as e:
    db.rollback()
    print(f"Błąd podczas populowania bazy: {e}")
finally:
    db.close()
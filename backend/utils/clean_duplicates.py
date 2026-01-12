# backend/utils/clean_duplicates.py  (lub w dowolnym pliku utils)

from sqlalchemy import and_, extract, func
from datetime import datetime
from app.core.db import SessionLocal
from app.models.fuel_price import FuelPrice

def clean_duplicate_prices():
    db = SessionLocal()
    try:
        print("Rozpoczynam czyszczenie duplikatów cen w tej samej dacie...")

        # Znajdujemy wszystkie rekordy do analizy
        duplicates_query = (
            db.query(
                FuelPrice.station_id,
                FuelPrice.fuel_type,
                FuelPrice.price,
                extract('year', FuelPrice.created_at).label('year'),
                extract('month', FuelPrice.created_at).label('month'),
                extract('day', FuelPrice.created_at).label('day'),
                func.count().label('count')
            )
            .group_by(
                FuelPrice.station_id,
                FuelPrice.fuel_type,
                FuelPrice.price,
                extract('year', FuelPrice.created_at),
                extract('month', FuelPrice.created_at),
                extract('day', FuelPrice.created_at),
            )
            .having(func.count() > 1)
        )

        duplicates = duplicates_query.all()
        deleted_count = 0

        for dup in duplicates:
            # Pobieramy wszystkie rekordy z tą samą stacją, paliwem, ceną i datą
            records = (
                db.query(FuelPrice)
                .filter(
                    FuelPrice.station_id == dup.station_id,
                    FuelPrice.fuel_type == dup.fuel_type,
                    FuelPrice.price == dup.price,
                    extract('year', FuelPrice.created_at) == dup.year,
                    extract('month', FuelPrice.created_at) == dup.month,
                    extract('day', FuelPrice.created_at) == dup.day,
                )
                .order_by(FuelPrice.created_at.desc())  # najnowszy na górze
                .all()
            )

            # Zostawiamy najnowszy (najwyższy created_at)
            # Usuwamy resztę
            for record in records[1:]:
                db.delete(record)
                deleted_count += 1

        db.commit()
        print(f"Czyszczenie zakończone. Usunięto {deleted_count} duplikatów.")

    except Exception as e:
        db.rollback()
        print(f"Błąd podczas czyszczenia: {e}")
    finally:
        db.close()
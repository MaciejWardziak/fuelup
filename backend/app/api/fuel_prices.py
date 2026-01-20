from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, func, extract, text
from typing import List
from datetime import datetime
from app.core.db import get_db
from app.models.fuel_price import FuelPrice
from app.models.station import Station
from app.schemas.fuel_price import FuelPriceCreate, FuelPriceRead

router = APIRouter(
    prefix="/prices",
    tags=["Fuel Prices"],
)

@router.post("/{station_id}", response_model=FuelPriceRead, status_code=status.HTTP_201_CREATED)
def add_fuel_price(
    station_id: int,
    data: FuelPriceCreate,
    db: Session = Depends(get_db),
):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="station_not_found")

    print(f"[DEBUG] Próba dodania ceny: station_id={station_id}, fuel_type={data.fuel_type}, price={data.price} (type: {type(data.price)})")

    today_start = func.date_trunc('day', func.now())

    existing_today = (
        db.query(FuelPrice)
        .filter(
            FuelPrice.station_id == station_id,
            FuelPrice.fuel_type == data.fuel_type,
            FuelPrice.created_at >= today_start,
        )
        .order_by(FuelPrice.created_at.desc())
        .first()
    )

    if existing_today:
        print(f"[DEBUG] Znaleziono istniejący rekord ID={existing_today.id}")
        print(f"  Baza: price={existing_today.price} (type: {type(existing_today.price)})")
        print(f"  Request: price={data.price} (type: {type(data.price)})")

        existing_today.price = data.price
        existing_today.updated_at = datetime.utcnow()
        db.commit()
        print("[DEBUG] Cena zaktualizowana")
        return existing_today
    else:
        print("[DEBUG] Nie znaleziono rekordu z dziś – dodaję nowy")
        new_price = FuelPrice(
            station_id=station_id,
            fuel_type=data.fuel_type,
            price=data.price,
        )
        db.add(new_price)
        db.commit()
        db.refresh(new_price)
        return new_price


# READ – ceny dla konkretnej stacji (wszystkie historyczne)
@router.get("/{station_id}", response_model=List[FuelPriceRead])
def get_fuel_prices_for_station(
    station_id: int,
    db: Session = Depends(get_db),
):
    # Opcjonalnie: sprawdź czy stacja istnieje (można pominąć, bo pusta lista i tak będzie)
    if not db.query(Station.id).filter(Station.id == station_id).scalar():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="station_not_found"
        )

    prices = db.query(FuelPrice).filter(FuelPrice.station_id == station_id).all()
    return prices  # pusta lista jeśli brak


from decimal import Decimal

@router.get("/latest/{station_id}", response_model=List[FuelPriceRead])
def get_latest_fuel_prices(
    station_id: int,
    db: Session = Depends(get_db),
):
    # Pobieramy unikalne typy paliw
    fuel_types = db.query(FuelPrice.fuel_type).filter(
        FuelPrice.station_id == station_id
    ).distinct().all()
    
    fuel_types = [f[0] for f in fuel_types]
    results = []

    for f_type in fuel_types:
        # Pobieramy 2 najnowsze rekordy, sortując po ID i dacie
        # To ważne: jeśli created_at jest identyczne, ID nam powie, który był drugi
        latest_two = (
            db.query(FuelPrice)
            .filter(FuelPrice.station_id == station_id, FuelPrice.fuel_type == f_type)
            .order_by(FuelPrice.created_at.desc(), FuelPrice.id.desc())
            .limit(2)
            .all()
        )

        if not latest_two:
            continue

        current = latest_two[0]
        trend = "equal"
        change = 0.0
        
        if len(latest_two) > 1:
            # Konwertujemy na Decimal dla precyzyjnych obliczeń
            curr_val = Decimal(str(latest_two[0].price))
            prev_val = Decimal(str(latest_two[1].price))
            
            diff = curr_val - prev_val

            if diff > 0:
                trend = "up"
                change = float(diff)
            elif diff < 0:
                trend = "down"
                change = float(diff)

        # DEBUG: Wypisz w konsoli co widzi serwer
        print(f"Paliwo: {f_type}, Teraz: {current.price}, Poprzednio: {latest_two[1].price if len(latest_two)>1 else 'BRAK'}, Trend: {trend}")

        results.append({
            "id": current.id,
            "station_id": current.station_id,
            "fuel_type": current.fuel_type,
            "price": float(current.price),
            "created_at": current.created_at,
            "updated_at": current.updated_at,
            "trend": trend,
            "change": change
        })

    return results
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from typing import List
from app.core.db import get_db
from app.models.fuel_price import FuelPrice
from app.models.station import Station
from app.schemas.fuel_price import FuelPriceCreate, FuelPriceRead

router = APIRouter(
    prefix="/prices",
    tags=["Fuel Prices"],
)

# CREATE – tylko dodawanie nowej ceny (przez scraper lub admina)
@router.post("/{station_id}", response_model=FuelPriceRead, status_code=status.HTTP_201_CREATED)
def add_fuel_price(
    station_id: int,
    data: FuelPriceCreate,
    db: Session = Depends(get_db),
):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="station_not_found"
        )

    price = FuelPrice(
        station_id=station_id,
        fuel_type=data.fuel_type,
        price=data.price,
    )
    db.add(price)
    db.commit()
    db.refresh(price)
    return price


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


# READ – tylko najnowsze ceny dla stacji (najważniejszy endpoint!)
@router.get("/latest/{station_id}", response_model=List[FuelPriceRead])
def get_latest_fuel_prices(
    station_id: int,
    db: Session = Depends(get_db),
):
    if not db.query(Station.id).filter(Station.id == station_id).scalar():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="station_not_found"
        )

    # Efektywne zapytanie: najnowsza cena dla każdego fuel_type
    subquery = (
        db.query(
            FuelPrice.fuel_type,
            func.max(FuelPrice.created_at).label("max_created_at")
        )
        .filter(FuelPrice.station_id == station_id)
        .group_by(FuelPrice.fuel_type)
        .subquery()
    )

    latest_prices = (
        db.query(FuelPrice)
        .join(
            subquery,
            and_(
                FuelPrice.fuel_type == subquery.c.fuel_type,
                FuelPrice.created_at == subquery.c.max_created_at,
            )
        )
        .filter(FuelPrice.station_id == station_id)
        .all()
    )

    return latest_prices
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload, aliased
from sqlalchemy import desc, func, and_
from typing import List, Optional
from app.core.db import get_db
from app.models.station import Station
from app.models.fuel_price import FuelPrice
from app.schemas.station import StationCreate, StationRead, StationUpdate
from app.schemas.station_opening_hours import StationOpeningHoursRead

router = APIRouter(prefix="/stations", tags=["Stations"])


@router.post("/", response_model=StationRead, status_code=status.HTTP_201_CREATED)
def create_station(station: StationCreate, db: Session = Depends(get_db)):
    new_station = Station(**station.dict())
    db.add(new_station)
    db.commit()
    db.refresh(new_station)
    return new_station


@router.get("/", response_model=List[StationRead])
def get_stations(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    search: Optional[str] = Query(None, description="Szukaj po nazwie lub adresie"),
    lat: Optional[float] = Query(None),
    lng: Optional[float] = Query(None),
    radius_km: Optional[float] = Query(None, description="Promień w km od podanych współrzędnych"),
):
    query = db.query(Station).options(joinedload(Station.opening_hours))

    if search:
        query = query.filter(
            (Station.name.ilike(f"%{search}%")) | (Station.address.ilike(f"%{search}%"))
        )

    query = query.order_by(Station.id.asc())

    stations = query.offset(skip).limit(limit).all()

    if not stations:
        return []  

    latest_price_subquery = (
        db.query(
            FuelPrice.station_id,
            FuelPrice.fuel_type,
            func.max(FuelPrice.created_at).label("max_created_at")
        )
        .group_by(FuelPrice.station_id, FuelPrice.fuel_type)
        .subquery()
    )

    # Dołącz najnowsze ceny
    latest_prices = (
        db.query(FuelPrice)
        .join(
            latest_price_subquery,
            and_(
                FuelPrice.station_id == latest_price_subquery.c.station_id,
                FuelPrice.fuel_type == latest_price_subquery.c.fuel_type,
                FuelPrice.created_at == latest_price_subquery.c.max_created_at,
            )
        )
        .filter(FuelPrice.station_id.in_([s.id for s in stations]))
        .all()
    )

    # Mapuj ceny do stacji
    prices_by_station = {}
    for price in latest_prices:
        prices_by_station.setdefault(price.station_id, []).append(price)

    for station in stations:
        station.prices = prices_by_station.get(station.id, [])

    return stations


@router.get("/{station_id}", response_model=StationRead)
def get_station(station_id: int, db: Session = Depends(get_db)):
    station = (
        db.query(Station)
        .options(joinedload(Station.opening_hours))
        .filter(Station.id == station_id)
        .first()
    )

    if not station:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="station_not_found"  # klucz dla frontendu
        )

    # Najnowsze ceny – to samo efektywne zapytanie co wyżej, ale tylko dla jednej stacji
    latest_price_subquery = (
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
            latest_price_subquery,
            and_(
                FuelPrice.fuel_type == latest_price_subquery.c.fuel_type,
                FuelPrice.created_at == latest_price_subquery.c.max_created_at,
            )
        )
        .filter(FuelPrice.station_id == station_id)
        .all()
    )

    station.prices = latest_prices
    return station


@router.put("/{station_id}", response_model=StationRead)
def update_station(
    station_id: int,
    update: StationUpdate,
    db: Session = Depends(get_db)
):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="station_not_found"
        )

    update_data = update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(station, key, value)

    db.commit()
    db.refresh(station)
    return station


@router.delete("/{station_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_station(station_id: int, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="station_not_found"
        )

    db.delete(station)
    db.commit()
    return None  # 204 No Content – brak ciała odpowiedzi
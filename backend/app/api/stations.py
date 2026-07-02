from datetime import datetime, date
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_
from typing import List, Optional
from decimal import Decimal

from app.core.db import get_db
from app.models.station import Station
from app.models.fuel_price import FuelPrice
from app.schemas.station import StationCreate, StationRead, StationUpdate

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
    limit: int = Query(100, ge=1, le=100),
    search: Optional[str] = Query(None, description="Szukaj po nazwie lub adresie"),
):
    # 1. Pobieramy podstawowe dane stacji
    query = db.query(Station).options(joinedload(Station.opening_hours))

    if search:
        query = query.filter(
            (Station.name.ilike(f"%{search}%")) | (Station.address.ilike(f"%{search}%"))
        )

    stations = query.order_by(Station.id.asc()).offset(skip).limit(limit).all()

    if not stations:
        return []  

    station_ids = [s.id for s in stations]

    # 2. Pobieramy historię cen dla tych stacji, by wyliczyć trend
    # Sortujemy od najnowszej, aby łatwo wybrać 2 ostatnie w Pythonie
    all_prices = (
        db.query(FuelPrice)
        .filter(FuelPrice.station_id.in_(station_ids))
        .order_by(FuelPrice.station_id, FuelPrice.fuel_type, FuelPrice.created_at.desc())
        .all()
    )

    # 3. Mapowanie i obliczanie trendów
    prices_map = {}
    
    for s_id in station_ids:
        # Filtrujemy ceny tylko dla tej konkretnej stacji
        station_prices = [p for p in all_prices if p.station_id == s_id]
        
        # Grupujemy po typie paliwa
        by_fuel = {}
        for p in station_prices:
            by_fuel.setdefault(p.fuel_type, []).append(p)
        
        calculated_latest = []
        for f_type, p_list in by_fuel.items():
            # Pierwszy element to najnowsza cena
            latest = p_list[0]
            
            # Inicjalizacja pól trendu (wymagane przez nowy schemat Pydantic)
            latest.trend = "equal"
            latest.change = 0.0
            
            # Jeśli mamy co najmniej dwa wpisy, porównujemy
            if len(p_list) > 1:
                curr_val = Decimal(str(latest.price))
                prev_val = Decimal(str(p_list[1].price))
                diff = curr_val - prev_val
                
                if diff > 0:
                    latest.trend = "up"
                    latest.change = float(diff)
                elif diff < 0:
                    latest.trend = "down"
                    latest.change = float(diff)
            
            calculated_latest.append(latest)
        
        prices_map[s_id] = calculated_latest

    # 4. Przypisujemy przetworzone ceny do obiektów stacji
    DAY_ORDER = ["mon", "tue", "wen", "thu", "fri", "sat", "sun"]

    for station in stations:
        station.prices = prices_map.get(station.id, [])
        station.opening_hours.sort(
            key=lambda h: DAY_ORDER.index(h.day_of_week) if h.day_of_week in DAY_ORDER else 99
        )

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
            detail="station_not_found"
        )

    # Pobieramy ceny dla tej konkretnej stacji
    all_prices = (
        db.query(FuelPrice)
        .filter(FuelPrice.station_id == station_id)
        .order_by(FuelPrice.fuel_type, FuelPrice.created_at.desc())
        .all()
    )

    by_fuel = {}
    for p in all_prices:
        by_fuel.setdefault(p.fuel_type, []).append(p)

    calculated_latest = []
    for f_type, p_list in by_fuel.items():
        latest = p_list[0]
        latest.trend = "equal"
        latest.change = 0.0
        
        if len(p_list) > 1:
            diff = Decimal(str(latest.price)) - Decimal(str(p_list[1].price))
            if diff > 0:
                latest.trend = "up"
                latest.change = float(diff)
            elif diff < 0:
                latest.trend = "down"
                latest.change = float(diff)
        
        calculated_latest.append(latest)

    station.prices = calculated_latest
    return station

@router.put("/{station_id}", response_model=StationRead)
def update_station(
    station_id: int,
    update: StationUpdate,
    db: Session = Depends(get_db)
):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="station_not_found")

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
        raise HTTPException(status_code=404, detail="station_not_found")

    db.delete(station)
    db.commit()
    return None
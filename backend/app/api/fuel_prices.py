from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime
from sqlalchemy.orm import Session
from app.core.db import get_db
from typing import List
from app.models.fuel_price import FuelPrice
from app.models.station import Station
from app.schemas.fuel_price import FuelPriceCreate, FuelPriceRead

router = APIRouter(prefix="/prices", tags=["Fuel Prices"])

@router.post("/{station_id}", response_model=FuelPriceRead)
def add_fuel_price(station_id: int, data: FuelPriceCreate, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(404, "Station not found")

    price = FuelPrice(
        station_id=station_id,
        fuel_type=data.fuel_type,
        price=data.price,
    )

    db.add(price)
    db.commit()
    db.refresh(price)
    return price

@router.get("/", response_model=List[FuelPriceRead])
def get_prices(db: Session = Depends(get_db)):
    prices = db.query(FuelPrice).all()
    return prices or []

@router.get("/{station_id}", response_model=List[FuelPriceRead])
def get_fuel_prices(station_id: int, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
    
    prices = db.query(FuelPrice).filter(FuelPrice.station_id == station_id).all()
    return prices or []

@router.get("/latest/{station_id}", response_model=List[FuelPriceRead])
def get_latest_fuel_prices(station_id: int, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(404, "Station not found")
    
    # grupowanie po fuel_type i wybieranie najnowszego
    latest_prices = []
    for fuel_type in ["on", "pb95"]:
        price = db.query(FuelPrice).filter(
            FuelPrice.station_id == station_id,
            FuelPrice.fuel_type == fuel_type
        ).order_by(FuelPrice.created_at.desc()).first()
        if price:
            latest_prices.append(price)
    
    return latest_prices

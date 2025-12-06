from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.db import get_db
from typing import List
from app.models.station import Station
from app.schemas.station import StationCreate, StationRead, StationUpdate

router = APIRouter(prefix="/stations", tags=["Stations"])

@router.post("/", response_model=StationRead)
def create_station(station: StationCreate, db: Session = Depends(get_db)):
    new_station = Station(**station.dict())
    db.add(new_station)
    db.commit()
    db.refresh(new_station)
    return new_station

@router.get("/", response_model=List[StationRead])
def get_stations(db: Session = Depends(get_db)):
    stations = db.query(Station).all()
    return stations or []

@router.get("/{station_id}", response_model=StationRead)
def get_station(station_id: int, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(404, "Station not found")
    return station

@router.put("/{station_id}", response_model=StationRead)
def update_station(station_id: int, update: StationUpdate, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(404, "Station not found")

    for key, value in update.dict(exclude_unset=True).items():
        setattr(station, key, value)

    db.commit()
    db.refresh(station)
    return station

@router.delete("/{station_id}")
def delete_station(station_id: int, db: Session = Depends(get_db)):
    station = db.query(Station).filter(Station.id == station_id).first()
    if not station:
        raise HTTPException(404, "Station not found")

    db.delete(station)
    db.commit()
    return {"message": "Station deleted"}

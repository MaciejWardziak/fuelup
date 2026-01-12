# app/routers/fuel_prices_archive.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.core.db import get_db
from app.models.fuel_price_archive import FuelPriceArchive
from app.models.station import Station
from app.schemas.fuel_price_archive import FuelPriceArchiveRead

router = APIRouter(
    prefix="/archive",
    tags=["Fuel Prices Archive"],
)

@router.get("/{station_id}", response_model=List[FuelPriceArchiveRead])
def get_archive_prices_for_station(
    station_id: int,
    db: Session = Depends(get_db),
):
    if not db.query(Station).filter(Station.id == station_id).first():
        raise HTTPException(status_code=404, detail="station_not_found")

    archive_prices = (
        db.query(FuelPriceArchive)
        .filter(FuelPriceArchive.station_id == station_id)
        .order_by(FuelPriceArchive.created_at)
        .all()
    )

    return archive_prices
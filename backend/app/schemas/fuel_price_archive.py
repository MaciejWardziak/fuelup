# app/schemas/fuel_price.py

from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class FuelPriceArchiveBase(BaseModel):
    fuel_type: str
    price: float  

class FuelPriceArchiveCreate(FuelPriceArchiveBase):
    pass

class FuelPriceArchiveRead(FuelPriceArchiveBase):
    id: int
    station_id: int
    created_at: datetime

    class Config:
        orm_mode = True
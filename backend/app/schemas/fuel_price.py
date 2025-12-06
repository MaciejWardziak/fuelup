from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class FuelPriceBase(BaseModel):
    fuel_type: str
    price: float

class FuelPriceCreate(FuelPriceBase):
    pass

class FuelPriceRead(BaseModel):
    id: int
    station_id: int
    fuel_type: str
    price: float
    created_at: datetime

    class Config:
        orm_mode = True

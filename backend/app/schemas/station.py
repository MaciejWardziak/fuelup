from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List
from app.schemas.fuel_price import FuelPriceRead

class StationBase(BaseModel):
    name: str
    address: Optional[str] = None
    website_url: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None

class StationCreate(StationBase):
    pass

class StationUpdate(StationBase):
    pass

class StationRead(BaseModel):
    id: int
    name: str
    address: Optional[str] = None
    website_url: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    prices: List[FuelPriceRead] = []

    class Config:
        from_attributes = True

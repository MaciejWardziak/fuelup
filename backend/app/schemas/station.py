from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List, Dict, Any
from app.schemas.fuel_price import FuelPriceRead
from app.schemas.station_opening_hours import StationOpeningHoursRead

class StationBase(BaseModel):
    name: str
    address: Optional[str] = None
    website_url: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    scraper_config: Optional[Dict[str, Any]] = None

class StationCreate(StationBase):
    pass

class StationUpdate(StationBase):
    name: Optional[str] = None
    address: Optional[str] = None
    website_url: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    scraper_config: Optional[Dict[str, Any]] = None

class StationRead(BaseModel):
    id: int
    name: str
    address: Optional[str] = None
    website_url: Optional[str] = None
    last_updated: Optional[datetime] = None
    scraper_config: Optional[Dict[str, Any]] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    prices: List[FuelPriceRead] = []
    opening_hours: List[StationOpeningHoursRead] = []

    class Config:
        from_attributes = True

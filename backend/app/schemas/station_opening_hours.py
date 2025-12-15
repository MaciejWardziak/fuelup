from pydantic import BaseModel
from datetime import time, datetime
from typing import Optional

class StationOpeningHoursBase(BaseModel):
    day_of_week: str
    open_time: time
    close_time: time

class StationOpeningHoursCreate(StationOpeningHoursBase):
    station_id: int

class StationOpeningHoursRead(StationOpeningHoursBase):
    id: int
    station_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class StationOpeningHoursUpdate(StationOpeningHoursBase):
    day_of_week: Optional[str] = None
    open_time: Optional[time] = None
    close_time: Optional[time] = None
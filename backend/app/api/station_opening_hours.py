from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.db import get_db
from app.models.station_opening_hours import StationOpeningHours
from app.schemas import StationOpeningHoursCreate, StationOpeningHoursRead
from datetime import datetime

router = APIRouter(prefix="/opening_hours", tags=["opening_hours"])

@router.post("/", response_model=StationOpeningHoursRead)
def create_opening_hours(data: StationOpeningHoursCreate, db: Session = Depends(get_db)):
    oh = StationOpeningHours(**data.dict())
    db.add(oh)
    db.commit()
    db.refresh(oh)
    return oh

@router.get("/{station_id}", response_model=list[StationOpeningHoursRead])
def get_opening_hours(station_id: int, db: Session = Depends(get_db)):
    hours = db.query(StationOpeningHours).filter_by(station_id=station_id).all()
    if not hours:
        # zwracamy "pusty" rekord z poprawnymi polami, żeby FastAPI nie narzekało
        return [{
            "id": 0,
            "station_id": station_id,
            "day_of_week": "",
            "open_time": None,
            "close_time": None,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }]
    return hours


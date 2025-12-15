from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.db import get_db
from app.models.station_opening_hours import StationOpeningHours
from app.schemas.station_opening_hours import (
    StationOpeningHoursCreate,
    StationOpeningHoursRead,
    StationOpeningHoursUpdate,
)

router = APIRouter(
    prefix="/opening-hours",  
    tags=["Opening Hours"],
)

# CREATE
@router.post("/", response_model=StationOpeningHoursRead, status_code=status.HTTP_201_CREATED)
def create_opening_hours(
    data: StationOpeningHoursCreate,
    db: Session = Depends(get_db),
):
    oh = StationOpeningHours(**data.dict())
    db.add(oh)
    db.commit()
    db.refresh(oh)
    return oh


# READ ALL dla danej stacji
@router.get("/{station_id}", response_model=List[StationOpeningHoursRead])
def get_opening_hours_for_station(
    station_id: int,
    db: Session = Depends(get_db),
):
    hours = db.query(StationOpeningHours).filter_by(station_id=station_id).all()
    
    return hours  


@router.put("/{hours_id}", response_model=StationOpeningHoursRead)
def update_opening_hours(
    hours_id: int,
    update: StationOpeningHoursUpdate,
    db: Session = Depends(get_db),
):
    hours = db.query(StationOpeningHours).filter(StationOpeningHours.id == hours_id).first()
    if not hours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="opening_hours_not_found"
        )

    update_data = update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(hours, key, value)

    db.commit()
    db.refresh(hours)
    return hours


@router.delete("/{hours_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_opening_hours(
    hours_id: int,
    db: Session = Depends(get_db),
):
    hours = db.query(StationOpeningHours).filter(StationOpeningHours.id == hours_id).first()
    if not hours:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="opening_hours_not_found"
        )

    db.delete(hours)
    db.commit()
    return None  # 204 No Content
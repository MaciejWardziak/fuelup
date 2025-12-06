from sqlalchemy import Column, Integer, String, Time, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.core.db import Base
from datetime import datetime

class StationOpeningHours(Base):
    __tablename__ = "station_opening_hours"

    id = Column(Integer, primary_key=True, index=True)
    station_id = Column(Integer, ForeignKey("stations.id"), nullable=False)
    day_of_week = Column(String, nullable=False)  # "mon", "tue", ..., "sun"
    open_time = Column(Time, nullable=False)
    close_time = Column(Time, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    station = relationship("Station", back_populates="opening_hours")

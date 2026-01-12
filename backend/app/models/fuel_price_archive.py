from sqlalchemy import Column, Integer, String, ForeignKey, Numeric, DateTime, Index
from sqlalchemy.orm import relationship
from app.core.db import Base
from datetime import datetime

class FuelPriceArchive(Base):
    __tablename__ = "fuel_prices_archive"

    id = Column(Integer, primary_key=True, index=True) 
    station_id = Column(Integer, ForeignKey("stations.id", ondelete="CASCADE"), nullable=False, index=True)
    fuel_type = Column(String, nullable=False, index=True)
    price = Column(Numeric(5, 2), nullable=False)
    created_at = Column(DateTime, nullable=False)

    __table_args__ = (
        Index('ix_fuel_prices_archive_station_fuel_created', "station_id", "fuel_type", "created_at"),
    )
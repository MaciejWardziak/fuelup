from sqlalchemy import Column, Integer, String, ForeignKey, Numeric, DateTime, Index
from sqlalchemy.orm import relationship
from app.core.db import Base
from datetime import datetime

class FuelPrice(Base):
    __tablename__ = "fuel_prices"

    id = Column(Integer, primary_key=True, index=True)
    station_id = Column(Integer, ForeignKey("stations.id"), nullable=False)
    fuel_type = Column(String, nullable=False)
    price = Column(Numeric(5, 2), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    station = relationship("Station", back_populates="prices")

    # Brak __table_args__ – nie potrzebujemy tu dodatkowego indeksu archive
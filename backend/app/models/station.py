from sqlalchemy import Column, Integer, String, Float, ForeignKey, Numeric, DateTime, JSON
from sqlalchemy.orm import relationship
from app.core.db import Base
from datetime import datetime

class Station(Base):
    __tablename__ = "stations"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    address = Column(String)
    website_url = Column(String, nullable=True)
    last_updated = Column(DateTime, default=None)
    lat = Column(Float)
    lng = Column(Float)
    scraper_config = Column(JSON, nullable=True, default=None)
    # Przykład wartości:
    # {"type": "list"}                                      # E.Leclerc
    # {"type": "table"}                                     # stacja z tabelą
    # {"type": "text", "filter_by_city": true}              # Rolmasz
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


    prices = relationship("FuelPrice", back_populates="station", cascade="all, delete")
    opening_hours = relationship("StationOpeningHours", back_populates="station", cascade="all, delete")




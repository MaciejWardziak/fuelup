#!/bin/bash
set -e

echo "=== Uruchamiamy backend FuelUp ==="

cd backend

echo "Aktywujemy wirtualne środowisko..."
source venv/bin/activate

echo "Wykonujemy migracje bazy (Alembic)..."
alembic upgrade head

echo "Uruchamiamy backend FastAPI..."
python -m uvicorn app.main:app --reload --host 0.0.0.0

cd ..
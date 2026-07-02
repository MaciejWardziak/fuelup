#!/bin/bash
set -e

echo "=== Setup backendu FuelUp ==="

cd backend

echo "Tworzymy wirtualne środowisko Pythona..."
python3 -m venv venv

echo "Aktywujemy wirtualne środowisko..."
source venv/bin/activate

echo "Instalujemy zależności..."
pip install -r requirements.txt

echo "Wykonujemy migracje bazy danych (Alembic)..."
alembic upgrade head

echo "=== Setup zakończony! ==="
echo "Teraz uruchom: ./start_backend.sh"

cd ..
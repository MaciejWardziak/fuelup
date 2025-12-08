#!/bin/bash

set -e

echo "=== 1. Uruchamiamy Docker i PostgreSQL ==="
sudo docker compose up -d

echo "=== 2. Tworzymy/aktualizujemy wirtualne środowisko Pythona w backend ==="
cd backend
python3 -m venv venv
source venv/bin/activate

echo "=== 3. Instalujemy zależności backend ==="
pip install --upgrade pip
pip install -r requirements.txt

echo "=== 4. Tworzymy tabele w bazie i wypełniamy populate.py ==="
python populate.py

cd ..

echo "=== 5. Instalujemy zależności frontend ==="
cd frontend
npm install
cd ..

echo "=== 6. Uruchamiamy backend FastAPI w osobnym terminalu ==="
gnome-terminal -- bash -c "cd backend && source venv/bin/activate && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000; exec bash"

echo "=== 7. Uruchamiamy frontend Vite w osobnym terminalu ==="
gnome-terminal -- bash -c "cd frontend && npm run dev; exec bash"

echo "=== Setup zakończony! ==="

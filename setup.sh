#!/bin/bash
set -e  # Przerywa skrypt przy błędzie

echo "=== 1. Uruchamiamy Docker i PostgreSQL ==="
sudo docker compose up -d

# Czekamy chwilę aż PostgreSQL się uruchomi (ważne przy pierwszym uruchomieniu)
echo "Czekamy 10 sekund aż baza PostgreSQL będzie gotowa..."
sleep 10

echo "=== 2. Tworzymy/aktualizujemy wirtualne środowisko Pythona w backend ==="
cd backend

if [ ! -d "venv" ]; then
  python3 -m venv venv
fi

source venv/bin/activate

echo "=== 3. Instalujemy/aktualizujemy zależności backend ==="
pip install --upgrade pip
pip install -r requirements.txt

echo "=== 4. Wykonujemy migracje bazy danych (Alembic) ==="
alembic upgrade head
echo "Migracje zakończone – baza ma aktualną strukturę."

echo "=== 5. Wypełniamy bazę przykładowymi danymi (populate.py) ==="
python populate.py
echo "Dane testowe wstawione."

cd ..

echo "=== 6. Instalujemy zależności frontend ==="
cd frontend
npm install
cd ..

echo "=== 7. Uruchamiamy backend FastAPI w osobnym terminalu ==="
gnome-terminal --title="FuelUp Backend" -- bash -c "cd backend && source venv/bin/activate && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000; echo 'Backend zatrzymany – naciśnij Enter aby zamknąć...'; read"

echo "=== 8. Uruchamiamy frontend Vite w osobnym terminalu ==="
gnome-terminal --title="FuelUp Frontend" -- bash -c "cd frontend && npm run dev; echo 'Frontend zatrzymany – naciśnij Enter aby zamknąć...'; read"

echo "=== Setup zakończony! ==="
echo "Backend działa na: http://localhost:8000"
echo "Frontend działa na: http://localhost:5173 (lub inny port podany w terminalu)"
echo "Dokumentacja API: http://localhost:8000/docs"

echo "Od teraz do szybkiego uruchamiania używaj: ./run.sh"
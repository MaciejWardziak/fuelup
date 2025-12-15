#!/bin/bash
set -e  # Przerywa przy błędzie

echo "=== Uruchamiamy Docker (PostgreSQL) ==="
sudo docker compose up -d

# Krótka przerwa na start bazy
echo "Czekamy 8 sekund aż baza będzie gotowa..."
sleep 8

echo "=== Wykonujemy migracje bazy (Alembic) – tylko jeśli potrzebne ==="
cd backend
source venv/bin/activate
alembic upgrade head
echo "Baza zaktualizowana."
cd ..

echo "=== Uruchamiamy backend FastAPI w osobnym terminalu ==="
gnome-terminal --title="FuelUp Backend" -- bash -c "cd backend && source venv/bin/activate && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000; echo 'Backend zatrzymany – naciśnij Enter aby zamknąć...'; read"

echo "=== Uruchamiamy frontend Vite w osobnym terminalu ==="
gnome-terminal --title="FuelUp Frontend" -- bash -c "cd frontend && npm run dev; echo 'Frontend zatrzymany – naciśnij Enter aby zamknąć...'; read"

echo "=== Aplikacja uruchomiona! ==="
echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:5173 (lub port podany w terminalu)"
echo "API docs: http://localhost:8000/docs"
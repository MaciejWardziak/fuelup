Write-Host "=== Uruchamiamy backend FuelUp ===" -ForegroundColor Green

Set-Location backend

Write-Host "Aktywujemy wirtualne środowisko..."
& venv\Scripts\Activate.ps1

Write-Host "Wykonujemy migracje bazy (Alembic)..."
alembic upgrade head

Write-Host "Uruchamiamy backend FastAPI..."
python -m uvicorn app.main:app --reload --host 0.0.0.0

Set-Location ..
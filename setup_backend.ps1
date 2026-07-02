Write-Host "=== Setup backendu FuelUp ===" -ForegroundColor Green

Set-Location backend

Write-Host "Tworzymy wirtualne środowisko Pythona..."
python -m venv venv

Write-Host "Aktywujemy wirtualne środowisko..."
& venv\Scripts\Activate.ps1

Write-Host "Instalujemy zależności..."
pip install -r requirements.txt

Write-Host "Wykonujemy migracje bazy danych (Alembic)..."
alembic upgrade head

Write-Host "=== Setup zakończony! ===" -ForegroundColor Green
Write-Host "Teraz uruchom: .\start_backend.ps1"

Set-Location ..
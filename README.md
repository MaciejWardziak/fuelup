# FuelUp – aplikacja do sprawdzania cen paliw

FuelUp to aplikacja mobilna Flutter do sprawdzania cen paliw na lokalnych stacjach.
Składa się z **backendu FastAPI + SQLite** oraz **aplikacji mobilnej Flutter**.

---

## Struktura projektu
fuelup/
backend/    # FastAPI + SQLite + scraper cen paliw
frontend/   # React/Vite (wersja webowa – branch develop)
mobile/     # Flutter (wersja mobilna – branch mobile)

---

## Wymagania wstępne

- Python 3.9+
- Flutter SDK 3.10+
- Android Studio (emulator Android)

---

## Uruchomienie backendu

### Pierwsze uruchomienie (setup)

Windows (PowerShell):
```powershell
.\setup_backend.ps1
```

Mac/Linux:
```bash
chmod +x setup_backend.sh
./setup_backend.sh
```

### Kolejne uruchomienia

Windows:
```powershell
.\start_backend.ps1
```

Mac/Linux:
```bash
./start_backend.sh
```
> **Windows:** Jeśli PowerShell blokuje skrypty, uruchom najpierw:
> `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

Backend dostępny pod: `http://localhost:8000`  
Dokumentacja API: `http://localhost:8000/docs`

---

## Uruchomienie aplikacji Flutter

```powershell
cd mobile
flutter pub get
flutter run
```

> Upewnij się że backend działa przed uruchomieniem aplikacji.

---

## Konfiguracja

Plik `backend/.env`:
DATABASE_URL=sqlite:///./fuelup.db

---

## Autor

Projekt przygotowany przez Maciej Wardziak
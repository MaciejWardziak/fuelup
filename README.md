# FuelUp – prototyp strony do sprawdzania cen paliw

FuelUp to prototyp aplikacji webowej umożliwiającej sprawdzanie informacji o cenach paliw na konkretnych stacjach oraz w wybranych okolicach. Aplikacja składa się z **backendu FastAPI** oraz **frontendu React/Vite**.  

---

## Pobranie repozytorium GitHub

git clone --branch develop https://github.com/MaciejWardziak/fuelup/.git


---

## Wymagania wstępne

Przed uruchomieniem projektu należy upewnić się, że system posiada zainstalowane poniższe narzędzia. Komendy różnią się w zależności od dystrybucji Linuxa.

### 1. Python 3.9+ i pip

python3 --version
pip3 --version

Instalacja (Ubuntu/Debian):

sudo apt update && sudo apt install python3 python3-venv python3-pip -y

Instalacja (Fedora):

sudo dnf install python3 python3-venv python3-pip -y


### 2. Node.js i npm (zalecana wersja Node 20+)

node --version
npm --version

Instalacja/aktualizacja (Ubuntu/Debian):

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

Instalacja/aktualizacja (Fedora):

sudo dnf module reset nodejs
sudo dnf module enable nodejs:20
sudo dnf install nodejs -y


### 3. Docker i Docker Compose

docker --version
docker compose version

Instalacja (Ubuntu/Debian):

sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl enable --now docker

Instalacja (Fedora):

sudo dnf install docker docker-compose -y
sudo systemctl enable --now docker


### 4. GNOME Terminal (do uruchamiania backendu i frontendu w osobnych oknach)

gnome-terminal --version

Instalacja (Ubuntu/Debian):

sudo apt install gnome-terminal -y

Instalacja (Fedora):

sudo dnf install gnome-terminal -y

> Jeśli GNOME Terminal nie jest dostępny, backend i frontend można uruchomić ręcznie w osobnych terminalach.



## Konfiguracja backendu

1. Przejdź do folderu `backend`:

cd backend


2. Skopiuj plik `.env.example` do `.env`:

cp .env.example .env


3. Edytuj `.env`, jeśli trzeba zmienić dane połączenia z bazą PostgreSQL.  
Przykładowe wartości:

POSTGRES_USER=fuelup
POSTGRES_PASSWORD=fuelup
POSTGRES_DB=fuelup_db
POSTGRES_HOST=localhost
POSTGRES_PORT=5432 #lub 5433


---

## Uruchomienie projektu

1. Wróć do folderu głównego projektu:

cd ..


2. Nadaj uprawnienia do wykonywania skryptu:

chmod +x setup.sh


3. Uruchom setup:

./setup.sh


Skrypt wykona następujące kroki:  
- Uruchomi **Docker i PostgreSQL**  
- Utworzy wirtualne środowisko Pythona w `backend/venv`  
- Zainstaluje zależności backendu (`pip install -r backend/requirements.txt`)  
- Wykona `populate.py` w celu utworzenia początkowych danych w bazie  
- Zainstaluje zależności frontendu (`npm install`)  
- Uruchomi backend FastAPI w osobnym terminalu  
- Uruchomi frontend Vite w osobnym terminalu  

Po uruchomieniu backend będzie dostępny pod `http://localhost:8000`, a frontend pod adresem podanym przez Vite (domyślnie `http://localhost:5173`).

---

## Ręczne uruchamianie backendu/frontendu (jeśli brak GNOME Terminal)

### Backend

cd backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000


### Frontend

cd frontend
npm run dev


---

## Uwagi

- Jeśli napotkasz problemy z wersją Node.js lub npm, upewnij się, że masz Node 20+.  
- Nie jest wymagane wirtualne środowisko w folderze głównym – wszystkie zależności Pythona są w `backend/venv`.  
- `setup.sh` automatyzuje większość kroków i otwiera backend oraz frontend w osobnych oknach GNOME Terminal.  

---

## Autor
- Projekt przygotowany przez [Maciej Wardziak]  

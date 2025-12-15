# app/core/scraper.py
import requests
from bs4 import BeautifulSoup
import re
from typing import List, Dict, Optional

HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}

# --------------------------------------------------
# Wspólne stałe – używane przez wszystkie parsery
# --------------------------------------------------

# Mapowanie różnych wariantów nazw paliw na nasze standardowe kody
FUEL_MAP = {
    'on': 'on',
    'olej': 'on',
    'diesel': 'on',
    'pb95': 'pb95',
    'pb': 'pb95',
    '95': 'pb95',
    'benzyna': 'pb95',
    'pb98': 'pb98',
    '98': 'pb98',
    'lpg': 'lpg',
    'gaz': 'lpg',
    'cng': 'cng',
    'adblue': 'adblue',
    'ad-blue': 'adblue',
    'blue': 'adblue',
}

# Zbiór standardowych kodów paliw (do szybkiego sprawdzania w parse_list)
KNOWN_FUELS = set(FUEL_MAP.values())

# Priorytet klas w <li> dla E.Leclerc (żeby wybrać właściwą, gdy jest np. "on b7")
FUEL_CLASS_PRIORITY = ['pb95', 'pb98', 'on', 'lpg', 'cng', 'adblue']


def extract_city_from_address(address: Optional[str]) -> Optional[str]:
    """
    Wyciąga miasto z adresu stacji (np. "Szczecińska 36k, 76-200 Słupsk" → "Słupsk")
    Poprawiona wersja – bardziej odporna na różne formaty.
    """
    if not address:
        return None

    # Usuwamy nadmiarowe spacje i dzielimy po przecinkach
    parts = [part.strip() for part in address.split(',') if part.strip()]

    # Miasto zazwyczaj jest ostatnią częścią po przecinku
    if parts:
        candidate = parts[-1]
        # Sprawdzamy czy wygląda jak miasto (duża litera, litery, >3 znaki)
        if len(candidate) > 3 and candidate[0].isupper() and candidate.replace('-', '').isalpha():
            return candidate

    # Fallback: szukamy w całym adresie słowa z wielkiej litery
    words = re.findall(r'\b[A-ZŚĆŹŻŁŃÓĄĘ][a-zśćźżłńóąę]+\b', address)
    if words:
        return words[-1]  # zazwyczaj ostatnie to miasto

    print(f"Nie udało się wyciągnąć miasta z adresu: {address}")
    return None


def parse_list(soup: BeautifulSoup) -> List[Dict]:
    """Parser dla stacji typu E.Leclerc – ceny w <ul> z klasami w <li>"""
    prices = []

    # Szukamy charakterystycznego nagłówka
    header = soup.find(lambda tag: tag.name == 'span' and 'h2' in tag.get('class', [])
                      and "ceny paliw" in tag.get_text(strip=True).lower())

    if not header:
        print("Nie znaleziono nagłówka <span class='h2'>Ceny paliw</span>")
        return []

    # Najpierw próbujemy najbliższy <ul> jako sibling
    ul = header.find_next_sibling('ul')
    if not ul:
        # Fallback: <ul> wewnątrz tego samego rodzica
        parent = header.parent
        ul = parent.find('ul') if parent else None

    if not ul:
        print("Nie znaleziono <ul> z cenami")
        return []

    for li in ul.find_all('li'):
        text = li.get_text(strip=True)
        if not text:
            continue

        price_str = text.replace(' ', '').replace(',', '.')
        try:
            price = float(price_str)
        except ValueError:
            print(f"Niepoprawna cena w liście: {text}")
            continue

        classes = [cls.lower() for cls in li.get('class', []) if cls]
        fuel = None
        for candidate in FUEL_CLASS_PRIORITY:
            if candidate in classes:
                fuel = candidate
                break

        if not fuel:
            print(f"Pominięto <li> bez znanego paliwa: klasy={classes}, tekst={text}")
            continue

        prices.append({"fuel": fuel, "price": price})

    return prices


def parse_table(soup: BeautifulSoup) -> List[Dict]:
    """Parser dla stacji z cenami w <table> (np. MZK) + AdBlue spoza tabeli"""
    prices = []

    # --- Część 1: Standardowe paliwa z tabeli ---
    table = soup.find('table')
    if table:
        for tr in table.find_all('tr'):
            cells = tr.find_all(['th', 'td'])
            if len(cells) < 2:
                continue

            fuel_cell = cells[0]
            price_cell = cells[1]

            fuel_text = fuel_cell.get_text(separator=' ', strip=True).lower()

            fuel = None
            for key, mapped in FUEL_MAP.items():
                if key in fuel_text:
                    fuel = mapped
                    break

            if not fuel:
                print(f"Pominięto nieznane paliwo w tabeli: {fuel_text}")
                continue

            price_text = price_cell.get_text(separator=' ', strip=True)
            price_text = re.sub(r'\s*zł\s*|\s*<br\s*/?>\s*', ' ', price_text, flags=re.I)
            price_text = re.sub(r'[^\d,.]', '', price_text)

            if not price_text:
                continue

            try:
                price = float(price_text.replace(',', '.'))
                prices.append({"fuel": fuel, "price": price})
            except ValueError:
                print(f"Nie udało się przekonwertować ceny z tabeli: '{price_text}' dla {fuel}")

    # --- Część 2: AdBlue spoza tabeli (dedykowany regex) ---
    # Szukamy tekstu typu "AdBlue w cenie 2,49 zł/l" lub podobnego
    adblue_text = soup.find(string=re.compile(r'adblue', re.I))
    if adblue_text:
        parent_p = adblue_text.find_parent('p')
        if parent_p:
            text = parent_p.get_text(separator=' ', strip=True)
            # Regex: szuka liczby z przecinkiem po "cena" lub "cenie", opcjonalnie zł/l
            match = re.search(r'cenie?\s*(\d+,\d+)\s*zł', text, re.I)
            if match:
                price_str = match.group(1)
                try:
                    price = float(price_str.replace(',', '.'))
                    prices.append({"fuel": "adblue", "price": price})
                except ValueError:
                    print(f"Błąd konwersji ceny AdBlue: {price_str}")
            else:
                print(f"Znaleziono tekst z AdBlue, ale bez czytelnej ceny: {text}")
        else:
            print("Znaleziono AdBlue, ale nie w <p>")

    return prices


def parse_text(soup: BeautifulSoup, target_city: Optional[str] = None) -> List[Dict]:
    """Parser dla stacji z cenami w akapitach tekstowych (np. Rolmasz – wiele miast)"""
    prices = []

    if not target_city:
        print("Brak target_city – nie można filtrować w parse_text")
        return []

    target_city_lower = target_city.strip().lower()

    for p in soup.find_all('p'):
        text = p.get_text(separator=' ', strip=True)
        if not text:
            continue

        # Normalizacja myślników i spacji
        text = text.replace('&#8211;', '-').replace('–', '-').replace('—', '-').replace('−', '-')
        text = re.sub(r'\s+', ' ', text)
        text_lower = text.lower()

        if target_city_lower not in text_lower:
            continue

        # Główny regex – łapie większość przypadków
        pattern = r'([A-Za-z0-9]+)\s*[-–—]\s*(\d+,\d+)\s*(zł)?'
        matches = re.findall(pattern, text, re.IGNORECASE)

        for fuel_raw, price_str, _ in matches:
            fuel_key = fuel_raw.strip().lower()
            fuel = FUEL_MAP.get(fuel_key)
            if not fuel:
                continue

            price_clean = price_str.replace(' ', '').replace(',', '.')
            try:
                price = float(price_clean)
                prices.append({"fuel": fuel, "price": price})
            except ValueError:
                continue

    # Fallback dla przypadków bez "zł" (np. LPG -2,84)
    if not prices:
        for p in soup.find_all('p'):
            text = p.get_text(separator=' ', strip=True)
            text = text.replace('&#8211;', '-').replace('–', '-').replace('—', '-')
            text = re.sub(r'\s+', ' ', text)
            if target_city_lower not in text.lower():
                continue

            alt_matches = re.findall(r'([A-Za-z0-9]+)\s*[-–—]\s*(\d+,\d+)', text, re.IGNORECASE)
            for fuel_raw, price_str in alt_matches:
                fuel_key = fuel_raw.strip().lower()
                fuel = FUEL_MAP.get(fuel_key)
                if not fuel:
                    continue
                price_clean = price_str.replace(' ', '').replace(',', '.')
                try:
                    price = float(price_clean)
                    prices.append({"fuel": fuel, "price": price})
                except ValueError:
                    continue

    return prices


def scrape_station_prices(
    url: str,
    scraper_config: Optional[Dict] = None,
    address: Optional[str] = None
) -> List[Dict]:
    """Główna funkcja scrapera"""
    if not url:
        print("Brak URL")
        return []

    if not scraper_config or "type" not in scraper_config:
        print("Brak lub niepoprawny scraper_config")
        return []

    try:
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Błąd pobierania {url}: {e}")
        return []

    soup = BeautifulSoup(response.text, "html.parser")
    config_type = scraper_config.get("type")

    if config_type == "list":
        return parse_list(soup)
    elif config_type == "table":
        return parse_table(soup)
    elif config_type == "text":
        target_city = extract_city_from_address(address) if scraper_config.get("filter_by_city") else None
        return parse_text(soup, target_city=target_city)
    else:
        print(f"Nieznany typ scrapera: {config_type}")
        return []
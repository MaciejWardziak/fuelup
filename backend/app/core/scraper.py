# app/core/scraper.py
import requests
from bs4 import BeautifulSoup

def scrape_station_prices(url: str):
    """
    Pobiera ceny paliw ze strony stacji.
    Zwraca listę słowników: [{"fuel": "on", "price": 5.83}, {"fuel": "pb95", "price": 5.65}]
    """
    response = requests.get(url)
    if response.status_code != 200:
        print(f"Nie udało się pobrać strony: {url}")
        return []

    soup = BeautifulSoup(response.text, "html.parser")

    prices = []

    # ON (diesel)
    on_elem = soup.select_one("li.on.b7")
    if on_elem and on_elem.text.strip():
        try:
            prices.append({"fuel": "on", "price": float(on_elem.text.strip().replace(",", "."))})
        except ValueError:
            print(f"Nie udało się sparsować ceny ON: {on_elem.text.strip()}")

    # Pb95 (benzyna)
    pb95_elem = soup.select_one("li.pb95")
    if pb95_elem and pb95_elem.text.strip():
        try:
            prices.append({"fuel": "pb95", "price": float(pb95_elem.text.strip().replace(",", "."))})
        except ValueError:
            print(f"Nie udało się sparsować ceny Pb95: {pb95_elem.text.strip()}")

    return prices

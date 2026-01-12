// src/services/stationService.ts

import type { Station } from "../models/Station";
import type { FuelPrice } from "../models/FuelPrice";
import type { StationOpeningHours } from "../models/StationOpeningHours";

const API_URL = "http://127.0.0.1:8000"; // w produkcji przenieś do .env

export type StationFullData = {
  station: Station;
  prices: FuelPrice[];
  opening_hours: StationOpeningHours[];
};

// Pobiera WSZYSTKIE stacje (używane na HomePage)
export async function getAllStations(): Promise<StationFullData[]> {
  try {
    const response = await fetch(`${API_URL}/stations/`);

    if (!response.ok) {
      throw new Error(`Błąd serwera: ${response.status} ${response.statusText}`);
    }

    const rawStations: Station[] = await response.json();

    return rawStations.map((station) => ({
      station,
      prices: station.prices ?? [],
      opening_hours: station.opening_hours ?? [],
    }));
  } catch (err) {
    console.error("Błąd pobierania listy stacji:", err);
    throw err; // przekazujemy błąd do komponentu
  }
}

// Pobiera jedną stację po ID (na przyszłość – np. strona szczegółów)
export async function getStationFullData(id: number): Promise<StationFullData | null> {
  try {
    const response = await fetch(`${API_URL}/stations/${id}`);

    if (!response.ok) {
      if (response.status === 404) {
        console.warn(`Stacja o ID ${id} nie została znaleziona (404)`);
        return null;
      }
      console.error(`Błąd serwera: ${response.status} ${response.statusText}`);
      return null;
    }

    const station: Station = await response.json();

    return {
      station,
      prices: station.prices ?? [],
      opening_hours: station.opening_hours ?? [],
    };
  } catch (err) {
    console.error("Błąd połączenia z backendem:", err);
    return null;
  }
}

export async function getRecentPrices(stationId: number): Promise<FuelPrice[]> {
  try {
    const response = await fetch(`${API_URL}/prices/${stationId}`);
    return response.ok ? await response.json() : [];
  } catch (err) {
    console.error("Błąd pobierania cen bieżących:", err);
    return [];
  }
}

// Pomocnicza funkcja do pobierania cen archiwalnych (starsze niż 30 dni)
export async function getArchivedPrices(stationId: number): Promise<FuelPrice[]> {
  try {
    const response = await fetch(`${API_URL}/archive/${stationId}`);
    return response.ok ? await response.json() : [];
  } catch (err) {
    console.error("Błąd pobierania archiwum:", err);
    return [];
  }
}

// GŁÓWNA FUNKCJA DLA WYKRESU
export async function getFullPriceHistory(stationId: number): Promise<FuelPrice[]> {
  try {
    // Pobieramy oba źródła jednocześnie dla szybkości
    const [recent, archived] = await Promise.all([
      getRecentPrices(stationId),
      getArchivedPrices(stationId)
    ]);

    // Łączymy tablice
    const combined = [...recent, ...archived];

    // Opcjonalnie: Usuwanie duplikatów po ID (na wypadek, gdyby ten sam rekord był w obu tabelach)
    const unique = Array.from(new Map(combined.map(item => [item.id, item])).values());

    return unique;
  } catch (err) {
    console.error("Błąd podczas łączenia historii:", err);
    return [];
  }
}
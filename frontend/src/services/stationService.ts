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
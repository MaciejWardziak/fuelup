import type { Station } from "../models/Station";
import type { FuelPrice } from "../models/FuelPrice";
import type { StationOpeningHours } from "../models/StationOpeningHours";

const API_URL = "http://127.0.0.1:8000"; // dostosuj URL backendu

export type StationFullData = {
  station: Station;
  prices: FuelPrice[];
  opening_hours: StationOpeningHours[];
};

export async function getStationFullData(id: number): Promise<StationFullData | null> {
  try {
    const [stationRes, pricesRes, hoursRes] = await Promise.all([
      fetch(`${API_URL}/stations/${id}`),
      fetch(`${API_URL}/prices/${id}`),
      fetch(`${API_URL}/opening_hours/${id}`)
    ]);


    if (!stationRes.ok || !pricesRes.ok || !hoursRes.ok) {
      console.error("Błąd pobierania danych stacji:", stationRes.status, pricesRes.status, hoursRes.status);
      return null;
    }

    const station: Station = await stationRes.json();
    const prices: FuelPrice[] = await pricesRes.json();
    const opening_hours: StationOpeningHours[] = await hoursRes.json();

    return { station, prices, opening_hours };
  } catch (err) {
    console.error("Błąd fetch:", err);
    return null;
  }
}

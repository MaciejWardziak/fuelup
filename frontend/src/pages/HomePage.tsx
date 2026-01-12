// src/pages/HomePage.tsx (lub gdzie masz HomePage)

import { useEffect, useState } from "react";
import type { StationFullData } from "../services/stationService";
import { getAllStations } from "../services/stationService";
import StationCard from "../components/StationCard"; // <-- tylko to importujemy

const sortOptions = [
  { value: "", label: "Bez sortowania" },
  { value: "pb95", label: "Pb95 – od najtańszej" },
  { value: "on", label: "ON – od najtańszej" },
  { value: "pb98", label: "Pb98 – od najtańszej" },
  { value: "lpg", label: "LPG – od najtańszej" },
  { value: "cng", label: "CNG – od najtańszej" },
  { value: "adblue", label: "AdBlue – od najtańszej" },
];

export default function HomePage() {
  const [stations, setStations] = useState<StationFullData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortByFuel, setSortByFuel] = useState<string>("");

  useEffect(() => {
    async function loadStations() {
      try {
        const data = await getAllStations();
        setStations(data);
      } catch (err) {
        setError("Nie udało się załadować danych. Spróbuj później.");
      } finally {
        setLoading(false);
      }
    }
    loadStations();
  }, []);

  const sortedStations = [...stations].sort((a, b) => {
    if (!sortByFuel) {
      return a.station.id - b.station.id;
    }
    const priceA = a.prices.find((p) => p.fuel_type === sortByFuel)?.price ?? Infinity;
    const priceB = b.prices.find((p) => p.fuel_type === sortByFuel)?.price ?? Infinity;
    if (priceA !== priceB) {
      return priceA - priceB;
    }
    return a.station.id - b.station.id;
  });

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-blue-50 to-blue-200">
        <div className="text-2xl text-blue-900">Ładowanie stacji paliw...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-blue-50 to-blue-200">
        <div className="text-2xl text-red-600 text-center px-4">{error}</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 via-blue-100 to-blue-200 py-8 px-4">
      <h1 className="text-5xl font-bold text-center mb-6 text-blue-900">
        Stacje paliw – aktualne ceny
      </h1>

      {/* Sortowanie */}
      <div className="max-w-7xl mx-auto mb-10 text-center">
        <label className="text-lg font-medium text-gray-700 mr-4">
          Sortuj według:
        </label>
        <select
          value={sortByFuel}
          onChange={(e) => setSortByFuel(e.target.value)}
          className="px-6 py-3 rounded-lg border border-gray-300 bg-white text-gray-800 font-medium shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
        >
          {sortOptions.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </div>

      {stations.length === 0 ? (
        <p className="text-center text-xl text-gray-600">Brak stacji w bazie danych.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-7xl mx-auto">
        {sortedStations.map((stationData) => (
          <div key={stationData.station.id} className="min-h-[800px]">
            <StationCard data={stationData} />
          </div>
        ))}
      </div>
      )}
    </div>
  );
}
import { useEffect, useState, useMemo } from "react";
import type { StationFullData } from "../services/stationService";
import { getAllStations } from "../services/stationService";
import StationCard from "../components/StationCard";

const fuelOptions = [
  { value: "", label: "Wszystkie paliwa" },
  { value: "pb95", label: "Pb95 – najtańsze" },
  { value: "on", label: "ON – najtańsze" },
  { value: "pb98", label: "Pb98 – najtańsze" },
  { value: "lpg", label: "LPG – najtańsze" },
  { value: "cng", label: "CNG – najtańsze" },
  { value: "adblue", label: "AdBlue – najtańsze" },
];

export default function HomePage() {
  const [stations, setStations] = useState<StationFullData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [selectedCity, setSelectedCity] = useState<string>("");
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

  // Pomocnicza funkcja do wyciągania miasta z adresu (bezpieczna dla TS)
  const extractCity = (address: string | undefined): string => {
    if (!address) return "Nieznane";
    const parts = address.split(",");
    if (parts.length < 2) return "Nieznane";
    const cityPart = parts[1].trim(); 
    return cityPart.replace(/^\d{2}-\d{3}\s+/, "").trim();
  };

  // 1. Lista unikalnych miast do filtra
  const availableCities = useMemo(() => {
    const cities = stations.map((s) => extractCity(s.station?.address));
    return Array.from(new Set(cities))
      .filter(city => city !== "Nieznane")
      .sort((a, b) => a.localeCompare(b, 'pl'));
  }, [stations]);

  // 2. Dynamiczne paliwa dostępne w wybranym mieście
  const dynamicFuelOptions = useMemo(() => {
    if (!selectedCity) return fuelOptions;

    const fuelsInCity = new Set<string>();
    stations.forEach(s => {
      if (extractCity(s.station?.address) === selectedCity) {
        s.prices?.forEach(p => fuelsInCity.add(p.fuel_type));
      }
    });

    return fuelOptions.filter(opt => opt.value === "" || fuelsInCity.has(opt.value));
  }, [stations, selectedCity]);

  // 3. Logika filtrowania i sortowania
  const filteredAndSortedStations = useMemo(() => {
    let result = [...stations];

    if (selectedCity) {
      result = result.filter(s => extractCity(s.station?.address) === selectedCity);
    }

    if (sortByFuel) {
      result = result.filter(s => s.prices?.some(p => p.fuel_type === sortByFuel));
    }

    result.sort((a, b) => {
      if (!sortByFuel) return (a.station?.id || 0) - (b.station?.id || 0);

      const priceA = a.prices?.find(p => p.fuel_type === sortByFuel)?.price ?? Infinity;
      const priceB = b.prices?.find(p => p.fuel_type === sortByFuel)?.price ?? Infinity;

      if (priceA !== priceB) return priceA - priceB;
      return (a.station?.id || 0) - (b.station?.id || 0);
    });

    return result;
  }, [stations, selectedCity, sortByFuel]);

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-blue-50 to-blue-200">
        <div className="text-2xl text-blue-900 animate-pulse font-semibold">
          Ładowanie stacji paliw...
        </div>
      </div>
    );
  }

  // Tutaj używamy zmiennej 'error', aby błąd TS 6133 zniknął
  if (error) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-gradient-to-b from-blue-50 to-blue-200">
        <div className="bg-white p-8 rounded-2xl shadow-xl border border-red-100 text-center">
          <div className="text-red-500 text-4xl mb-4">⚠️</div>
          <div className="text-xl text-red-600 font-medium">{error}</div>
          <button 
            onClick={() => window.location.reload()}
            className="mt-6 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
          >
            Spróbuj ponownie
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 via-blue-100 to-blue-200 py-8 px-4">
      {/* Definicja animacji CSS wewnątrz pliku */}
      <style>{`
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(15px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-card {
          animation: fadeInUp 0.4s ease-out forwards;
        }
      `}</style>

      <h1 className="text-5xl font-bold text-center mb-10 text-blue-900 tracking-tight">
        Stacje paliw – aktualne ceny
      </h1>

      {/* Kontenery filtrów */}
      <div className="max-w-7xl mx-auto mb-10 flex flex-col md:flex-row justify-center items-end gap-6">
        
        {/* Filtr Miast */}
        <div className="w-full md:w-72">
          <label className="block text-sm font-bold text-blue-900 mb-2 ml-1 uppercase tracking-wider">
            Wybierz miasto:
          </label>
          <select
            value={selectedCity}
            onChange={(e) => {
              setSelectedCity(e.target.value);
              setSortByFuel(""); 
            }}
            className="w-full px-5 py-3 rounded-xl border-none bg-white shadow-lg text-gray-800 font-medium focus:ring-2 focus:ring-blue-500 transition-all appearance-none cursor-pointer"
          >
            <option value="">Wszystkie lokalizacje</option>
            {availableCities.map(city => (
              <option key={city} value={city}>{city}</option>
            ))}
          </select>
        </div>

        {/* Filtr Paliw */}
        <div className="w-full md:w-72">
          <label className="block text-sm font-bold text-blue-900 mb-2 ml-1 uppercase tracking-wider">
            Najniższa cena:
          </label>
          <select
            value={sortByFuel}
            onChange={(e) => setSortByFuel(e.target.value)}
            className="w-full px-5 py-3 rounded-xl border-none bg-white shadow-lg text-gray-800 font-medium focus:ring-2 focus:ring-blue-500 transition-all appearance-none cursor-pointer"
          >
            {dynamicFuelOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>

        {/* Resetowanie */}
        {(selectedCity || sortByFuel) && (
          <button
            onClick={() => { setSelectedCity(""); setSortByFuel(""); }}
            className="mb-3 text-sm font-semibold text-blue-700 hover:text-blue-900 transition-colors border-b-2 border-blue-200"
          >
            Wyczyść filtry
          </button>
        )}
      </div>

      {filteredAndSortedStations.length === 0 ? (
        <div className="text-center py-24 animate-card">
          <p className="text-2xl text-gray-500 font-light">
            Brak stacji spełniających wybrane kryteria.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-7xl mx-auto">
          {filteredAndSortedStations.map((stationData) => (
            <div 
              key={`${stationData.station.id}-${selectedCity}-${sortByFuel}`} 
              className="min-h-[800px] animate-card"
            >
              <StationCard data={stationData} />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
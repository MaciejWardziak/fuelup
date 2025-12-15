import { useEffect, useState } from "react";
import type { StationFullData } from "../services/stationService";
import { getAllStations } from "../services/stationService";

const dayMap: Record<string, string> = {
  mon: "Poniedziałek",
  tue: "Wtorek",
  wed: "Środa",
  thu: "Czwartek",
  fri: "Piątek",
  sat: "Sobota",
  sun: "Niedziela",
  holiday: "Niehandlowa",
};

const allDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun", "holiday"];

const fuelNameMap: Record<string, string> = {
  on: "ON",
  pb95: "Pb95",
  pb98: "Pb98",
  lpg: "LPG",
  cng: "CNG",
  adblue: "AdBlue",
};

// Opcje sortowania w select
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
      // Bez sortowania po paliwie – domyślnie po ID rosnąco
      return a.station.id - b.station.id;
    }
  
    const priceA = a.prices.find((p) => p.fuel_type === sortByFuel)?.price ?? Infinity;
    const priceB = b.prices.find((p) => p.fuel_type === sortByFuel)?.price ?? Infinity;
  
    // Najpierw po cenie (rosnąco)
    if (priceA !== priceB) {
      return priceA - priceB;
    }
  
    // Jeśli ceny takie same – po ID rosnąco
    return a.station.id - b.station.id;
  });

  const formatTime = (time: string) => {
    const [hours, minutes] = time.split(":");
    return `${hours}:${minutes}`;
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleString("pl-PL", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getHoursForDay = (hours: StationFullData["opening_hours"], day: string) => {
    const entry = hours.find((h) => h.day_of_week === day);
    return entry
      ? `${formatTime(entry.open_time)}–${formatTime(entry.close_time)}`
      : "Zamknięte";
  };

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

      {/* Select do sortowania */}
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
          {sortedStations.map(({ station, prices, opening_hours }) => (
            <div
              key={station.id}
              className="bg-white rounded-2xl shadow-xl p-6 hover:shadow-2xl transition-shadow duration-300"
            >
              <h2 className="text-3xl font-bold text-center mb-2 text-blue-800">
                {station.name}
              </h2>
              <p className="text-center text-gray-600 mb-8">{station.address}</p>

              {/* Sekcja cen – stała wysokość */}
              <div className="mb-10">
                <div className="min-h-[220px]">
                  {prices.length > 0 ? (
                    <div className="grid grid-cols-2 gap-4">
                      {prices.map((price) => (
                        <div
                          key={price.fuel_type}
                          className="flex justify-between items-center bg-gray-50 px-5 py-4 rounded-xl text-lg font-bold"
                        >
                          <span className="text-gray-700">
                            {fuelNameMap[price.fuel_type] || price.fuel_type.toUpperCase()}
                          </span>
                          <span className="text-2xl text-green-600">
                            {price.price.toFixed(2).replace(".", ",")}
                          </span>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-center text-gray-500 py-16 text-lg">
                      Brak aktualnych cen
                    </p>
                  )}
                </div>

                <p className="text-center text-sm text-gray-500 mt-4 mb-6">
                  Ceny w zł/litr
                </p>

                {station.last_updated && (
                  <p className="text-center text-sm text-gray-500 mb-6">
                    Aktualizacja: {formatDate(station.last_updated)}
                  </p>
                )}
              </div>

              {/* Godziny otwarcia */}
              <h3 className="text-xl font-semibold mb-4 text-center">
                Godziny otwarcia
              </h3>
              <ul className="text-base space-y-2 text-gray-700">
                {allDays.map((day) => {
                  const hoursText = getHoursForDay(opening_hours, day);
                  const isClosed = hoursText === "Zamknięte";
                  return (
                    <li key={day} className="flex justify-between items-baseline">
                      <strong className="text-gray-800">{dayMap[day]}:</strong>
                      <span
                        className={`font-medium ${
                          isClosed ? "text-red-600" : "text-gray-600"
                        }`}
                      >
                        {hoursText}
                      </span>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
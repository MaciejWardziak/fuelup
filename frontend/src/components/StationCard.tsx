import { useState } from "react";
import StationHistoryChart from "./StationHistoryChart";
import type { StationFullData } from "../services/stationService";

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

interface Props {
  data: StationFullData;
}

export default function StationCard({ data }: Props) {
  const { station, prices, opening_hours } = data;
  const availableFuels = prices.map((p) => p.fuel_type);

  const [showHistory, setShowHistory] = useState(false);

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

  const getHoursForDay = (day: string) => {
    const entry = opening_hours.find((h) => h.day_of_week === day);
    return entry ? `${formatTime(entry.open_time)}–${formatTime(entry.close_time)}` : "Zamknięte";
  };

  return (
    <div className="h-[800px] relative overflow-hidden rounded-2xl shadow-xl border border-gray-100 bg-white">
      {/* Wspólny nagłówek – zawsze widoczny */}
      <div className="relative px-6 pt-6 pb-4 bg-white z-10">
        <h2 className="text-3xl font-bold text-center text-blue-800">
          {station.name}
        </h2>
        <p className="text-center text-gray-600 mt-2">{station.address}</p>

        {/* Przyciski przełączania */}
        <button
          onClick={() => setShowHistory(true)}
          className={`
            absolute top-6 right-6 p-3 bg-blue-100 text-blue-700 rounded-xl hover:bg-blue-200 transition-colors
            ${showHistory ? "opacity-0 pointer-events-none" : "opacity-100"}
          `}
          title="Historia cen"
          aria-label="Pokaż historię cen"
        >
          <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
            />
          </svg>
        </button>

        <button
          onClick={() => setShowHistory(false)}
          className={`
            absolute top-6 right-6 p-3 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 transition-colors
            ${showHistory ? "opacity-100" : "opacity-0 pointer-events-none"}
          `}
          title="Powrót"
          aria-label="Powrót do aktualnych cen"
        >
          <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
        </button>
      </div>

      {/* Treść zmieniająca się pod nagłówkiem */}
      <div className="relative h-[calc(100%-120px)]">
        {/* Aktualne ceny + godziny */}
        <div
          className={`
            absolute inset-0 px-6 pb-6 flex flex-col
            transition-all duration-600 ease-in-out
            ${showHistory ? "-translate-x-6 opacity-0 pointer-events-none" : "translate-x-0 opacity-100"}
          `}
        >
          <div className="mb-8 flex-1 mt-4">
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

          <p className="text-center text-sm text-gray-500 mb-4">Ceny w zł/litr</p>

          {station.last_updated && (
            <p className="text-center text-sm text-gray-500 mb-6">
              Aktualizacja: {formatDate(station.last_updated)}
            </p>
          )}

          <div className="border-t pt-4">
            <h3 className="text-xl font-semibold text-center mb-3">Godziny otwarcia</h3>
            <ul className="text-base space-y-2 text-gray-700">
              {allDays.map((day) => {
                const hoursText = getHoursForDay(day);
                return (
                  <li key={day} className="flex justify-between items-baseline">
                    <strong className="text-gray-800">{dayMap[day]}:</strong>
                    <span
                      className={`font-medium ${
                        hoursText === "Zamknięte" ? "text-red-600" : "text-gray-600"
                      }`}
                    >
                      {hoursText}
                    </span>
                  </li>
                );
              })}
            </ul>
          </div>
        </div>

        {/* Historia cen */}
        <div
          className={`
            absolute inset-0 px-6 pb-6 flex flex-col
            transition-all duration-600 ease-in-out
            ${showHistory ? "translate-x-0 opacity-100" : "translate-x-6 opacity-0 pointer-events-none"}
          `}
        >
          <div className="flex-1 flex flex-col min-h-0 mt-4">
            <StationHistoryChart
              stationId={station.id}
              availableFuels={availableFuels}
              fuelNameMap={fuelNameMap}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
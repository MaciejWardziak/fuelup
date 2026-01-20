import { useState } from "react";
import StationHistoryChart from "./StationHistoryChart";
import type { StationFullData } from "../services/stationService";

const dayMap: Record<string, string> = {
  mon: "Poniedziałek", tue: "Wtorek", wed: "Środa", thu: "Czwartek",
  fri: "Piątek", sat: "Sobota", sun: "Niedziela", holiday: "Niehandlowa",
};

const allDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun", "holiday"];

const fuelNameMap: Record<string, string> = {
  pb95: "Pb95", pb98: "Pb98", on: "ON", lpg: "LPG", cng: "CNG", adblue: "AdBlue",
};

const FUEL_ORDER = ["pb95", "pb98", "on", "lpg", "cng", "adblue"];

interface Props {
  data: StationFullData;
}

export default function StationCard({ data }: Props) {
  const { station, prices, opening_hours } = data;
  const [showHistory, setShowHistory] = useState(false);

  const sortedPrices = [...prices].sort((a, b) => {
    return FUEL_ORDER.indexOf(a.fuel_type) - FUEL_ORDER.indexOf(b.fuel_type);
  });

  const availableFuels = sortedPrices.map((p) => p.fuel_type);

  const formatTime = (time: string) => time.split(":").slice(0, 2).join(":");

  // Funkcja formatująca datę z dodaniem +1h
  const formatDateWithOffset = (dateString: string) => {
    const date = new Date(dateString);
    date.setHours(date.getHours() + 1); // Korekta strefy czasowej
    return date.toLocaleString("pl-PL", {
      day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit",
    });
  };

  const getHoursForDay = (day: string) => {
    const entry = opening_hours.find((h) => h.day_of_week === day);
    return entry ? `${formatTime(entry.open_time)}–${formatTime(entry.close_time)}` : "Zamknięte";
  };

  const renderTrend = (price: any) => {
    if (price.trend === "up") {
      return (
        <span className="flex items-center text-red-500 font-bold text-sm ml-1">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-5 h-5">
            <path fillRule="evenodd" d="M12.577 4.878a.75.75 0 01.919-.53l4.75 1.25a.75.75 0 01.53.919l-1.25 4.75a.75.75 0 01-1.449-.38l.684-2.597L10.53 14.53a.75.75 0 11-1.06-1.06l6.241-6.241-2.597.684a.75.75 0 01-.537-.935z" clipRule="evenodd" />
          </svg>
          {price.change.toFixed(2)}
        </span>
      );
    }
    if (price.trend === "down") {
      return (
        <span className="flex items-center text-green-600 font-bold text-sm ml-1">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="w-5 h-5">
            <path fillRule="evenodd" d="M12.577 15.122a.75.75 0 00.919.53l4.75-1.25a.75.75 0 00.53-.919l-1.25-4.75a.75.75 0 00-1.449.38l.684 2.597L10.53 5.47a.75.75 0 10-1.06 1.06l6.241 6.241-2.597-.684a.75.75 0 00-.537.935z" clipRule="evenodd" />
          </svg>
          {Math.abs(price.change).toFixed(2)}
        </span>
      );
    }
    return <span className="text-gray-300 ml-1 text-lg font-bold">▬</span>;
  };

  return (
    <div className="h-[800px] relative overflow-hidden rounded-2xl shadow-xl border border-gray-100 bg-white">
      {/* Nagłówek */}
      <div className="relative px-6 pt-8 pb-4 bg-white z-10 pr-20 border-b border-gray-50">
        <h2 className="text-3xl font-bold text-center text-blue-800 truncate">{station.name}</h2>
        <p className="text-center text-gray-600 mt-2 truncate">{station.address}</p>

        <button
          onClick={() => setShowHistory(!showHistory)}
          className={`absolute top-8 right-6 p-3 rounded-xl transition-all shadow-sm ${
            showHistory ? "bg-gray-100 text-gray-700" : "bg-blue-600 text-white hover:bg-blue-700"
          }`}
        >
          {showHistory ? (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={2.5} stroke="currentColor" className="w-6 h-6">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 15L3 9m0 0l6-6M3 9h12a6 6 0 010 12h-3" />
            </svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={2.5} stroke="currentColor" className="w-6 h-6">
              <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0V12m3 4.5V12m3 4.5V12M6.75 21h10.5" />
            </svg>
          )}
        </button>
      </div>

      <div className="relative h-[calc(100%-125px)]">
        {/* Widok: Ceny + Godziny */}
        <div className={`absolute inset-0 px-6 pb-6 flex flex-col transition-all duration-600 ${
          showHistory ? "-translate-x-full opacity-0 pointer-events-none" : "translate-x-0 opacity-100"
        }`}>
          
          {/* Sekcja Cen - Sztywny Grid 2x3 */}
          <div className="grid grid-cols-2 grid-rows-3 gap-4 mt-6 min-h-[280px]">
            {sortedPrices.map((price) => (
              <div key={price.fuel_type} className="flex flex-col bg-gray-50 px-5 py-4 rounded-2xl border border-gray-100 shadow-sm h-[80px] justify-center">
                <span className="text-xs font-bold text-gray-400 uppercase tracking-wider">{fuelNameMap[price.fuel_type]}</span>
                <div className="flex items-center justify-between mt-1">
                  <span className="text-2xl font-black text-gray-800">{price.price.toFixed(2).replace(".", ",")}</span>
                  {renderTrend(price)}
                </div>
              </div>
            ))}
            {[...Array(6 - sortedPrices.length)].map((_, i) => (
              <div key={`empty-${i}`} className="h-[80px] invisible" />
            ))}
          </div>

          <div className="text-center my-4">
            <p className="text-sm text-gray-400 italic">Ceny w zł/litr</p>
            {station.last_updated && (
              <p className="text-[11px] text-blue-500 font-bold uppercase mt-1">
                Aktualizacja: {formatDateWithOffset(station.last_updated)}
              </p>
            )}
          </div>

          <div className="mt-auto border-t border-gray-100 pt-5">
            <h3 className="text-lg font-bold text-center mb-4 text-gray-800 uppercase tracking-tight">Godziny otwarcia</h3>
            <ul className="text-base space-y-1.5 text-gray-700">
              {allDays.map((day) => {
                const hoursText = getHoursForDay(day);
                return (
                  <li key={day} className="flex justify-between items-center px-2">
                    <span className="font-semibold text-gray-600">{dayMap[day]}:</span>
                    <span className={`font-mono font-bold px-3 py-0.5 rounded-lg ${
                      hoursText === "Zamknięte" ? "bg-red-50 text-red-600" : "bg-gray-100 text-gray-700"
                    }`}>
                      {hoursText}
                    </span>
                  </li>
                );
              })}
            </ul>
          </div>
        </div>

        {/* Widok: Wykres */}
        <div className={`absolute inset-0 px-6 pb-6 flex flex-col transition-all duration-600 ${
          showHistory ? "translate-x-0 opacity-100" : "translate-x-full opacity-0 pointer-events-none"
        }`}>
          <div className="flex-1 flex flex-col min-h-0 mt-6">
            <StationHistoryChart stationId={station.id} availableFuels={availableFuels} fuelNameMap={fuelNameMap} />
          </div>
        </div>
      </div>
    </div>
  );
}
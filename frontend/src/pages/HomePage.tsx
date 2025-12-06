import { useEffect, useState } from "react";
import { getStationFullData, type StationFullData } from "../services/stationService";

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

export default function HomePage() {
  const [data, setData] = useState<StationFullData | null>(null);

  useEffect(() => {
    getStationFullData(1).then(setData);
  }, []);

  if (!data) return <div className="text-center mt-10">Ładowanie danych stacji...</div>;

  const formatTime = (time: string) => {
    const [hours, minutes] = time.split(":");
    return `${hours}:${minutes}`;
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleString("pl-PL", { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit" });
  };

  return (
    <div className="flex flex-col items-center p-6 min-h-screen bg-gradient-to-b from-blue-50 via-blue-100 to-blue-200">
      <h1 className="text-4xl font-bold mb-2">{data.station.name}</h1>
      <p className="mb-6 text-lg text-gray-700">{data.station.address}</p>

      <div className="flex space-x-8 mb-2 text-3xl font-extrabold">
        <span>ON: {data.prices.find(p => p.fuel_type === "on")?.price ?? "-"} zł</span>
        <span>Pb95: {data.prices.find(p => p.fuel_type === "pb95")?.price ?? "-"} zł</span>
      </div>

      {data.station.last_updated && (
        <p className="mb-6 text-gray-600 text-sm">
          Ostatnia aktualizacja: {formatDate(data.station.last_updated)}
        </p>
      )}

      <h2 className="text-2xl font-semibold mb-2">Godziny otwarcia:</h2>
      <ul className="text-lg text-gray-800">
        {data.opening_hours.map(hour => (
          <li key={hour.id}>
            {dayMap[hour.day_of_week] ?? hour.day_of_week}: {formatTime(hour.open_time)} - {formatTime(hour.close_time)}
          </li>
        ))}
      </ul>
    </div>
  );
}

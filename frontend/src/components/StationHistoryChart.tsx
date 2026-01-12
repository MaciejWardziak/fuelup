import { useEffect, useState } from "react";
import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  TimeScale,
  Filler,
} from "chart.js";
import "chartjs-adapter-date-fns";
import { getFullPriceHistory } from "../services/stationService";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  TimeScale,
  Filler
);

type Period = "week" | "month" | "year" | "all";
type ChartTimeUnit = "day" | "week" | "month";

interface Props {
  stationId: number;
  availableFuels: string[];
  fuelNameMap: Record<string, string>;
}

export default function StationHistoryChart({ stationId, availableFuels, fuelNameMap }: Props) {
  const [history, setHistory] = useState<any>(null);
  const [selectedFuel, setSelectedFuel] = useState<string>(availableFuels[0] || "");
  const [period, setPeriod] = useState<Period>("all");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadHistory() {
      setLoading(true);
      try {
        const data = await getFullPriceHistory(stationId);
        if (data && Array.isArray(data)) {
          const grouped = data.reduce((acc: any, curr: any) => {
            const fuel = curr.fuel_type;
            const date = new Date(curr.created_at);
            if (!isNaN(date.getTime())) {
              if (!acc[fuel]) acc[fuel] = [];
              acc[fuel].push({ x: date, y: curr.price });
            }
            return acc;
          }, {});
          setHistory(grouped);
        }
      } catch (err) {
        console.error("Błąd ładowania historii:", err);
      } finally {
        setLoading(false);
      }
    }
    loadHistory();
  }, [stationId]);

  const getTimeUnit = (): ChartTimeUnit => {
    if (period === "week") return "day";
    if (period === "month") return "week";
    return "month";
  };

  const getFilteredData = () => {
    if (!history || !history[selectedFuel]) return [];
    
    const points = [...history[selectedFuel]];
    const now = new Date();
    let cutoff = new Date(0);

    if (period === "week") {
      cutoff = new Date();
      cutoff.setDate(now.getDate() - 7);
    } else if (period === "month") {
      cutoff = new Date();
      cutoff.setMonth(now.getMonth() - 1);
    } else if (period === "year") {
      cutoff = new Date();
      cutoff.setFullYear(now.getFullYear() - 1);
    }

    return points
      .filter((p: any) => p.x >= cutoff)
      .sort((a: any, b: any) => a.x.getTime() - b.x.getTime());
  };

  const filteredData = getFilteredData();

  const chartData = {
    datasets: [
      {
        label: fuelNameMap[selectedFuel] || selectedFuel.toUpperCase(),
        data: filteredData,
        borderColor: "#2563eb",
        backgroundColor: "rgba(37, 99, 235, 0.1)",
        borderWidth: 3,
        tension: 0.1, 
        fill: true,
        pointRadius: 6,
        pointHoverRadius: 9,
        pointBackgroundColor: "#2563eb",
        spanGaps: true,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    layout: {
      padding: {
        bottom: 20 // Dodatkowe miejsce na pionowe daty
      }
    },
    scales: {
      x: {
        type: "time" as const,
        time: {
          unit: getTimeUnit(),
          displayFormats: {
            day: "dd.MM",
            week: "dd.MM",
            month: "MM.yyyy",
          },
        },
        grid: {
          display: true,
          drawOnChartArea: true,
          color: "#f3f4f6",
        },
        ticks: {
          source: 'data' as const, // WYMUSZA ETYKIETĘ DLA KAŻDEGO PUNKTU
          autoSkip: false,
          maxRotation: 90,
          minRotation: 90, // Pełny pion dla maksymalnej czytelności
          font: {
            size: 10,
          },
          callback: function(val: any) {
            const date = new Date(val);
            return date.toLocaleDateString("pl-PL", { day: '2-digit', month: '2-digit' });
          }
        },
      },
      y: {
        beginAtZero: false,
        grid: { color: "#f3f4f6" },
        ticks: {
          callback: (val: any) => `${val.toFixed(2)} zł`,
        },
      },
    },
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: "rgba(30, 58, 138, 0.9)",
        titleFont: { size: 13 },
        bodyFont: { size: 13 },
        padding: 12,
        displayColors: false,
        callbacks: {
          label: (context: any) => ` Cena: ${context.parsed.y.toFixed(2)} zł`,
          title: (context: any) => {
            const date = new Date(context[0].parsed.x);
            return date.toLocaleDateString("pl-PL", { 
              day: 'numeric', month: 'long', hour: '2-digit', minute: '2-digit' 
            });
          }
        },
      },
    },
  };

  return (
    <div className="h-full flex flex-col">
      {/* Kwadraciki paliw */}
      <div className="flex flex-wrap gap-2 justify-center mb-6">
        {availableFuels.map((fuel) => (
          <button
            key={fuel}
            onClick={() => setSelectedFuel(fuel)}
            className={`w-16 h-10 rounded-lg text-xs font-bold border transition-all flex items-center justify-center ${
              selectedFuel === fuel
                ? "bg-blue-600 border-blue-600 text-white shadow-md transform scale-105"
                : "bg-white border-gray-200 text-gray-600 hover:border-blue-400"
            }`}
          >
            {fuelNameMap[fuel] || fuel.toUpperCase()}
          </button>
        ))}
      </div>

      {/* Wykres z siatką i pionowymi datami */}
      <div className="flex-1 min-h-[350px] bg-white rounded-2xl p-2">
        {loading ? (
          <div className="h-full flex items-center justify-center text-blue-500 font-medium">
            Pobieranie danych...
          </div>
        ) : filteredData.length > 0 ? (
          <Line data={chartData} options={options} />
        ) : (
          <div className="h-full flex flex-col items-center justify-center text-gray-400 bg-gray-50 rounded-xl border border-dashed border-gray-200">
             <p className="font-semibold">Brak historii dla tego okresu</p>
             <p className="text-xs mt-1 text-gray-500 text-center px-6">
               Kliknij "Wszystko", aby zobaczyć dane z grudnia i stycznia.
             </p>
          </div>
        )}
      </div>

      {/* Przyciski okresu */}
      <div className="grid grid-cols-4 gap-2 mt-6">
        {(["week", "month", "year", "all"] as const).map((p) => (
          <button
            key={p}
            onClick={() => setPeriod(p)}
            className={`py-3 rounded-xl text-sm font-bold transition-all ${
              period === p
                ? "bg-blue-900 text-white shadow-lg"
                : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            {p === "week" ? "Tydzień" : p === "month" ? "Miesiąc" : p === "year" ? "Rok" : "Wszystko"}
          </button>
        ))}
      </div>
    </div>
  );
}
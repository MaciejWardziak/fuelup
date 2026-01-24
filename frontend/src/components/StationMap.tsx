import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import { useEffect } from 'react';
import 'leaflet/dist/leaflet.css';
import type { StationFullData } from '../services/stationService';

// Fix dla ikon Leaflet - używamy bezpośrednich linków do CDN
const customIcon = L.icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
});

// Komponent pomocniczy do centrowania mapy
function RecenterMap({ stations }: { stations: StationFullData[] }) {
  const map = useMap();

  useEffect(() => {
    if (stations.length > 0) {
      // Wyciągamy współrzędne sprawdzając czy istnieją
      const points = stations
        .filter(s => s.station.lat && s.station.lng)
        .map(s => [s.station.lat, s.station.lng] as [number, number]);

      if (points.length > 0) {
        const bounds = L.latLngBounds(points);
        map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 });
      }
    }
  }, [stations, map]);

  return null;
}

interface StationMapProps {
  stations: StationFullData[];
}

export default function StationMap({ stations }: StationMapProps) {
  // Środek Słupska jako punkt startowy
  const defaultCenter: [number, number] = [54.464, 17.028];

  return (
    <div className="w-full h-[450px] relative z-0">
      <MapContainer 
        center={defaultCenter} 
        zoom={13} 
        scrollWheelZoom={false}
        style={{ height: '100%', width: '100%' }}
      >
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; OpenStreetMap contributors'
        />
        
        <RecenterMap stations={stations} />

        {stations.map((s) => {
          const { station, prices } = s;
          
          // Kluczowe: sprawdzamy czy stacja ma współrzędne
          if (!station.lat || !station.lng) return null;

          return (
            <Marker 
              key={station.id} 
              position={[station.lat, station.lng] as [number, number]} 
              icon={customIcon}
            >
              <Popup>
                <div className="min-w-[160px] p-1">
                    <h3 className="font-bold text-blue-800 text-sm border-b border-gray-100 pb-1 mb-2">
                    {station.name}
                    </h3>
                    <p className="text-[11px] text-gray-500 mb-3 leading-tight italic">
                    {station.address}
                    </p>
                    
                    <div className="space-y-1.5">
                    {prices && prices.length > 0 ? (
                        prices.map((p) => (
                        <div key={p.id} className="flex justify-between items-center text-xs">
                            <span className="font-bold text-gray-500 uppercase text-[10px]">
                            {p.fuel_type}:
                            </span>
                            <span className="font-mono font-black text-blue-700 bg-blue-50 px-2 py-0.5 rounded border border-blue-100">
                            {p.price.toFixed(2).replace(".", ",")} zł
                            </span>
                        </div>
                        ))
                    ) : (
                        <p className="text-[10px] italic text-gray-400">Brak aktualnych cen</p>
                    )}
                    </div>
                </div>
                </Popup>
            </Marker>
          );
        })}
      </MapContainer>
    </div>
  );
}
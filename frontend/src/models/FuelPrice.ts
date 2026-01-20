export interface FuelPrice {
    id: number;
    station_id: number;
    fuel_type: string;
    price: number;
    trend: "up" | "down" | "equal";
    change: number;
    created_at: string;
    updated_at: string;
  }
  
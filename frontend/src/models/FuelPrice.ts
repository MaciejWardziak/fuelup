export interface FuelPrice {
    id: number;
    station_id: number;
    fuel_type: "on" | "pb95";
    price: number;
    created_at: string;
    updated_at: string;
  }
  
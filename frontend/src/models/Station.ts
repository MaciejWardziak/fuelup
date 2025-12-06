import type { FuelPrice } from "./FuelPrice.ts";
import type { StationOpeningHours } from "./StationOpeningHours.ts";

export interface Station {
  id: number;
  name: string;
  address?: string;
  website_url?: string;
  last_updated?: string;
  lat?: number;
  lng?: number;
  created_at: string;
  updated_at: string;
  prices?: FuelPrice[];
  opening_hours?: StationOpeningHours[];
}

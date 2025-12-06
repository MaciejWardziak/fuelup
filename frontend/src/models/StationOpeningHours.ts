export interface StationOpeningHours {
    id: number;
    station_id: number;
    day_of_week: "mon" | "tue" | "wed" | "thu" | "fri" | "sat" | "sun" | "holiday";
    open_time: string;   // np. "06:00"
    close_time: string;  // np. "21:00"
    created_at: string;
    updated_at: string;
  }
  
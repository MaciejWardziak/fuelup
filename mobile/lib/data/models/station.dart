class Station {
  final int id;
  final String name;
  final String? address;
  final String? websiteUrl;
  final double? lat;
  final double? lng;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? scraperConfig;
  final List<FuelPrice> prices;
  final List<StationOpeningHours> openingHours;

  Station({
    required this.id,
    required this.name,
    this.address,
    this.websiteUrl,
    this.lat,
    this.lng,
    this.lastUpdated,
    this.scraperConfig,
    this.prices = const [],
    this.openingHours = const [],
  });

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    websiteUrl: json['website_url'],
    lat: json['lat']?.toDouble(),
    lng: json['lng']?.toDouble(),
    lastUpdated: json['last_updated'] != null
        ? DateTime.parse(json['last_updated'] + 'Z').toLocal()
        : null,
    scraperConfig: json['scraper_config'],
    prices: (json['prices'] as List<dynamic>?)
        ?.map((e) => FuelPrice.fromJson(e))
        .toList() ??
        [],
    openingHours: (json['opening_hours'] as List<dynamic>?)
        ?.map((e) => StationOpeningHours.fromJson(e))
        .toList() ??
        [],
  );
}

class FuelPrice {
  final int id;
  final int stationId;
  final String fuelType;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String trend;
  final double change;

  FuelPrice({
    required this.id,
    required this.stationId,
    required this.fuelType,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.trend = 'equal',
    this.change = 0.0,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) => FuelPrice(
    id: json['id'],
    stationId: json['station_id'],
    fuelType: json['fuel_type'],
    price: double.parse(json['price'].toString()),
    createdAt: DateTime.parse(json['created_at'] + 'Z').toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] + 'Z').toLocal(),
    trend: json['trend'] ?? 'equal',
    change: (json['change'] ?? 0.0).toDouble(),
  );
}

class StationOpeningHours {
  final int id;
  final int stationId;
  final String dayOfWeek;
  final String openTime;
  final String closeTime;

  StationOpeningHours({
    required this.id,
    required this.stationId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
  });

  factory StationOpeningHours.fromJson(Map<String, dynamic> json) =>
      StationOpeningHours(
        id: json['id'],
        stationId: json['station_id'],
        dayOfWeek: json['day_of_week'],
        openTime: json['open_time'],
        closeTime: json['close_time'],
      );
}
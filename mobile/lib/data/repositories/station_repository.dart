import '../models/station.dart';
import '../services/api_service.dart';

class StationRepository {
  final ApiService _api;

  StationRepository(this._api);

  Future<List<Station>> getStations({String? search}) =>
      _api.getStations(search: search);

  Future<Station> getStation(int id) => _api.getStation(id);

  Future<Station> createStation(Map<String, dynamic> data) =>
      _api.createStation(data);

  Future<Station> updateStation(int id, Map<String, dynamic> data) =>
      _api.updateStation(id, data);

  Future<void> deleteStation(int id) => _api.deleteStation(id);

  Future<List<FuelPrice>> getFullPriceHistory(int stationId) =>
      _api.getFullPriceHistory(stationId);

  Future<StationOpeningHours> createOpeningHours(
      Map<String, dynamic> data) =>
      _api.createOpeningHours(data);

  Future<StationOpeningHours> updateOpeningHours(
      int id, Map<String, dynamic> data) =>
      _api.updateOpeningHours(id, data);

  Future<void> deleteOpeningHours(int id) => _api.deleteOpeningHours(id);
}
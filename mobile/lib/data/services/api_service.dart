import 'package:dio/dio.dart';
import '../models/station.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000';
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── Stacje ────────────────────────────────────────────────────────────────

  Future<List<Station>> getStations({String? search}) async {
    try {
      final response = await _dio.get(
        '/stations/',
        queryParameters: search != null ? {'search': search} : null,
      );
      return (response.data as List)
          .map((e) => Station.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Station> getStation(int id) async {
    try {
      final response = await _dio.get('/stations/$id');
      return Station.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Station> createStation(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/stations/', data: data);
      return Station.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Station> updateStation(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/stations/$id', data: data);
      return Station.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteStation(int id) async {
    try {
      await _dio.delete('/stations/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Ceny ──────────────────────────────────────────────────────────────────

  Future<List<FuelPrice>> getRecentPrices(int stationId) async {
    try {
      final response = await _dio.get('/prices/$stationId');
      return (response.data as List)
          .map((e) => FuelPrice.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<FuelPrice>> getArchivedPrices(int stationId) async {
    try {
      final response = await _dio.get('/archive/$stationId');
      return (response.data as List)
          .map((e) => FuelPrice.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<FuelPrice>> getFullPriceHistory(int stationId) async {
    try {
      final recent = await getRecentPrices(stationId);
      final archived = await getArchivedPrices(stationId);
      final combined = [...recent, ...archived];
      final unique = {for (final p in combined) p.id: p}.values.toList();
      return unique;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Godziny otwarcia ──────────────────────────────────────────────────────

  Future<StationOpeningHours> createOpeningHours(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/opening-hours/', data: data);
      return StationOpeningHours.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StationOpeningHours> updateOpeningHours(
      int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/opening-hours/$id', data: data);
      return StationOpeningHours.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteOpeningHours(int id) async {
    try {
      await _dio.delete('/opening-hours/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handling ────────────────────────────────────────────────────────

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Przekroczono czas połączenia z serwerem');
      case DioExceptionType.connectionError:
        return Exception('Brak połączenia z serwerem');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 404) return Exception('Nie znaleziono zasobu');
        if (status == 422) return Exception('Nieprawidłowe dane');
        return Exception('Błąd serwera: $status');
      default:
        return Exception('Nieznany błąd: ${e.message}');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/station.dart';
import '../repositories/station_repository.dart';
import '../services/api_service.dart';

// ── Podstawowe providery ──────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final stationRepositoryProvider = Provider<StationRepository>(
      (ref) => StationRepository(ref.watch(apiServiceProvider)),
);

// ── Stacje ────────────────────────────────────────────────────────────────

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getStations();
});

final stationProvider =
FutureProvider.family<Station, int>((ref, id) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getStation(id);
});

// ── Historia cen ──────────────────────────────────────────────────────────

final priceHistoryProvider =
FutureProvider.family<List<FuelPrice>, int>((ref, stationId) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getFullPriceHistory(stationId);
});

// ── Filtry ────────────────────────────────────────────────────────────────

final selectedFuelFilterProvider = StateProvider<String>((ref) => '');

final selectedCityFilterProvider = StateProvider<String>((ref) => '');


final filteredStationsProvider = Provider<AsyncValue<List<Station>>>((ref) {
  final stationsAsync = ref.watch(stationsProvider);
  final selectedFuel = ref.watch(selectedFuelFilterProvider);
  final selectedCity = ref.watch(selectedCityFilterProvider);

  return stationsAsync.whenData((stations) {
    var result = [...stations];

    if (selectedCity.isNotEmpty) {
      result = result.where((s) {
        final city = _extractCity(s.address);
        return city == selectedCity;
      }).toList();
    }

    if (selectedFuel.isNotEmpty) {
      result = result
          .where((s) => s.prices.any((p) => p.fuelType == selectedFuel))
          .toList();

      result.sort((a, b) {
        final priceA = a.prices
            .firstWhere((p) => p.fuelType == selectedFuel,
            orElse: () => FuelPrice(
                id: 0,
                stationId: 0,
                fuelType: '',
                price: double.infinity,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()))
            .price;
        final priceB = b.prices
            .firstWhere((p) => p.fuelType == selectedFuel,
            orElse: () => FuelPrice(
                id: 0,
                stationId: 0,
                fuelType: '',
                price: double.infinity,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()))
            .price;
        return priceA.compareTo(priceB);
      });
    }

    return result;
  });
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final localeProvider = StateProvider<Locale>((ref) => const Locale('pl'));

final availableCitiesProvider = Provider<List<String>>((ref) {
  final stationsAsync = ref.watch(stationsProvider);
  return stationsAsync.whenData((stations) {
    final cities = stations
        .map((s) => _extractCity(s.address))
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    cities.sort((a, b) => a.compareTo(b));
    return cities;
  }).value ??
      [];
});

// ── Helper ────────────────────────────────────────────────────────────────

String? _extractCity(String? address) {
  if (address == null) return null;
  final parts = address.split(',');
  if (parts.length < 2) return null;
  return parts.last.trim().replaceAll(RegExp(r'^\d{2}-\d{3}\s+'), '').trim();
}
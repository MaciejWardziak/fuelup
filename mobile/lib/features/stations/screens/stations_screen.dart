import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/station_providers.dart';
import '../widgets/station_card.dart';
import '../widgets/stations_map.dart';
import '../../../data/services/theme_service.dart';
import '../../../data/services/locale_service.dart';
import '../../../core/l10n/app_localizations.dart';

bool _isDark(WidgetRef ref, BuildContext context) {
  final mode = ref.watch(themeModeProvider);
  if (mode == ThemeMode.system) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
  return mode == ThemeMode.dark;
}

List<(String, String)> _getFuelOptions(AppLocalizations l10n) => [
  ('', l10n.allFuels),
  ('pb95', 'Pb95'),
  ('pb98', 'Pb98'),
  ('on', 'ON'),
  ('lpg', 'LPG'),
  ('cng', 'CNG'),
  ('adblue', 'AdBlue'),
];

class StationsScreen extends ConsumerWidget {
  const StationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filteredAsync = ref.watch(filteredStationsProvider);
    final cities = ref.watch(availableCitiesProvider);
    final selectedFuel = ref.watch(selectedFuelFilterProvider);
    final selectedCity = ref.watch(selectedCityFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FuelUp',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Text(
              ref.watch(localeProvider).languageCode.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () async {
              final current = ref.read(localeProvider);
              final next = current.languageCode == 'pl'
                  ? const Locale('en')
                  : const Locale('pl');
              ref.read(localeProvider.notifier).state = next;
              await LocaleService.save(next);
            },
          ),
          IconButton(
            icon: Icon(_isDark(ref, context)
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () async {
              final isDark = _isDark(ref, context);
              final next = isDark ? ThemeMode.light : ThemeMode.dark;
              ref.read(themeModeProvider.notifier).state = next;
              await ThemeService.save(next);
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: l10n.admin,
            onPressed: () => context.push('/admin'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stationsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Filtry
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (cities.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: InputDecoration(
                          labelText: l10n.city,
                          prefixIcon:
                          const Icon(Icons.location_city_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: '',
                              child: Text(l10n.allLocations)),
                          ...cities.map((c) => DropdownMenuItem(
                              value: c, child: Text(c))),
                        ],
                        onChanged: (v) => ref
                            .read(selectedCityFilterProvider.notifier)
                            .state = v ?? '',
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedFuel,
                      decoration: InputDecoration(
                        labelText: l10n.fuel,
                        prefixIcon: const Icon(
                            Icons.local_gas_station_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      items: _getFuelOptions(l10n)
                          .map((o) => DropdownMenuItem(
                          value: o.$1, child: Text(o.$2)))
                          .toList(),
                      onChanged: (v) => ref
                          .read(selectedFuelFilterProvider.notifier)
                          .state = v ?? '',
                    ),
                    if (selectedFuel.isNotEmpty || selectedCity.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(selectedFuelFilterProvider.notifier)
                              .state = '';
                          ref
                              .read(selectedCityFilterProvider.notifier)
                              .state = '';
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: Text(l10n.clearFilters),
                      ),
                  ],
                ),
              ),
            ),

            // Mapa
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: filteredAsync
                    .whenData((stations) =>
                    StationsMap(stations: stations))
                    .value !=
                    null
                    ? StationsMap(
                  stations: filteredAsync.value ?? [],
                )
                    : const SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Lista stacji
            filteredAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('$e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(stationsProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (stations) => stations.isEmpty
                  ? SliverFillRemaining(
                child: Center(
                  child: Text(l10n.noStations),
                ),
              )
                  : SliverPadding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                        StationCard(station: stations[i]),
                    childCount: stations.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
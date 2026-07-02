import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/station.dart';
import '../../../core/l10n/app_localizations.dart';

const _fuelNames = {
  'pb95': 'Pb95',
  'pb98': 'Pb98',
  'on': 'ON',
  'lpg': 'LPG',
  'cng': 'CNG',
  'adblue': 'AdBlue',
};

class StationsMap extends StatefulWidget {
  final List<Station> stations;
  const StationsMap({super.key, required this.stations});

  @override
  State<StationsMap> createState() => _StationsMapState();
}

class _StationsMapState extends State<StationsMap> {
  Station? _selectedStation;

  @override
  Widget build(BuildContext context) {
    final validStations = widget.stations
        .where((s) => s.lat != null && s.lng != null)
        .toList();

    final center = validStations.isEmpty
        ? LatLng(54.464, 17.028)
        : LatLng(
      validStations.map((s) => s.lat!).reduce((a, b) => a + b) /
          validStations.length,
      validStations.map((s) => s.lng!).reduce((a, b) => a + b) /
          validStations.length,
    );

    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 11,
                onTap: (_, __) => setState(() => _selectedStation = null),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fuelup',
                ),
                MarkerLayer(
                  markers: validStations
                      .map((s) => Marker(
                    point: LatLng(s.lat!, s.lng!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => setState(
                              () => _selectedStation = s),
                      child: Icon(
                        Icons.local_gas_station,
                        color: _selectedStation?.id == s.id
                            ? Colors.orange
                            : Colors.blue,
                        size: 36,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
            if (_selectedStation != null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: _StationPopup(
                  station: _selectedStation!,
                  onClose: () =>
                      setState(() => _selectedStation = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StationPopup extends StatelessWidget {
  final Station station;
  final VoidCallback onClose;
  const _StationPopup(
      {required this.station, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (station.address != null) ...[
              const SizedBox(height: 2),
              Text(
                station.address!,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (station.prices.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: station.prices
                    .map((p) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_fuelNames[p.fuelType] ?? p.fuelType}: ${p.price.toStringAsFixed(2).replaceAll('.', ',')} zł',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => context.push('/station/${station.id}'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.details, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
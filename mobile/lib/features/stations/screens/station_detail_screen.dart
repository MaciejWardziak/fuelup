import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/station.dart';
import '../../../data/providers/station_providers.dart';
import '../widgets/fuel_price_chip.dart';
import '../../../core/l10n/app_localizations.dart';

const _dayOrder = ['mon', 'tue', 'wen', 'thu', 'fri', 'sat', 'sun', 'holiday'];

String _getDayName(BuildContext context, String day) {
  final l10n = AppLocalizations.of(context)!;
  switch (day) {
    case 'mon': return l10n.monday;
    case 'tue': return l10n.tuesday;
    case 'wen': return l10n.wednesday;
    case 'thu': return l10n.thursday;
    case 'fri': return l10n.friday;
    case 'sat': return l10n.saturday;
    case 'sun': return l10n.sunday;
    case 'holiday': return l10n.holiday;
    default: return day;
  }
}

class StationDetailScreen extends ConsumerWidget {
  final int stationId;
  const StationDetailScreen({super.key, required this.stationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stationAsync = ref.watch(stationProvider(stationId));

    return Scaffold(
      appBar: AppBar(
        title: stationAsync.whenData((s) => Text(s.name)).value ??
            const Text('Stacja'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      body: stationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(stationProvider(stationId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (station) => _StationDetailBody(station: station),
      ),
    );
  }
}

class _StationDetailBody extends ConsumerWidget {
  final Station station;
  const _StationDetailBody({required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sortedPrices = sortPrices(station.prices);
    final sortedHours = [...station.openingHours]..sort((a, b) {
      final ia = _dayOrder.indexOf(a.dayOfWeek);
      final ib = _dayOrder.indexOf(b.dayOfWeek);
      return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (station.address != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(station.address!),
              subtitle: station.lastUpdated != null
                  ? Text(
                '${l10n.update}: ${DateFormat('dd.MM.yyyy HH:mm').format(station.lastUpdated!.toLocal())}',
                style: const TextStyle(fontSize: 12),
              )
                  : null,
            ),
          ),
        const SizedBox(height: 12),

        Text(l10n.currentPrices,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (sortedPrices.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noPrices),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sortedPrices
                    .map((p) => FuelPriceChip(price: p))
                    .toList(),
              ),
            ),
          ),
        const SizedBox(height: 16),

        Text(l10n.priceHistory,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _PriceHistorySection(stationId: station.id, prices: sortedPrices),
        const SizedBox(height: 16),

        if (sortedHours.isNotEmpty) ...[
          Text(l10n.openingHours,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: sortedHours.map((h) {
                  final open = h.openTime.substring(0, 5);
                  final close = h.closeTime.substring(0, 5);
                  final isClosed = open == '00:00' && close == '00:00';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getDayName(context, h.dayOfWeek),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isClosed
                                ? Colors.red.shade50
                                : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isClosed ? l10n.closed : '$open – $close',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isClosed ? Colors.red.shade700 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PriceHistorySection extends ConsumerStatefulWidget {
  final int stationId;
  final List<FuelPrice> prices;
  const _PriceHistorySection(
      {required this.stationId, required this.prices});

  @override
  ConsumerState<_PriceHistorySection> createState() =>
      _PriceHistorySectionState();
}

class _PriceHistorySectionState extends ConsumerState<_PriceHistorySection> {
  String? _selectedFuel;

  @override
  void initState() {
    super.initState();
    if (widget.prices.isNotEmpty) {
      _selectedFuel = widget.prices.first.fuelType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(priceHistoryProvider(widget.stationId));
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.prices.isNotEmpty)
              Wrap(
                spacing: 8,
                children: widget.prices.map((p) {
                  final selected = _selectedFuel == p.fuelType;
                  return FilterChip(
                    label: Text(p.fuelType.toUpperCase()),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedFuel = p.fuelType),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            historyAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('${l10n.error}: $e'),
              data: (history) {
                final filtered = history
                    .where((p) => p.fuelType == _selectedFuel)
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (filtered.isEmpty) {
                  return Text(l10n.noHistory);
                }

                return Column(
                  children: filtered.take(10).map((p) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('dd.MM.yyyy HH:mm')
                                  .format(p.createdAt.toLocal()),
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            '${p.price.toStringAsFixed(2).replaceAll('.', ',')} zł',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
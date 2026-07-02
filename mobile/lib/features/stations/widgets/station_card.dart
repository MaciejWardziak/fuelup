import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/station.dart';
import 'fuel_price_chip.dart';
import '../../../core/l10n/app_localizations.dart';

class StationCard extends StatelessWidget {
  final Station station;
  const StationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sortedPrices = sortPrices(station.prices);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/station/${station.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nagłówek
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (station.address != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            station.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ceny paliw
              if (sortedPrices.isEmpty)
                Text(
                  l10n.noPrices,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sortedPrices
                      .map((p) => FuelPriceChip(price: p))
                      .toList(),
                ),

              // Data aktualizacji
              if (station.lastUpdated != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.update}: ${_formatDate(station.lastUpdated!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
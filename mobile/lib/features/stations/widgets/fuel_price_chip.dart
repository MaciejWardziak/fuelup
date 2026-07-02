import 'package:flutter/material.dart';
import '../../../data/models/station.dart';

const _fuelNames = {
  'pb95': 'Pb95',
  'pb98': 'Pb98',
  'on': 'ON',
  'lpg': 'LPG',
  'cng': 'CNG',
  'adblue': 'AdBlue',
};

const _fuelOrder = ['pb95', 'pb98', 'on', 'lpg', 'cng', 'adblue'];

class FuelPriceChip extends StatelessWidget {
  final FuelPrice price;
  const FuelPriceChip({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fuelNames[price.fuelType] ?? price.fuelType.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                price.price.toStringAsFixed(2).replaceAll('.', ','),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              _TrendIcon(trend: price.trend, change: price.change),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendIcon extends StatelessWidget {
  final String trend;
  final double change;
  const _TrendIcon({required this.trend, required this.change});

  @override
  Widget build(BuildContext context) {
    if (trend == 'up') {
      return Column(
        children: [
          Icon(Icons.arrow_upward, size: 14, color: Colors.red.shade600),
          Text(
            change.toStringAsFixed(2),
            style: TextStyle(fontSize: 10, color: Colors.red.shade600),
          ),
        ],
      );
    }
    if (trend == 'down') {
      return Column(
        children: [
          Icon(Icons.arrow_downward, size: 14, color: Colors.green.shade600),
          Text(
            change.abs().toStringAsFixed(2),
            style: TextStyle(fontSize: 10, color: Colors.green.shade600),
          ),
        ],
      );
    }
    return Icon(Icons.remove, size: 14, color: Colors.grey.shade400);
  }
}

// Helper do sortowania cen po ustalonej kolejności
List<FuelPrice> sortPrices(List<FuelPrice> prices) {
  final sorted = [...prices];
  sorted.sort((a, b) {
    final ia = _fuelOrder.indexOf(a.fuelType);
    final ib = _fuelOrder.indexOf(b.fuelType);
    return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
  });
  return sorted;
}
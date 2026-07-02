import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/station.dart';
import '../../../data/providers/station_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stationsAsync = ref.watch(stationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.admin,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (stations) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: () => _showStationForm(context, ref, null),
              icon: const Icon(Icons.add),
              label: Text(l10n.addStation),
            ),
            const SizedBox(height: 16),
            Text('${l10n.stations} (${stations.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...stations.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                subtitle: Text(s.address ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          _showStationForm(context, ref, s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.schedule_outlined),
                      onPressed: () =>
                          _showHoursForm(context, ref, s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: () =>
                          _confirmDelete(context, ref, s),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showStationForm(
      BuildContext context, WidgetRef ref, Station? station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StationForm(station: station, ref: ref),
    );
  }

  void _showHoursForm(
      BuildContext context, WidgetRef ref, Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HoursForm(station: station, ref: ref),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Station station) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteStation),
        content: Text(l10n.deleteStationConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(stationRepositoryProvider)
                    .deleteStation(station.id);
                ref.invalidate(stationsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.error}: $e')));
                }
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ── Formularz stacji ──────────────────────────────────────────────────────────

class _StationForm extends StatefulWidget {
  final Station? station;
  final WidgetRef ref;
  const _StationForm({this.station, required this.ref});

  @override
  State<_StationForm> createState() => _StationFormState();
}

class _StationFormState extends State<_StationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _url;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  String _scraperType = 'list';
  bool _filterByCity = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.station;
    _name = TextEditingController(text: s?.name ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _url = TextEditingController(text: s?.websiteUrl ?? '');
    _lat = TextEditingController(text: s?.lat?.toString() ?? '');
    _lng = TextEditingController(text: s?.lng?.toString() ?? '');
    if (s?.scraperConfig != null) {
      _scraperType = s!.scraperConfig!['type'] ?? 'list';
      _filterByCity = s.scraperConfig!['filter_by_city'] ?? false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _url.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'website_url': _url.text.trim(),
      'lat': double.tryParse(_lat.text),
      'lng': double.tryParse(_lng.text),
      'scraper_config': {
        'type': _scraperType,
        if (_scraperType == 'text') 'filter_by_city': _filterByCity,
      },
    };

    try {
      if (widget.station == null) {
        await widget.ref
            .read(stationRepositoryProvider)
            .createStation(data);
      } else {
        await widget.ref
            .read(stationRepositoryProvider)
            .updateStation(widget.station!.id, data);
      }
      widget.ref.invalidate(stationsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.station == null ? l10n.newStation : l10n.editStation,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: '${l10n.stationName} *'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.stationName
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.address),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _url,
                decoration: InputDecoration(labelText: l10n.websiteUrl),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      decoration:
                      InputDecoration(labelText: l10n.latitude),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lng,
                      decoration:
                      InputDecoration(labelText: l10n.longitude),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _scraperType,
                decoration:
                InputDecoration(labelText: l10n.scraperType),
                items: const [
                  DropdownMenuItem(
                      value: 'list',
                      child: Text('Lista (E.Leclerc)')),
                  DropdownMenuItem(
                      value: 'table', child: Text('Tabela (MZK)')),
                  DropdownMenuItem(
                      value: 'text', child: Text('Tekst (Rolmasz)')),
                  DropdownMenuItem(
                      value: 'main_page_leclerc',
                      child: Text('Strona główna Leclerc')),
                ],
                onChanged: (v) =>
                    setState(() => _scraperType = v ?? 'list'),
              ),
              if (_scraperType == 'text') ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(l10n.filterByCity),
                  value: _filterByCity,
                  onChanged: (v) => setState(() => _filterByCity = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : Text(widget.station == null
                      ? l10n.add
                      : l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Formularz godzin otwarcia ─────────────────────────────────────────────────

class _HoursForm extends StatefulWidget {
  final Station station;
  final WidgetRef ref;
  const _HoursForm({required this.station, required this.ref});

  @override
  State<_HoursForm> createState() => _HoursFormState();
}

class _HoursFormState extends State<_HoursForm> {
  late Map<String, TimeOfDay?> _openTimes;
  late Map<String, TimeOfDay?> _closeTimes;
  bool _loading = false;

  List<(String, String)> _getDays(AppLocalizations l10n) => [
    ('mon', l10n.monday),
    ('tue', l10n.tuesday),
    ('wen', l10n.wednesday),
    ('thu', l10n.thursday),
    ('fri', l10n.friday),
    ('sat', l10n.saturday),
    ('sun', l10n.sunday),
    ('holiday', l10n.holiday),
  ];

  @override
  void initState() {
    super.initState();
    _openTimes = {};
    _closeTimes = {};

    for (final h in widget.station.openingHours) {
      final openParts = h.openTime.split(':');
      final closeParts = h.closeTime.split(':');
      _openTimes[h.dayOfWeek] = TimeOfDay(
        hour: int.parse(openParts[0]),
        minute: int.parse(openParts[1]),
      );
      _closeTimes[h.dayOfWeek] = TimeOfDay(
        hour: int.parse(closeParts[0]),
        minute: int.parse(closeParts[1]),
      );
    }
  }

  Future<void> _pickTime(String day, bool isOpen) async {
    final initial = isOpen
        ? (_openTimes[day] ?? const TimeOfDay(hour: 6, minute: 0))
        : (_closeTimes[day] ?? const TimeOfDay(hour: 22, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openTimes[day] = picked;
        } else {
          _closeTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = widget.ref.read(stationRepositoryProvider);
      final days = _getDays(l10n);

      for (final (day, _) in days) {
        final open = _openTimes[day];
        final close = _closeTimes[day];
        if (open == null || close == null) continue;

        final openStr =
            '${open.hour.toString().padLeft(2, '0')}:${open.minute.toString().padLeft(2, '0')}:00';
        final closeStr =
            '${close.hour.toString().padLeft(2, '0')}:${close.minute.toString().padLeft(2, '0')}:00';

        final existing = widget.station.openingHours
            .where((h) => h.dayOfWeek == day)
            .firstOrNull;

        if (existing != null) {
          await repo.updateOpeningHours(existing.id, {
            'open_time': openStr,
            'close_time': closeStr,
          });
        } else {
          await repo.createOpeningHours({
            'station_id': widget.station.id,
            'day_of_week': day,
            'open_time': openStr,
            'close_time': closeStr,
          });
        }
      }

      widget.ref.invalidate(stationsProvider);
      widget.ref.invalidate(stationProvider(widget.station.id));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = _getDays(l10n);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.openingHoursFor} — ${widget.station.name}',
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...days.map((d) {
            final day = d.$1;
            final name = d.$2;
            final open = _openTimes[day];
            final close = _closeTimes[day];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(name,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(day, true),
                      child: Text(open != null
                          ? open.format(context)
                          : l10n.opening),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(day, false),
                      child: Text(close != null
                          ? close.format(context)
                          : l10n.closing),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : Text(l10n.saveHours),
            ),
          ),
        ],
      ),
    );
  }
}
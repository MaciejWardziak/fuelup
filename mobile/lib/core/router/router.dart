import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/stations/screens/stations_screen.dart';
import '../../features/stations/screens/station_detail_screen.dart';
import '../../features/admin/screens/admin_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'stations',
      builder: (context, state) => const StationsScreen(),
    ),
    GoRoute(
      path: '/station/:id',
      name: 'station-detail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return StationDetailScreen(stationId: id);
      },
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Strona nie istnieje: ${state.error}'),
    ),
  ),
);
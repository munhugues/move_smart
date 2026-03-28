import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/scheduled_route.dart';
import '../models/trip_state.dart';

// Streams all bus routes from Firestore in real time
final routesProvider = StreamProvider<List<ScheduledRoute>>((ref) {
  return FirebaseFirestore.instance
      .collection('ScheduleRoute')
      .snapshots()
      .map((snap) => snap.docs.map(ScheduledRoute.fromFirestore).toList());
});

// Tracks which bottom nav tab is active (0 = Home, 1 = Search, etc.)
final navIndexProvider = NotifierProvider<_NavNotifier, int>(_NavNotifier.new);

class _NavNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int i) => state = i;
}

// Holds the search text the user types
final searchQueryProvider =
    NotifierProvider<_QueryNotifier, String>(_QueryNotifier.new);

class _QueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

// Filters routes by the search query
final filteredRoutesProvider =
    Provider<AsyncValue<List<ScheduledRoute>>>((ref) {
  final routesAsync = ref.watch(routesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return routesAsync.whenData((routes) {
    if (query.isEmpty) return routes;
    return routes
        .where((r) =>
            r.from.toLowerCase().contains(query) ||
            r.to.toLowerCase().contains(query) ||
            r.busName.toLowerCase().contains(query))
        .toList();
  });
});

// Manages the live trip state (bus moving, user location, ETA)
class TripNotifier extends Notifier<TripState?> {
  StreamSubscription<Position>? _locationSub;
  Timer? _busTimer;
  int _waypointIndex = 0;

  @override
  TripState? build() => null;

  Future<void> startTrip(ScheduledRoute route) async {
    _waypointIndex = 0;
    // Use Firestore waypoints if available, else just start → end
    final waypoints = route.routePoints.isNotEmpty
        ? route.routePoints
        : [route.fromCoords, route.toCoords];

    state = TripState(
      routeId: route.id,
      fromName: route.from,
      toName: route.to,
      destination: route.toCoords,
      busLocation: waypoints.first,
      routePoints: waypoints,
      seatsLeft: route.seatsLeft,
    );

    await _getLocation();
    _moveBus(waypoints);
  }

  // Try to get the user's real GPS location
  Future<void> _getLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) { _useFallback(); return; }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _useFallback();
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      state = state?.copyWith(userLocation: loc, locationReady: true);
      if (state != null) _updateETA(loc);

      // Keep updating as the user moves
      _locationSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((p) {
        final l = LatLng(p.latitude, p.longitude);
        state = state?.copyWith(userLocation: l);
        _updateETA(l);
      });
    } catch (_) {
      _useFallback();
    }
  }

  // If GPS fails, use a fixed point in Kigali
  void _useFallback() {
    const fallback = LatLng(-1.9500, 30.0588);
    state = state?.copyWith(userLocation: fallback, locationReady: true);
    if (state != null) _updateETA(fallback);
  }

  // Move the bus marker along the waypoints every 4 seconds
  void _moveBus(List<LatLng> waypoints) {
    _busTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (state == null) return;
      if (_waypointIndex < waypoints.length - 1) {
        _waypointIndex++;
        state = state?.copyWith(busLocation: waypoints[_waypointIndex]);
      } else {
        _busTimer?.cancel();
        state = state?.copyWith(tripEnded: true);
      }
    });
  }

  // Calculate distance and ETA from user to destination
  void _updateETA(LatLng userLoc) {
    if (state == null) return;
    final dist = _km(userLoc, state!.destination);
    state = state?.copyWith(
      distanceKm: dist,
      etaMinutes: (dist / 0.5).ceil(), // rough walking speed
    );
  }

  // Haversine formula — straight-line distance between two GPS points
  double _km(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(a.latitude)) * cos(_rad(b.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _rad(double d) => d * pi / 180;

  // Stop everything and clear the trip
  void endTrip() {
    _locationSub?.cancel();
    _busTimer?.cancel();
    state = null;
    _waypointIndex = 0;
  }
}

final tripProvider = NotifierProvider<TripNotifier, TripState?>(TripNotifier.new);

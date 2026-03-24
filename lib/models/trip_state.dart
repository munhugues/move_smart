import 'package:latlong2/latlong.dart';

// Holds everything about the live trip on the map
class TripState {
  final String routeId;
  final String fromName;
  final String toName;
  final LatLng destination;
  final LatLng? userLocation;
  final LatLng busLocation;
  final List<LatLng> routePoints;
  final double distanceKm;
  final int etaMinutes;
  final int seatsLeft;
  final bool locationReady;
  final bool tripEnded;

  const TripState({
    required this.routeId,
    required this.fromName,
    required this.toName,
    required this.destination,
    required this.busLocation,
    required this.routePoints,
    this.userLocation,
    this.distanceKm = 0,
    this.etaMinutes = 0,
    this.seatsLeft = 30,
    this.locationReady = false,
    this.tripEnded = false,
  });

  // Returns a new TripState with only the changed fields updated
  TripState copyWith({
    LatLng? userLocation,
    LatLng? busLocation,
    List<LatLng>? routePoints,
    double? distanceKm,
    int? etaMinutes,
    int? seatsLeft,
    bool? locationReady,
    bool? tripEnded,
  }) {
    return TripState(
      routeId: routeId,
      fromName: fromName,
      toName: toName,
      destination: destination,
      userLocation: userLocation ?? this.userLocation,
      busLocation: busLocation ?? this.busLocation,
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      locationReady: locationReady ?? this.locationReady,
      tripEnded: tripEnded ?? this.tripEnded,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

// One bus route from Firestore
class ScheduledRoute {
  final String id;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String busName;
  final String busType;
  final double fare;
  final int seatsLeft;
  final String duration;
  final LatLng fromCoords;
  final LatLng toCoords;
  final List<LatLng> routePoints;

  const ScheduledRoute({
    required this.id,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.busName,
    required this.busType,
    required this.fare,
    required this.seatsLeft,
    required this.duration,
    required this.fromCoords,
    required this.toCoords,
    required this.routePoints,
  });

  // Build a ScheduledRoute from a Firestore document
  factory ScheduledRoute.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Read routePoints list if it exists
    final points = (d['routePoints'] as List? ?? []).map((p) {
      final pt = p as Map<String, dynamic>;
      return LatLng((pt['lat'] as num).toDouble(), (pt['lng'] as num).toDouble());
    }).toList();

    return ScheduledRoute(
      id: doc.id,
      from: (d['from'] ?? d['departureLocation'] ?? '') as String,
      to: (d['to'] ?? d['destinationLocation'] ?? '') as String,
      departureTime: (d['departureTime'] ?? '') as String,
      arrivalTime: (d['arrivalTime'] ?? d['destinationTime'] ?? '') as String,
      busName: (d['busName'] ?? d['busNumber'] ?? '') as String,
      busType: (d['busType'] ?? '') as String,
      fare: ((d['fare'] ?? d['seatPrice'] ?? 0) as num).toDouble(),
      seatsLeft: (d['seatsLeft'] as num?)?.toInt() ?? 30,
      duration: (d['duration'] ?? d['journeyDuration'] ?? '') as String,
      // Use stored coords or fall back to centre of Kigali
      fromCoords: LatLng(
        (d['fromLat'] as num?)?.toDouble() ?? -1.9441,
        (d['fromLng'] as num?)?.toDouble() ?? 30.0619,
      ),
      toCoords: LatLng(
        (d['toLat'] as num?)?.toDouble() ?? -1.9536,
        (d['toLng'] as num?)?.toDouble() ?? 30.1127,
      ),
      routePoints: points,
    );
  }
}

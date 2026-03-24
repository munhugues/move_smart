/// Represents a single recent trip shown on the Home screen.
class TripEntity {
  final String id;
  final String origin;
  final String destination;
  final double distanceKm;
  final int durationMins;
  final double fareEtb;

  const TripEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMins,
    required this.fareEtb,
  });

  /// Convenience getter: "Remera → Nyanza"
  String get routeLabel => '$origin → $destination';
}

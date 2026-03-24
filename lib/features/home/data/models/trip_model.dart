import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.origin,
    required super.destination,
    required super.distanceKm,
    required super.durationMins,
    required super.fareEtb,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id:          map['id']          as String,
      origin:      map['origin']      as String,
      destination: map['destination'] as String,
      distanceKm:  (map['distanceKm']  as num).toDouble(),
      durationMins: map['durationMins'] as int,
      fareEtb:     (map['fareEtb']     as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'origin': origin, 'destination': destination,
    'distanceKm': distanceKm, 'durationMins': durationMins, 'fareEtb': fareEtb,
  };
}

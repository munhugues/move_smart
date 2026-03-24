import '../entities/trip_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class HomeRepository {
  Future<({List<TripEntity>? trips, Failure? failure})> getRecentTrips(String userId);
}

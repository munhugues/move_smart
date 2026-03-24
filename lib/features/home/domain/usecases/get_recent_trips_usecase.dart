import '../entities/trip_entity.dart';
import '../repositories/home_repository.dart';
import '../../../../core/errors/failures.dart';

class GetRecentTripsUseCase {
  final HomeRepository repository;
  const GetRecentTripsUseCase(this.repository);

  Future<({List<TripEntity>? trips, Failure? failure})> call(String userId) {
    return repository.getRecentTrips(userId);
  }
}

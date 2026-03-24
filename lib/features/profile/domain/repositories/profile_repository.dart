import '../entities/profile_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class ProfileRepository {
  Future<({ProfileEntity? profile, Failure? failure})> getProfile(String uid);
  Future<Failure?> updateProfile(ProfileEntity profile);
  Future<Failure?> savePreferences(ProfileEntity profile);
}

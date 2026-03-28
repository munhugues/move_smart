import '../../../../core/errors/failures.dart';
import '../../../../core/services/prefs_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._prefsService);

  final PrefsService _prefsService;

  @override
  Future<({ProfileEntity? profile, Failure? failure})> getProfile(
      String uid) async {
    try {
      final profile = ProfileEntity(
        uid: uid,
        fullName: _prefsService.savedName ?? 'Move Smart User',
        email: _prefsService.savedEmail ?? '',
        photoUrl: _prefsService.savedPhotoUrl,
        locationEnabled: _prefsService.locationEnabled,
        pushNotificationsEnabled: _prefsService.pushNotificationsEnabled,
        darkModeEnabled: _prefsService.isDarkMode,
      );
      return (profile: profile, failure: null);
    } catch (e) {
      return (profile: null, failure: CacheFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> updateProfile(ProfileEntity profile) async {
    try {
      await _prefsService.saveUserSession(
        uid: profile.uid,
        email: profile.email,
        name: profile.fullName,
      );
      await _prefsService.setProfilePhotoUrl(profile.photoUrl);
      await _prefsService.setDarkMode(profile.darkModeEnabled);
      await _prefsService.setLocationEnabled(profile.locationEnabled);
      await _prefsService
          .setPushNotificationsEnabled(profile.pushNotificationsEnabled);
      return null;
    } catch (e) {
      return CacheFailure(e.toString());
    }
  }

  @override
  Future<Failure?> savePreferences(ProfileEntity profile) async {
    try {
      await _prefsService.setDarkMode(profile.darkModeEnabled);
      await _prefsService.setLocationEnabled(profile.locationEnabled);
      await _prefsService
          .setPushNotificationsEnabled(profile.pushNotificationsEnabled);
      return null;
    } catch (e) {
      return CacheFailure(e.toString());
    }
  }
}

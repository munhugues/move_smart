/// Represents a user's profile and their preference settings.
class ProfileEntity {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final bool locationEnabled;
  final bool pushNotificationsEnabled;
  final bool darkModeEnabled;

  const ProfileEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.locationEnabled = true,
    this.pushNotificationsEnabled = false,
    this.darkModeEnabled = false,
  });

  /// Returns a copy with some fields changed — keeps objects immutable.
  ProfileEntity copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
    bool? locationEnabled,
    bool? pushNotificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return ProfileEntity(
      uid:                     uid,
      fullName:                fullName                ?? this.fullName,
      email:                   email                   ?? this.email,
      photoUrl:                photoUrl                ?? this.photoUrl,
      locationEnabled:         locationEnabled         ?? this.locationEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      darkModeEnabled:         darkModeEnabled         ?? this.darkModeEnabled,
    );
  }
}

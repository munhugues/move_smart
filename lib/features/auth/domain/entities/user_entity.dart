/// Pure Dart class — no Firebase, no Flutter imports.
/// This is the user object the whole app works with.
class UserEntity {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String? authToken;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.authToken,
  });
}

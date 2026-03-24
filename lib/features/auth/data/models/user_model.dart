import '../../domain/entities/user_entity.dart';

/// UserModel adds Firebase conversion on top of UserEntity.
/// The UI only ever sees UserEntity — never UserModel directly.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    super.photoUrl,
  });

  /// Convert Firestore document map → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:      map['uid']      as String,
      email:    map['email']    as String,
      fullName: map['fullName'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  /// Convert UserModel → Firestore document map
  Map<String, dynamic> toMap() => {
    'uid':      uid,
    'email':    email,
    'fullName': fullName,
    'photoUrl': photoUrl,
  };
}

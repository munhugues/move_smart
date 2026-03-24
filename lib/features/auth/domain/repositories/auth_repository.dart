import '../entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

/// Abstract contract — domain layer only knows this interface.
/// Data layer provides the real Firebase implementation.
abstract class AuthRepository {
  Future<({UserEntity? user, Failure? failure})> signInWithEmail({
    required String email,
    required String password,
  });

  Future<({UserEntity? user, Failure? failure})> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<({UserEntity? user, Failure? failure})> signInWithGoogle();

  Future<Failure?> signOut();

  UserEntity? get currentUser;
}

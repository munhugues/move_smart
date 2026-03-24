import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/errors/failures.dart';

/// Real implementation of AuthRepository.
/// Catches Firebase exceptions and converts them to Failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<({UserEntity? user, Failure? failure})> signInWithEmail({
    required String email, required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(email, password);
      return (user: user, failure: null);
    } catch (e) {
      return (user: null, failure: AuthFailure(e.toString()));
    }
  }

  @override
  Future<({UserEntity? user, Failure? failure})> signUpWithEmail({
    required String email, required String password, required String fullName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(email, password, fullName);
      return (user: user, failure: null);
    } catch (e) {
      return (user: null, failure: AuthFailure(e.toString()));
    }
  }

  @override
  Future<({UserEntity? user, Failure? failure})> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return (user: user, failure: null);
    } catch (e) {
      return (user: null, failure: AuthFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> signOut() async {
    try {
      await remoteDataSource.signOut();
      return null;
    } catch (e) {
      return AuthFailure(e.toString());
    }
  }

  @override
  UserEntity? get currentUser => remoteDataSource.currentUser;
}

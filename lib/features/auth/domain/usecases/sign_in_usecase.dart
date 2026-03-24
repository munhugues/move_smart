import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case: sign in with email and password.
/// One class = one action. Business rules live here, not in the UI.
class SignInUseCase {
  final AuthRepository repository;
  const SignInUseCase(this.repository);

  Future<({UserEntity? user, Failure? failure})> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }
}

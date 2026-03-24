import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class SignUpUseCase {
  final AuthRepository repository;
  const SignUpUseCase(this.repository);

  Future<({UserEntity? user, Failure? failure})> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return repository.signUpWithEmail(
      email: email, password: password, fullName: fullName,
    );
  }
}

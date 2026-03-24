import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class AppleSignInUseCase {
  final AuthRepository repository;
  const AppleSignInUseCase(this.repository);

  Future<({UserEntity? user, Failure? failure})> call() {
    return repository.signInWithApple();
  }
}

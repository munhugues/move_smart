import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;
  const GoogleSignInUseCase(this.repository);

  Future<({UserEntity? user, Failure? failure})> call() {
    return repository.signInWithGoogle();
  }
}

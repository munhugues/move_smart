/// Failures are returned instead of throwing exceptions.
/// This keeps error handling explicit and easy to test.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure     extends Failure { const AuthFailure(super.message);     }
class NetworkFailure  extends Failure { const NetworkFailure(super.message);  }
class DatabaseFailure extends Failure { const DatabaseFailure(super.message); }
class CacheFailure    extends Failure { const CacheFailure(super.message);    }

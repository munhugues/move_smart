import '../models/user_model.dart';

/// Interface for Firebase auth calls.
/// TODO: Implement AuthRemoteDataSourceImpl using FirebaseAuth + Firestore.
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String email, String password, String fullName);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  UserModel? get currentUser;
}

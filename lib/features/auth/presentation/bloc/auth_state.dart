part of 'auth_bloc.dart';

/// States = what the UI shows (outputs from the BLoC).
sealed class AuthState {}

class AuthInitial      extends AuthState {}
class AuthLoading      extends AuthState {}
class AuthSignedOut    extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState(this.message);
}

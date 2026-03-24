part of 'auth_bloc.dart';

/// Events = things the USER does (inputs to the BLoC).
sealed class AuthEvent {}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  SignInWithEmailRequested({required this.email, required this.password});
}

class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });
}

class SignInWithGoogleRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

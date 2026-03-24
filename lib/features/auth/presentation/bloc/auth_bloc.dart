import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// AuthBloc: sits between the UI and the use cases.
/// UI sends Events → BLoC calls use cases → BLoC emits States → UI rebuilds.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event, Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInUseCase(email: event.email, password: event.password);
    result.failure != null
        ? emit(AuthFailureState(result.failure!.message))
        : emit(AuthSuccess(result.user!));
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event, Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      email: event.email, password: event.password, fullName: event.fullName,
    );
    result.failure != null
        ? emit(AuthFailureState(result.failure!.message))
        : emit(AuthSuccess(result.user!));
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event, Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await googleSignInUseCase();
    result.failure != null
        ? emit(AuthFailureState(result.failure!.message))
        : emit(AuthSuccess(result.user!));
  }

  Future<void> _onSignOut(
    SignOutRequested event, Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failure = await authRepository.signOut();
    failure != null
        ? emit(AuthFailureState(failure.message))
        : emit(AuthSignedOut());
  }
}

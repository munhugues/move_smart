import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/prefs_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/apple_sign_in_usecase.dart';
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
  final AppleSignInUseCase appleSignInUseCase;
  final AuthRepository authRepository;
  final PrefsService prefsService;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
    required this.appleSignInUseCase,
    required this.authRepository,
    required this.prefsService,
  }) : super(AuthInitial()) {
    on<AuthStatusRequested>(_onAuthStatusRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignInWithAppleRequested>(_onSignInWithApple);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onAuthStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final currentUser = authRepository.currentUser;
    if (currentUser != null) {
      await _saveSession(currentUser);
      emit(AuthSuccess(currentUser));
      return;
    }

    if (prefsService.isLoggedIn) {
      final restoredUser = UserEntity(
        uid: prefsService.savedUid ?? '',
        email: prefsService.savedEmail ?? '',
        fullName: prefsService.savedName ?? 'Move Smart User',
      );
      emit(AuthSuccess(restoredUser));
      return;
    }

    emit(AuthSignedOut());
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result =
        await signInUseCase(email: event.email, password: event.password);
    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
      return;
    }

    final user = result.user!;
    await _saveSession(user);
    emit(AuthSuccess(user));
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
    );
    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
      return;
    }

    final user = result.user!;
    await _saveSession(user);
    emit(AuthSuccess(user));
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await googleSignInUseCase();
    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
      return;
    }

    final user = result.user!;
    await _saveSession(user);
    emit(AuthSuccess(user));
  }

  Future<void> _onSignInWithApple(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await appleSignInUseCase();
    if (result.failure != null) {
      emit(AuthFailureState(result.failure!.message));
      return;
    }

    final user = result.user!;
    await _saveSession(user);
    emit(AuthSuccess(user));
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failure = await authRepository.signOut();
    if (failure != null) {
      emit(AuthFailureState(failure.message));
      return;
    }

    await prefsService.clearSession();
    emit(AuthSignedOut());
  }

  Future<void> _saveSession(UserEntity user) {
    return prefsService.saveUserSession(
      uid: user.uid,
      email: user.email,
      name: user.fullName,
      token: user.authToken,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_routes.dart';
import 'core/services/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/apple_sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/settings/presentation/cubit/app_settings_cubit.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'presentation/main_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.instance.init();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  runApp(
    // ProviderScope wraps everything so Riverpod (booking) works inside
    ProviderScope(
      child: MoveSmart(firebaseReady: firebaseReady),
    ),
  );
}

class MoveSmart extends StatelessWidget {
  const MoveSmart({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    final prefsService = PrefsService.instance;
    final authDataSource =
        firebaseReady ? FirebaseAuthRemoteDataSource() : _MockAuthDataSource();
    final authRepository = AuthRepositoryImpl(authDataSource);
    final profileRepository = ProfileRepositoryImpl(prefsService);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>(
          create: (_) => AppSettingsCubit(prefsService: prefsService),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: SignInUseCase(authRepository),
            signUpUseCase: SignUpUseCase(authRepository),
            googleSignInUseCase: GoogleSignInUseCase(authRepository),
            appleSignInUseCase: AppleSignInUseCase(authRepository),
            authRepository: authRepository,
            prefsService: prefsService,
          )..add(AuthStatusRequested()),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            profileRepository: profileRepository,
            appSettingsCubit: context.read<AppSettingsCubit>(),
          ),
        ),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Move Smart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const AuthGatePage(),
              AppRoutes.login: (_) => const LoginPage(),
              AppRoutes.signUp: (_) => const SignUpPage(),
              // Booking home — MainNav is the booking team's bottom nav shell
              AppRoutes.home: (_) => const MainNav(),
              AppRoutes.profile: (_) => const ProfilePage(),
              AppRoutes.settings: (_) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}

// Fallback mock used when Firebase isn't configured yet.
class _MockAuthDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
      uid: 'demo-uid',
      email: email,
      fullName: 'Demo User',
      authToken: 'demo-token',
    );
  }

  @override
  Future<UserModel> signUpWithEmail(
      String email, String password, String fullName) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
      uid: 'demo-uid',
      email: email,
      fullName: fullName,
      authToken: 'demo-token',
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const UserModel(
      uid: 'demo-google-uid',
      email: 'demo.google@movesmart.rw',
      fullName: 'Google Demo',
      authToken: 'demo-google-token',
    );
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const UserModel(
      uid: 'demo-apple-uid',
      email: 'demo.apple@movesmart.rw',
      fullName: 'Apple Demo',
      authToken: 'demo-apple-token',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  UserModel? get currentUser => null;
}

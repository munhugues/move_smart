import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/app_settings_cubit.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final AppSettingsCubit appSettingsCubit;

  ProfileBloc({
    required this.profileRepository,
    required this.appSettingsCubit,
  }) : super(ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<ToggleDarkModeRequested>(_onToggleDarkMode);
    on<ToggleNotificationsRequested>(_onToggleNotifications);
    on<ToggleLocationRequested>(_onToggleLocation);
  }

  Future<void> _onLoadProfile(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await profileRepository.getProfile(event.uid);
    result.failure != null
        ? emit(ProfileError(result.failure!.message))
        : emit(ProfileLoaded(result.profile!));
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final failure = await profileRepository.updateProfile(event.profile);
    failure != null
        ? emit(ProfileError(failure.message))
        : emit(ProfileUpdated(event.profile));
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkModeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final updated = (state as ProfileLoaded)
          .profile
          .copyWith(darkModeEnabled: event.enabled);
      await profileRepository.savePreferences(updated);
      await appSettingsCubit.setDarkMode(event.enabled);
      emit(ProfileLoaded(updated));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotificationsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final updated = (state as ProfileLoaded)
          .profile
          .copyWith(pushNotificationsEnabled: event.enabled);
      await profileRepository.savePreferences(updated);
      emit(ProfileLoaded(updated));
    }
  }

  Future<void> _onToggleLocation(
    ToggleLocationRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final updated = (state as ProfileLoaded)
          .profile
          .copyWith(locationEnabled: event.enabled);
      await profileRepository.savePreferences(updated);
      emit(ProfileLoaded(updated));
    }
  }
}

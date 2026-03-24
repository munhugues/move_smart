part of 'profile_bloc.dart';

sealed class ProfileEvent {}

class LoadProfileRequested extends ProfileEvent {
  final String uid;
  LoadProfileRequested(this.uid);
}

class UpdateProfileRequested extends ProfileEvent {
  final ProfileEntity profile;
  UpdateProfileRequested(this.profile);
}

class ToggleDarkModeRequested extends ProfileEvent {
  final bool enabled;
  ToggleDarkModeRequested(this.enabled);
}

class ToggleNotificationsRequested extends ProfileEvent {
  final bool enabled;
  ToggleNotificationsRequested(this.enabled);
}

class ToggleLocationRequested extends ProfileEvent {
  final bool enabled;
  ToggleLocationRequested(this.enabled);
}

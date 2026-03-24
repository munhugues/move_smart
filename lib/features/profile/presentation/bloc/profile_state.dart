part of 'profile_bloc.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileUpdated extends ProfileState {
  final ProfileEntity profile;
  ProfileUpdated(this.profile);
}

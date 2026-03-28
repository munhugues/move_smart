import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/prefs_service.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/preference_tile.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = PrefsService.instance.savedUid;
      if (uid != null && uid.isNotEmpty) {
        context.read<ProfileBloc>().add(LoadProfileRequested(uid));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignedOut) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splash,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: const Text(
            AppStrings.profile,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: const [AppOverflowMenu()],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final profile = (state as ProfileLoaded).profile;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    fullName: profile.fullName,
                    email: profile.email,
                    photoUrl: profile.photoUrl,
                    onEdit: () => _showEditProfileDialog(context, profile),
                    onChangePhoto: () =>
                        _showChangePhotoDialog(context, profile),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    AppStrings.preferences,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PreferenceTile(
                    title: AppStrings.location,
                    icon: Icons.location_on_outlined,
                    trailing: Switch.adaptive(
                      value: profile.locationEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleLocationRequested(value),
                            );
                      },
                    ),
                  ),
                  PreferenceTile(
                    title: AppStrings.pushNotifs,
                    icon: Icons.notifications_outlined,
                    trailing: Switch.adaptive(
                      value: profile.pushNotificationsEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleNotificationsRequested(value),
                            );
                      },
                    ),
                  ),
                  PreferenceTile(
                    title: AppStrings.darkMode,
                    icon: Icons.dark_mode_outlined,
                    trailing: Switch.adaptive(
                      value: profile.darkModeEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleDarkModeRequested(value),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.other,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PreferenceTile(
                    title: AppStrings.settings,
                    icon: Icons.settings_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.settings),
                  ),
                  PreferenceTile(
                    title: AppStrings.helpCenter,
                    icon: Icons.help_outline,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help Center coming soon.')),
                    ),
                  ),
                  PreferenceTile(
                    title: AppStrings.logout,
                    icon: Icons.logout,
                    onTap: () =>
                        context.read<AuthBloc>().add(SignOutRequested()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    ProfileEntity profile,
  ) async {
    final nameController = TextEditingController(text: profile.fullName);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter full name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedName = nameController.text.trim();
                if (updatedName.isEmpty) return;

                context.read<ProfileBloc>().add(
                      UpdateProfileRequested(
                        profile.copyWith(fullName: updatedName),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
  }

  Future<void> _showChangePhotoDialog(
    BuildContext context,
    ProfileEntity profile,
  ) async {
    final urlController = TextEditingController(text: profile.photoUrl ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Profile Photo'),
          content: TextField(
            controller: urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Photo URL',
              hintText: 'https://...'
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ProfileBloc>().add(
                      UpdateProfileRequested(
                        profile.copyWith(photoUrl: null),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(
                      UpdateProfileRequested(
                        profile.copyWith(photoUrl: urlController.text.trim()),
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    urlController.dispose();
  }
}

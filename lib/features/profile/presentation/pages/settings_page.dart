import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/app_settings_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/preference_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          if (profileState is! ProfileLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, settingsState) {
              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  const _SectionTitle('Account Settings'),
                  PreferenceTile(
                    title: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    onTap: () {},
                  ),
                  PreferenceTile(
                    title: 'Language',
                    icon: Icons.language,
                    trailing: Text(
                      settingsState.languageCode.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _showLanguagePicker(
                        context, settingsState.languageCode),
                  ),
                  PreferenceTile(
                    title: 'Change Password',
                    icon: Icons.lock_outline,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Notifications'),
                  PreferenceTile(
                    title: 'Trip Reminders',
                    icon: Icons.notifications_none_outlined,
                    trailing: Switch.adaptive(
                      value: profileState.profile.pushNotificationsEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleNotificationsRequested(value),
                            );
                      },
                    ),
                  ),
                  PreferenceTile(
                    title: 'Live Arrival Alerts',
                    icon: Icons.directions_bus_outlined,
                    trailing: Switch.adaptive(
                      value: profileState.profile.locationEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleLocationRequested(value),
                            );
                      },
                    ),
                  ),
                  PreferenceTile(
                    title: 'Service Disruptions or Delays',
                    icon: Icons.info_outline,
                    trailing: Switch.adaptive(
                      value: profileState.profile.darkModeEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleDarkModeRequested(value),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Privacy & Location'),
                  PreferenceTile(
                    title: 'Live Location Sharing',
                    icon: Icons.location_on_outlined,
                    trailing: Switch.adaptive(
                      value: profileState.profile.locationEnabled,
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                              ToggleLocationRequested(value),
                            );
                      },
                    ),
                  ),
                  PreferenceTile(
                    title: 'Privacy Policy',
                    icon: Icons.shield_outlined,
                    onTap: () {},
                  ),
                  PreferenceTile(
                    title: 'Permissions Settings',
                    icon: Icons.key_outlined,
                    onTap: () {},
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    String currentLanguage,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Choose Language',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _LanguageOption(
                label: 'English',
                code: 'en',
                selected: currentLanguage == 'en',
              ),
              _LanguageOption(
                label: 'Kinyarwanda',
                code: 'rw',
                selected: currentLanguage == 'rw',
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null && context.mounted) {
      await context.read<AppSettingsCubit>().setLanguage(selected);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
  });

  final String label;
  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: AppColors.textGrey),
      onTap: () => Navigator.pop(context, code),
    );
  }
}

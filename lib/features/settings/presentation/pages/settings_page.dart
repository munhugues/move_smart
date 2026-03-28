import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/prefs_service.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/widgets/preference_tile.dart';
import '../cubit/app_settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: const [AppOverflowMenu()],
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
                  const _SectionTitle('Preferences'),
                  PreferenceTile(
                    title: 'Push Notifications',
                    icon: Icons.notifications_outlined,
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
                    title: 'Location',
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
                    title: 'Dark Mode',
                    icon: Icons.dark_mode_outlined,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: theme.colorScheme.onSurface,
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

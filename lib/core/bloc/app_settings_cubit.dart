import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/prefs_service.dart';

class AppSettingsState {
  const AppSettingsState({
    required this.themeMode,
    required this.languageCode,
  });

  final ThemeMode themeMode;
  final String languageCode;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({required PrefsService prefsService})
      : _prefsService = prefsService,
        super(
          AppSettingsState(
            themeMode:
                prefsService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            languageCode: prefsService.language,
          ),
        );

  final PrefsService _prefsService;

  Future<void> setDarkMode(bool enabled) async {
    await _prefsService.setDarkMode(enabled);
    emit(state.copyWith(themeMode: enabled ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefsService.setLanguage(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Handles all local storage using SharedPreferences.
///
/// Member 1 requirement: save user settings (Language, Dark Mode)
/// and the Login Token so the app stays logged in after restart.
///
/// Keys are private constants — prevents typo bugs.
class PrefsService {
  PrefsService._(); // singleton pattern — call PrefsService.instance

  static PrefsService? _instance;
  static PrefsService get instance => _instance ??= PrefsService._();

  late SharedPreferences _prefs;

  /// MUST be called once in main() before runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Key constants ─────────────────────────────────────────
  static const _keyDarkMode = 'dark_mode';
  static const _keyLanguage = 'language';
  static const _keyAuthToken = 'auth_token';
  static const _keyUserUid = 'user_uid';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserPhoto = 'user_photo';
  static const _keyLocationEnabled = 'location_enabled';
  static const _keyPushNotificationsEnabled = 'push_notifications_enabled';

  // ── Dark Mode ─────────────────────────────────────────────

  /// Returns true if user has dark mode enabled (default: false)
  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;

  /// Save dark mode preference — persists across app restarts
  Future<void> setDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);

  // ── Language ──────────────────────────────────────────────

  /// Returns the user's chosen language code (default: 'en')
  String get language => _prefs.getString(_keyLanguage) ?? 'en';

  /// Save language preference
  Future<void> setLanguage(String langCode) =>
      _prefs.setString(_keyLanguage, langCode);

  // ── Auth Token / Login state ──────────────────────────────

  /// Save the Firebase UID and user info after successful login.
  /// This keeps the user "logged in" across app restarts.
  Future<void> saveUserSession({
    required String uid,
    required String email,
    required String name,
    String? token,
  }) async {
    await _prefs.setString(_keyUserUid, uid);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, name);
    if (token != null) await _prefs.setString(_keyAuthToken, token);
  }

  /// Returns true if a user session exists (i.e. user is logged in)
  bool get isLoggedIn => _prefs.getString(_keyUserUid) != null;

  /// Returns saved user UID (null if not logged in)
  String? get savedUid => _prefs.getString(_keyUserUid);
  String? get savedEmail => _prefs.getString(_keyUserEmail);
  String? get savedName => _prefs.getString(_keyUserName);
  String? get savedAuthToken => _prefs.getString(_keyAuthToken);
  String? get savedPhotoUrl => _prefs.getString(_keyUserPhoto);

  bool get locationEnabled => _prefs.getBool(_keyLocationEnabled) ?? true;
  bool get pushNotificationsEnabled =>
      _prefs.getBool(_keyPushNotificationsEnabled) ?? true;

  Future<void> setProfilePhotoUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      await _prefs.remove(_keyUserPhoto);
      return;
    }
    await _prefs.setString(_keyUserPhoto, url.trim());
  }

  Future<void> setLocationEnabled(bool value) =>
      _prefs.setBool(_keyLocationEnabled, value);

  Future<void> setPushNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyPushNotificationsEnabled, value);

  /// Clear session on logout — removes all saved login data
  Future<void> clearSession() async {
    await _prefs.remove(_keyUserUid);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyUserPhoto);
  }

  /// Clear ALL preferences (used in testing or full reset)
  Future<void> clearAll() => _prefs.clear();
}

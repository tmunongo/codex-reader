import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing application preferences
class PreferencesService {
  static const String _sidebarWidthKey = 'sidebar_width';
  static const String _themeModeKey = 'theme_mode';
  static const String _lastThemeKey = 'last_theme';

  SharedPreferences? _prefs;

  /// Initialize the service (must be called before use)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
  }

  // ========== Sidebar Width ==========

  /// Get saved sidebar width
  double getSidebarWidth(double defaultWidth) {
    _ensureInitialized();
    return _prefs!.getDouble(_sidebarWidthKey) ?? defaultWidth;
  }

  /// Save sidebar width
  Future<void> setSidebarWidth(double width) async {
    _ensureInitialized();
    await _prefs!.setDouble(_sidebarWidthKey, width);
  }

  // ========== Theme Mode ==========

  /// Get saved theme mode (light, dark, system)
  String getThemeMode() {
    _ensureInitialized();
    return _prefs!.getString(_themeModeKey) ?? 'dark';
  }

  /// Save theme mode
  Future<void> setThemeMode(String mode) async {
    _ensureInitialized();
    await _prefs!.setString(_themeModeKey, mode);
  }

  // ========== Last Used Theme ==========

  /// Get last used custom theme name
  String? getLastTheme() {
    _ensureInitialized();
    return _prefs!.getString(_lastThemeKey);
  }

  /// Save last used custom theme name
  Future<void> setLastTheme(String themeName) async {
    _ensureInitialized();
    await _prefs!.setString(_lastThemeKey, themeName);
  }

  /// Clear last used theme
  Future<void> clearLastTheme() async {
    _ensureInitialized();
    await _prefs!.remove(_lastThemeKey);
  }

  // ========== Utility ==========

  /// Clear all preferences
  Future<void> clearAll() async {
    _ensureInitialized();
    await _prefs!.clear();
  }
}

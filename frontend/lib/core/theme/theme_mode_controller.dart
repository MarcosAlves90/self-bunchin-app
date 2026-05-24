import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ThemePreferenceStore {
  Future<String?> readThemeMode();

  Future<void> writeThemeMode(ThemeMode mode);
}

class SecureThemePreferenceStore implements ThemePreferenceStore {
  SecureThemePreferenceStore({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _themeModeKey = 'theme_mode';
  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> readThemeMode() {
    return _secureStorage.read(key: _themeModeKey);
  }

  @override
  Future<void> writeThemeMode(ThemeMode mode) {
    return _secureStorage.write(key: _themeModeKey, value: _encode(mode));
  }

  static String _encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

class ThemeModeController extends ChangeNotifier {
  ThemeModeController({ThemePreferenceStore? store})
      : _store = store ?? SecureThemePreferenceStore();

  static final ThemeModeController instance = ThemeModeController();

  final ThemePreferenceStore _store;
  ThemeMode _mode = ThemeMode.dark;
  bool _isLoaded = false;

  ThemeMode get mode => _mode;

  bool get prefersLightTheme => _mode == ThemeMode.light;

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    _mode = _decode(await _store.readThemeMode());
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_mode == mode) {
      return;
    }

    _mode = mode;
    notifyListeners();
    _isLoaded = true;
    await _store.writeThemeMode(mode);
  }

  Future<void> setUseLightTheme(bool enabled) {
    return setThemeMode(enabled ? ThemeMode.light : ThemeMode.system);
  }

  static ThemeMode _decode(String? rawMode) {
    return switch (rawMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }
}

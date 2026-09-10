import 'package:flutter/material.dart';
import 'astronomy_engine.dart';

/// Application-wide user settings. Consumed by widgets through [Provider].
class SettingsProvider with ChangeNotifier {
  CalculationMode _mode = CalculationMode.modern;
  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;

  CalculationMode get mode => _mode;

  ThemeMode get themeMode => _themeMode;

  /// When enabled, themes are generated with maximum color contrast to
  /// improve legibility for low-vision users.
  bool get highContrast => _highContrast;

  void setMode(CalculationMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
  }

  AstronomyCalculator get calculator {
    switch (_mode) {
      case CalculationMode.heritage:
        return HeritageCalculator();
      case CalculationMode.modern:
        return ModernCalculator();
    }
  }

  String get modeLabel => switch (_mode) {
        CalculationMode.heritage => 'Heritage (1982)',
        CalculationMode.modern => 'Modern (J2000)',
      };
}
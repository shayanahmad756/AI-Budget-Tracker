import 'package:flutter/material.dart';

/// Provider for managing light and dark theme state.
class ThemeProvider extends ChangeNotifier {
  /// Flag to track if dark mode is enabled.
  bool _isDarkMode = false;

  /// Getter for dark mode status.
  bool get isDarkMode => _isDarkMode;

  /// Toggles between light and dark theme.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Set theme to a specific mode.
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

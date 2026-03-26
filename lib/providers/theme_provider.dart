import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load theme preference from database
  Future<void> loadFromDatabase() async {
    final isDark = DatabaseService.isDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Toggle and persist theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await DatabaseService.setDarkMode(_themeMode == ThemeMode.dark);
  }

  /// Set and persist theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await DatabaseService.setDarkMode(mode == ThemeMode.dark);
  }
}

class ThemeProviderInherited extends InheritedWidget {
  final ThemeProvider provider;

  const ThemeProviderInherited({
    super.key,
    required this.provider,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ThemeProviderInherited>();
    return widget!.provider;
  }

  @override
  bool updateShouldNotify(ThemeProviderInherited oldWidget) {
    return provider.themeMode != oldWidget.provider.themeMode;
  }
}

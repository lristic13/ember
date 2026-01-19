import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  Box? _box;

  @override
  ThemeMode build() {
    _initBox();
    return ThemeMode.dark; // Default to dark
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    final savedTheme = _box?.get(_themeKey) as String?;
    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      _box?.put(_themeKey, 'light');
    } else {
      state = ThemeMode.dark;
      _box?.put(_themeKey, 'dark');
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

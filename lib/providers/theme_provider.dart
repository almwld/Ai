import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = Hive.box('settings');
    final savedTheme = box.get('theme_mode', defaultValue: 'dark');
    state = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final box = Hive.box('settings');
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newTheme;
    await box.put('theme_mode', newTheme == ThemeMode.dark ? 'dark' : 'light');
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    final box = Hive.box('settings');
    box.put('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

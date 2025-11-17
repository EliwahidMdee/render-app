import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = SecureStorage();
  return ThemeNotifier(storage);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SecureStorage _storage;

  ThemeNotifier(this._storage) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final val = await _storage.read(AppConstants.darkModeKey);
    if (val == null) {
      state = ThemeMode.system;
    } else if (val == 'true') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    state = enabled ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(AppConstants.darkModeKey, enabled ? 'true' : 'false');
  }
}

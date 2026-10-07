import 'package:crypto_mart/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsCubit', () {
    test('initial state should default to ThemeMode.light when no preferences are saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.themeMode, ThemeMode.light);
    });

    test('should initialize with ThemeMode.dark when dark mode was previously saved', () async {
      SharedPreferences.setMockInitialValues({
        'CRYPTO_MART_THEME_MODE': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.themeMode, ThemeMode.dark);
    });

    test('should change theme mode to dark and persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = SettingsCubit(prefs);

      expect(cubit.state.themeMode, ThemeMode.light);

      await cubit.changeThemeMode(ThemeMode.dark);
      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(prefs.getString('CRYPTO_MART_THEME_MODE'), 'dark');

      await cubit.changeThemeMode(ThemeMode.light);
      expect(cubit.state.themeMode, ThemeMode.light);
      expect(prefs.getString('CRYPTO_MART_THEME_MODE'), 'light');
    });
  });
}

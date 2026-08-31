import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/currencies.dart';

class SettingsState extends Equatable {
  final CurrencyEntity selectedCurrency;
  final ThemeMode themeMode;

  const SettingsState({
    required this.selectedCurrency,
    required this.themeMode,
  });

  SettingsState copyWith({
    CurrencyEntity? selectedCurrency,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [selectedCurrency, themeMode];
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _currencyKey = 'CRYPTO_MART_SELECTED_CURRENCY';
  static const String _themeModeKey = 'CRYPTO_MART_THEME_MODE';

  SettingsCubit()
      : super(
          SettingsState(
            selectedCurrency: CurrencyEntity.defaultCurrency,
            themeMode: ThemeMode.dark,
          ),
        );

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyCode = prefs.getString(_currencyKey) ?? 'INR';
    final themeStr = prefs.getString(_themeModeKey) ?? 'dark';

    ThemeMode mode = ThemeMode.dark;
    if (themeStr == 'light') mode = ThemeMode.light;
    if (themeStr == 'system') mode = ThemeMode.system;

    emit(
      SettingsState(
        selectedCurrency: CurrencyEntity.fromCode(currencyCode),
        themeMode: mode,
      ),
    );
  }

  Future<void> changeCurrency(CurrencyEntity currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);

    emit(state.copyWith(selectedCurrency: currency));
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeStr = 'dark';
    if (themeMode == ThemeMode.light) themeStr = 'light';
    if (themeMode == ThemeMode.system) themeStr = 'system';

    await prefs.setString(_themeModeKey, themeStr);

    emit(state.copyWith(themeMode: themeMode));
  }
}

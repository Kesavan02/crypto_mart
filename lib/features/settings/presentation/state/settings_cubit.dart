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
  final SharedPreferences? _prefs;

  SettingsCubit([this._prefs])
      : super(
          SettingsState(
            selectedCurrency: _prefs != null
                ? CurrencyEntity.fromCode(_prefs.getString(_currencyKey) ?? 'INR')
                : CurrencyEntity.defaultCurrency,
            themeMode: _prefs != null
                ? _parseThemeMode(_prefs.getString(_themeModeKey) ?? 'light')
                : ThemeMode.light,
          ),
        );

  static ThemeMode _parseThemeMode(String themeStr) {
    if (themeStr == 'dark') return ThemeMode.dark;
    if (themeStr == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  Future<void> loadSettings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final currencyCode = prefs.getString(_currencyKey) ?? 'INR';
    final themeStr = prefs.getString(_themeModeKey) ?? 'light';

    emit(
      SettingsState(
        selectedCurrency: CurrencyEntity.fromCode(currencyCode),
        themeMode: _parseThemeMode(themeStr),
      ),
    );
  }

  Future<void> changeCurrency(CurrencyEntity currency) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);

    emit(state.copyWith(selectedCurrency: currency));
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    String themeStr = 'light';
    if (themeMode == ThemeMode.dark) themeStr = 'dark';
    if (themeMode == ThemeMode.system) themeStr = 'system';

    await prefs.setString(_themeModeKey, themeStr);

    emit(state.copyWith(themeMode: themeMode));
  }
}

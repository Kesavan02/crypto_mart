import 'package:equatable/equatable.dart';

class CurrencyEntity extends Equatable {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final double rateFromUsd;

  const CurrencyEntity({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.rateFromUsd,
  });

  @override
  List<Object?> get props => [code, symbol, name, flag, rateFromUsd];

  static const List<CurrencyEntity> supportedCurrencies = [
    CurrencyEntity(
      code: 'USD',
      symbol: '\$',
      name: 'United States Dollar',
      flag: '🇺🇸',
      rateFromUsd: 1.0,
    ),
    CurrencyEntity(
      code: 'EUR',
      symbol: '€',
      name: 'Euro (Eurozone)',
      flag: '🇪🇺',
      rateFromUsd: 0.95,
    ),
    CurrencyEntity(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      flag: '🇬🇧',
      rateFromUsd: 0.79,
    ),
    CurrencyEntity(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      flag: '🇮🇳',
      rateFromUsd: 84.50,
    ),
    CurrencyEntity(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      rateFromUsd: 154.20,
    ),
    CurrencyEntity(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      rateFromUsd: 1.54,
    ),
    CurrencyEntity(
      code: 'CAD',
      symbol: 'C\$',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      rateFromUsd: 1.41,
    ),
    CurrencyEntity(
      code: 'BRL',
      symbol: 'R\$',
      name: 'Brazilian Real',
      flag: '🇧🇷',
      rateFromUsd: 5.80,
    ),
    CurrencyEntity(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      flag: '🇨🇳',
      rateFromUsd: 7.24,
    ),
  ];

  static CurrencyEntity defaultCurrency = supportedCurrencies.first;

  static CurrencyEntity fromCode(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => defaultCurrency,
    );
  }
}

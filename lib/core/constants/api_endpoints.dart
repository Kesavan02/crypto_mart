abstract final class ApiEndpoints {
  // Live Render backend URL (Overridable via --dart-define=BACKEND_URL=...)
  static const String _defaultBaseUrl = 'https://crypto-mart.onrender.com/api';

  static const String nodeBackendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const String coins = '$nodeBackendBaseUrl/coins';
  static const String marketStats = '$nodeBackendBaseUrl/market/stats';

  static String coinDetail(String coinId) => '$nodeBackendBaseUrl/coins/$coinId';
  static String coinChart(String coinId, {int days = 7}) =>
      '$nodeBackendBaseUrl/coins/$coinId/chart?days=$days';
}

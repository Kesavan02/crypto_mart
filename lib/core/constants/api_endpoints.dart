abstract final class ApiEndpoints {
  // Configurable base URL: Defaults to local server, overridable via --dart-define or when deployed to Render
  static const String _defaultBaseUrl = 'http://localhost:3000/api';

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

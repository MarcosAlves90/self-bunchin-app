class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://self-bunchin-app.onrender.com/api/v1',
  );
}

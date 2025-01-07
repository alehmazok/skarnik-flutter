abstract class AppConfig {
  const AppConfig._();

  static const httpCacheDurationInHours = 'http_cache_duration_in_hours';

  static const wordsPerPage = 25;

  static const wordsSearchLimit = 15;

  static const skarnikSiteHostName = 'skarnik.by';

  static const apiHostName = String.fromEnvironment('API_HOSTNAME');

  static const devEmailAddress = String.fromEnvironment('DEV_EMAIL_ADDRESS');
}

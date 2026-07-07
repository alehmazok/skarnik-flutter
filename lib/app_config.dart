abstract class AppConfig {
  const AppConfig._();

  static const httpCacheDurationInHours = 'http_cache_duration_in_hours';

  static const wordsPerPage = 25;

  static const reviewRequestViewThreshold = 7;

  static const wordsSearchLimit = 15;

  // Fuzzy candidates are cut off at this limit before being scored, so it
  // must cover the largest first-letter bucket in the dataset or a typo
  // target can be excluded before it's ever considered.
  // Largest bucket (letter 'П') measured at ~61,939 of 316,237 total words
  // via the Supabase `main_word` table (2026-07-02); 65000 leaves headroom.
  static const fuzzySearchCandidateLimit = 65000;

  static const fuzzySearchMinQueryLength = 3;

  static const skarnikSiteHostName = 'skarnik.by';

  static const starnikSiteHostName = 'starnik.by';

  static const drukarnikSiteHostName = 'drukarnik.app';

  static const skarnikAppSiteHostName = 'skarnik.app';

  static const apiHostName = String.fromEnvironment('API_HOSTNAME');

  static const devEmailAddress = String.fromEnvironment('DEV_EMAIL_ADDRESS');

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_KEY');
}

import 'package:skarnik_flutter/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client configuration.
/// Uses environment variables:
/// - SUPABASE_URL: The Supabase project URL
/// - SUPABASE_KEY: The Supabase anon key
class SupabaseConfig {
  SupabaseConfig._();

  static SupabaseClient? _instance;

  /// Initialize Supabase client.
  /// Must be called before using the client.
  static Future<void> initialize() async {
    const url = AppConfig.supabaseUrl;
    const anonKey = AppConfig.supabaseAnonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not provided. '
        'Please set "SUPABASE_URL" and "SUPABASE_KEY" environment variables.',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _instance = Supabase.instance.client;
  }

  /// Get the Supabase client instance.
  /// Must call [initialize] before using this.
  static SupabaseClient get client {
    if (_instance == null) {
      throw Exception(
        'Supabase client not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
    return _instance!;
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendConfig {
  BackendConfig._();
  static bool get isConfigured =>
      (dotenv.env['SUPABASE_URL'] ?? '').isNotEmpty &&
      (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '').isNotEmpty;
  static SupabaseClient get client {
    if (!isConfigured) throw StateError('Configura SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY en .env');
    return Supabase.instance.client;
  }
}

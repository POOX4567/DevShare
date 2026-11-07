import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendConfig {
  BackendConfig._();

  static String get url => (dotenv.env['SUPABASE_URL'] ?? '').trim();

  static String get publishableKey =>
      (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim();

  static bool get isConfigured {
    if (url.isEmpty || publishableKey.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(url);

    return uri != null &&
        uri.hasScheme &&
        uri.hasAuthority &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        publishableKey.startsWith('sb_publishable_');
  }

  static SupabaseClient get client {
    if (!isConfigured) {
      throw StateError(
        'Configuración de Supabase incorrecta. '
        'Verifica SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY en .env',
      );
    }

    return Supabase.instance.client;
  }
}

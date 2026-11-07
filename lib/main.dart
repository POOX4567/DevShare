import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env', isOptional: false);

    final url = (dotenv.env['SUPABASE_URL'] ?? '').trim();
    final key = (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim();

    if (url.isEmpty || key.isEmpty) {
      throw Exception('Faltan SUPABASE_URL o SUPABASE_PUBLISHABLE_KEY en .env');
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw Exception(
        'SUPABASE_URL no es válida. Debe ser una URL HTTPS de Supabase.',
      );
    }

    if (!key.startsWith('sb_publishable_')) {
      throw Exception('SUPABASE_PUBLISHABLE_KEY no tiene el formato esperado.');
    }

    await Supabase.initialize(url: url, publishableKey: key);

    debugPrint('Supabase inicializado correctamente.');
  } catch (error, stackTrace) {
    debugPrint('ERROR AL INICIALIZAR SUPABASE: $error');
    debugPrint(stackTrace.toString());
  }

  runApp(const DevShareApp());
}

import 'package:flutter/material.dart';

import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';
import '../core/backend/backend_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';

class DevShareApp extends StatelessWidget {
  const DevShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.dark,
      surface: AppColors.panel,
    );
    return MaterialApp(
      title: 'DevShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.navy,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) {
    if (!BackendConfig.isConfigured) return const AuthPage();
    final client = BackendConfig.client;
    if (client.auth.currentSession != null) return const HomePage();
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) =>
          snapshot.data?.session == null ? const AuthPage() : const HomePage(),
    );
  }
}

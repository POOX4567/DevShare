import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/backend/backend_config.dart';

class AuthRepository {
  SupabaseClient get _db => BackendConfig.client;
  User? get currentUser => BackendConfig.isConfigured ? _db.auth.currentUser : null;
  Stream<AuthState> get changes => _db.auth.onAuthStateChange;
  Future<AuthResponse> signIn(String email,String password) => _db.auth.signInWithPassword(email:email.trim(),password:password);
  Future<AuthResponse> register({required String email,required String password,required String displayName}) => _db.auth.signUp(email:email.trim(),password:password,data:{'display_name':displayName.trim()});
  Future<void> signOut() => _db.auth.signOut();
  Future<void> resetPassword(String email) => _db.auth.resetPasswordForEmail(email.trim());
}

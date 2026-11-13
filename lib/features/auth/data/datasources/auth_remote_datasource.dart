import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/auth/data/models/auth_user_model.dart';

class AuthRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  Future<AuthUserModel> signUp({required String email, required String username, required String password}) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        // Verified [V 2026-11-12]: DB trigger public.handle_new_user() reads raw_user_meta_data->>'username'
        // (falls back to email prefix when empty), inserts into public.profiles (user_id, username).
        data: {'username': username},
      );
      final user = res.user;
      if (user == null) throw CoreFailure.unknown('Sign up returned no user');
      // session == null -> email confirmation required before first sign in
      return AuthUserModel(
        id: user.id,
        email: email,
        username: username,
        pendingEmailConfirmation: res.session == null,
      );
    } on AuthException catch (e) {
      throw CoreFailure.authError(e.message);
    }
  }

  Future<AuthUserModel> signIn({required String email, required String password}) async {
    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      final user = res.user;
      if (user == null) throw CoreFailure.authError('Sign in failed');
      return _profileFor(user, email);
    } on AuthException catch (e) {
      throw CoreFailure.authError(e.message);
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }

  Future<AuthUserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return _profileFor(user, user.email ?? '');
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<AuthUserModel> _profileFor(User user, String email) async {
    final profile = await _client
        .from('profiles')
        .select('user_id, username')
        .eq('user_id', user.id)
        .maybeSingle();
    if (profile == null) return AuthUserModel(id: user.id, email: email);
    return AuthUserModel.fromProfileAndEmail(profile, email);
  }
}

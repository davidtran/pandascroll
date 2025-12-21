import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = AsyncNotifierProvider<AuthController, bool>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final session = Supabase.instance.client.auth.currentSession;

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = AsyncValue.data(session != null);
    });

    return session != null;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '1050441360623-s81htcnhad6ulrnlpsrasofgavm69ih3.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        state = const AsyncValue.data(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUserProfile({
    required String level,
    required List<String> categories,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw 'User not logged in';

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'level': level,
        'categories': categories,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e, st) {
      // If we fail, just propagate for UI to show
      // In a real app we might retry or handle specific errors
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

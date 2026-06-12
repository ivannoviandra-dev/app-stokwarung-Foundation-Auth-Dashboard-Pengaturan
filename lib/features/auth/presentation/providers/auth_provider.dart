import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../pengaturan/presentation/providers/settings_provider.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? role;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.role,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? role,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final _supabase = Supabase.instance.client;

  @override
  AuthState build() {
    // Return initial state. Optionally check if there's a logged-in user:
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final role = session.user.userMetadata?['role'] as String?;
      return AuthState(isAuthenticated: true, role: role);
    }
    return AuthState();
  }

  Future<bool> login(String identifier, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    
    if (identifier.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false, 
        error: 'Email dan password tidak boleh kosong'
      );
      return false;
    }

    try {
      String loginEmail = identifier;
      if (role == 'kasir' && !identifier.contains('@')) {
        loginEmail = '$identifier@kasir.stokwarung.com';
      }

      final response = await _supabase.auth.signInWithPassword(
        email: loginEmail,
        password: password,
      );

      // Verify role if needed (assuming user metadata stores it)
      final userRole = response.user?.userMetadata?['role'] as String?;
      if (userRole != role && userRole != null) {
        await _supabase.auth.signOut();
        state = state.copyWith(
          isLoading: false,
          error: 'Akun ini terdaftar sebagai ${userRole.toUpperCase()}, bukan ${role.toUpperCase()}'
        );
        return false;
      }

      state = state.copyWith(isLoading: false, isAuthenticated: true, role: userRole ?? role);
      ref.invalidate(settingsProvider);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.message
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: 'Terjadi kesalahan tidak terduga'
      );
      return false;
    }
  }

  Future<bool> register({
    required String namaToko,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    if (namaToko.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Semua field harus diisi',
      );
      return false;
    }

    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nama_toko': namaToko,
          'role': 'owner',
        }
      );
      
      state = state.copyWith(isLoading: false);
      ref.invalidate(settingsProvider);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan tidak terduga',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

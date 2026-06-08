import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  AuthState build() {
    return AuthState();
  }

  Future<bool> login(String identifier, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (identifier.isNotEmpty && password.isNotEmpty) {
      state = state.copyWith(isLoading: false, isAuthenticated: true, role: role);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false, 
        error: 'Email dan password tidak boleh kosong'
      );
      return false;
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

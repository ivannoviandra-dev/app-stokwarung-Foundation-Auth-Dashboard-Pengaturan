import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsState {
  final String namaToko;
  final String alamat;
  final String nomorHp;
  final bool darkMode;
  final int stokMinimum;
  final Set<String> selectedExpiry;
  final String password;

  SettingsState({
    this.namaToko = '',
    this.alamat = '',
    this.nomorHp = '',
    this.darkMode = false,
    this.stokMinimum = 5,
    Set<String>? selectedExpiry,
    this.password = '',
  }) : selectedExpiry = selectedExpiry ?? {'H-7', 'H-3'};

  SettingsState copyWith({
    String? namaToko,
    String? alamat,
    String? nomorHp,
    bool? darkMode,
    int? stokMinimum,
    Set<String>? selectedExpiry,
    String? password,
  }) {
    return SettingsState(
      namaToko: namaToko ?? this.namaToko,
      alamat: alamat ?? this.alamat,
      nomorHp: nomorHp ?? this.nomorHp,
      darkMode: darkMode ?? this.darkMode,
      stokMinimum: stokMinimum ?? this.stokMinimum,
      selectedExpiry: selectedExpiry ?? this.selectedExpiry,
      password: password ?? this.password,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final namaToko = (metadata?['nama_toko'] as String?)?.trim() ?? '';
    final alamat = (metadata?['alamat'] as String?)?.trim() ?? '';
    final nomorHp = (metadata?['nomor_hp'] as String?)?.trim() ?? '';
    
    return SettingsState(
      namaToko: namaToko.isNotEmpty ? namaToko : 'Toko Saya',
      alamat: alamat,
      nomorHp: nomorHp,
    );
  }

  Future<void> updateNamaToko(String value) async {
    state = state.copyWith(namaToko: value);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'nama_toko': value}),
      );
      
      // Panggil RPC untuk memperbarui metadata kasir
      await Supabase.instance.client.rpc('update_kasir_nama_toko', params: {
        'p_nama_toko': value,
      });
    } catch (e) {
      print('Error saving nama toko: $e');
    }
  }

  Future<void> updateAlamat(String value) async {
    state = state.copyWith(alamat: value);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'alamat': value}),
      );
    } catch (e) {
      print('Error saving alamat: $e');
    }
  }

  Future<void> updateNomorHp(String value) async {
    state = state.copyWith(nomorHp: value);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'nomor_hp': value}),
      );
    } catch (e) {
      print('Error saving nomor hp: $e');
    }
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
  }

  void updateStokMinimum(int value) {
    state = state.copyWith(stokMinimum: value);
  }

  void toggleExpiry(String label) {
    final current = Set<String>.from(state.selectedExpiry);
    if (current.contains(label)) {
      current.remove(label);
    } else {
      current.add(label);
    }
    state = state.copyWith(selectedExpiry: current);
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) return false;
      
      // Verify old password by attempting to sign in
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      // If successful, update the password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

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
    
    return SettingsState(
      namaToko: namaToko.isNotEmpty ? namaToko : 'Toko Saya',
    );
  }

  Future<void> updateNamaToko(String value) async {
    state = state.copyWith(namaToko: value);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'nama_toko': value}),
      );
    } catch (e) {
      print('Error saving nama toko: $e');
    }
  }

  void updateAlamat(String value) {
    state = state.copyWith(alamat: value);
  }

  void updateNomorHp(String value) {
    state = state.copyWith(nomorHp: value);
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

  bool changePassword(String oldPassword, String newPassword) {
    if (oldPassword == state.password) {
      state = state.copyWith(password: newPassword);
      return true;
    }
    return false;
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

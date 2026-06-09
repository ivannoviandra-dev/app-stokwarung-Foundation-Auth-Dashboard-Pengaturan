import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KasirProfile {
  final String id;
  final String nama;
  final String username;
  final bool aktif;

  KasirProfile({
    required this.id,
    required this.nama,
    required this.username,
    required this.aktif,
  });

  factory KasirProfile.fromMap(Map<String, dynamic> map) {
    final username = map['username'] as String? ?? 'kasir';
    
    return KasirProfile(
      id: map['id'],
      nama: map['nama'] ?? 'Kasir',
      username: username,
      aktif: map['aktif'] ?? true,
    );
  }
}

class KasirState {
  final bool isLoading;
  final List<KasirProfile> kasirList;
  final String? error;

  KasirState({
    this.isLoading = false,
    this.kasirList = const [],
    this.error,
  });

  KasirState copyWith({
    bool? isLoading,
    List<KasirProfile>? kasirList,
    String? error,
  }) {
    return KasirState(
      isLoading: isLoading ?? this.isLoading,
      kasirList: kasirList ?? this.kasirList,
      error: error,
    );
  }
}

class KasirNotifier extends Notifier<KasirState> {
  final _supabase = Supabase.instance.client;

  @override
  KasirState build() {
    _fetchKasir();
    return KasirState(isLoading: true);
  }

  Future<void> _fetchKasir() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('kasir_profiles')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: true);

      final list = (response as List).map((e) => KasirProfile.fromMap(e)).toList();
      state = state.copyWith(isLoading: false, kasirList: list, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> tambahKasir({
    required String nama,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final owner = _supabase.auth.currentUser;
      if (owner == null) throw Exception('Owner tidak ditemukan');

      final registerEmail = '$username@kasir.stokwarung.com';

      // Gunakan REST API secara langsung untuk signUp agar tidak mengganggu sesi Owner
      final response = await http.post(
        Uri.parse('https://exjkwvlaovwbejudhcwn.supabase.co/auth/v1/signup'),
        headers: {
          'apikey': 'sb_publishable_CTYudOAovz4tzo786gOnKg_xszgieRC',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': registerEmail,
          'password': password,
          'data': {
            'role': 'kasir',
            'nama_kasir': nama,
            'owner_id': owner.id,
          }
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Gagal membuat user kasir. Username mungkin sudah digunakan.');
      }

      final responseData = jsonDecode(response.body);
      final newUserId = responseData['id'] ?? responseData['user']?['id'];
      if (newUserId == null) throw Exception('Gagal mendapatkan ID kasir');

      // Insert ke tabel kasir_profiles menggunakan client utama (owner)
      await _supabase.from('kasir_profiles').insert({
        'id': newUserId,
        'owner_id': owner.id,
        'nama': nama,
        'username': username,
        'aktif': true,
      });

      // Optimistic update agar langsung muncul di UI
      final newKasir = KasirProfile(
        id: newUserId,
        nama: nama,
        username: username,
        aktif: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        kasirList: [...state.kasirList, newKasir],
        error: null,
      );

      // Jalankan fetchKasir di background untuk sinkronisasi
      _fetchKasir();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleStatus(String id, bool currentStatus) async {
    try {
      await _supabase
          .from('kasir_profiles')
          .update({'aktif': !currentStatus})
          .eq('id', id);
      await _fetchKasir();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> hapusKasir(String id) async {
    try {
      await _supabase.from('kasir_profiles').delete().eq('id', id);
      await _fetchKasir();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final kasirProvider = NotifierProvider<KasirNotifier, KasirState>(() {
  return KasirNotifier();
});

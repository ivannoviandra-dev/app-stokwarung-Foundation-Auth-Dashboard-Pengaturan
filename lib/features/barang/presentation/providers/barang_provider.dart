import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/barang_model.dart';
import '../../../../core/services/notification_service.dart';
import '../../../pengaturan/presentation/providers/settings_provider.dart';

// ─── State class ───────────────────────────────────────────────────────────────
class BarangState {
  final List<Barang> semuaBarang;
  final String selectedKategori;
  final String searchQuery;
  final bool isLoading;

  BarangState({
    required this.semuaBarang,
    this.selectedKategori = 'Semua',
    this.searchQuery = '',
    this.isLoading = false,
  });

  /// Daftar barang yang sudah difilter berdasarkan kategori & pencarian
  List<Barang> get filteredBarang {
    return semuaBarang.where((b) {
      final matchKategori =
          selectedKategori == 'Semua' || b.kategori == selectedKategori;
      final matchSearch =
          searchQuery.isEmpty ||
          b.nama.toLowerCase().contains(searchQuery.toLowerCase());
      return matchKategori && matchSearch;
    }).toList();
  }

  /// Daftar kategori unik (ditambah "Semua" di awal)
  List<String> get daftarKategori {
    final kategoriSet = semuaBarang.map((b) => b.kategori).toSet().toList();
    kategoriSet.sort();
    return ['Semua', ...kategoriSet];
  }

  BarangState copyWith({
    List<Barang>? semuaBarang,
    String? selectedKategori,
    String? searchQuery,
    bool? isLoading,
  }) {
    return BarangState(
      semuaBarang: semuaBarang ?? this.semuaBarang,
      selectedKategori: selectedKategori ?? this.selectedKategori,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Notifier ──────────────────────────────────────────────────────────────────
class BarangNotifier extends Notifier<BarangState> {
  final _supabase = Supabase.instance.client;

  @override
  BarangState build() {
    // Jalankan fetch awal secara asynchronous tanpa memblokir build
    Future.microtask(() => fetchBarang());
    return BarangState(semuaBarang: _mockBarang);
  }

  Future<void> fetchBarang() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(semuaBarang: [], isLoading: false);
        return;
      }

      // Jika user adalah kasir, ambil barang milik owner-nya
      // Jika user adalah owner, ambil barang miliknya sendiri
      final userRole = user.userMetadata?['role'] as String?;
      final String targetUserId;
      if (userRole == 'kasir') {
        final ownerId = user.userMetadata?['owner_id'] as String?;
        if (ownerId == null) {
          state = state.copyWith(semuaBarang: [], isLoading: false);
          return;
        }
        targetUserId = ownerId;
      } else {
        targetUserId = user.id;
      }
      
      final response = await _supabase.from('barang').select().eq('user_id', targetUserId);
      final List<Barang> loadedBarang = (response as List).map((json) => Barang.fromJson(json)).toList();
      
      state = state.copyWith(semuaBarang: loadedBarang, isLoading: false);

      // Cek kedaluwarsa setelah load
      _checkExpiryNotifications(loadedBarang);
    } catch (e) {
      print('Error fetching barang: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void _checkExpiryNotifications(List<Barang> barangList) {
    final settings = ref.read(settingsProvider);
    final selectedExpiry = settings.selectedExpiry; 
    
    final expiryDays = <int>[];
    if (selectedExpiry.contains('H-7')) expiryDays.add(7);
    if (selectedExpiry.contains('H-3')) expiryDays.add(3);
    if (selectedExpiry.contains('H-1')) expiryDays.add(1);
    
    if (expiryDays.isEmpty) return;
    final maxExpiryDays = expiryDays.reduce((a, b) => a > b ? a : b);

    for (var barang in barangList) {
      if (barang.tanggalKedaluwarsa != null) {
        final daysToExpire = barang.tanggalKedaluwarsa!.difference(DateTime.now()).inDays;
        
        if (daysToExpire < 0) {
          NotificationService().showNotification(
            id: (barang.id.hashCode + 1), // Beda id dengan notif stok
            title: 'Sudah Kedaluwarsa!',
            body: '${barang.nama} telah kedaluwarsa ${daysToExpire.abs()} hari lalu.',
          );
        } else if (daysToExpire <= maxExpiryDays) {
          NotificationService().showNotification(
            id: (barang.id.hashCode + 1),
            title: 'Hampir Kedaluwarsa',
            body: '${barang.nama} kedaluwarsa dalam $daysToExpire hari.',
          );
        }
      }
    }
  }

  void setKategori(String kategori) {
    state = state.copyWith(selectedKategori: kategori);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> tambahBarang(Barang barang) async {
    try {
      state = state.copyWith(isLoading: true);
      final data = barang.toJson();
      
      // Hapus ID dari map agar database meng-generate UUID secara otomatis
      data.remove('id');
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
         data['user_id'] = userId; // Asumsi tabel barang punya kolom user_id
      }
      
      final response = await _supabase.from('barang').insert(data).select().single();
      final newBarang = Barang.fromJson(response);
      
      state = state.copyWith(
        semuaBarang: [...state.semuaBarang, newBarang],
        isLoading: false,
      );
    } catch (e) {
      print('Error adding barang: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> hapusBarang(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _supabase.from('barang').delete().eq('id', id);
      state = state.copyWith(
        semuaBarang: state.semuaBarang.where((b) => b.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      print('Error deleting barang: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateBarang(Barang updated) async {
    try {
      state = state.copyWith(isLoading: true);
      final data = updated.toJson();
      data.remove('id');
      
      final response = await _supabase.from('barang').update(data).eq('id', updated.id).select().single();
      final updatedFromDb = Barang.fromJson(response);

      state = state.copyWith(
        semuaBarang: state.semuaBarang
            .map((b) => b.id == updatedFromDb.id ? updatedFromDb : b)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      print('Error updating barang: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> kurangiStok(String id, int qty) async {
    try {
      final index = state.semuaBarang.indexWhere((b) => b.id == id);
      if (index == -1) return;
      
      final barang = state.semuaBarang[index];
      final sisaStok = barang.stok - qty;
      
      // Optimistic UI update
      final updatedLocal = barang.copyWith(stok: sisaStok);
      state = state.copyWith(
        semuaBarang: state.semuaBarang.map((b) => b.id == id ? updatedLocal : b).toList()
      );

      // Trigger Notifikasi Stok Menipis
      final settings = ref.read(settingsProvider);
      final batasStok = barang.stokMinimum > 0 ? barang.stokMinimum : settings.stokMinimum;
      
      if (sisaStok <= 0) {
        NotificationService().showNotification(
          id: id.hashCode,
          title: 'Stok Habis: ${barang.nama}',
          body: 'Segera restock, stok barang ini sudah habis (0).',
        );
      } else if (sisaStok <= batasStok && barang.stok > batasStok) {
        // Hanya notif jika stok baru saja menembus batas bawah
        NotificationService().showNotification(
          id: id.hashCode,
          title: 'Stok Menipis: ${barang.nama}',
          body: 'Sisa stok tinggal $sisaStok (Batas minimum: $batasStok).',
        );
      }

      // Update di database
      await _supabase.from('barang').update({'stok': sisaStok}).eq('id', id);
    } catch (e) {
      print('Error kurangi stok: $e');
      // Jika terjadi error, idealnya me-rollback data lokal di sini,
      // tapi untuk sementara minimal mencatat error.
    }
  }

  // ── Mock data awal ─────────────────────────────────────────────────────────
  static final List<Barang> _mockBarang = [];
}

// ─── Provider ──────────────────────────────────────────────────────────────────
final barangProvider =
    NotifierProvider<BarangNotifier, BarangState>(BarangNotifier.new);

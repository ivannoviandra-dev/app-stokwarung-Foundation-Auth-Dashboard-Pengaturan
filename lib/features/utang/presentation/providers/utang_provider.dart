import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/pelanggan_model.dart';
import '../../data/models/utang_model.dart';

class UtangState {
  final List<Pelanggan> pelangganList;
  final String searchQuery;
  final bool isLoading;

  UtangState({
    required this.pelangganList,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<Pelanggan> get filteredPelanggan {
    if (searchQuery.isEmpty) return pelangganList;
    return pelangganList.where((p) {
      return p.nama.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  int get totalPiutangKeseluruhan {
    return pelangganList.fold(0, (sum, p) => sum + p.totalUtang);
  }

  int get pelangganAktifCount {
    return pelangganList.where((p) => p.totalUtang > 0).length;
  }

  UtangState copyWith({
    List<Pelanggan>? pelangganList,
    String? searchQuery,
    bool? isLoading,
  }) {
    return UtangState(
      pelangganList: pelangganList ?? this.pelangganList,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UtangNotifier extends Notifier<UtangState> {
  final _supabase = Supabase.instance.client;

  @override
  UtangState build() {
    Future.microtask(() => fetchPelanggan());
    return UtangState(pelangganList: []);
  }

  Future<void> fetchPelanggan() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(pelangganList: [], isLoading: false);
        return;
      }

      final userRole = user.userMetadata?['role'] as String?;
      final String targetUserId;
      if (userRole == 'kasir') {
        final ownerId = user.userMetadata?['owner_id'] as String?;
        if (ownerId == null) {
          state = state.copyWith(pelangganList: [], isLoading: false);
          return;
        }
        targetUserId = ownerId;
      } else {
        targetUserId = user.id;
      }

      final response = await _supabase.from('pelanggan').select().eq('user_id', targetUserId);
      List<Pelanggan> loaded = (response as List).map((json) => Pelanggan.fromJson(json)).toList();

      if (loaded.isNotEmpty) {
        // Fetch all utang for these pelanggans
        final pelangganIds = loaded.map((p) => p.id).toList();
        
        // Handle different supabase_flutter versions for 'in' operator
        // using a manual loop to avoid method name conflicts (inFilter vs in_) 
        // since data might not be huge, or we can use the inner join approach:
        
        final utangResponse = await _supabase
            .from('utang')
            .select('*, pelanggan!inner(user_id)')
            .eq('pelanggan.user_id', targetUserId);
            
        final utangList = (utangResponse as List).map((json) => Utang.fromJson(json)).toList();

        loaded = loaded.map((p) {
          int total = 0;
          final pUtangs = utangList.where((u) => u.pelangganId == p.id);
          for (var u in pUtangs) {
            if (u.jenis == 'utang') {
              total += u.jumlah;
            } else if (u.jenis == 'bayar') {
              total -= u.jumlah;
            }
          }
          return p.copyWith(totalUtang: total);
        }).toList();
      }

      state = state.copyWith(pelangganList: loaded, isLoading: false);
    } catch (e) {
      print('Error fetching pelanggan: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> tambahPelanggan(String nama, int nominalAwal, {String? noHp}) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final userRole = user.userMetadata?['role'] as String?;
      final String targetUserId;
      if (userRole == 'kasir') {
        final ownerId = user.userMetadata?['owner_id'] as String?;
        if (ownerId == null) return;
        targetUserId = ownerId;
      } else {
        targetUserId = user.id;
      }

      // 1. Insert Pelanggan
      final dataPelanggan = {
        'user_id': targetUserId,
        'nama': nama,
        if (noHp != null && noHp.isNotEmpty) 'no_hp': noHp,
      };

      final responsePelanggan = await _supabase
          .from('pelanggan')
          .insert(dataPelanggan)
          .select()
          .single();
          
      Pelanggan newPelanggan = Pelanggan.fromJson(responsePelanggan);

      // 2. Insert Utang Awal (jika ada)
      if (nominalAwal > 0) {
        final dataUtang = {
          'pelanggan_id': newPelanggan.id,
          'jumlah': nominalAwal,
          'jenis': 'utang',
          'keterangan': 'Utang awal',
        };
        await _supabase.from('utang').insert(dataUtang);
        newPelanggan = newPelanggan.copyWith(totalUtang: nominalAwal);
      }

      state = state.copyWith(
        pelangganList: [...state.pelangganList, newPelanggan],
        isLoading: false,
      );
    } catch (e) {
      print('Error tambah pelanggan: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Method to add utang or bayar
  Future<void> tambahCatatanUtang({
    required String pelangganId,
    required int jumlah,
    required String jenis, // 'utang' atau 'bayar'
    String? keterangan,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final dataUtang = {
        'pelanggan_id': pelangganId,
        'jumlah': jumlah,
        'jenis': jenis,
        if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
      };

      await _supabase.from('utang').insert(dataUtang);

      // Update local state instead of re-fetching everything
      final updatedList = state.pelangganList.map((p) {
        if (p.id == pelangganId) {
          int newTotal = p.totalUtang;
          if (jenis == 'utang') {
            newTotal += jumlah;
          } else if (jenis == 'bayar') {
            newTotal -= jumlah;
          }
          return p.copyWith(totalUtang: newTotal);
        }
        return p;
      }).toList();

      state = state.copyWith(pelangganList: updatedList, isLoading: false);
    } catch (e) {
      print('Error tambah catatan utang: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Helper to fetch utang history for a specific customer
  Future<List<Utang>> fetchRiwayatUtang(String pelangganId) async {
    try {
      final response = await _supabase
          .from('utang')
          .select()
          .eq('pelanggan_id', pelangganId)
          .order('tanggal', ascending: false);
          
      return (response as List).map((json) => Utang.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching riwayat utang: $e');
      return [];
    }
  }

  // Hapus pelanggan
  Future<void> hapusPelanggan(String pelangganId) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Delete utang records first to prevent foreign key errors if cascade delete is not set
      await _supabase.from('utang').delete().eq('pelanggan_id', pelangganId);
      
      // Delete pelanggan
      await _supabase.from('pelanggan').delete().eq('id', pelangganId);

      final updatedList = state.pelangganList.where((p) => p.id != pelangganId).toList();
      state = state.copyWith(pelangganList: updatedList, isLoading: false);
    } catch (e) {
      print('Error hapus pelanggan: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Fetch semua riwayat utang global
  Future<List<Map<String, dynamic>>> fetchSemuaRiwayatUtang() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final userRole = user.userMetadata?['role'] as String?;
      final String targetUserId;
      if (userRole == 'kasir') {
        final ownerId = user.userMetadata?['owner_id'] as String?;
        if (ownerId == null) return [];
        targetUserId = ownerId;
      } else {
        targetUserId = user.id;
      }

      final response = await _supabase
          .from('utang')
          .select('*, pelanggan!inner(nama, user_id)')
          .eq('pelanggan.user_id', targetUserId)
          .order('tanggal', ascending: false);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching semua riwayat utang: $e');
      return [];
    }
  }
}

final utangProvider = NotifierProvider<UtangNotifier, UtangState>(UtangNotifier.new);

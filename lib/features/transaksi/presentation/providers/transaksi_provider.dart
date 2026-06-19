import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/transaksi_model.dart';

class TransaksiState {
  final List<Transaksi> transaksiList;
  final bool isLoading;

  TransaksiState({
    required this.transaksiList,
    this.isLoading = false,
  });

  // Transaksi hari ini
  List<Transaksi> get transaksiHariIni {
    final now = DateTime.now();
    return transaksiList.where((t) {
      final d = t.createdAt.toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  int get totalHariIni => transaksiHariIni.fold(0, (s, t) => s + t.total);
  int get jumlahTransaksiHariIni => transaksiHariIni.length;

  int get labaHariIni {
    int laba = 0;
    for (var t in transaksiHariIni) {
      for (var item in t.items) {
        laba += (item.harga - item.hargaModal) * item.qty;
      }
    }
    return laba;
  }

  TransaksiState copyWith({
    List<Transaksi>? transaksiList,
    bool? isLoading,
  }) {
    return TransaksiState(
      transaksiList: transaksiList ?? this.transaksiList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TransaksiNotifier extends Notifier<TransaksiState> {
  final _supabase = Supabase.instance.client;

  @override
  TransaksiState build() {
    Future.microtask(() => fetchTransaksi());
    return TransaksiState(transaksiList: []);
  }

  String get _targetUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) return '';
    final userRole = user.userMetadata?['role'] as String?;
    if (userRole == 'kasir') {
      return user.userMetadata?['owner_id'] as String? ?? '';
    }
    return user.id;
  }

  Future<void> fetchTransaksi() async {
    try {
      state = state.copyWith(isLoading: true);
      final targetUserId = _targetUserId;
      if (targetUserId.isEmpty) {
        state = state.copyWith(transaksiList: [], isLoading: false);
        return;
      }

      final response = await _supabase
          .from('transaksi')
          .select('*, transaksi_item(*)')
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((json) => Transaksi.fromJson(json))
          .toList();

      state = state.copyWith(transaksiList: list, isLoading: false);
    } catch (e) {
      print('Error fetching transaksi: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Transaksi?> simpanTransaksi({
    required List<Map<String, dynamic>> keranjang,
    required int total,
    required String metode,
    String? namaPelanggan,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final targetUserId = _targetUserId;
      if (targetUserId.isEmpty) return null;

      // 1. Insert transaksi header
      final dataTransaksi = {
        'user_id': targetUserId,
        'total': total,
        'metode': metode,
        if (namaPelanggan != null) 'nama_pelanggan': namaPelanggan,
      };

      final responseTransaksi = await _supabase
          .from('transaksi')
          .insert(dataTransaksi)
          .select()
          .single();

      final transaksiId = responseTransaksi['id'].toString();

      // 2. Insert transaksi items
      final items = keranjang.map((item) {
        final harga = item['harga'] as int;
        final hargaModal = item['harga_modal'] as int? ?? 0;
        final qty = item['qty'] as int;
        return {
          'transaksi_id': transaksiId,
          'barang_id': item['id']?.toString(),
          'nama_barang': item['nama'] as String,
          'harga': harga,
          'harga_modal': hargaModal,
          'qty': qty,
          'subtotal': harga * qty,
        };
      }).toList();

      await _supabase.from('transaksi_item').insert(items);

      // 3. Refresh the list
      await fetchTransaksi();

      return state.transaksiList.firstWhere((t) => t.id == transaksiId);
    } catch (e) {
      print('Error simpan transaksi: $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final transaksiProvider =
    NotifierProvider<TransaksiNotifier, TransaksiState>(TransaksiNotifier.new);

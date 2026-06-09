import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/barang_model.dart';

// ─── State class ───────────────────────────────────────────────────────────────
class BarangState {
  final List<Barang> semuaBarang;
  final String selectedKategori;
  final String searchQuery;

  BarangState({
    required this.semuaBarang,
    this.selectedKategori = 'Semua',
    this.searchQuery = '',
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
  }) {
    return BarangState(
      semuaBarang: semuaBarang ?? this.semuaBarang,
      selectedKategori: selectedKategori ?? this.selectedKategori,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ─── Notifier ──────────────────────────────────────────────────────────────────
class BarangNotifier extends Notifier<BarangState> {
  @override
  BarangState build() {
    return BarangState(semuaBarang: _mockBarang);
  }

  void setKategori(String kategori) {
    state = state.copyWith(selectedKategori: kategori);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void tambahBarang(Barang barang) {
    state = state.copyWith(semuaBarang: [...state.semuaBarang, barang]);
  }

  void hapusBarang(String id) {
    state = state.copyWith(
      semuaBarang: state.semuaBarang.where((b) => b.id != id).toList(),
    );
  }

  void updateBarang(Barang updated) {
    state = state.copyWith(
      semuaBarang: state.semuaBarang
          .map((b) => b.id == updated.id ? updated : b)
          .toList(),
    );
  }

  // ── Mock data awal ─────────────────────────────────────────────────────────
  static final List<Barang> _mockBarang = [];
}

// ─── Provider ──────────────────────────────────────────────────────────────────
final barangProvider =
    NotifierProvider<BarangNotifier, BarangState>(BarangNotifier.new);

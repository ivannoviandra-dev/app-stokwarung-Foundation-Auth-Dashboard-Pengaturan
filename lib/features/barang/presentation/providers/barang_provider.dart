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
  static final List<Barang> _mockBarang = [
    Barang(id: '1', nama: 'Minyak Goreng 1L', kategori: 'Sembako', harga: 14500, stok: 15),
    Barang(id: '2', nama: 'Beras 5kg', kategori: 'Sembako', harga: 65000, stok: 5),
    Barang(id: '3', nama: 'Susu Kental Manis', kategori: 'Minuman', harga: 12000, stok: 20),
    Barang(id: '4', nama: 'Gula Pasir 1kg', kategori: 'Sembako', harga: 15000, stok: 2, stokMinimum: 5),
    Barang(id: '5', nama: 'Indomie Goreng', kategori: 'Makanan', harga: 3500, stok: 48),
    Barang(id: '6', nama: 'Teh Botol 450ml', kategori: 'Minuman', harga: 5000, stok: 30),
    Barang(id: '7', nama: 'Sabun Cuci Piring', kategori: 'Kebutuhan Rumah', harga: 8000, stok: 12),
    Barang(id: '8', nama: 'Kecap Manis 250ml', kategori: 'Sembako', harga: 10000, stok: 8),
    Barang(id: '9', nama: 'Air Mineral 600ml', kategori: 'Minuman', harga: 3000, stok: 50),
    Barang(id: '10', nama: 'Detergen Bubuk 1kg', kategori: 'Kebutuhan Rumah', harga: 18000, stok: 6),
    Barang(id: '11', nama: 'Pop Mie Ayam', kategori: 'Makanan', harga: 5500, stok: 25),
    Barang(id: '12', nama: 'Telur Ayam 1kg', kategori: 'Sembako', harga: 28000, stok: 10),
  ];
}

// ─── Provider ──────────────────────────────────────────────────────────────────
final barangProvider =
    NotifierProvider<BarangNotifier, BarangState>(BarangNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../barang/presentation/providers/barang_provider.dart';

class DashboardData {
  final int profitHariIni;
  final int totalPiutang;
  final int totalBarang;
  final int totalTransaksi;
  final List<AttentionItem> perluPerhatian;
  final int totalNotifikasi;

  DashboardData({
    required this.profitHariIni,
    required this.totalPiutang,
    required this.totalBarang,
    required this.totalTransaksi,
    required this.perluPerhatian,
    required this.totalNotifikasi,
  });
}

class AttentionItem {
  final String title;
  final String subtitle;
  final String badgeText;
  final String type; // 'kritis', 'rendah', 'kadaluarsa'
  final dynamic originalData; // Untuk referensi data asli

  AttentionItem({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.type,
    this.originalData,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final barangState = ref.watch(barangProvider);
  final semuaBarang = barangState.semuaBarang;

  List<AttentionItem> perhatian = [];

  for (var barang in semuaBarang) {
    // Cek Stok
    if (barang.stok <= 0) {
      perhatian.add(AttentionItem(
        title: 'Stok Habis: ${barang.nama}',
        subtitle: 'Segera restock, stok saat ini: 0',
        badgeText: 'KRITIS',
        type: 'stok_kritis',
        originalData: barang,
      ));
    } else if (barang.stok <= barang.stokMinimum) {
      perhatian.add(AttentionItem(
        title: 'Stok Rendah: ${barang.nama}',
        subtitle: 'Sisa stok: ${barang.stok} (Minimum: ${barang.stokMinimum})',
        badgeText: 'RENDAH',
        type: 'stok_rendah',
        originalData: barang,
      ));
    }

    // Cek Kedaluwarsa
    if (barang.tanggalKedaluwarsa != null) {
      final daysToExpire = barang.tanggalKedaluwarsa!.difference(DateTime.now()).inDays;
      if (daysToExpire <= 7 && daysToExpire >= 0) {
         perhatian.add(AttentionItem(
          title: 'Hampir Kedaluwarsa: ${barang.nama}',
          subtitle: 'Kedaluwarsa dalam $daysToExpire hari',
          badgeText: 'KADALUARSA',
          type: 'kadaluarsa_hampir',
          originalData: barang,
        ));
      } else if (daysToExpire < 0) {
         perhatian.add(AttentionItem(
          title: 'Sudah Kedaluwarsa: ${barang.nama}',
          subtitle: 'Telah kedaluwarsa ${daysToExpire.abs()} hari yang lalu',
          badgeText: 'KRITIS',
          type: 'kadaluarsa_kritis',
          originalData: barang,
        ));
      }
    }
  }

  // Mock data untuk profit dan transaksi
  return DashboardData(
    profitHariIni: 0,
    totalPiutang: 0,
    totalBarang: semuaBarang.length,
    totalTransaksi: 0,
    perluPerhatian: perhatian,
    totalNotifikasi: perhatian.length,
  );
});

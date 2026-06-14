import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../barang/presentation/providers/barang_provider.dart';
import '../../../transaksi/presentation/providers/transaksi_provider.dart';
import '../../../pengaturan/presentation/providers/settings_provider.dart';
import '../../../utang/presentation/providers/utang_provider.dart';

class DashboardData {
  final int profitHariIni;
  final int totalPenjualanHariIni;
  final int totalPiutang;
  final int totalBarang;
  final int totalTransaksi;
  final List<AttentionItem> perluPerhatian;
  final int totalNotifikasi;

  DashboardData({
    required this.profitHariIni,
    required this.totalPenjualanHariIni,
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
  final String type; // 'stok_kritis', 'stok_rendah', 'kadaluarsa_hampir', 'kadaluarsa_kritis'
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
  final transaksiState = ref.watch(transaksiProvider);
  final utangState = ref.watch(utangProvider);
  final settings = ref.watch(settingsProvider);

  // Ambil pengaturan dari Settings
  final stokMinimumDefault = settings.stokMinimum;
  final selectedExpiry = settings.selectedExpiry; // {'H-7', 'H-3', 'H-1'}

  // Hitung hari-hari peringatan kedaluwarsa dari settings
  final expiryDays = <int>[];
  if (selectedExpiry.contains('H-7')) expiryDays.add(7);
  if (selectedExpiry.contains('H-3')) expiryDays.add(3);
  if (selectedExpiry.contains('H-1')) expiryDays.add(1);
  final maxExpiryDays = expiryDays.isNotEmpty ? expiryDays.reduce((a, b) => a > b ? a : b) : 7;

  List<AttentionItem> perhatian = [];

  for (var barang in semuaBarang) {
    // Gunakan stok minimum per barang, atau default dari settings
    final batasStok = barang.stokMinimum > 0 ? barang.stokMinimum : stokMinimumDefault;

    // Cek Stok
    if (barang.stok <= 0) {
      perhatian.add(AttentionItem(
        title: 'Stok Habis: ${barang.nama}',
        subtitle: 'Segera restock, stok saat ini: 0',
        badgeText: 'KRITIS',
        type: 'stok_kritis',
        originalData: barang,
      ));
    } else if (barang.stok <= batasStok) {
      perhatian.add(AttentionItem(
        title: 'Stok Rendah: ${barang.nama}',
        subtitle: 'Sisa stok: ${barang.stok} (Minimum: $batasStok)',
        badgeText: 'RENDAH',
        type: 'stok_rendah',
        originalData: barang,
      ));
    }

    // Cek Kedaluwarsa (hanya jika ada pengaturan expiry yang dipilih)
    if (barang.tanggalKedaluwarsa != null && expiryDays.isNotEmpty) {
      final daysToExpire = barang.tanggalKedaluwarsa!.difference(DateTime.now()).inDays;
      if (daysToExpire < 0) {
        perhatian.add(AttentionItem(
          title: 'Sudah Kedaluwarsa: ${barang.nama}',
          subtitle: 'Telah kedaluwarsa ${daysToExpire.abs()} hari yang lalu',
          badgeText: 'KRITIS',
          type: 'kadaluarsa_kritis',
          originalData: barang,
        ));
      } else if (daysToExpire <= maxExpiryDays) {
        // Tentukan label berdasarkan hari terdekat yang cocok
        String label = 'H-$daysToExpire';
        perhatian.add(AttentionItem(
          title: 'Hampir Kedaluwarsa: ${barang.nama}',
          subtitle: 'Kedaluwarsa dalam $daysToExpire hari',
          badgeText: label,
          type: 'kadaluarsa_hampir',
          originalData: barang,
        ));
      }
    }
  }

  // Data dashboard dari provider
  return DashboardData(
    profitHariIni: transaksiState.labaHariIni,
    totalPenjualanHariIni: transaksiState.totalHariIni,
    totalPiutang: utangState.totalPiutangKeseluruhan,
    totalBarang: semuaBarang.length,
    totalTransaksi: transaksiState.jumlahTransaksiHariIni,
    perluPerhatian: perhatian,
    totalNotifikasi: perhatian.length,
  );
});

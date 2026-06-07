import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardData {
  final int profitHariIni;
  final int totalPiutang;
  final int totalBarang;
  final int totalTransaksi;
  final List<AttentionItem> perluPerhatian;

  DashboardData({
    required this.profitHariIni,
    required this.totalPiutang,
    required this.totalBarang,
    required this.totalTransaksi,
    required this.perluPerhatian,
  });
}

class AttentionItem {
  final String title;
  final String subtitle;
  final String badgeText;
  final String type; // 'kritis' or 'kadaluarsa'

  AttentionItem({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.type,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  // Mock data
  return DashboardData(
    profitHariIni: 560000,
    totalPiutang: 1200000,
    totalBarang: 234,
    totalTransaksi: 47,
    perluPerhatian: [
      AttentionItem(
        title: 'Gula Pasir 1kg',
        subtitle: 'Sisa 2 unit',
        badgeText: 'STOK KRITIS',
        type: 'kritis',
      ),
      AttentionItem(
        title: 'Mie Instan Solo',
        subtitle: 'Exp: 3 hari lagi',
        badgeText: 'KADALUARSA',
        type: 'kadaluarsa',
      ),
      AttentionItem(
        title: 'Teh Botol 450ml',
        subtitle: 'Exp: 5 hari lagi',
        badgeText: 'KADALUARSA',
        type: 'kadaluarsa',
      ),
    ],
  );
});

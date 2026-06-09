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
    profitHariIni: 0,
    totalPiutang: 0,
    totalBarang: 0,
    totalTransaksi: 0,
    perluPerhatian: [],
  );
});

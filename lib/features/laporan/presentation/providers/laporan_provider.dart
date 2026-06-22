import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/transaksi/presentation/providers/transaksi_provider.dart';

class LaporanData {
  final int labaBersihBulanIni;
  final int labaPersentase;
  final int totalPenjualan;
  final int totalModal;
  final List<DailySales> tren7Hari;
  final List<ItemStat> barangTerlaris;
  final List<ItemStat> marginTertinggi;

  LaporanData({
    required this.labaBersihBulanIni,
    required this.labaPersentase,
    required this.totalPenjualan,
    required this.totalModal,
    required this.tren7Hari,
    required this.barangTerlaris,
    required this.marginTertinggi,
  });
}

class DailySales {
  final String hari;
  final double ratio; // 0.0 to 1.0 for the graph
  final int total;

  DailySales({required this.hari, required this.ratio, required this.total});
}

class ItemStat {
  final String nama;
  final String subtitle;
  final String nilai;
  final bool isPositive;

  ItemStat({
    required this.nama,
    required this.subtitle,
    required this.nilai,
    this.isPositive = true,
  });
}

final laporanProvider = Provider<LaporanData>((ref) {
  final transaksiState = ref.watch(transaksiProvider);
  final allTransactions = transaksiState.transaksiList;

  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  int totalPenjualan = 0;
  int totalModal = 0;

  // Filter transactions for current month
  final monthlyTransactions = allTransactions.where((t) {
    final d = t.createdAt.toLocal();
    return d.month == currentMonth && d.year == currentYear;
  }).toList();

  Map<String, int> itemQtyMap = {};
  Map<String, int> itemMarginMap = {};

  for (var t in monthlyTransactions) {
    totalPenjualan += t.total;
    for (var item in t.items) {
      totalModal += (item.hargaModal * item.qty);

      // Track qty for best sellers
      itemQtyMap[item.namaBarang] = (itemQtyMap[item.namaBarang] ?? 0) + item.qty;

      // Track margin
      final margin = item.harga - item.hargaModal;
      if (margin > 0) {
        if (!itemMarginMap.containsKey(item.namaBarang) || margin > itemMarginMap[item.namaBarang]!) {
          itemMarginMap[item.namaBarang] = margin;
        }
      }
    }
  }

  final labaBersih = totalPenjualan - totalModal;

  // Tren 7 Hari Terakhir
  List<DailySales> tren = [];
  int maxDailySales = 0;
  List<int> dailyTotals = [];
  List<String> dailyNames = [];

  for (int i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final dayStr = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][day.weekday - 1];
    dailyNames.add(dayStr);

    final dayTotal = allTransactions.where((t) {
      final d = t.createdAt.toLocal();
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).fold(0, (sum, t) => sum + t.total);

    dailyTotals.add(dayTotal);
    if (dayTotal > maxDailySales) {
      maxDailySales = dayTotal;
    }
  }

  for (int i = 0; i < 7; i++) {
    tren.add(DailySales(
      hari: dailyNames[i],
      ratio: maxDailySales == 0 ? 0.0 : dailyTotals[i] / maxDailySales,
      total: dailyTotals[i],
    ));
  }

  // Barang Terlaris (Top 3)
  final sortedQty = itemQtyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  List<ItemStat> terlaris = sortedQty.take(3).map((e) {
    return ItemStat(
      nama: e.key,
      subtitle: 'Terjual bulan ini',
      nilai: '${e.value} pcs',
    );
  }).toList();

  // Margin Tertinggi (Top 3)
  final sortedMargin = itemMarginMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  List<ItemStat> marginTinggi = sortedMargin.take(3).map((e) {
    return ItemStat(
      nama: e.key,
      subtitle: 'Keuntungan per barang',
      nilai: _formatCurrency(e.value),
    );
  }).toList();

  return LaporanData(
    labaBersihBulanIni: labaBersih,
    labaPersentase: 0, // Placeholder
    totalPenjualan: totalPenjualan,
    totalModal: totalModal,
    tren7Hari: tren,
    barangTerlaris: terlaris,
    marginTertinggi: marginTinggi,
  );
});

String _formatCurrency(int amount) {
  final str = amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return 'Rp$str';
}

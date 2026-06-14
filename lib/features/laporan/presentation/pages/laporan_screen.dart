import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/laporan_provider.dart';
import '../services/pdf_service.dart';

class LaporanScreen extends ConsumerWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final data = ref.watch(laporanProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,

        title: Text(
          'Laporan',
          style: TextStyle(color: c.primary, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profit Summary Card
            Container(
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: -32, top: -32,
                      child: Container(
                        width: 128, height: 128,
                        decoration: BoxDecoration(
                          color: c.primaryContainer.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LABA BERSIH BULAN INI',
                            style: TextStyle(color: c.primaryFixed, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_formatCurrency(data.labaBersihBulanIni), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: c.onPrimaryFixedVariant, borderRadius: BorderRadius.circular(16)),
                                child: Row(children: [
                                  Icon(data.labaBersihBulanIni >= 0 ? Icons.arrow_upward : Icons.arrow_downward, color: c.primaryFixed, size: 14),
                                  const SizedBox(width: 2),
                                  Text('${data.labaPersentase}%', style: TextStyle(color: c.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold)),
                                ]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: c.onPrimaryFixedVariant),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Penjualan', style: TextStyle(color: c.primaryFixed.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(_formatCurrency(data.totalPenjualan), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Modal', style: TextStyle(color: c.primaryFixed.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(_formatCurrency(data.totalModal), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sales Trend Graph
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.outlineVariant),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tren 7 Hari Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.onSurface)),
                      Icon(Icons.insights, color: c.outline),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: data.tren7Hari.map((day) {
                        return _buildBar(context, day.hari, day.ratio, day.ratio == 1.0 && day.total > 0);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(children: [
              Icon(Icons.stars, color: c.profitGold),
              const SizedBox(width: 8),
              Text('Barang Terlaris', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.onSurface)),
            ]),
            const SizedBox(height: 12),
            data.barangTerlaris.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('Belum ada data barang terlaris', style: TextStyle(color: c.onSurfaceVariant))))
                : Column(
                    children: data.barangTerlaris.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildItemRankRow(context, item.nama, item.subtitle, item.nilai, item.isPositive),
                    )).toList(),
                  ),
            const SizedBox(height: 24),

            // High Margin
            Row(children: [
              Icon(Icons.trending_up, color: c.primary),
              const SizedBox(width: 8),
              Text('Margin Tertinggi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.onSurface)),
            ]),
            const SizedBox(height: 12),
            data.marginTertinggi.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('Belum ada data margin', style: TextStyle(color: c.onSurfaceVariant))))
                : Column(
                    children: data.marginTertinggi.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildMarginRow(context, item.nama, item.subtitle, item.nilai),
                    )).toList(),
                  ),
            const SizedBox(height: 32),

            // Download Button
            ElevatedButton(
              onPressed: () async {
                final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
                final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';
                
                await PdfService.generateAndPrintLaporan(
                  namaWarung: namaToko,
                  data: data,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.picture_as_pdf), SizedBox(width: 8),
                Text('Unduh Laporan PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  Widget _buildBar(BuildContext context, String label, double heightRatio, bool isHighest) {
    final c = AppColors.of(context);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: FractionallySizedBox(
              heightFactor: heightRatio,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isHighest ? c.primaryContainer : c.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isHighest ? FontWeight.bold : FontWeight.w600, color: isHighest ? c.primary : c.outline)),
        ],
      ),
    );
  }

  Widget _buildItemRankRow(BuildContext context, String title, String subtitle, String trailing, bool isPositive) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.inventory_2, color: c.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.onSurface)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: c.onSurfaceVariant)),
              ],
            ),
          ),
          Text(trailing, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPositive ? c.statusSuccess : c.outline)),
        ],
      ),
    );
  }

  Widget _buildMarginRow(BuildContext context, String title, String subtitle, String price) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.local_cafe, color: c.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.onSurface)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: c.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.primary)),
              Text('/ pcs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

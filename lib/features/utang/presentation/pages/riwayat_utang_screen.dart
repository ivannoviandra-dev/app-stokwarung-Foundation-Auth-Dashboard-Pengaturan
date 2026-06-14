import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/utang_provider.dart';

class RiwayatUtangScreen extends ConsumerStatefulWidget {
  const RiwayatUtangScreen({super.key});

  @override
  ConsumerState<RiwayatUtangScreen> createState() => _RiwayatUtangScreenState();
}

class _RiwayatUtangScreenState extends ConsumerState<RiwayatUtangScreen> {
  late Future<List<Map<String, dynamic>>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = ref.read(utangProvider.notifier).fetchSemuaRiwayatUtang();
  }

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Semua Riwayat Utang',
          style: TextStyle(
            color: c.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: c.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan memuat data', style: TextStyle(color: c.statusCritical)));
          }
          
          final riwayat = snapshot.data ?? [];
          
          if (riwayat.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: c.outlineVariant),
                  const SizedBox(height: 16),
                  Text('Belum ada riwayat transaksi.', style: TextStyle(color: c.onSurfaceVariant)),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: riwayat.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = riwayat[index];
              final isBayar = item['jenis'] == 'bayar';
              final pelanggan = item['pelanggan'] != null ? item['pelanggan']['nama'] : 'Unknown';
              final tanggal = DateTime.parse(item['tanggal']).toLocal().toString().split('.')[0];
              final jumlah = item['jumlah'] as int;
              final keterangan = item['keterangan'] as String?;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isBayar ? c.statusSuccess.withValues(alpha: 0.1) : c.statusCritical.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBayar ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isBayar ? c.statusSuccess : c.statusCritical,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pelanggan,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: c.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBayar ? 'Pembayaran' : 'Utang Baru',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isBayar ? c.statusSuccess : c.statusCritical,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tanggal,
                            style: TextStyle(
                              fontSize: 12,
                              color: c.onSurfaceVariant,
                            ),
                          ),
                          if (keterangan != null && keterangan.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              keterangan,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: c.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      (isBayar ? '-' : '+') + _formatCurrency(jumlah),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBayar ? c.statusSuccess : c.statusCritical,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/transaksi_provider.dart';
import '../../data/models/transaksi_model.dart';

class RiwayatTransaksiScreen extends ConsumerStatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  ConsumerState<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends ConsumerState<RiwayatTransaksiScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(transaksiProvider.notifier).fetchTransaksi());
  }

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  IconData _getMetodeIcon(String metode) {
    switch (metode) {
      case 'QRIS':
        return Icons.qr_code_2;
      case 'Utang':
        return Icons.menu_book;
      default:
        return Icons.payments;
    }
  }

  Color _getMetodeColor(String metode, AppColors c) {
    switch (metode) {
      case 'QRIS':
        return c.secondary;
      case 'Utang':
        return c.tertiary;
      default:
        return c.primary;
    }
  }

  void _showDetailTransaksi(Transaksi transaksi) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: c.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Detail Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.onSurface)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getMetodeColor(transaksi.metode, c).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(transaksi.metode, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getMetodeColor(transaksi.metode, c))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_formatDate(transaksi.createdAt), style: TextStyle(fontSize: 13, color: c.onSurfaceVariant)),
                  if (transaksi.namaPelanggan != null) ...[
                    const SizedBox(height: 4),
                    Text('Pelanggan: ${transaksi.namaPelanggan}', style: TextStyle(fontSize: 13, color: c.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 20),
                  Divider(color: c.outlineVariant),
                  const SizedBox(height: 12),
                  // Items
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: transaksi.items.length,
                      separatorBuilder: (_, __) => Divider(height: 24, color: c.outlineVariant.withValues(alpha: 0.5)),
                      itemBuilder: (_, i) {
                        final item = transaksi.items[i];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.namaBarang, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.onSurface)),
                                  const SizedBox(height: 2),
                                  Text('${item.qty}x @ ${_formatCurrency(item.harga)}', style: TextStyle(fontSize: 13, color: c.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Text(_formatCurrency(item.subtotal), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.onSurface)),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(color: c.outlineVariant),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.onSurface)),
                      Text(_formatCurrency(transaksi.total), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final transaksiState = ref.watch(transaksiProvider);
    final allTransaksi = transaksiState.transaksiList;

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
          'Riwayat Transaksi',
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
      body: transaksiState.isLoading && allTransaksi.isEmpty
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : allTransaksi.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: c.outlineVariant),
                      const SizedBox(height: 16),
                      Text('Belum ada transaksi.', style: TextStyle(color: c.onSurfaceVariant, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Transaksi akan muncul setelah\nAnda memproses pembayaran di kasir.', textAlign: TextAlign.center, style: TextStyle(color: c.outline, fontSize: 13)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      color: c.surfaceContainerLow,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Hari Ini', style: TextStyle(fontSize: 12, color: c.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(transaksiState.totalHariIni),
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c.primary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: c.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${transaksiState.jumlahTransaksiHariIni} transaksi',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: RefreshIndicator(
                        color: c.primary,
                        onRefresh: () => ref.read(transaksiProvider.notifier).fetchTransaksi(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: allTransaksi.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final trx = allTransaksi[index];
                            final metodeColor = _getMetodeColor(trx.metode, c);

                            return InkWell(
                              onTap: () => _showDetailTransaksi(trx),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
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
                                        color: metodeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_getMetodeIcon(trx.metode), color: metodeColor),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trx.namaPelanggan != null
                                                ? '${trx.metode} - ${trx.namaPelanggan}'
                                                : '${trx.metode} • ${trx.items.length} item',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.onSurface),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(trx.createdAt),
                                            style: TextStyle(fontSize: 12, color: c.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(trx.total),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.primary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

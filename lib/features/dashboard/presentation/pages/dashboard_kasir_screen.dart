import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/kasir/presentation/pages/kasir_screen.dart';
import '../../../../features/utang/presentation/pages/buku_utang_screen.dart';
import '../../../../features/pengaturan/presentation/pages/pengaturan_kasir_screen.dart';

class DashboardKasirScreen extends ConsumerStatefulWidget {
  const DashboardKasirScreen({super.key});

  @override
  ConsumerState<DashboardKasirScreen> createState() => _DashboardKasirScreenState();
}

class _DashboardKasirScreenState extends ConsumerState<DashboardKasirScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';

    return Scaffold(
      backgroundColor: c.background,
      appBar: _selectedIndex == 0 ? _buildAppBar(c, namaToko) : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Index 0: Beranda
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section
                  Text(
                    'Selamat bekerja,',
                    style: TextStyle(color: c.greyText, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Halo! 👋',
                    style: TextStyle(
                      color: c.darkText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Action: Mulai Transaksi
                  _buildMainAction(c),
                  const SizedBox(height: 24),

                  // Bento Grid
                  _buildBentoGrid(c),
                  const SizedBox(height: 24),

                  // Recent Activity Feed
                  _buildRecentActivity(c),
                  const SizedBox(height: 24),

                  // Tip Card
                  _buildTipCard(c),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Index 1: Kasir
          const KasirScreen(),
          // Index 2: Utang
          const BukuUtangScreen(),
          // Index 3: Atur
          const PengaturanKasirScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(c),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors c, String namaToko) {
    return AppBar(
      backgroundColor: c.surface,
      elevation: 0,
      titleSpacing: 24,
      title: Row(
        children: [
          Icon(Icons.storefront_outlined, color: c.primaryGreen, size: 24),
          const SizedBox(width: 8),
          Text(
            namaToko,
            style: TextStyle(
              color: c.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Profil', style: TextStyle(color: c.greyText, fontSize: 10, fontWeight: FontWeight.w600)),
            Text('Kasir', style: TextStyle(color: c.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 12),
        Container(
          margin: const EdgeInsets.only(right: 24),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_none, color: c.greyText, size: 20),
            onPressed: () {},
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: c.outlineVariant, height: 1.0),
      ),
    );
  }

  Widget _buildMainAction(AppColors c) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = 1; // Ke halaman transaksi kasir
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: c.primaryGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: c.primaryGreen.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.point_of_sale, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mulai Transaksi',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Buka mesin kasir sekarang',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(AppColors c) {
    return Column(
      children: [
        // Transaksi Hari Ini
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceContainerLowest,
            border: Border.all(color: c.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.receipt_long, color: c.secondary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSAKSI HARI INI', style: TextStyle(color: c.greyText, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: c.darkText),
                          children: const [
                            TextSpan(text: '0 ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            TextSpan(text: 'Pesanan', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.statusSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+Rp0',
                  style: TextStyle(color: c.statusSuccess, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                c: c,
                icon: Icons.qr_code_scanner,
                title: 'Cari / Scan Barang',
                iconColor: c.primaryGreen,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                c: c,
                icon: Icons.menu_book,
                title: 'Buku Utang',
                iconColor: c.tertiary,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required AppColors c,
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceContainerLowest,
          border: Border.all(color: c.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: c.darkText, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terakhir',
              style: TextStyle(color: c.darkText, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _showRiwayatSheet(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(color: c.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.cardColor,
            border: Border.all(color: c.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 40, color: c.outlineVariant),
                const SizedBox(height: 8),
                Text('Belum ada aktivitas', style: TextStyle(color: c.greyText, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required AppColors c,
    required String title,
    required String timeInfo,
    required String amount,
    required IconData icon,
    required Color amountColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.cardColor,
          border: Border.all(color: c.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: c.greyText, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: c.darkText, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(timeInfo, style: TextStyle(color: c.greyText, fontSize: 12)),
                  ],
                ),
              ],
            ),
            Text(amount, style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(AppColors c) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('💡 Tips disimpan!'),
            backgroundColor: c.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips Hari Ini',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selalu cek stok barang yang paling laku setiap sore hari agar tidak kehabisan.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Icon(Icons.lightbulb, color: Colors.white.withOpacity(0.2), size: 80),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Riwayat Transaksi Bottom Sheet ───────────────────────────────
  void _showRiwayatSheet(BuildContext context) {
    final c = AppColors.of(context);
    final List<Map<String, dynamic>> riwayat = [];

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
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: c.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Transaksi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.darkText),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${riwayat.length} Transaksi',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: riwayat.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = riwayat[i];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _showDetailTransaksi(
                              context, c,
                              item['title'] as String,
                              item['time'] as String,
                              item['metode'] as String,
                              item['amount'] as String,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: c.cardColor,
                              border: Border.all(color: c.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: c.surfaceContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(item['icon'] as IconData, color: c.greyText, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'] as String, style: TextStyle(color: c.darkText, fontSize: 14, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text('${item['time']} • ${item['metode']}', style: TextStyle(color: c.greyText, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(item['amount'] as String, style: TextStyle(color: item['color'] as Color, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Detail Transaksi Dialog ──────────────────────────────────────
  void _showDetailTransaksi(BuildContext context, AppColors c, String title, String time, String metode, String amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: c.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.onSurface))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow(c, 'Waktu', time),
            const SizedBox(height: 12),
            _detailRow(c, 'Metode', metode),
            const SizedBox(height: 12),
            Divider(color: c.outlineVariant),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.onSurface)),
                Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.primaryGreen)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: TextStyle(color: c.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(AppColors c, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: c.greyText)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.onSurface)),
      ],
    );
  }

  Widget _buildBottomNav(AppColors c) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (idx) {
        setState(() {
          _selectedIndex = idx;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: c.surface,
      selectedItemColor: c.primaryGreen,
      unselectedItemColor: c.greyText,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Utang'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Atur'),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../pengaturan/presentation/providers/settings_provider.dart';

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

    return Scaffold(
      backgroundColor: c.background,
      appBar: _buildAppBar(c),
      body: SingleChildScrollView(
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
                'Halo, Budi! 👋',
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
      bottomNavigationBar: _buildBottomNav(c),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors c) {
    return AppBar(
      backgroundColor: c.surface,
      elevation: 0,
      titleSpacing: 24,
      title: Row(
        children: [
          Icon(Icons.storefront_outlined, color: c.primaryGreen, size: 24),
          const SizedBox(width: 8),
          Text(
            'Warung Pak Budi',
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
        context.push('/kasir'); // Ke halaman transaksi
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
                            TextSpan(text: '12 ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  '+Rp125rb',
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
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                c: c,
                icon: Icons.menu_book,
                title: 'Buku Utang',
                iconColor: c.tertiary,
                onTap: () {},
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
            Text(
              'Lihat Semua',
              style: TextStyle(color: c.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          c: c,
          title: 'Penjualan Sembako',
          timeInfo: '10:45 WIB • Tunai',
          amount: 'Rp45.000',
          icon: Icons.shopping_bag_outlined,
          amountColor: c.primaryGreen,
        ),
        const SizedBox(height: 8),
        _buildActivityItem(
          c: c,
          title: 'Utang: Pak RT',
          timeInfo: '09:12 WIB • Catat',
          amount: 'Rp12.500',
          icon: Icons.person_off_outlined,
          amountColor: c.tertiary,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
    );
  }

  Widget _buildTipCard(AppColors c) {
    return Container(
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
    );
  }

  Widget _buildBottomNav(AppColors c) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (idx) {
        setState(() {
          _selectedIndex = idx;
        });
        if (idx == 1) {
          context.push('/kasir');
        } else if (idx == 2) {
          context.push('/utang');
        } else if (idx == 3) {
          context.push('/atur');
        }
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

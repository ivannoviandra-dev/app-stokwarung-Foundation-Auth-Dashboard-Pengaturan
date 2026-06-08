import 'package:flutter/material.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  static const surface = Color(0xFFF4FBF4);
  static const onSurface = Color(0xFF161D19);
  static const primary = Color(0xFF006C49);
  static const primaryContainer = Color(0xFF10B981);
  static const onPrimaryContainer = Color(0xFF00422B);
  static const primaryFixed = Color(0xFF6FFBBE);
  static const onPrimaryFixedVariant = Color(0xFF005236);
  static const outlineVariant = Color(0xFFBBCABF);
  static const outline = Color(0xFF6C7A71);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFE3EAE3);
  static const surfaceContainerLow = Color(0xFFEEF6EE);
  static const onSurfaceVariant = Color(0xFF3C4A42);
  static const statusSuccess = Color(0xFF10B981);
  static const profitGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primary),
          onPressed: () {},
        ),
        title: const Text(
          'Laporan',
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_circle,
              color: onPrimaryContainer,
              size: 20,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: outlineVariant,
            height: 1.0,
          ),
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
                color: primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned(
                      right: -32,
                      top: -32,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: primaryContainer.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LABA BERSIH BULAN INI',
                            style: TextStyle(
                              color: primaryFixed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Rp 12.500.000',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: onPrimaryFixedVariant,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.arrow_upward, color: primaryFixed, size: 14),
                                    SizedBox(width: 2),
                                    Text(
                                      '12%',
                                      style: TextStyle(
                                        color: primaryFixed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: onPrimaryFixedVariant),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Penjualan',
                                      style: TextStyle(
                                        color: primaryFixed.withValues(alpha: 0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Rp 45.200.000',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Modal',
                                      style: TextStyle(
                                        color: primaryFixed.withValues(alpha: 0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Rp 32.700.000',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outlineVariant),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tren 7 Hari Terakhir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      Icon(Icons.insights, color: outline),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBar('Sen', 0.6, false),
                        _buildBar('Sel', 0.45, false),
                        _buildBar('Rab', 0.85, false),
                        _buildBar('Kam', 0.7, false),
                        _buildBar('Jum', 1.0, true),
                        _buildBar('Sab', 0.4, false),
                        _buildBar('Min', 0.55, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Best Sellers
            Row(
              children: [
                const Icon(Icons.stars, color: profitGold),
                const SizedBox(width: 8),
                const Text(
                  'Barang Terlaris',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildItemRankRow('Mie Instan Goreng', '1.240 Terjual', '+18%', true, 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?q=80&w=200&auto=format&fit=crop'),
            const SizedBox(height: 12),
            _buildItemRankRow('Telur Ayam Ras', '850 Terjual', '+5%', true, 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?q=80&w=200&auto=format&fit=crop'),
            const SizedBox(height: 24),

            // High Margin
            Row(
              children: [
                const Icon(Icons.trending_up, color: primary),
                const SizedBox(width: 8),
                const Text(
                  'Margin Tertinggi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMarginRow('Kopi Sachet Mix', 'Margin 45%', 'Rp 1.500', 'https://images.unsplash.com/photo-1559525839-b184a4d698c7?q=80&w=200&auto=format&fit=crop'),
            const SizedBox(height: 12),
            _buildMarginRow('Kerupuk Kaleng', 'Margin 40%', 'Rp 2.000', 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?q=80&w=200&auto=format&fit=crop'),
            const SizedBox(height: 32),

            // Download Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf),
                  SizedBox(width: 8),
                  Text(
                    'Unduh Laporan PDF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double heightRatio, bool isHighest) {
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
                  color: isHighest ? primaryContainer : surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isHighest ? FontWeight.bold : FontWeight.w600,
              color: isHighest ? primary : outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRankRow(String title, String subtitle, String trailing, bool isPositive, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? statusSuccess : outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginRow(String title, String subtitle, String price, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const Text(
                '/ pcs',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

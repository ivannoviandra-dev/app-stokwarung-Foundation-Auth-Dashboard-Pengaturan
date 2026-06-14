import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../reminder/presentation/pages/notifications_screen.dart';

class StrukPembayaranScreen extends StatelessWidget {
  final List<Map<String, dynamic>> keranjang;
  final int total;
  final String metode;

  const StrukPembayaranScreen({
    super.key,
    required this.keranjang,
    required this.total,
    required this.metode,
  });

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
    final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';
    final alamat = userMetadata?['alamat'] as String? ?? 'Alamat Belum Diatur';
    final nomorHp = userMetadata?['nomor_hp'] as String? ?? '';
    
    final date = DateTime.now();
    final dateString = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    final transactionId = "TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.storefront, color: c.primary),
            const SizedBox(width: 8),
            Text(
              namaToko,
              style: TextStyle(
                color: c.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: c.onSurfaceVariant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          // Background Pattern Decoration
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: DotPatternPainter(color: c.primary),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Success Indicator
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: c.primaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pembayaran Berhasil!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: c.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transaksi Anda telah selesai diproses.',
                        style: TextStyle(
                          fontSize: 14,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Receipt Component
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: c.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipPath(
                          clipper: ZigZagClipper(),
                          child: Container(
                            color: c.cardColor,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Receipt Header
                                Text(
                                  namaToko,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: c.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alamat.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: c.onSurfaceVariant,
                                  ),
                                ),
                                if (nomorHp.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'TELP: $nomorHp',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Divider(color: c.outlineVariant),
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateString,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
                                        ),
                                        Text(
                                          transactionId,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Kasir: Admin',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Items List
                                ...keranjang.map((item) {
                                  final nama = item['nama'];
                                  final qty = item['qty'];
                                  final harga = item['harga'];
                                  final itemTotal = qty * harga;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nama,
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.onSurface),
                                              ),
                                              Text(
                                                '${qty}x @ ${_formatCurrency(harga)}',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(itemTotal),
                                          style: TextStyle(fontSize: 14, color: c.onSurface),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                
                                const SizedBox(height: 12),
                                Divider(color: c.outlineVariant),
                                const SizedBox(height: 16),

                                // Totals
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Subtotal', style: TextStyle(fontSize: 14, color: c.onSurfaceVariant)),
                                    Text(_formatCurrency(total), style: TextStyle(fontSize: 14, color: c.onSurface)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.onSurface)),
                                    Text(
                                      _formatCurrency(total),
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('METODE PEMBAYARAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: c.secondaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        metode.toUpperCase(),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.onSecondaryContainer),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Footer
                                Text(
                                  'Terima kasih sudah belanja!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Simpan struk ini sebagai bukti pembayaran sah.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surfaceContainerLow,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('🖨️ Struk berhasil dicetak!'),
                              backgroundColor: c.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print),
                            SizedBox(width: 8),
                            Text('Cetak Struk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: c.cardColor,
                          foregroundColor: c.onSurfaceVariant,
                          side: BorderSide(color: c.outlineVariant),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Go back to kasir
                        },
                        child: const Text('Transaksi Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    double x = 0;
    double y = size.height;
    double increment = 10;

    while (x < size.width) {
      x += increment;
      y = y == size.height ? size.height - 6 : size.height;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, 0);

    x = size.width;
    y = 0;
    while (x > 0) {
      x -= increment;
      y = y == 0 ? 6 : 0;
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DotPatternPainter extends CustomPainter {
  final Color color;

  DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (double x = 0; x < size.width; x += 24) {
      for (double y = 0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

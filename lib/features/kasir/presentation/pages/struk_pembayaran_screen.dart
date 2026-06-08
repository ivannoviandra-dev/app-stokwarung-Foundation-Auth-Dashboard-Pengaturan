import 'package:flutter/material.dart';

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
    const primary = Color(0xFF006C49);
    const background = Color(0xFFF4FBF4);
    const onBackground = Color(0xFF161D19);
    const onSurfaceVariant = Color(0xFF3C4A42);
    const outlineVariant = Color(0xFFBBCABF);
    const primaryContainer = Color(0xFF10B981);
    const secondaryContainer = Color(0xFF5BB8FE);
    const onSecondaryContainer = Color(0xFF00476E);
    
    final date = DateTime.now();
    final dateString = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    final transactionId = "TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.storefront, color: primary),
            SizedBox(width: 8),
            Text(
              'Warung Pak Budi',
              style: TextStyle(
                color: primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: onSurfaceVariant),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: outlineVariant, height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          // Background Pattern Decoration
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: DotPatternPainter(),
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
                          color: primaryContainer,
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
                      const Text(
                        'Pembayaran Berhasil!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Transaksi Anda telah selesai diproses.',
                        style: TextStyle(
                          fontSize: 14,
                          color: onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Receipt Component
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            color: Colors.white,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Receipt Header
                                const Text(
                                  'Warung Pak Budi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: onBackground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'JL. MELATI NO. 12, JAKARTA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: outlineVariant),
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateString,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                                        ),
                                        Text(
                                          transactionId,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      'Kasir: Admin',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant),
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
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onBackground),
                                              ),
                                              Text(
                                                '${qty}x @ ${_formatCurrency(harga)}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(itemTotal),
                                          style: const TextStyle(fontSize: 14, color: onBackground),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                
                                const SizedBox(height: 12),
                                const Divider(color: outlineVariant),
                                const SizedBox(height: 16),

                                // Totals
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Subtotal', style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                                    Text(_formatCurrency(total), style: const TextStyle(fontSize: 14, color: onBackground)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onBackground)),
                                    Text(
                                      _formatCurrency(total),
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('METODE PEMBAYARAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVariant)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: secondaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        metode.toUpperCase(),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: onSecondaryContainer),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Footer
                                const Text(
                                  'Terima kasih sudah belanja!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: onSurfaceVariant),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Simpan struk ini sebagai bukti pembayaran sah.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: onSurfaceVariant),
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
                  color: const Color(0xFFEEF6EE),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
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
                          backgroundColor: Colors.white,
                          foregroundColor: onSurfaceVariant,
                          side: const BorderSide(color: outlineVariant),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006C49)
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

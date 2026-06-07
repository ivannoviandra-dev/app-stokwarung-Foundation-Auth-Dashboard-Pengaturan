import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'struk_pembayaran_screen.dart';

class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});

  @override
  ConsumerState<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  // Design Colors
  static const neutralSurface = Color(0xFFF8FAFC);
  static const surface = Color(0xFFF4FBF4);
  static const onSurface = Color(0xFF161D19);
  static const primary = Color(0xFF006C49);
  static const outlineVariant = Color(0xFFBBCABF);
  static const outline = Color(0xFF6C7A71);
  static const tertiary = Color(0xFFA43A3A);
  static const onSurfaceVariant = Color(0xFF3C4A42);
  static const secondaryContainer = Color(0xFF5BB8FE);
  static const onSecondaryContainer = Color(0xFF00476E);
  static const secondary = Color(0xFF006398);

  final List<Map<String, dynamic>> _keranjang = [
    {
      'nama': 'Mie Instan Goreng',
      'harga': 3000,
      'qty': 5,
    },
    {
      'nama': 'Teh Botol Kotak',
      'harga': 5000,
      'qty': 2,
    },
  ];

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  void _prosesPembayaran(String metode) {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }
    
    final keranjangCopy = List<Map<String, dynamic>>.from(_keranjang.map((e) => Map<String, dynamic>.from(e)));
    final total = _totalPrice;
    
    setState(() {
      _keranjang.clear();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StrukPembayaranScreen(
          keranjang: keranjangCopy,
          total: total,
          metode: metode,
        ),
      ),
    );
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _keranjang[index]['qty'] += delta;
      if (_keranjang[index]['qty'] <= 0) {
        _keranjang.removeAt(index);
      }
    });
  }

  int get _totalPrice {
    return _keranjang.fold(0, (sum, item) {
      return sum + ((item['harga'] as int) * (item['qty'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralSurface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.storefront, color: onSurface),
          onPressed: () {},
        ),
        title: const Text(
          'Warung Pak Budi',
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: onSurface),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: outlineVariant,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search / Scan Area
          Container(
            color: surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF6EE), // surface-container-low
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: outlineVariant),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: outline),
                  ),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari barang atau scan barcode...',
                        hintStyle: TextStyle(color: outline, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: onSurface, fontSize: 16),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        onTap: () {},
                        child: const Icon(Icons.qr_code_scanner, color: primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Keranjang List
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Keranjang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                          children: [
                            const TextSpan(text: 'Keranjang '),
                            TextSpan(
                              text: '(${_keranjang.length} item)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _keranjang.clear();
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline, size: 16, color: tertiary),
                            SizedBox(width: 4),
                            Text(
                              'Kosongkan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List Items
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDDE4DD)), // surface-container-highest
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: _keranjang.isEmpty
                          ? const Center(
                              child: Text(
                                'Keranjang masih kosong',
                                style: TextStyle(color: outline, fontSize: 16),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _keranjang.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFDDE4DD)),
                              itemBuilder: (context, index) {
                                final item = _keranjang[index];
                                final harga = item['harga'] as int;
                                final qty = item['qty'] as int;
                                final total = harga * qty;

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['nama'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  _formatCurrency(harga),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: onSurface,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  '/ pcs',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: outline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatCurrency(total),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: outlineVariant),
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () => _updateQty(index, -1),
                                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                                  child: Container(
                                                    width: 36,
                                                    alignment: Alignment.center,
                                                    child: const Icon(Icons.remove, size: 20, color: onSurfaceVariant),
                                                  ),
                                                ),
                                                Container(
                                                  width: 36,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '$qty',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: onSurface,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () => _updateQty(index, 1),
                                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                                  child: Container(
                                                    width: 36,
                                                    alignment: Alignment.center,
                                                    child: const Icon(Icons.add, size: 20, color: onSurfaceVariant),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(top: BorderSide(color: Color(0xFFDDE4DD))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatCurrency(_totalPrice),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                ),
                onPressed: () => _prosesPembayaran('Tunai'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments),
                    SizedBox(width: 8),
                    Text('Bayar Tunai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryContainer,
                  foregroundColor: onSecondaryContainer,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                ),
                onPressed: () => _prosesPembayaran('QRIS'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2),
                    SizedBox(width: 8),
                    Text('Bayar QRIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: secondary,
                  side: const BorderSide(color: secondary, width: 2),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book),
                    SizedBox(width: 8),
                    Text('Catat Utang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

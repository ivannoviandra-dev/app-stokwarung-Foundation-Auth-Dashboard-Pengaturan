import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'struk_pembayaran_screen.dart';
import '../../../barang/presentation/providers/barang_provider.dart';
import '../../../reminder/presentation/pages/notifications_screen.dart';
import '../../../utang/presentation/providers/utang_provider.dart';
import '../../../transaksi/presentation/providers/transaksi_provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});

  @override
  ConsumerState<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _keranjang = [];

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
    final keranjangCopy = List<Map<String, dynamic>>.from(
        _keranjang.map((e) => Map<String, dynamic>.from(e)));
    final total = _totalPrice;

    // Kurangi stok barang
    final barangNotifier = ref.read(barangProvider.notifier);
    for (var item in keranjangCopy) {
      if (item['id'] != null) {
        barangNotifier.kurangiStok(item['id'], item['qty'] as int);
      }
    }

    // Simpan transaksi ke database
    ref.read(transaksiProvider.notifier).simpanTransaksi(
      keranjang: keranjangCopy,
      total: total,
      metode: metode,
    );

    setState(() => _keranjang.clear());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StrukPembayaranScreen(
          keranjang: keranjangCopy, total: total, metode: metode,
        ),
      ),
    );
  }

  void _showCatatUtangDialog() {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final c = AppColors.of(context);
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: c.surface,
              title: Text('Catat Utang', style: TextStyle(color: c.onSurface)),
              content: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pelanggan',
                  hintStyle: TextStyle(color: c.outline),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: c.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: c.primary)),
                ),
                style: TextStyle(color: c.onSurface),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: c.tertiary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white),
                  onPressed: isSubmitting ? null : () async {
                    final nama = nameController.text.trim();
                    if (nama.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama tidak boleh kosong')),
                      );
                      return;
                    }

                    setDialogState(() => isSubmitting = true);

                    try {
                      final total = _totalPrice;
                      final keranjangCopy = List<Map<String, dynamic>>.from(
                        _keranjang.map((e) => Map<String, dynamic>.from(e)));

                      // Kurangi stok barang
                      final barangNotifier = ref.read(barangProvider.notifier);
                      for (var item in keranjangCopy) {
                        if (item['id'] != null) {
                          barangNotifier.kurangiStok(item['id'], item['qty'] as int);
                        }
                      }

                      // Simpan ke utang
                      final utangNotifier = ref.read(utangProvider.notifier);
                      final state = ref.read(utangProvider);
                      
                      final existingPelanggan = state.pelangganList.where((p) => p.nama.toLowerCase() == nama.toLowerCase()).toList();
                      
                      if (existingPelanggan.isNotEmpty) {
                        await utangNotifier.tambahCatatanUtang(
                          pelangganId: existingPelanggan.first.id,
                          jumlah: total,
                          jenis: 'utang',
                          keterangan: 'Belanja warung',
                        );
                      } else {
                        await utangNotifier.tambahPelanggan(nama, total);
                      }

                      // Simpan transaksi ke database
                      ref.read(transaksiProvider.notifier).simpanTransaksi(
                        keranjang: keranjangCopy,
                        total: total,
                        metode: 'Utang',
                        namaPelanggan: nama,
                      );

                      if (mounted) {
                        setState(() => _keranjang.clear());
                        Navigator.pop(context); // Close dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil mencatat utang!')),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StrukPembayaranScreen(
                              keranjang: keranjangCopy, total: total, metode: 'Utang ($nama)',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Terjadi kesalahan: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() => isSubmitting = false);
                      }
                    }
                  },
                  child: isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _tambahKeKeranjang(String value) {
    if (value.trim().isNotEmpty) {
      final semuaBarang = ref.read(barangProvider).semuaBarang;
      final foundBarang = semuaBarang.where((b) => 
        b.nama.toLowerCase() == value.trim().toLowerCase() || 
        (b.barcode != null && b.barcode == value.trim())
      ).toList();

      if (foundBarang.isNotEmpty) {
        final barang = foundBarang.first;
        setState(() {
          final index = _keranjang.indexWhere((item) =>
              item['nama'].toString().toLowerCase() ==
                  barang.nama.toLowerCase());
          if (index >= 0) {
            _keranjang[index]['qty'] += 1;
          } else {
            _keranjang.add({
              'id': barang.id,
              'nama': barang.nama, 
              'harga': barang.harga, 
              'harga_modal': barang.hargaBeli,
              'qty': 1
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang tidak ditemukan!')),
        );
      }
      _searchController.clear();
    }
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _keranjang[index]['qty'] += delta;
      if (_keranjang[index]['qty'] <= 0) _keranjang.removeAt(index);
    });
  }

  int get _totalPrice =>
      _keranjang.fold(0, (s, i) => s + ((i['harga'] as int) * (i['qty'] as int)));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';

    return Scaffold(
      backgroundColor: c.neutralSurface,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.storefront, color: c.onSurface),
          onPressed: () {},
        ),
        title: Text(
          namaToko,
          style: TextStyle(color: c.primary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: c.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Search / Scan Area
          Container(
            color: c.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: c.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.outlineVariant),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: c.outline),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama barang lalu enter...',
                        hintStyle: TextStyle(color: c.outline, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: c.onSurface, fontSize: 16),
                      onSubmitted: (value) => _tambahKeKeranjang(value),
                    ),
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8), bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8), bottomRight: Radius.circular(8),
                        ),
                        onTap: () async {
                          var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SimpleBarcodeScannerPage(),
                            ),
                          );
                          if (res is String && res != '-1' && res.isNotEmpty) {
                            _tambahKeKeranjang(res);
                          }
                        },
                        child: Icon(Icons.qr_code_scanner, color: c.primary),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.onSurface),
                          children: [
                            const TextSpan(text: 'Keranjang '),
                            TextSpan(
                              text: '(${_keranjang.length} item)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: c.outline),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _keranjang.clear()),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 16, color: c.tertiary),
                            const SizedBox(width: 4),
                            Text('Kosongkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.tertiary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.surfaceContainerHighest),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 2), blurRadius: 4),
                        ],
                      ),
                      child: _keranjang.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart_checkout, size: 64, color: c.outlineVariant),
                                  const SizedBox(height: 16),
                                  Text('Keranjang masih kosong', style: TextStyle(color: c.outline, fontSize: 16)),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Arahkan kursor ke input pencarian saat tombol "Tambah Barang" diklik
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Silakan cari nama barang di atas')),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Tambah Barang'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: c.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _keranjang.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: c.surfaceContainerHighest),
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
                                            Text(item['nama'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.onSurface)),
                                            const SizedBox(height: 4),
                                            Row(children: [
                                              Text(_formatCurrency(harga), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.onSurface)),
                                              const SizedBox(width: 4),
                                              Text('/ pcs', style: TextStyle(fontSize: 14, color: c.outline)),
                                            ]),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(_formatCurrency(total), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c.primary)),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: c.cardColor,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: c.outlineVariant),
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () => _updateQty(index, -1),
                                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                                  child: SizedBox(width: 36, child: Center(child: Icon(Icons.remove, size: 20, color: c.onSurfaceVariant))),
                                                ),
                                                SizedBox(
                                                  width: 36,
                                                  child: Center(child: Text('$qty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.onSurface))),
                                                ),
                                                InkWell(
                                                  onTap: () => _updateQty(index, 1),
                                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                                  child: SizedBox(width: 36, child: Center(child: Icon(Icons.add, size: 20, color: c.onSurfaceVariant))),
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
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(top: BorderSide(color: c.surfaceContainerHighest)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 12),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.onSurfaceVariant)),
                  Text(_formatCurrency(_totalPrice), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: c.primary)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary, foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1,
                ),
                onPressed: () => _prosesPembayaran('Tunai'),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.payments), SizedBox(width: 8),
                  Text('Bayar Tunai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.secondaryContainer, foregroundColor: c.onSecondaryContainer,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1,
                ),
                onPressed: () => _prosesPembayaran('QRIS'),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.qr_code_2), SizedBox(width: 8),
                  Text('Bayar QRIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.secondary, side: BorderSide(color: c.secondary, width: 2),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showCatatUtangDialog,
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.menu_book), SizedBox(width: 8),
                  Text('Catat Utang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

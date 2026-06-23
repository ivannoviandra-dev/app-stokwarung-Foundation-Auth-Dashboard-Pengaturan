import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/midtrans_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'struk_pembayaran_screen.dart';
import 'midtrans_payment_screen.dart';
import '../../../transaksi/data/models/transaksi_model.dart';
import '../../../barang/presentation/providers/barang_provider.dart';
import '../../../transaksi/presentation/providers/transaksi_provider.dart';
import '../../../utang/presentation/providers/utang_provider.dart';
import '../../../reminder/presentation/pages/notifications_screen.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class KasirScreen extends ConsumerStatefulWidget {
  const KasirScreen({super.key});

  @override
  ConsumerState<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends ConsumerState<KasirScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final value = _searchController.text.trim();
    if (value.isEmpty) {
      if (_searchResults.isNotEmpty) {
        setState(() => _searchResults = []);
      }
      return;
    }
    
    final semuaBarang = ref.read(barangProvider).semuaBarang;
    final found = semuaBarang.where((b) => 
      b.nama.toLowerCase().contains(value.toLowerCase()) || 
      (b.barcode != null && b.barcode!.contains(value))
    ).toList();
    
    setState(() {
      _searchResults = found;
    });
  }

  void _tambahKeKeranjang(dynamic barang) {
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
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _keranjang = [];
  bool _isProcessingQRIS = false;

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  Future<void> _prosesPembayaran(String metode, {String? pelangganId, String? namaPelanggan}) async {
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

    Transaksi? savedTransaksi;
    try {
      savedTransaksi = await ref.read(transaksiProvider.notifier).simpanTransaksi(
        keranjang: keranjangCopy,
        total: total,
        metode: metode,
        namaPelanggan: namaPelanggan,
      );

      if (metode == 'Utang' && pelangganId != null) {
        await ref.read(utangProvider.notifier).tambahCatatanUtang(
          pelangganId: pelangganId,
          jumlah: total,
          jenis: 'utang',
          keterangan: 'Transaksi Pembelian',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses transaksi: $e')),
        );
      }
      return; // Stop here if failed
    }

    if (mounted) {
      setState(() => _keranjang.clear());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StrukPembayaranScreen(
            keranjang: keranjangCopy,
            total: total,
            metode: metode,
            transaksiId: savedTransaksi?.id,
          ),
        ),
      );
    }
  }

  /// Proses pembayaran QRIS melalui Midtrans Snap.
  Future<void> _prosesQRIS() async {
    if (_isProcessingQRIS) return;
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    setState(() {
      _isProcessingQRIS = true;
    });

    final keranjangCopy = List<Map<String, dynamic>>.from(
        _keranjang.map((e) => Map<String, dynamic>.from(e)));
    final total = _totalPrice;
    final orderId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. Buat Snap Token via Midtrans API
      final snapResult = await MidtransService.createSnapToken(
        orderId: orderId,
        grossAmount: total,
        items: keranjangCopy.map((item) {
          return {
            'id': item['id']?.toString() ?? 'item',
            'nama': item['nama'] as String,
            'harga': item['harga'] as int,
            'qty': item['qty'] as int,
          };
        }).toList(),
      );

      if (!mounted) return;

      final snapToken = snapResult['token']!;

      // 2. Tentukan jalur berdasarkan platform
      String paymentResult;

      if (kIsWeb) {
        // Di Web: buka Snap.js popup langsung di browser
        paymentResult = await MidtransService.openSnapPopup(snapToken);
      } else {
        // Di Mobile: buka WebView
        final redirectUrl = snapResult['redirect_url']!;
        final status = await Navigator.push<MidtransPaymentStatus>(
          context,
          MaterialPageRoute(
            builder: (_) => MidtransPaymentScreen(
              redirectUrl: redirectUrl,
              orderId: orderId,
              totalAmount: total,
            ),
          ),
        );

        // Map MidtransPaymentStatus ke string
        switch (status) {
          case MidtransPaymentStatus.success:
            paymentResult = 'success';
            break;
          case MidtransPaymentStatus.pending:
            paymentResult = 'pending';
            break;
          case MidtransPaymentStatus.cancelled:
            paymentResult = 'close';
            break;
          default:
            paymentResult = 'error';
        }
      }

      if (!mounted) return;

      // 3. Proses hasil pembayaran
      if (paymentResult == 'success' || paymentResult == 'pending') {
        // Kurangi stok barang
        final barangNotifier = ref.read(barangProvider.notifier);
        for (var item in keranjangCopy) {
          if (item['id'] != null) {
            barangNotifier.kurangiStok(item['id'], item['qty'] as int);
          }
        }

        // Simpan transaksi ke Supabase
        Transaksi? savedTransaksi;
        try {
          savedTransaksi = await ref.read(transaksiProvider.notifier).simpanTransaksi(
            keranjang: keranjangCopy,
            total: total,
            metode: 'QRIS',
            midtransOrderId: orderId,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pembayaran berhasil, tapi gagal menyimpan: $e')),
            );
          }
          return;
        }

        if (mounted) {
          setState(() => _keranjang.clear());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StrukPembayaranScreen(
                keranjang: keranjangCopy,
                total: total,
                metode: 'QRIS',
                transaksiId: savedTransaksi?.id,
              ),
            ),
          );
        }
      } else if (paymentResult == 'close') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran QRIS dibatalkan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran QRIS gagal. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pembayaran QRIS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingQRIS = false;
        });
      }
    }
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _keranjang[index]['qty'] += delta;
      if (_keranjang[index]['qty'] <= 0) _keranjang.removeAt(index);
    });
  }

  void _showCatatUtangSheet() {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    final utangState = ref.read(utangProvider);
    final pelangganList = utangState.pelangganList;
    final c = AppColors.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: c.outlineVariant, borderRadius: BorderRadius.circular(2)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pilih Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.darkText)),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showTambahPelangganUtangDialog();
                        },
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Pelanggan Baru'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (pelangganList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text('Belum ada pelanggan.\nTambahkan pelanggan di menu Buku Utang terlebih dahulu.', textAlign: TextAlign.center, style: TextStyle(color: c.greyText)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: pelangganList.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx2, i) {
                          final p = pelangganList[i];
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: c.primaryContainer, child: Text(p.nama.isNotEmpty ? p.nama[0].toUpperCase() : '?', style: TextStyle(color: c.onPrimaryContainer))),
                            title: Text(p.nama, style: TextStyle(fontWeight: FontWeight.bold, color: c.onSurface)),
                            subtitle: p.noHp != null ? Text(p.noHp!) : null,
                            onTap: () {
                              Navigator.pop(ctx);
                              _prosesPembayaran('Utang', pelangganId: p.id, namaPelanggan: p.nama);
                            },
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

  void _showTambahPelangganUtangDialog() {
    final c = AppColors.of(context);
    final namaController = TextEditingController();
    final hpController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Pelanggan Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hpController,
              decoration: InputDecoration(
                labelText: 'Nomor HP (Opsional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: c.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nama = namaController.text.trim();
              if (nama.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama pelanggan harus diisi!')),
                );
                return;
              }

              // Tutup dialog
              Navigator.pop(ctx);

              // Tampilkan loading (opsional, tapi karena cepat kita langsung panggil)
              try {
                final newPelanggan = await ref.read(utangProvider.notifier).tambahPelanggan(
                  nama,
                  0, // Nominal awal 0 karena utangnya dicatat dari total belanja
                  noHp: hpController.text.trim(),
                );
                if (newPelanggan != null) {
                  // Langsung proses pembayaran utang
                  _prosesPembayaran('Utang', pelangganId: newPelanggan.id, namaPelanggan: newPelanggan.nama);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambah pelanggan: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan & Catat Utang'),
          ),
        ],
      ),
    );
  }

  int get _totalPrice =>
      _keranjang.fold(0, (s, i) => s + ((i['harga'] as int) * (i['qty'] as int)));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
      resizeToAvoidBottomInset: true,
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
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          final semuaBarang = ref.read(barangProvider).semuaBarang;
                          final foundBarang = semuaBarang.where((b) => 
                            b.nama.toLowerCase() == value.trim().toLowerCase() || 
                            (b.barcode != null && b.barcode == value.trim())
                          ).toList();

                          if (foundBarang.isNotEmpty) {
                            final barang = foundBarang.first;
                            _tambahKeKeranjang(barang);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Barang tidak ditemukan!')),
                            );
                          }
                          _searchController.clear();
                        }
                      },
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
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SimpleBarcodeScannerPage(),
                            ),
                          );
                          if (res is String && res != '-1') {
                            _searchController.text = res;
                            final value = res;
                            if (value.trim().isNotEmpty) {
                              final semuaBarang = ref.read(barangProvider).semuaBarang;
                              final foundBarang = semuaBarang.where((b) => 
                                b.nama.toLowerCase() == value.trim().toLowerCase() || 
                                (b.barcode != null && b.barcode == value.trim())
                              ).toList();

                              if (foundBarang.isNotEmpty) {
                                final barang = foundBarang.first;
                                _tambahKeKeranjang(barang);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Barang tidak ditemukan!')),
                                );
                              }
                              _searchController.clear();
                            }
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

          // Search Results
          if (_searchResults.isNotEmpty)
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 4),
                constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.outlineVariant),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: c.surfaceContainerHighest),
                itemBuilder: (context, index) {
                  final barang = _searchResults[index];
                  return ListTile(
                    title: Text(barang.nama, style: TextStyle(color: c.onSurface, fontWeight: FontWeight.w500)),
                    subtitle: Text(_formatCurrency(barang.harga), style: TextStyle(color: c.primary, fontSize: 13)),
                    trailing: Icon(Icons.add_shopping_cart, color: c.primary, size: 20),
                    onTap: () {
                      _tambahKeKeranjang(barang);
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),

          // Keranjang List
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxHeight < 120) {
                  return const SizedBox.shrink();
                }
                return Container(
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart_checkout, size: 48, color: c.outlineVariant),
                                      const SizedBox(height: 8),
                                      Text('Keranjang masih kosong', style: TextStyle(color: c.outline, fontSize: 14)),
                                    ],
                                  ),
                                ),
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
            );
          },
        ),
      ),
    ],
      ),
      bottomNavigationBar: isKeyboardOpen ? const SizedBox.shrink() : Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
                  Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.onSurfaceVariant)),
                  Text(_formatCurrency(_totalPrice), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c.primary)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _prosesPembayaran('Tunai'),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.payments, size: 20), SizedBox(width: 8),
                    Text('Bayar Tunai', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.secondaryContainer, foregroundColor: c.onSecondaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: _isProcessingQRIS ? null : _prosesQRIS,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          if (_isProcessingQRIS) ...[
                            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 6),
                            const Text('Proses...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ] else ...[
                            const Icon(Icons.qr_code_2, size: 20), const SizedBox(width: 6),
                            const Text('QRIS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ]
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.secondary, side: BorderSide(color: c.secondary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: _showCatatUtangSheet,
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.menu_book, size: 20), SizedBox(width: 6),
                          Text('Utang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

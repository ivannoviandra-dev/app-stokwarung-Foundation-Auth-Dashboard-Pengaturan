import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/barang_model.dart';
import '../providers/barang_provider.dart';
import 'tambah_barang_screen.dart';
import '../../../reminder/presentation/pages/notifications_screen.dart';

class ManajemenBarangScreen extends ConsumerStatefulWidget {
  const ManajemenBarangScreen({super.key});

  @override
  ConsumerState<ManajemenBarangScreen> createState() =>
      _ManajemenBarangScreenState();
}

class _ManajemenBarangScreenState extends ConsumerState<ManajemenBarangScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final primaryGreen = c.primaryGreen;
    final bgColor = c.background;
    final greyText = c.greyText;

    final barangState = ref.watch(barangProvider);
    final barangNotifier = ref.read(barangProvider.notifier);
    final filteredBarang = barangState.filteredBarang;
    final daftarKategori = barangState.daftarKategori;
    final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              namaToko,
              style: TextStyle(
                color: primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined,
                color: primaryGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan_fab',
            backgroundColor: primaryGreen,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Scan Barcode (Segera Hadir)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Icon(Icons.qr_code_scanner, color: c.surface),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_fab',
            backgroundColor: primaryGreen,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahBarangScreen(),
                ),
              );
            },
            child: Icon(Icons.add, color: c.surface),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Search Bar ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: c.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => barangNotifier.setSearch(value),
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    hintStyle: TextStyle(color: greyText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: greyText),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Category Filters ─────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(daftarKategori.length, (index) {
                    final kategori = daftarKategori[index];
                    final isSelected =
                        kategori == barangState.selectedKategori;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => barangNotifier.setKategori(kategori),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? primaryGreen : c.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? primaryGreen
                                  : c.outlineVariant,
                            ),
                          ),
                          child: Text(
                            kategori,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : greyText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Result Count ─────────────────────────────────────
              Text(
                '${filteredBarang.length} barang ditemukan',
                style: TextStyle(
                  color: greyText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),

              // ─── Inventory List ───────────────────────────────────
              if (filteredBarang.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada barang ditemukan',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBarang.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: c.outlineVariant),
                  itemBuilder: (context, index) {
                    final barang = filteredBarang[index];
                    return _buildItemCard(
                      c: c,
                      barang: barang,
                      onEdit: () => _showEditDialog(context, c, barang),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Item Card Widget ──────────────────────────────────────────────────────
  Widget _buildItemCard({
    required AppColors c,
    required Barang barang,
    required VoidCallback onEdit,
  }) {
    // Use context colors for card
    final cardColor = c.cardColor;
    final cardBorderColor = c.cardBorder;

    final statusStok = barang.statusStok;
    final Color statusColor;
    final String statusText;
    final bool isPulsing;

    switch (statusStok) {
      case 'kritis':
        statusColor = c.statusCritical;
        statusText = 'Kritis';
        isPulsing = true;
        break;
      case 'rendah':
        statusColor = c.statusWarning;
        statusText = 'Stok Rendah';
        isPulsing = true;
        break;
      default:
        statusColor = c.statusSuccess;
        statusText = 'Aman';
        isPulsing = false;
    }

    String? kedaluwarsaText;
    Color? kedaluwarsaColor;

    if (barang.tanggalKedaluwarsa != null) {
      final daysToExpire = barang.tanggalKedaluwarsa!.difference(DateTime.now()).inDays;
      if (daysToExpire < 0) {
        kedaluwarsaText = 'Kedaluwarsa';
        kedaluwarsaColor = c.statusCritical;
      } else if (daysToExpire <= 7) {
        kedaluwarsaText = 'Segera Kedaluwarsa';
        kedaluwarsaColor = c.statusWarning;
      }
    }

    final hargaFormatted = 'Rp${barang.harga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';

    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.nama,
                    style: TextStyle(
                      color: c.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          barang.kategori.toUpperCase(),
                          style: TextStyle(
                            color: c.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hargaFormatted,
                        style: TextStyle(
                          color: c.greyText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: isPulsing ? statusColor : c.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${barang.stok}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPulsing ? statusColor : c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (kedaluwarsaText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: kedaluwarsaColor!.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 10, color: kedaluwarsaColor),
                        const SizedBox(width: 4),
                        Text(
                          kedaluwarsaText,
                          style: TextStyle(
                            color: kedaluwarsaColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
    );
  }



  // ─── Dialog: Edit Barang ──────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, AppColors c, Barang barang) {
    final namaCtrl = TextEditingController(text: barang.nama);
    final hargaCtrl = TextEditingController(text: barang.harga.toString());
    final stokCtrl = TextEditingController(text: barang.stok.toString());
    String kategori = barang.kategori;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Barang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: kategori,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: () {
                    final defaultKategori = ['Sembako', 'Makanan', 'Minuman', 'Rokok', 'Kebutuhan Rumah', 'Lainnya'];
                    final list = defaultKategori.toList();
                    if (!list.contains(kategori)) {
                      list.add(kategori);
                    }
                    return list.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList();
                  }(),
                  onChanged: (val) {
                    setDialogState(() => kategori = val!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hargaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stokCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Hapus barang
                ref.read(barangProvider.notifier).hapusBarang(barang.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Barang "${barang.nama}" dihapus.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: c.statusCritical,
                  ),
                );
              },
              child:
                  Text('Hapus', style: TextStyle(color: c.statusCritical)),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: TextStyle(color: c.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: c.primaryGreen),
              onPressed: () {
                final nama = namaCtrl.text.trim();
                final harga = int.tryParse(hargaCtrl.text.trim()) ?? 0;
                final stok = int.tryParse(stokCtrl.text.trim()) ?? 0;

                if (nama.isEmpty || harga <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan harga wajib diisi!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final updated = barang.copyWith(
                  nama: nama,
                  kategori: kategori,
                  harga: harga,
                  stok: stok,
                );
                ref.read(barangProvider.notifier).updateBarang(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Barang "$nama" berhasil diperbarui!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: c.statusSuccess,
                  ),
                );
              },
              child: Text('Simpan',
                  style: TextStyle(color: c.surface)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/barang_model.dart';
import '../providers/barang_provider.dart';

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
    const primaryGreen = Color(0xFF10A87A);
    const bgColor = Color(0xFFF3FAF6);
    const greyText = Color(0xFF6B7280);

    final barangState = ref.watch(barangProvider);
    final barangNotifier = ref.read(barangProvider.notifier);
    final filteredBarang = barangState.filteredBarang;
    final daftarKategori = barangState.daftarKategori;

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
              decoration: const BoxDecoration(
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
            const Text(
              'Warung Pak Budi',
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
            icon: const Icon(Icons.notifications_none_outlined,
                color: primaryGreen),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Search Bar ───────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => barangNotifier.setSearch(value),
                      decoration: const InputDecoration(
                        hintText: 'Cari barang...',
                        hintStyle: TextStyle(color: greyText, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: greyText),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                                    isSelected ? primaryGreen : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryGreen
                                      : Colors.grey.shade300,
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
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Inventory Grid ───────────────────────────────────
                  if (filteredBarang.isEmpty)
                    SizedBox(
                      height: 200,
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
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.80,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBarang.length,
                      itemBuilder: (context, index) {
                        final barang = filteredBarang[index];
                        return _buildItemCard(
                          barang: barang,
                          onEdit: () => _showEditDialog(context, barang),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ─── Floating Action Buttons ──────────────────────────────────
          Positioned(
            right: 24,
            bottom: 24,
            child: Column(
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
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'add_fab',
                  backgroundColor: primaryGreen,
                  onPressed: () => _showTambahDialog(context),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Item Card Widget ──────────────────────────────────────────────────────
  Widget _buildItemCard({
    required Barang barang,
    required VoidCallback onEdit,
  }) {
    const primaryGreen = Color(0xFF10A87A);
    const darkText = Color(0xFF1F2937);

    final statusStok = barang.statusStok;
    final Color statusColor;
    final String statusText;
    final bool isPulsing;

    switch (statusStok) {
      case 'kritis':
        statusColor = Colors.red;
        statusText = 'Kritis';
        isPulsing = true;
        break;
      case 'rendah':
        statusColor = Colors.orange;
        statusText = 'Stok Rendah';
        isPulsing = true;
        break;
      default:
        statusColor = Colors.green;
        statusText = 'Aman';
        isPulsing = false;
    }

    final hargaFormatted = 'Rp${barang.harga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPulsing ? statusColor.withValues(alpha: 0.5) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    barang.kategori.toUpperCase(),
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPulsing
                      ? statusColor.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPulsing
                        ? statusColor.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 12,
                      color:
                          isPulsing ? statusColor : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${barang.stok}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPulsing
                            ? statusColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            barang.nama,
            style: const TextStyle(
              color: darkText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            hargaFormatted,
            style: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      Flexible(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.edit, size: 10, color: Colors.blue),
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

  // ─── Dialog: Tambah Barang ─────────────────────────────────────────────────
  void _showTambahDialog(BuildContext context) {
    final namaCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();
    final stokCtrl = TextEditingController();
    String kategori = 'Sembako';
    const primaryGreen = Color(0xFF10A87A);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tambah Barang Baru'),
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
                  items: ['Sembako', 'Makanan', 'Minuman', 'Kebutuhan Rumah']
                      .map((k) =>
                          DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
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
                    labelText: 'Stok Awal',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
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

                final newBarang = Barang(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nama: nama,
                  kategori: kategori,
                  harga: harga,
                  stok: stok,
                );
                ref.read(barangProvider.notifier).tambahBarang(newBarang);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Barang "$nama" berhasil ditambahkan!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: primaryGreen,
                  ),
                );
              },
              child: const Text('Simpan',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog: Edit Barang ──────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, Barang barang) {
    final namaCtrl = TextEditingController(text: barang.nama);
    final hargaCtrl = TextEditingController(text: barang.harga.toString());
    final stokCtrl = TextEditingController(text: barang.stok.toString());
    String kategori = barang.kategori;
    const primaryGreen = Color(0xFF10A87A);

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
                  items: ['Sembako', 'Makanan', 'Minuman', 'Kebutuhan Rumah']
                      .map((k) =>
                          DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
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
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child:
                  const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
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
                    backgroundColor: primaryGreen,
                  ),
                );
              },
              child: const Text('Simpan',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

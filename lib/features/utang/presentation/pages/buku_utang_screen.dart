import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bayar_utang_screen.dart';
import '../../../reminder/presentation/pages/notifications_screen.dart';


class BukuUtangScreen extends StatefulWidget {
  const BukuUtangScreen({super.key});

  @override
  State<BukuUtangScreen> createState() => _BukuUtangScreenState();
}

class _BukuUtangScreenState extends State<BukuUtangScreen> {
  late TextEditingController _searchController;
  final List<Map<String, dynamic>> _pelanggan = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredPelanggan(AppColors c) {
    // Inject dynamic colors into the list items here
    final List<Map<String, dynamic>> pelangganWithColors = _pelanggan.map((p) {
      final newMap = Map<String, dynamic>.from(p);
      if (p['nama'] == 'Bu Siti') {
        newMap['statusColor'] = c.onSurfaceVariant;
        newMap['bgColor'] = c.primaryContainer;
        newMap['textColor'] = c.onPrimaryContainer;
      } else if (p['nama'] == 'Mbak Dina') {
        newMap['statusColor'] = c.statusWarning;
        newMap['bgColor'] = c.tertiary;
        newMap['textColor'] = c.surface;
      } else {
        newMap['statusColor'] = c.onSurfaceVariant;
        newMap['bgColor'] = c.secondaryContainer;
        newMap['textColor'] = c.onSecondaryContainer;
      }
      return newMap;
    }).toList();

    if (_searchController.text.isEmpty) return pelangganWithColors;
    return pelangganWithColors.where((p) {
      final nama = (p['nama'] as String).toLowerCase();
      final query = _searchController.text.toLowerCase();
      return nama.contains(query);
    }).toList();
  }

  void _showAddDialog(AppColors c) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: c.surfaceContainerLow,
          title: Text('Tambah Pelanggan Baru', style: TextStyle(color: c.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Piutang Awal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: c.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _pelanggan.add({
                      'nama': nameController.text,
                      'status': '1 Transaksi belum lunas',
                      'utang': int.tryParse(amountController.text) ?? 0,
                      'inisial': nameController.text[0].toUpperCase(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

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
    final filteredPelanggan = _filteredPelanggan(c);
    final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    final namaToko = userMetadata?['nama_toko'] as String? ?? 'Warung Saya';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
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
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Section
          Text(
            'Buku Utang',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola piutang pelanggan dengan mudah.',
            style: TextStyle(
              fontSize: 14,
              color: c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.outlineVariant),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Piutang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: c.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(_pelanggan.fold<int>(0, (sum, item) => sum + (item['utang'] as int))),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: c.statusCritical,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.groups, size: 16, color: c.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Tersebar di ${_pelanggan.where((p) => (p['utang'] as int) > 0).length} pelanggan aktif',
                          style: TextStyle(
                            fontSize: 14,
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Search Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: c.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.outlineVariant),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: c.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama pelanggan...',
                      hintStyle: TextStyle(color: c.outline, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Debt List
          Container(
            decoration: BoxDecoration(
              color: c.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.outlineVariant),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPelanggan.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: c.outlineVariant),
              itemBuilder: (context, index) {
                final item = filteredPelanggan[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BayarUtangScreen(pelanggan: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item['bgColor'] as Color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['inisial'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: item['textColor'] as Color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: c.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['status'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: item['statusColor'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Amount & Action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(item['utang'] as int),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: c.statusCritical,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BayarUtangScreen(pelanggan: item),
                                ),
                              );
                            },
                            child: Text(
                              'Catat Bayar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
              },
            ),
          ),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(c),
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

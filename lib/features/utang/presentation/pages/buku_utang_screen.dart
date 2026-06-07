import 'package:flutter/material.dart';
import 'bayar_utang_screen.dart';

class BukuUtangScreen extends StatefulWidget {
  const BukuUtangScreen({super.key});

  @override
  State<BukuUtangScreen> createState() => _BukuUtangScreenState();
}

class _BukuUtangScreenState extends State<BukuUtangScreen> {
  // Design Colors
  static const primary = Color(0xFF006C49);
  static const surfaceContainerLow = Color(0xFFEEF6EE);
  static const outlineVariant = Color(0xFFBBCABF);
  static const outline = Color(0xFF6C7A71);
  static const onSurface = Color(0xFF161D19);
  static const onSurfaceVariant = Color(0xFF3C4A42);
  static const statusCritical = Color(0xFFEF4444);
  static const statusWarning = Color(0xFFF59E0B);
  static const background = Color(0xFFF4FBF4);

  late TextEditingController _searchController;

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

  final List<Map<String, dynamic>> _pelanggan = [
    {
      'nama': 'Bu Siti',
      'status': '2 Transaksi belum lunas',
      'statusColor': onSurfaceVariant,
      'utang': 350000,
      'inisial': 'S',
      'bgColor': const Color(0xFF10B981), // primary-container
      'textColor': const Color(0xFF00422B), // on-primary-container
    },
    {
      'nama': 'Pak RT',
      'status': '1 Transaksi belum lunas',
      'statusColor': onSurfaceVariant,
      'utang': 120000,
      'inisial': 'R',
      'bgColor': const Color(0xFF5BB8FE), // secondary-container
      'textColor': const Color(0xFF00476E), // on-secondary-container
    },
    {
      'nama': 'Mbak Dina',
      'status': 'Jatuh tempo hari ini',
      'statusColor': statusWarning,
      'utang': 50000,
      'inisial': 'D',
      'bgColor': const Color(0xFFFC7C78), // tertiary-container
      'textColor': const Color(0xFF711419), // on-tertiary-container
    },
  ];

  List<Map<String, dynamic>> get _filteredPelanggan {
    if (_searchController.text.isEmpty) return _pelanggan;
    return _pelanggan.where((p) {
      final nama = (p['nama'] as String).toLowerCase();
      final query = _searchController.text.toLowerCase();
      return nama.contains(query);
    }).toList();
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceContainerLow,
          title: const Text('Tambah Pelanggan Baru', style: TextStyle(color: onSurface)),
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
              child: const Text('Batal', style: TextStyle(color: onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _pelanggan.add({
                      'nama': nameController.text,
                      'status': '1 Transaksi belum lunas',
                      'statusColor': onSurfaceVariant,
                      'utang': int.tryParse(amountController.text) ?? 0,
                      'inisial': nameController.text[0].toUpperCase(),
                      'bgColor': const Color(0xFF5BB8FE),
                      'textColor': const Color(0xFF00476E),
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
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: outlineVariant, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Section
          const Text(
            'Buku Utang',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola piutang pelanggan dengan mudah.',
            style: TextStyle(
              fontSize: 14,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlineVariant),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Piutang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(_pelanggan.fold<int>(0, (sum, item) => sum + (item['utang'] as int))),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: statusCritical,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.groups, size: 16, color: primary),
                        const SizedBox(width: 4),
                        Text(
                          'Tersebar di ${_pelanggan.where((p) => (p['utang'] as int) > 0).length} pelanggan aktif',
                          style: const TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: outlineVariant),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search, color: outline),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama pelanggan...',
                      hintStyle: TextStyle(color: outline, fontSize: 14),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlineVariant),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredPelanggan.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: outlineVariant),
              itemBuilder: (context, index) {
                final item = _filteredPelanggan[index];
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusCritical,
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
                            child: const Text(
                              'Catat Bayar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primary,
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
        onPressed: _showAddDialog,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

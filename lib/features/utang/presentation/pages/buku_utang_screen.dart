import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bayar_utang_screen.dart';
import '../../../reminder/presentation/pages/notifications_screen.dart';
import '../providers/utang_provider.dart';
import '../../data/models/pelanggan_model.dart';
import 'riwayat_utang_screen.dart';

class BukuUtangScreen extends ConsumerStatefulWidget {
  const BukuUtangScreen({super.key});

  @override
  ConsumerState<BukuUtangScreen> createState() => _BukuUtangScreenState();
}

class _BukuUtangScreenState extends ConsumerState<BukuUtangScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      ref.read(utangProvider.notifier).setSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getAvatarColor(String nama, AppColors c) {
    int hash = nama.codeUnits.fold(0, (a, b) => a + b);
    switch (hash % 3) {
      case 0: return c.primaryContainer;
      case 1: return c.tertiaryContainer;
      default: return c.secondaryContainer;
    }
  }

  Color _getTextColor(String nama, AppColors c) {
    int hash = nama.codeUnits.fold(0, (a, b) => a + b);
    switch (hash % 3) {
      case 0: return c.onPrimaryContainer;
      case 1: return c.onTertiaryContainer;
      default: return c.onSecondaryContainer;
    }
  }

  Color _getStatusColor(String nama, AppColors c) {
    int hash = nama.codeUnits.fold(0, (a, b) => a + b);
    return hash % 2 == 0 ? c.onSurfaceVariant : c.statusWarning;
  }

  void _showAddDialog(AppColors c) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP (Opsional)',
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
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final nominalAwal = int.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                  try {
                    await ref.read(utangProvider.notifier).tambahPelanggan(
                      nameController.text, 
                      nominalAwal,
                      noHp: phoneController.text,
                    );
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menambah pelanggan: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String pelangganId, String namaPelanggan, AppColors c) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: c.surfaceContainerLow,
          title: Text('Hapus Pelanggan', style: TextStyle(color: c.onSurface)),
          content: Text('Apakah Anda yakin ingin menghapus $namaPelanggan dari daftar utang? Semua riwayat utangnya akan ikut terhapus.', style: TextStyle(color: c.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: c.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: c.statusCritical, foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  await ref.read(utangProvider.notifier).hapusPelanggan(pelangganId);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pelanggan berhasil dihapus')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus pelanggan: $e')),
                    );
                  }
                }
              },
              child: const Text('Hapus'),
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
    final utangState = ref.watch(utangProvider);
    final filteredPelanggan = utangState.filteredPelanggan;
    final totalPiutang = utangState.totalPiutangKeseluruhan;
    final aktifCount = utangState.pelangganAktifCount;

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
            icon: Icon(Icons.history, color: c.onSurfaceVariant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatUtangScreen()),
              );
            },
          ),
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
      body: utangState.isLoading && filteredPelanggan.isEmpty
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : ListView(
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
                            _formatCurrency(totalPiutang),
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
                                'Tersebar di $aktifCount pelanggan aktif',
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
                if (filteredPelanggan.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text(
                        'Belum ada pelanggan dengan kriteria pencarian ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.onSurfaceVariant),
                      ),
                    ),
                  )
                else
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
                        final inisial = item.nama.isNotEmpty ? item.nama[0].toUpperCase() : '?';
                        
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
                                  color: _getAvatarColor(item.nama, c),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  inisial,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getTextColor(item.nama, c),
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
                                      item.nama,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: c.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.totalUtang > 0 ? 'Ada utang belum lunas' : 'Utang lunas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: item.totalUtang > 0 ? c.statusCritical : c.primary,
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
                                    _formatCurrency(item.totalUtang),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: item.totalUtang > 0 ? c.statusCritical : c.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.totalUtang <= 0)
                                    InkWell(
                                      onTap: () => _showDeleteDialog(item.id, item.nama, c),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: c.statusCritical.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: c.statusCritical,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
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

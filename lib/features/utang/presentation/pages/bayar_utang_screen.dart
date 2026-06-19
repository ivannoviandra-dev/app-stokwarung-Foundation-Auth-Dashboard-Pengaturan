import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/pelanggan_model.dart';
import '../../data/models/utang_model.dart';
import '../providers/utang_provider.dart';

class BayarUtangScreen extends ConsumerStatefulWidget {
  final Pelanggan pelanggan;

  const BayarUtangScreen({super.key, required this.pelanggan});

  @override
  ConsumerState<BayarUtangScreen> createState() => _BayarUtangScreenState();
}

class _BayarUtangScreenState extends ConsumerState<BayarUtangScreen> {
  late TextEditingController _amountController;
  late TextEditingController _keteranganController;
  int _jumlahBayar = 0;
  String _metode = 'Tunai';
  String? _selectedChip;
  String _jenisTransaksi = 'bayar'; // 'bayar' atau 'utang'
  bool _isSaving = false;
  late Future<List<Utang>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = ref.read(utangProvider.notifier).fetchRiwayatUtang(widget.pelanggan.id);
    _amountController = TextEditingController();
    _keteranganController = TextEditingController();
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final parsed = int.tryParse(text) ?? 0;
      setState(() {
        _jumlahBayar = parsed;
        // Clear chip selection when user manually edits
        if (_selectedChip == 'lunas' && parsed != widget.pelanggan.totalUtang) {
          _selectedChip = null;
        } else if (_selectedChip == '50000' && parsed != 50000) {
          _selectedChip = null;
        } else if (_selectedChip == '100000' && parsed != 100000) {
          _selectedChip = null;
        } else if (_selectedChip == '200000' && parsed != 200000) {
          _selectedChip = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  void _setAmount(int amount, String chipKey) {
    setState(() {
      _selectedChip = chipKey;
    });
    _amountController.text = amount.toString();
    _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
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

  Future<void> _simpan() async {
    if (_jumlahBayar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah nominal yang valid')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(utangProvider.notifier).tambahCatatanUtang(
        pelangganId: widget.pelanggan.id,
        jumlah: _jumlahBayar,
        jenis: _jenisTransaksi,
        keterangan: _keteranganController.text.isEmpty ? null : _keteranganController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final inisial = widget.pelanggan.nama.isNotEmpty ? widget.pelanggan.nama[0].toUpperCase() : '?';
    
    // Get latest total utang from state just in case it updated
    final utangState = ref.watch(utangProvider);
    final currentPelanggan = utangState.pelangganList.firstWhere(
      (p) => p.id == widget.pelanggan.id, 
      orElse: () => widget.pelanggan
    );
    final totalUtang = currentPelanggan.totalUtang;

    int sisaUtang;
    if (_jenisTransaksi == 'bayar') {
      sisaUtang = (totalUtang - _jumlahBayar) < 0 ? 0 : (totalUtang - _jumlahBayar);
    } else {
      sisaUtang = totalUtang + _jumlahBayar;
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Catat Transaksi',
          style: TextStyle(
            color: c.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            children: [
              // Customer Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _getAvatarColor(widget.pelanggan.nama, c),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            inisial,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(widget.pelanggan.nama, c),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pelanggan.nama,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: c.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Terdaftar pada: ${widget.pelanggan.createdAt.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: c.outlineVariant),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL UTANG SAAT INI',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(totalUtang),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: totalUtang > 0 ? c.statusCritical : c.primary,
                              ),
                            ),
                          ],
                        ),
                        if (totalUtang > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.statusCritical.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Belum Lunas',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.statusCritical,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Transaction Type Toggle
              Row(
                children: [
                  Expanded(
                    child: _buildTypeToggle(context, 'Terima Pembayaran', 'bayar', Icons.arrow_downward),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeToggle(context, 'Tambah Utang', 'utang', Icons.arrow_upward),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input Section
              Text(
                'NOMINAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: c.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: c.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant, width: 2),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: c.onSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: c.onSurface,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Amount Chips
              if (_jenisTransaksi == 'bayar')
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (totalUtang > 0)
                        _buildChip(context, 'Bayar Lunas', () => _setAmount(totalUtang, 'lunas'), chipKey: 'lunas'),
                      if (totalUtang > 0) const SizedBox(width: 8),
                      _buildChip(context, 'Rp50.000', () => _setAmount(50000, '50000'), chipKey: '50000'),
                      const SizedBox(width: 8),
                      _buildChip(context, 'Rp100.000', () => _setAmount(100000, '100000'), chipKey: '100000'),
                      const SizedBox(width: 8),
                      _buildChip(context, 'Rp200.000', () => _setAmount(200000, '200000'), chipKey: '200000'),
                    ],
                  ),
                ),
              if (_jenisTransaksi == 'bayar') const SizedBox(height: 24),

              Text(
                'KETERANGAN (OPSIONAL)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: c.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _jenisTransaksi == 'bayar' ? 'Contoh: Bayar cicilan' : 'Contoh: Ambil rokok 2 bungkus',
                  filled: true,
                  fillColor: c.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary Card (Sisa Utang)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sisa Utang Nantinya',
                          style: TextStyle(
                            fontSize: 14,
                            color: c.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(sisaUtang),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sisaUtang == 0 && _jumlahBayar > 0 ? c.primaryContainer : c.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.calculate, color: c.outlineVariant),
                  ],
                ),
              ),
              
              if (_jenisTransaksi == 'bayar') ...[
                const SizedBox(height: 24),
                // Metode Pembayaran
                Text(
                  'METODE PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetodeCard(context, 'Tunai', Icons.payments),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetodeCard(context, 'QRIS', Icons.qr_code_2),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              Text(
                'RIWAYAT TRANSAKSI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: c.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Utang>>(
                future: _riwayatFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: CircularProgressIndicator(color: c.primary)));
                  }
                  if (snapshot.hasError) {
                    return Padding(padding: const EdgeInsets.all(16.0), child: Text('Error memuat riwayat', style: TextStyle(color: c.statusCritical)));
                  }
                  final riwayat = snapshot.data ?? [];
                  if (riwayat.isEmpty) {
                    return Padding(padding: const EdgeInsets.all(16.0), child: Text('Belum ada riwayat transaksi.', style: TextStyle(color: c.onSurfaceVariant)));
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: c.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.outlineVariant),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: riwayat.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: c.outlineVariant),
                      itemBuilder: (context, index) {
                        final item = riwayat[index];
                        final isBayar = item.jenis == 'bayar';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isBayar ? c.statusSuccess.withValues(alpha: 0.1) : c.statusCritical.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isBayar ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isBayar ? c.statusSuccess : c.statusCritical,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            isBayar ? 'Pembayaran' : 'Catat Utang',
                            style: TextStyle(fontWeight: FontWeight.bold, color: c.onSurface, fontSize: 14),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                item.tanggal.toLocal().toString().split('.')[0],
                                style: TextStyle(fontSize: 12, color: c.onSurfaceVariant),
                              ),
                              if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.keterangan!,
                                  style: TextStyle(fontSize: 12, color: c.onSurfaceVariant),
                                ),
                              ]
                            ],
                          ),
                          trailing: Text(
                            (isBayar ? '-' : '+') + _formatCurrency(item.jumlah),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBayar ? c.statusSuccess : c.statusCritical,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 100), // padding for bottom button
            ],
          ),
          
          // Fixed Action Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    c.background,
                    c.background.withValues(alpha: 0.9),
                    c.background.withValues(alpha: 0),
                  ],
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed: _isSaving ? null : _simpan,
                child: _isSaving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_jenisTransaksi == 'bayar' ? Icons.save : Icons.add_shopping_cart),
                        const SizedBox(width: 8),
                        Text('Simpan Transaksi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(BuildContext context, String label, String type, IconData icon) {
    final c = AppColors.of(context);
    final isSelected = _jenisTransaksi == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _jenisTransaksi = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? c.primaryContainer : c.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? c.primary : c.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? c.onPrimaryContainer : c.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? c.onPrimaryContainer : c.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, VoidCallback onTap, {required String chipKey}) {
    final c = AppColors.of(context);
    final isSelected = _selectedChip == chipKey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primaryContainer : c.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: c.primary, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? c.onPrimaryContainer : c.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildMetodeCard(BuildContext context, String label, IconData icon) {
    final c = AppColors.of(context);
    final isSelected = _metode == label;
    
    return InkWell(
      onTap: () {
        setState(() {
          _metode = label;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? c.primaryContainer.withValues(alpha: 0.1) : c.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? c.primary : c.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? c.primary : c.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? c.primary : c.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

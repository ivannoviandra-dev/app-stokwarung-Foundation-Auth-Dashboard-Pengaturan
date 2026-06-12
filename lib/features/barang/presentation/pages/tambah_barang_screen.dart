import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/barang_model.dart';
import '../providers/barang_provider.dart';

class TambahBarangScreen extends ConsumerStatefulWidget {
  const TambahBarangScreen({super.key});

  @override
  ConsumerState<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends ConsumerState<TambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokAwalController = TextEditingController();
  final _stokMinController = TextEditingController();

  String? _kategori;
  String? _satuan;
  DateTime? _tanggalKedaluwarsa;
  bool _isLoading = false;

  void dispose() {
    _namaController.dispose();
    _barcodeController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokAwalController.dispose();
    _stokMinController.dispose();
    super.dispose();
  }

  Future<void> _simpanBarang() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final barcode = _barcodeController.text.trim();
      final hargaBeli = int.tryParse(_hargaBeliController.text.trim()) ?? 0;
      final harga = int.tryParse(_hargaJualController.text.trim()) ?? 0;
      final stok = int.tryParse(_stokAwalController.text.trim()) ?? 0;
      final stokMin = int.tryParse(_stokMinController.text.trim()) ?? 10;
      final kategori = _kategori ?? 'Sembako';
      final satuan = _satuan;

      final newBarang = Barang(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        barcode: barcode,
        kategori: kategori,
        satuan: satuan,
        hargaBeli: hargaBeli,
        harga: harga,
        stok: stok,
        stokMinimum: stokMin,
        tanggalKedaluwarsa: _tanggalKedaluwarsa,
      );

      setState(() => _isLoading = true);

      try {
        await ref.read(barangProvider.notifier).tambahBarang(newBarang);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Barang "$nama" berhasil ditambahkan!'),
              backgroundColor: AppColors.of(context).statusSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan barang: $e'),
              backgroundColor: AppColors.of(context).statusCritical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildSectionHeader(AppColors c, IconData icon, String title, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: c.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    AppColors c, {
    required String label,
    required TextEditingController controller,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.onSurfaceVariant,
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 16, color: c.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: c.neutralSurface,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: 10,
              color: c.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    AppColors c, {
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.onSurfaceVariant,
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          style: TextStyle(fontSize: 14, color: c.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: c.neutralSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    String formatCurrency(int amount) {
      final str = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      return 'Rp$str';
    }

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Barang',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: c.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: c.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Informasi Dasar ──────────────────────────────────────────
              _buildSectionHeader(c, Icons.inventory_2, 'Informasi Dasar', c.primary),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      c,
                      label: 'Nama Barang',
                      controller: _namaController,
                      hintText: 'Contoh: Beras Pandan Wangi 5kg',
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      c,
                      label: 'Barcode / Kode SKU',
                      controller: _barcodeController,
                      hintText: 'Scan atau ketik kode',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code_scanner, color: c.primary),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            c,
                            label: 'Kategori',
                            value: _kategori,
                            items: [
                              'Sembako',
                              'Makanan',
                              'Minuman',
                              'Rokok',
                              'Kebutuhan Rumah',
                              'Lainnya'
                            ],
                            onChanged: (val) => setState(() => _kategori = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            c,
                            label: 'Satuan',
                            value: _satuan,
                            items: ['pcs', 'kg', 'liter', 'dus', 'pak'],
                            onChanged: (val) => setState(() => _satuan = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Atur Harga ───────────────────────────────────────────────
              _buildSectionHeader(c, Icons.payments, 'Atur Harga', c.secondary), // Secondary color
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            c,
                            label: 'Harga Beli',
                            controller: _hargaBeliController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            c,
                            label: 'Harga Jual',
                            controller: _hargaJualController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Wajib'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimasi Margin Laba:',
                            style: TextStyle(
                              fontSize: 12,
                              color: c.onSurfaceVariant,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_hargaBeliController, _hargaJualController]),
                            builder: (context, _) {
                              int beli = int.tryParse(
                                      _hargaBeliController.text.trim()) ??
                                  0;
                              int jual = int.tryParse(
                                      _hargaJualController.text.trim()) ??
                                  0;
                              int currentMargin = jual - beli;
                              
                              Color marginColor = c.onSurfaceVariant;
                              String prefix = '';
                              if (currentMargin > 0) {
                                marginColor = c.statusSuccess;
                                prefix = '+';
                              } else if (currentMargin < 0) {
                                marginColor = c.statusCritical;
                                prefix = '-';
                              }

                              return Text(
                                '$prefix${formatCurrency(currentMargin.abs())}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: marginColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Stok & Inventaris ────────────────────────────────────────
              _buildSectionHeader(c, Icons.analytics, 'Stok & Inventaris', c.tertiary), // Tertiary color
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            c,
                            label: 'Stok Awal',
                            controller: _stokAwalController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            c,
                            label: 'Stok Minimum',
                            controller: _stokMinController,
                            hintText: '5',
                            keyboardType: TextInputType.number,
                            helperText:
                                'Berikan peringatan jika stok di bawah angka ini.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Kedaluwarsa (Opsional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.onSurfaceVariant,
                            letterSpacing: 0.05,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggalKedaluwarsa ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _tanggalKedaluwarsa = picked);
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: c.neutralSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.outlineVariant),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _tanggalKedaluwarsa != null 
                                ? '${_tanggalKedaluwarsa!.day.toString().padLeft(2, '0')}/${_tanggalKedaluwarsa!.month.toString().padLeft(2, '0')}/${_tanggalKedaluwarsa!.year}'
                                : 'dd/mm/yyyy',
                              style: TextStyle(
                                color: _tanggalKedaluwarsa != null ? c.onSurface : c.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Decorative Card ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: c.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Optimalkan Bisnis Anda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: c.onPrimaryContainer,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistem akan otomatis memberikan laporan laba rugi untuk setiap barang yang Anda simpan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: c.onPrimaryContainer.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.trending_up,
                      size: 48,
                      color: c.onPrimaryContainer.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // padding for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: c.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: _isLoading ? null : _simpanBarang,
          child: _isLoading 
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    'Simpan Barang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

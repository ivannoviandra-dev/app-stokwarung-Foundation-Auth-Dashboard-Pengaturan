import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Colors based on the design
  static const primary = Color(0xFF006C49);
  static const surface = Color(0xFFF4FBF4);
  static const outlineVariant = Color(0xFFBBCABF);
  static const neutralSurface = Color(0xFFF8FAFC);
  static const onSurface = Color(0xFF161D19);
  static const onSurfaceVariant = Color(0xFF3C4A42);
  static const statusSuccess = Color(0xFF10B981);
  static const statusCritical = Color(0xFFEF4444);
  static const primaryContainer = Color(0xFF10B981);

  @override
  void dispose() {
    _namaController.dispose();
    _barcodeController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokAwalController.dispose();
    _stokMinController.dispose();
    super.dispose();
  }

  void _simpanBarang() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final harga = int.tryParse(_hargaJualController.text.trim()) ?? 0;
      final stok = int.tryParse(_stokAwalController.text.trim()) ?? 0;
      final stokMin = int.tryParse(_stokMinController.text.trim()) ?? 10;
      final kategori = _kategori ?? 'Sembako';

      final newBarang = Barang(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        kategori: kategori,
        harga: harga,
        stok: stok,
        stokMinimum: stokMin,
      );

      ref.read(barangProvider.notifier).tambahBarang(newBarang);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang "$nama" berhasil ditambahkan!'),
          backgroundColor: statusSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildSectionHeader(IconData icon, String title, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onSurfaceVariant,
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16, color: onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: neutralSurface,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 10,
              color: onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onSurfaceVariant,
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
          style: const TextStyle(fontSize: 14, color: onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: neutralSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formatCurrency(int amount) {
      final str = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      return 'Rp$str';
    }

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Barang',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: outlineVariant,
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
              _buildSectionHeader(Icons.inventory_2, 'Informasi Dasar', primary),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outlineVariant),
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
                      label: 'Nama Barang',
                      controller: _namaController,
                      hintText: 'Contoh: Beras Pandan Wangi 5kg',
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Barcode / Kode SKU',
                      controller: _barcodeController,
                      hintText: 'Scan atau ketik kode',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: primary),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
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
              _buildSectionHeader(Icons.payments, 'Atur Harga', const Color(0xFF006398)), // Secondary color
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outlineVariant),
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
                            label: 'Harga Beli',
                            controller: _hargaBeliController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: onSurfaceVariant,
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
                            label: 'Harga Jual',
                            controller: _hargaJualController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: onSurfaceVariant,
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
                        color: const Color(0xFFEEF6EE), // surface-container-low
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimasi Margin Laba:',
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurfaceVariant,
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
                              
                              Color marginColor = onSurfaceVariant;
                              String prefix = '';
                              if (currentMargin > 0) {
                                marginColor = statusSuccess;
                                prefix = '+';
                              } else if (currentMargin < 0) {
                                marginColor = statusCritical;
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
              _buildSectionHeader(Icons.analytics, 'Stok & Inventaris', const Color(0xFFA43A3A)), // Tertiary color
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outlineVariant),
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
                            label: 'Stok Awal',
                            controller: _stokAwalController,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
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
                        const Text(
                          'Tanggal Kedaluwarsa (Opsional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant,
                            letterSpacing: 0.05,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            // Visual implementation only for now
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: neutralSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: outlineVariant),
                            ),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'dd/mm/yyyy',
                              style: TextStyle(color: onSurfaceVariant),
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
                  color: primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Optimalkan Bisnis Anda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistem akan otomatis memberikan laporan laba rugi untuk setiap barang yang Anda simpan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.trending_up,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.2),
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
          color: surface,
          border: const Border(top: BorderSide(color: outlineVariant)),
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
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: _simpanBarang,
          child: const Row(
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

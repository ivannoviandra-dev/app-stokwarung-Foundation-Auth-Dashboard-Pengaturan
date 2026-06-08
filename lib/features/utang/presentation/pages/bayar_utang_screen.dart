import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BayarUtangScreen extends StatefulWidget {
  final Map<String, dynamic> pelanggan;

  const BayarUtangScreen({super.key, required this.pelanggan});

  @override
  State<BayarUtangScreen> createState() => _BayarUtangScreenState();
}

class _BayarUtangScreenState extends State<BayarUtangScreen> {
  late TextEditingController _amountController;
  late int _totalUtang;
  int _jumlahBayar = 0;
  String _metode = 'Tunai';

  @override
  void initState() {
    super.initState();
    _totalUtang = widget.pelanggan['utang'] as int;
    _amountController = TextEditingController();
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      setState(() {
        _jumlahBayar = int.tryParse(text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  void _setAmount(int amount) {
    _amountController.text = amount.toString();
    // Move cursor to end
    _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final int sisaUtang = (_totalUtang - _jumlahBayar) < 0 ? 0 : (_totalUtang - _jumlahBayar);

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
          'Bayar Utang',
          style: TextStyle(
            color: c.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: c.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
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
                            color: widget.pelanggan['bgColor'] as Color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.pelanggan['inisial'] as String,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.pelanggan['textColor'] as Color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pelanggan['nama'] as String,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: c.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pelanggan Setia',
                                style: TextStyle(
                                  fontSize: 14,
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
                              _formatCurrency(_totalUtang),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: c.statusCritical,
                              ),
                            ),
                          ],
                        ),
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

              // Input Section
              Text(
                'JUMLAH BAYAR',
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip(context, 'Bayar Lunas', () => _setAmount(_totalUtang), isPrimary: true),
                    const SizedBox(width: 8),
                    _buildChip(context, 'Rp50.000', () => _setAmount(50000)),
                    const SizedBox(width: 8),
                    _buildChip(context, 'Rp100.000', () => _setAmount(100000)),
                    const SizedBox(width: 8),
                    _buildChip(context, 'Rp200.000', () => _setAmount(200000)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Bayar cicilan pertama',
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
                  border: Border.all(color: c.outlineVariant, style: BorderStyle.solid), // Should be dashed, but we'll use solid to simplify
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
                onPressed: () {
                  if (_jumlahBayar <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan jumlah bayar yang valid')),
                    );
                    return;
                  }
                  
                  // Simulate success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembayaran berhasil disimpan!')),
                  );
                  Navigator.pop(context); // Go back
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Simpan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, VoidCallback onTap, {bool isPrimary = false}) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? c.primaryContainer : c.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isPrimary ? c.onPrimaryContainer : c.onSurfaceVariant,
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

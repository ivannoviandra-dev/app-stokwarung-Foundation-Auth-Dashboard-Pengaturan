import 'package:flutter/material.dart';

class RiwayatTransaksiScreen extends StatelessWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: const Center(
        child: Text('Halaman Riwayat Transaksi (Segera Hadir)'),
      ),
    );
  }
}

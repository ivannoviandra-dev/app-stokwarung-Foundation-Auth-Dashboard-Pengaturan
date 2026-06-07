import 'package:flutter/material.dart';

class ManajemenBarangScreen extends StatelessWidget {
  const ManajemenBarangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Barang'),
      ),
      body: const Center(
        child: Text('Halaman Daftar Barang (Segera Hadir)'),
      ),
    );
  }
}

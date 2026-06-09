import 'package:flutter/material.dart';

class PerluPerhatianScreen extends StatelessWidget {
  const PerluPerhatianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perlu Perhatian'),
      ),
      body: const Center(
        child: Text('Halaman Daftar Barang Perlu Perhatian (Segera Hadir)'),
      ),
    );
  }
}

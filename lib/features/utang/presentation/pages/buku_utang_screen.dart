import 'package:flutter/material.dart';

class BukuUtangScreen extends StatelessWidget {
  const BukuUtangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Utang Pelanggan'),
      ),
      body: const Center(
        child: Text('Halaman Buku Utang (Segera Hadir)'),
      ),
    );
  }
}

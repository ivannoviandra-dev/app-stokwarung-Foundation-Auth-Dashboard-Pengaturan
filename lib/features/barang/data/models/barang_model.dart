class Barang {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final int stok;
  final int stokMinimum;

  Barang({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.stokMinimum = 10,
  });

  /// Status stok: 'aman', 'rendah', atau 'kritis'
  String get statusStok {
    if (stok <= 0) return 'kritis';
    if (stok <= stokMinimum) return 'rendah';
    return 'aman';
  }

  Barang copyWith({
    String? id,
    String? nama,
    String? kategori,
    int? harga,
    int? stok,
    int? stokMinimum,
  }) {
    return Barang(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      stokMinimum: stokMinimum ?? this.stokMinimum,
    );
  }
}

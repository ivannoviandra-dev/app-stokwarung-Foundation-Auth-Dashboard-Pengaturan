class Barang {
  final String id;
  final String nama;
  final String? barcode;
  final String kategori;
  final String? satuan;
  final int hargaBeli;
  final int harga; // ini berfungsi sebagai harga jual
  final int stok;
  final int stokMinimum;
  final DateTime? tanggalKedaluwarsa;

  Barang({
    required this.id,
    required this.nama,
    this.barcode,
    required this.kategori,
    this.satuan,
    required this.hargaBeli,
    required this.harga,
    required this.stok,
    this.stokMinimum = 10,
    this.tanggalKedaluwarsa,
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
    String? barcode,
    String? kategori,
    String? satuan,
    int? hargaBeli,
    int? harga,
    int? stok,
    int? stokMinimum,
    DateTime? tanggalKedaluwarsa,
  }) {
    return Barang(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      barcode: barcode ?? this.barcode,
      kategori: kategori ?? this.kategori,
      satuan: satuan ?? this.satuan,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      stokMinimum: stokMinimum ?? this.stokMinimum,
      tanggalKedaluwarsa: tanggalKedaluwarsa ?? this.tanggalKedaluwarsa,
    );
  }

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      barcode: json['barcode'],
      kategori: json['kategori'] ?? '',
      satuan: json['satuan'],
      hargaBeli: json['harga_beli'] ?? 0,
      harga: json['harga'] ?? 0,
      stok: json['stok'] ?? 0,
      stokMinimum: json['stok_minimum'] ?? 10,
      tanggalKedaluwarsa: json['tanggal_kedaluwarsa'] != null 
          ? DateTime.tryParse(json['tanggal_kedaluwarsa'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
      'kategori': kategori,
      if (satuan != null && satuan!.isNotEmpty) 'satuan': satuan,
      'harga_beli': hargaBeli,
      'harga': harga,
      'stok': stok,
      'stok_minimum': stokMinimum,
      if (tanggalKedaluwarsa != null) 'tanggal_kedaluwarsa': tanggalKedaluwarsa!.toIso8601String(),
    };
  }
}

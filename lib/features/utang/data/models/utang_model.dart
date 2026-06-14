class Utang {
  final String id;
  final String pelangganId;
  final int jumlah;
  final String jenis; // 'utang' atau 'bayar'
  final String? keterangan;
  final DateTime tanggal;
  final DateTime createdAt;

  Utang({
    required this.id,
    required this.pelangganId,
    required this.jumlah,
    required this.jenis,
    this.keterangan,
    required this.tanggal,
    required this.createdAt,
  });

  Utang copyWith({
    String? id,
    String? pelangganId,
    int? jumlah,
    String? jenis,
    String? keterangan,
    DateTime? tanggal,
    DateTime? createdAt,
  }) {
    return Utang(
      id: id ?? this.id,
      pelangganId: pelangganId ?? this.pelangganId,
      jumlah: jumlah ?? this.jumlah,
      jenis: jenis ?? this.jenis,
      keterangan: keterangan ?? this.keterangan,
      tanggal: tanggal ?? this.tanggal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Utang.fromJson(Map<String, dynamic> json) {
    return Utang(
      id: json['id'].toString(),
      pelangganId: json['pelanggan_id'].toString(),
      jumlah: json['jumlah'] ?? 0,
      jenis: json['jenis'] ?? 'utang',
      keterangan: json['keterangan'],
      tanggal: DateTime.parse(json['tanggal'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'pelanggan_id': pelangganId,
      'jumlah': jumlah,
      'jenis': jenis,
      if (keterangan != null) 'keterangan': keterangan,
      'tanggal': tanggal.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

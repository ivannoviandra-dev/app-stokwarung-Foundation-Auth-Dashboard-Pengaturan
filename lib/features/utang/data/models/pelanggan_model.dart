class Pelanggan {
  final String id;
  final String userId;
  final String nama;
  final String? noHp;
  final DateTime createdAt;
  final int totalUtang; // Not a direct table column, but useful for state

  Pelanggan({
    required this.id,
    required this.userId,
    required this.nama,
    this.noHp,
    required this.createdAt,
    this.totalUtang = 0,
  });

  Pelanggan copyWith({
    String? id,
    String? userId,
    String? nama,
    String? noHp,
    DateTime? createdAt,
    int? totalUtang,
  }) {
    return Pelanggan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      createdAt: createdAt ?? this.createdAt,
      totalUtang: totalUtang ?? this.totalUtang,
    );
  }

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      nama: json['nama'] ?? '',
      noHp: json['no_hp'],
      createdAt: DateTime.parse(json['created_at'].toString()),
      totalUtang: json['total_utang'] != null ? int.tryParse(json['total_utang'].toString()) ?? 0 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'nama': nama,
      if (noHp != null) 'no_hp': noHp,
      // created_at usually handled by DB, but we can include it
      'created_at': createdAt.toIso8601String(),
    };
  }
}

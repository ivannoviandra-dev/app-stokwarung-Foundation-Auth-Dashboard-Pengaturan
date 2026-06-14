class Transaksi {
  final String id;
  final String userId;
  final int total;
  final String metode;
  final String? namaPelanggan;
  final String? catatan;
  final DateTime createdAt;
  final List<TransaksiItem> items;

  Transaksi({
    required this.id,
    required this.userId,
    required this.total,
    required this.metode,
    this.namaPelanggan,
    this.catatan,
    required this.createdAt,
    this.items = const [],
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    List<TransaksiItem> items = [];
    if (json['transaksi_item'] != null) {
      items = (json['transaksi_item'] as List)
          .map((e) => TransaksiItem.fromJson(e))
          .toList();
    }

    return Transaksi(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      total: json['total'] ?? 0,
      metode: json['metode'] ?? 'Tunai',
      namaPelanggan: json['nama_pelanggan'],
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at'].toString()),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total': total,
      'metode': metode,
      if (namaPelanggan != null) 'nama_pelanggan': namaPelanggan,
      if (catatan != null) 'catatan': catatan,
    };
  }
}

class TransaksiItem {
  final String id;
  final String transaksiId;
  final String? barangId;
  final String namaBarang;
  final int harga;
  final int hargaModal;
  final int qty;
  final int subtotal;
  final DateTime createdAt;

  TransaksiItem({
    required this.id,
    required this.transaksiId,
    this.barangId,
    required this.namaBarang,
    required this.harga,
    required this.hargaModal,
    required this.qty,
    required this.subtotal,
    required this.createdAt,
  });

  factory TransaksiItem.fromJson(Map<String, dynamic> json) {
    return TransaksiItem(
      id: json['id'].toString(),
      transaksiId: json['transaksi_id'].toString(),
      barangId: json['barang_id']?.toString(),
      namaBarang: json['nama_barang'] ?? '',
      harga: json['harga'] ?? 0,
      hargaModal: json['harga_modal'] ?? 0,
      qty: json['qty'] ?? 1,
      subtotal: json['subtotal'] ?? 0,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaksi_id': transaksiId,
      if (barangId != null) 'barang_id': barangId,
      'nama_barang': namaBarang,
      'harga': harga,
      'harga_modal': hargaModal,
      'qty': qty,
      'subtotal': subtotal,
    };
  }
}

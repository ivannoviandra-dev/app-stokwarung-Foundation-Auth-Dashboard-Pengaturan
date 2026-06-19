import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service untuk berkomunikasi dengan Midtrans Snap API (Sandbox).
///
/// CATATAN: Server Key di-hardcode di sini hanya untuk sandbox/development.
/// Untuk production, request Snap Token HARUS dilakukan di backend (server-side).
class MidtransService {
  // Sandbox credentials (Dihapus untuk di-push ke GitHub karena secret protection)
  static const String _serverKey = 'YOUR_MIDTRANS_SERVER_KEY';
  static const String _clientKey = 'YOUR_MIDTRANS_CLIENT_KEY';

  // Sandbox Snap API endpoint
  static const String _snapApiUrl =
      'https://app.sandbox.midtrans.com/snap/v1/transactions';

  /// Membuat Snap Token untuk transaksi pembayaran.
  ///
  /// [orderId] — ID unik untuk order ini.
  /// [grossAmount] — Total harga dalam Rupiah (integer).
  /// [items] — Daftar item belanjaan.
  /// [customerName] — Nama pelanggan (opsional).
  ///
  /// Return Map berisi 'token' dan 'redirect_url'.
  static Future<Map<String, String>> createSnapToken({
    required String orderId,
    required int grossAmount,
    required List<Map<String, dynamic>> items,
    String? customerName,
  }) async {
    // Basic Auth header: Base64 encode dari "ServerKey:"
    final authString = base64Encode(utf8.encode('$_serverKey:'));

    final body = {
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': grossAmount,
      },
      'item_details': items.map((item) {
        return {
          'id': item['id']?.toString() ?? 'item',
          'price': item['harga'] as int,
          'quantity': item['qty'] as int,
          'name': _truncateName(item['nama'] as String),
        };
      }).toList(),
      if (customerName != null)
        'customer_details': {
          'first_name': customerName,
        },
      'credit_card': {
        'secure': true,
      },
    };

    final response = await http.post(
      Uri.parse(_snapApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Basic $authString',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'token': data['token'] as String,
        'redirect_url': data['redirect_url'] as String,
      };
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMsg = errorBody['error_messages'] is List
          ? (errorBody['error_messages'] as List).join(', ')
          : response.body;
      throw Exception('Gagal membuat Snap Token: $errorMsg');
    }
  }

  /// Midtrans membatasi nama item maksimal 50 karakter.
  static String _truncateName(String name) {
    if (name.length > 50) {
      return '${name.substring(0, 47)}...';
    }
    return name;
  }

  /// Client key (dibutuhkan untuk Snap.js, tapi kita pakai redirect URL).
  static String get clientKey => _clientKey;
}

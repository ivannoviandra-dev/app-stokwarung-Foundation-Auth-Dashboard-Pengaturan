import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

// Conditional imports for web JS interop
import 'midtrans_web_stub.dart'
    if (dart.library.js_interop) 'midtrans_web_impl.dart'
    as midtrans_web;

/// Service untuk berkomunikasi dengan Midtrans Snap API (Sandbox).
///
/// - Di **Web**: Menggunakan Snap.js popup (menghindari CORS).
/// - Di **Mobile**: Menggunakan HTTP API langsung ke Snap endpoint.
///
/// CATATAN: Server Key di-hardcode di sini hanya untuk sandbox/development.
/// Untuk production, request Snap Token HARUS dilakukan di backend (server-side).
class MidtransService {
  // Sandbox credentials
  static String get _serverKey => 'YOUR_SERVER_KEY'; // GANTI DENGAN SERVER KEY ANDA
  static String get _clientKey => 'Mid-client-CyW1GyJqKIUCur1n';

  // Sandbox Snap API endpoint
  static const String _snapApiUrl =
      'https://app.sandbox.midtrans.com/snap/v1/transactions';

  /// Membuat Snap Token untuk transaksi pembayaran.
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
      'transaction_details': {'order_id': orderId, 'gross_amount': grossAmount},
      'item_details': items.map((item) {
        return {
          'id': item['id']?.toString() ?? 'item',
          'price': item['harga'] as int,
          'quantity': item['qty'] as int,
          'name': _truncateName(item['nama'] as String),
        };
      }).toList(),
      if (customerName != null)
        'customer_details': {'first_name': customerName},
      'credit_card': {'secure': true},
    };

    debugPrint('[Midtrans] Creating Snap Token for order: $orderId, amount: $grossAmount');
    debugPrint('[Midtrans] DEBUG _serverKey: "$_serverKey" (length: ${_serverKey.length})');
    debugPrint('[Midtrans] DEBUG authString: "$authString"');
    debugPrint('[Midtrans] DEBUG URL: $_snapApiUrl');

    final response = await http.post(
      Uri.parse(_snapApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Basic $authString',
      },
      body: jsonEncode(body),
    );

    debugPrint('[Midtrans] Response status: ${response.statusCode}');
    debugPrint('[Midtrans] Response body: ${response.body}');

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

  /// Buka popup Snap.js di Web. Return status: 'success', 'pending', 'error', 'close'.
  /// Hanya bisa digunakan di Flutter Web.
  static Future<String> openSnapPopup(String snapToken) {
    if (!kIsWeb) {
      throw UnsupportedError(
        'openSnapPopup hanya bisa digunakan di Flutter Web',
      );
    }
    return midtrans_web.openSnapPopup(snapToken);
  }

  /// Midtrans membatasi nama item maksimal 50 karakter.
  static String _truncateName(String name) {
    if (name.length > 50) {
      return '${name.substring(0, 47)}...';
    }
    return name;
  }

  /// Client key getter.
  static String get clientKey => _clientKey;
}

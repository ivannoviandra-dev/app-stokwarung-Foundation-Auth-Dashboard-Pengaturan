import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

/// Hasil pembayaran dari Midtrans WebView.
enum MidtransPaymentStatus {
  success,
  pending,
  failed,
  cancelled,
}

/// Screen yang menampilkan halaman pembayaran Midtrans Snap di WebView.
///
/// Mendeteksi callback URL dari Midtrans untuk menentukan status pembayaran.
/// Return [MidtransPaymentStatus] ke screen pemanggil via Navigator.pop().
class MidtransPaymentScreen extends StatefulWidget {
  final String redirectUrl;
  final String orderId;
  final int totalAmount;

  const MidtransPaymentScreen({
    super.key,
    required this.redirectUrl,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
              });
              _checkPaymentStatus(url);
            },
            onPageFinished: (url) {
              setState(() {
                _isLoading = false;
              });
            },
            onNavigationRequest: (request) {
              _checkPaymentStatus(request.url);
              return NavigationDecision.navigate;
            },
            onWebResourceError: (error) {
              // Tangani error loading
              debugPrint('WebView error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.redirectUrl));
    } else {
      // Untuk Web, buka di tab baru segera setelah initState selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchUrlForWeb();
      });
    }
  }

  Future<void> _launchUrlForWeb() async {
    final uri = Uri.parse(widget.redirectUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() {
        _isLoading = false;
      });
    } else {
      debugPrint('Could not launch $uri');
    }
  }

  /// Cek URL untuk mendeteksi status pembayaran dari callback Midtrans.
  void _checkPaymentStatus(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final lowerUrl = url.toLowerCase();

    // Midtrans Sandbox redirect URLs after payment:
    // Success: contains "status_code=200" or "transaction_status=settlement" or "transaction_status=capture"
    // Pending: contains "status_code=201" or "transaction_status=pending"
    // Error/Deny: contains "status_code=202" or "transaction_status=deny" or "transaction_status=cancel" or "transaction_status=expire"

    // Juga detect finish URL patterns dari Midtrans
    if (lowerUrl.contains('transaction_status=capture') ||
        lowerUrl.contains('transaction_status=settlement') ||
        (uri.queryParameters['status_code'] == '200' &&
            uri.queryParameters['transaction_status'] != null)) {
      _finishPayment(MidtransPaymentStatus.success);
    } else if (lowerUrl.contains('transaction_status=pending') ||
        uri.queryParameters['status_code'] == '201') {
      _finishPayment(MidtransPaymentStatus.pending);
    } else if (lowerUrl.contains('transaction_status=deny') ||
        lowerUrl.contains('transaction_status=cancel') ||
        lowerUrl.contains('transaction_status=expire') ||
        uri.queryParameters['status_code'] == '202' ||
        uri.queryParameters['status_code'] == '203') {
      _finishPayment(MidtransPaymentStatus.failed);
    }

    // Detect Midtrans example finish URLs
    if (lowerUrl.contains('example.com')) {
      if (lowerUrl.contains('finish') || lowerUrl.contains('callback')) {
        // Parse the transaction status from the URL params
        final status = uri.queryParameters['transaction_status'];
        if (status == 'settlement' || status == 'capture') {
          _finishPayment(MidtransPaymentStatus.success);
        } else if (status == 'pending') {
          _finishPayment(MidtransPaymentStatus.pending);
        } else {
          _finishPayment(MidtransPaymentStatus.failed);
        }
      }
    }
  }

  void _finishPayment(MidtransPaymentStatus status) {
    if (mounted) {
      Navigator.pop(context, status);
    }
  }

  String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: c.onSurface),
          onPressed: () => _showCancelDialog(context, c),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembayaran Midtrans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: c.onSurface,
              ),
            ),
            Text(
              _formatCurrency(widget.totalAmount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.primary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: _isLoading && !kIsWeb
              ? LinearProgressIndicator(
                  color: c.primary,
                  backgroundColor: c.surfaceContainerHighest,
                  minHeight: 3,
                )
              : Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: kIsWeb ? _buildWebUI(c) : WebViewWidget(controller: _controller),
    );
  }

  Widget _buildWebUI(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_new, size: 64, color: c.primary),
            const SizedBox(height: 24),
            Text(
              'Pembayaran dibuka di tab baru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Selesaikan pembayaran di halaman Midtrans.\nLalu konfirmasi di sini setelah selesai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: c.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _finishPayment(MidtransPaymentStatus.success),
              child: const Text('Saya Sudah Bayar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: c.primary,
                side: BorderSide(color: c.primary),
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _launchUrlForWeb,
              child: const Text('Buka Ulang Halaman Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppColors c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: c.tertiary, size: 28),
            const SizedBox(width: 8),
            const Text('Batalkan Pembayaran?'),
          ],
        ),
        content: const Text(
          'Pembayaran belum selesai. Apakah Anda yakin ingin membatalkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Lanjutkan Bayar', style: TextStyle(color: c.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c.tertiary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context, MidtransPaymentStatus.cancelled); // close webview
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

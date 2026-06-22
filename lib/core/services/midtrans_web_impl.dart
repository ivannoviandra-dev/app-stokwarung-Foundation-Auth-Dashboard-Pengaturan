import 'dart:async';
import 'dart:js_interop';

/// Implementasi web yang memanggil fungsi JavaScript `openMidtransSnap`
/// yang sudah didefinisikan di index.html.
///
/// Snap.js akan menampilkan popup pembayaran Midtrans langsung di browser.
Future<String> openSnapPopup(String snapToken) {
  final completer = Completer<String>();

  _openMidtransSnap(
    snapToken.toJS,
    // onSuccess
    ((JSString result) {
      completer.complete('success');
    }).toJS,
    // onPending
    ((JSString result) {
      completer.complete('pending');
    }).toJS,
    // onError
    ((JSString result) {
      completer.complete('error');
    }).toJS,
    // onClose
    (() {
      if (!completer.isCompleted) {
        completer.complete('close');
      }
    }).toJS,
  );

  return completer.future;
}

/// Binding ke fungsi JavaScript global `openMidtransSnap` di index.html.
@JS('openMidtransSnap')
external void _openMidtransSnap(
  JSString token,
  JSFunction onSuccess,
  JSFunction onPending,
  JSFunction onError,
  JSFunction onClose,
);

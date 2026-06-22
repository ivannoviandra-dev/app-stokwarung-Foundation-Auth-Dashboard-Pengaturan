/// Stub implementation untuk platform non-web (mobile/desktop).
/// Fungsi ini tidak akan pernah dipanggil di mobile karena
/// MidtransService.openSnapPopup() sudah di-guard dengan kIsWeb check.
Future<String> openSnapPopup(String snapToken) {
  throw UnsupportedError('Snap.js popup tidak tersedia di platform ini');
}

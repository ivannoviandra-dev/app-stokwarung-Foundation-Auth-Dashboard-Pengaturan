import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/laporan_provider.dart';

class PdfService {
  static Future<void> generateAndPrintLaporan({
    required String namaWarung,
    required LaporanData data,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(namaWarung),
            pw.SizedBox(height: 24),
            _buildRingkasan(data),
            pw.SizedBox(height: 32),
            _buildBarangTerlaris(data.barangTerlaris),
            pw.SizedBox(height: 32),
            _buildMarginTertinggi(data.marginTertinggi),
          ];
        },
      ),
    );

    // Tampilkan dialog print/share PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_$namaWarung.pdf',
    );
  }

  static pw.Widget _buildHeader(String namaWarung) {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Laporan Keuangan',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          namaWarung,
          style: pw.TextStyle(fontSize: 16, color: PdfColors.teal700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Tanggal Cetak: $dateStr',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildRingkasan(LaporanData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.teal200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Ringkasan Bulan Ini', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Laba Bersih', _formatCurrency(data.labaBersihBulanIni), isHighlight: true),
              _buildSummaryItem('Total Penjualan', _formatCurrency(data.totalPenjualan)),
              _buildSummaryItem('Total Modal', _formatCurrency(data.totalModal)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String title, String value, {bool isHighlight = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isHighlight ? 20 : 16,
            fontWeight: pw.FontWeight.bold,
            color: isHighlight ? PdfColors.teal900 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBarangTerlaris(List<ItemStat> items) {
    if (items.isEmpty) {
      return pw.Text('Belum ada data barang terlaris.', style: const pw.TextStyle(color: PdfColors.grey600));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Barang Terlaris', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(8),
          headers: ['No', 'Nama Barang', 'Jumlah Terjual'],
          data: List<List<String>>.generate(items.length, (i) {
            return [(i + 1).toString(), items[i].nama, items[i].nilai];
          }),
        ),
      ],
    );
  }

  static pw.Widget _buildMarginTertinggi(List<ItemStat> items) {
    if (items.isEmpty) {
      return pw.Text('Belum ada data margin.', style: const pw.TextStyle(color: PdfColors.grey600));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Margin Tertinggi', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(8),
          headers: ['No', 'Nama Barang', 'Keuntungan/Pcs'],
          data: List<List<String>>.generate(items.length, (i) {
            return [(i + 1).toString(), items[i].nama, items[i].nilai];
          }),
        ),
      ],
    );
  }

  static String _formatCurrency(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }
}

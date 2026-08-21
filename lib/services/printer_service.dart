import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/database_helper.dart';
import '../models/bill.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Builds a thermal-receipt-formatted PDF and hands it to Android's system
/// print framework (Printing.layoutPdf / Printing.sharePdf). This works
/// completely offline with any printer registered on the device as a print
/// service, including most Bluetooth and USB thermal printers that ship an
/// Android print-service driver — no internet or cloud print is used.
class PrinterService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<double> _pageWidthPoints() async {
    final widthMm = double.tryParse(await _db.getSetting(AppConstants.keyPrinterWidth) ?? '58') ?? 58;
    // 1mm = 2.834645669 points
    return widthMm * 2.834645669;
  }

  Future<Uint8List> buildReceiptPdf(Bill bill) async {
    final shopName = await _db.getSetting(AppConstants.keyShopName) ?? AppConstants.appName;
    final pageWidth = await _pageWidthPoints();
    final doc = pw.Document();

    final dateStr = bill.billDate.split('-').reversed.join('-'); // yyyy-mm-dd -> dd-mm-yyyy
    final formattedDate = _reformatDate(bill.billDate);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, double.infinity, marginAll: 8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  shopName,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(AppConstants.appSubtitle, style: const pw.TextStyle(fontSize: 9)),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.Text('Bill No: ${bill.billNumber}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Time: ${bill.billTime}', style: const pw.TextStyle(fontSize: 9)),
              pw.Divider(thickness: 1),
              pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.Text('ITEM', style: _headStyle)),
                  pw.Expanded(flex: 2, child: pw.Text('QTY', style: _headStyle, textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 3, child: pw.Text('PRICE', style: _headStyle, textAlign: pw.TextAlign.right)),
                  pw.Expanded(flex: 3, child: pw.Text('TOTAL', style: _headStyle, textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(thickness: 0.5),
              ...bill.items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 4, child: pw.Text(item.dishName, style: _rowStyle)),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text('${item.quantity}', style: _rowStyle, textAlign: pw.TextAlign.center)),
                        pw.Expanded(
                            flex: 3,
                            child: pw.Text(Formatters.currencyNoSymbol(item.price),
                                style: _rowStyle, textAlign: pw.TextAlign.right)),
                        pw.Expanded(
                            flex: 3,
                            child: pw.Text(Formatters.currencyNoSymbol(item.total),
                                style: _rowStyle, textAlign: pw.TextAlign.right)),
                      ],
                    ),
                  )),
              pw.Divider(thickness: 1),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(Formatters.currencyNoSymbol(bill.grandTotal),
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),
              pw.Center(child: pw.Text('Thank You!', style: const pw.TextStyle(fontSize: 10))),
              pw.Center(child: pw.Text('Visit Again', style: const pw.TextStyle(fontSize: 9))),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static final _headStyle = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
  static const _rowStyle = pw.TextStyle(fontSize: 9);

  String _reformatDate(String ymd) {
    final parts = ymd.split('-'); // yyyy-mm-dd
    if (parts.length != 3) return ymd;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  /// Opens Android's native print dialog (shows any Bluetooth/USB/Wi-Fi
  /// printer already paired/configured as a system print service).
  Future<void> printBill(Bill bill) async {
    final pdfBytes = await buildReceiptPdf(bill);
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  /// Lets the user save/share the receipt as a PDF via Android's share sheet.
  Future<void> shareBillPdf(Bill bill) async {
    final pdfBytes = await buildReceiptPdf(bill);
    await Printing.sharePdf(bytes: pdfBytes, filename: '${bill.billNumber}.pdf');
  }
}

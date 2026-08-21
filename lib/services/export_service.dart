import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import '../models/bill.dart';
import '../utils/formatters.dart';

/// Exports sales data to CSV/TXT files stored in the app's own external
/// files directory (Android scoped storage — no broad storage permission
/// needed on Android 10+), and lets the user share/save them anywhere via
/// the system share sheet or file picker.
class ExportService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Returns the app-accessible folder used for all exports/backups.
  /// On Android this resolves to a path like:
  /// /storage/emulated/0/Android/data/<package>/files
  /// which the app can read/write without runtime storage permissions.
  Future<Directory> _exportDir() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final salesDir = Directory('${dir.path}/SIK_Sales');
    if (!await salesDir.exists()) {
      await salesDir.create(recursive: true);
    }
    return salesDir;
  }

  List<List<dynamic>> _billsToRows(List<Bill> bills) {
    final rows = <List<dynamic>>[
      ['Bill No', 'Date', 'Time', 'Item', 'Quantity', 'Price', 'Total'],
    ];
    for (final bill in bills) {
      for (final item in bill.items) {
        rows.add([
          bill.billNumber,
          _reformatDate(bill.billDate),
          bill.billTime,
          item.dishName,
          item.quantity,
          item.price,
          item.total,
        ]);
      }
    }
    return rows;
  }

  String _reformatDate(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<List<Bill>> _withItems(List<Bill> bills) async {
    final full = <Bill>[];
    for (final b in bills) {
      full.add(await _db.getBillWithItems(b.id!));
    }
    return full;
  }

  /// Exports the given bills as a CSV file and returns the saved File.
  Future<File> exportCsv(List<Bill> bills, String label) async {
    final fullBills = await _withItems(bills);
    final rows = _billsToRows(fullBills);
    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await _exportDir();
    final file = File('${dir.path}/SIK_Sales_$label.csv');
    await file.writeAsString(csvString);
    return file;
  }

  /// Exports the given bills as a plain TXT receipt-style file.
  Future<File> exportTxt(List<Bill> bills, String label) async {
    final fullBills = await _withItems(bills);
    final buffer = StringBuffer();
    for (final bill in fullBills) {
      buffer.writeln('Bill No: ${bill.billNumber}');
      buffer.writeln('Date: ${_reformatDate(bill.billDate)}  Time: ${bill.billTime}');
      buffer.writeln('-' * 32);
      for (final item in bill.items) {
        buffer.writeln(
            '${item.dishName.padRight(14)} x${item.quantity}  ${Formatters.currency(item.total)}');
      }
      buffer.writeln('TOTAL: ${Formatters.currency(bill.grandTotal)}');
      buffer.writeln('=' * 32);
      buffer.writeln();
    }
    final dir = await _exportDir();
    final file = File('${dir.path}/SIK_Sales_$label.txt');
    await file.writeAsString(buffer.toString());
    return file;
  }

  /// Automatic end-of-day export, called once per day (see main.dart /
  /// todays_sales screen) so a CSV backup always exists for that date even
  /// if the admin never taps "Save Sales File" manually.
  Future<File?> autoExportForDate(DateTime date) async {
    final start = Formatters.startOfDay(date);
    final end = Formatters.endOfDay(date);
    final bills = await _db.getBillsBetween(start, end);
    if (bills.isEmpty) return null;
    return exportCsv(bills, Formatters.dateForFile(date));
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'SIK Sales Export');
  }
}

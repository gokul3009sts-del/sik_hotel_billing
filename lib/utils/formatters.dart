import 'package:intl/intl.dart';
import '../utils/constants.dart';

class Formatters {
  static String currency(num value) {
    return '\u20B9${value.toStringAsFixed(2)}';
  }

  static String currencyNoSymbol(num value) {
    return value.toStringAsFixed(2);
  }

  static String dateForDisplay(DateTime dt) {
    return DateFormat('dd-MM-yyyy').format(dt);
  }

  static String timeForDisplay(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String dateForFile(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  /// Returns start/end of the given day (local time) as ISO strings,
  /// used for querying "today's" or "selected date's" bills.
  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  static String formatBillNumber(int number) {
    return '${AppConstants.billPrefix}${number.toString().padLeft(AppConstants.billNumberPadding, '0')}';
  }
}

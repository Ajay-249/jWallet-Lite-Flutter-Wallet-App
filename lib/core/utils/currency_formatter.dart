import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _inrFormatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final f = NumberFormat('#,##,##0.00', 'en_IN');
    return f.format(amount);
  }
}

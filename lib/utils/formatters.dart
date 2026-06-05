import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static String currency(num amount) {
    return _currencyFormat.format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  static String formatIndianNumber(int number) {
    return NumberFormat.decimalPattern('en_IN').format(number);
  }
}

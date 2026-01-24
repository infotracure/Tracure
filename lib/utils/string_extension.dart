import 'package:intl/intl.dart';

extension StringNumberFormat on String {
  String toFormattedNumber() {
    if (isEmpty) return this;

    final number = int.tryParse(this);
    if (number == null) return this;

    final formatter = NumberFormat.decimalPattern(); // adds commas based on locale
    return formatter.format(number);
  }
}
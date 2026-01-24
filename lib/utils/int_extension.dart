import 'package:intl/intl.dart';

extension NullableIntNumberFormat on int? {
  String toFormattedNumber() {
    if (this == null) return '';
    final formatter =
        NumberFormat.decimalPattern(); // adds commas based on locale
    return formatter.format(this);
  }
}

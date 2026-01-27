import 'package:intl/intl.dart';

extension NullableIntNumberFormat on int? {
  String toFormattedNumber() {
    if (this == null) return '';
    final formatter =
        NumberFormat.decimalPattern(); // adds commas based on locale
    return formatter.format(this);
  }

  String toTimeFormat() {
    if (this == null || this! <= 0) return '0min';
    final minutes = this!;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }
}

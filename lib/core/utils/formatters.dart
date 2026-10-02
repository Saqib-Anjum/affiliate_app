import "package:intl/intl.dart";

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(symbol: r"$", decimalDigits: 0);
  static final _date = DateFormat("MMM d, yyyy");
  static final _dateTime = DateFormat("MMM d, yyyy • h:mm a");
  static final _time = DateFormat("h:mm a");

  static String currency(num? amount, {String? code}) {
    final value = amount ?? 0;
    final formatted = _currency.format(value);
    return code != null && code != "USD" ? "$formatted $code" : formatted;
  }

  static String date(DateTime? value) => value == null ? "—" : _date.format(value);

  static String dateTime(DateTime? value) => value == null ? "—" : _dateTime.format(value);

  static String time(DateTime? value) => value == null ? "—" : _time.format(value);

  static String duration(int? totalSeconds) {
    if (totalSeconds == null) return "—";
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes}m ${seconds}s";
  }

  static String statusLabel(String status) {
    return status
        .split("_")
        .map((word) => word.isEmpty ? word : "${word[0].toUpperCase()}${word.substring(1)}")
        .join(" ");
  }
}

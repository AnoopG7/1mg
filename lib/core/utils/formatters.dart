import 'package:intl/intl.dart';

class Fmt {
  const Fmt._();

  static final NumberFormat _rupee = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _rupee2 = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// ₹499  (drops the decimals when the amount is whole)
  static String money(num value) {
    if (value == value.roundToDouble()) return _rupee.format(value);
    return _rupee2.format(value);
  }

  /// Always two decimals — used in price-comparison breakdowns.
  static String moneyPrecise(num value) => _rupee2.format(value);

  static String percent(num value) => '${value.round()}%';

  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);

  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);

  static String dateTime(DateTime d) => DateFormat('d MMM, h:mm a').format(d);

  static String time(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, h, m));
  }

  /// "2h ago", "3 days ago", "12 Mar"
  static String relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return DateFormat('d MMM').format(d);
  }

  /// "in 3 days", "today"
  static String untilDay(DateTime d) {
    final today = DateTime.now();
    final diff = DateTime(d.year, d.month, d.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'tomorrow';
    if (diff < 0) return 'ended';
    return 'in $diff days';
  }

  static String compact(int n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

import 'package:intl/intl.dart';

/// Unified price formatting utility for the entire app.
/// Formats numbers with thousands separators and optional decimals.
class PriceFormatter {
  PriceFormatter._();

  static final _formatter = NumberFormat('#,###', 'en');
  static final _formatterDecimal = NumberFormat('#,###.##', 'en');

  /// Format a price value with thousands separators.
  /// e.g. 1000000 → "1,000,000"
  static String format(dynamic price, {bool showDecimals = false}) {
    if (price == null) return '0';
    final num value;
    if (price is num) {
      value = price;
    } else {
      value = num.tryParse(price.toString()) ?? 0;
    }
    if (showDecimals) {
      return _formatterDecimal.format(value);
    }
    return _formatter.format(value.round());
  }

  /// Format with currency suffix. e.g. "1,000,000 EGP"
  static String withCurrency(dynamic price, String currency,
      {bool showDecimals = false}) {
    return '${format(price, showDecimals: showDecimals)} $currency';
  }
}

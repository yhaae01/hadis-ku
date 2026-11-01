/// Format angka dengan pemisah ribuan gaya Indonesia: 6638 -> 6.638.
String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${value < 0 ? '-' : ''}$buffer';
}

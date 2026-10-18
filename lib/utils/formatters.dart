// Owner: Louis | FR: FR-03, FR-04

/// Memformat integer ke format mata uang Rupiah standar ('Rp 25.000').
/// Pilihan format angka negatif: '-Rp 25.000' (tanda minus ditempatkan di depan prefix).
String formatRupiah(int amount) {
  final isNegative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  final length = digits.length;

  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  final formattedNumber = buffer.toString();
  return isNegative ? '-Rp $formattedNumber' : 'Rp $formattedNumber';
}

/// Memformat DateTime ke representasi tanggal saja 'YYYY-MM-DD'.
String dateOnly(DateTime date) {
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

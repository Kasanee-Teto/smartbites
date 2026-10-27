import 'package:budget_bites/utils/formatters.dart';
import 'package:budget_bites/utils/responsive_breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('windowSizeFor pure function tests', () {
    test('resolves WindowSize.compact below 600 dp', () {
      expect(windowSizeFor(359), WindowSize.compact);
      expect(windowSizeFor(599), WindowSize.compact);
    });

    test('resolves WindowSize.medium between 600 and 839 dp', () {
      expect(windowSizeFor(600), WindowSize.medium);
      expect(windowSizeFor(839), WindowSize.medium);
    });

    test('resolves WindowSize.expanded at 840 dp and above', () {
      expect(windowSizeFor(840), WindowSize.expanded);
      expect(windowSizeFor(1024), WindowSize.expanded);
    });
  });

  group('formatRupiah pure function tests', () {
    test('formats zero correctly', () {
      expect(formatRupiah(0), 'Rp 0');
    });

    test('formats hundreds without separator', () {
      expect(formatRupiah(999), 'Rp 999');
    });

    test('formats thousands with dot separator', () {
      expect(formatRupiah(1000), 'Rp 1.000');
    });

    test('formats millions with multiple dot separators', () {
      expect(formatRupiah(1500000), 'Rp 1.500.000');
    });

    test('formats negative amounts with minus prefix before currency', () {
      expect(formatRupiah(-25000), '-Rp 25.000');
    });
  });

  group('dateOnly pure function tests', () {
    test('formats date to YYYY-MM-DD with zero-padding', () {
      expect(dateOnly(DateTime(2026, 10, 18)), '2026-10-18');
      expect(dateOnly(DateTime(2026, 5, 4)), '2026-05-04');
    });
  });
}

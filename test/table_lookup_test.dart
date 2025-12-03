import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/core/table_lookup.dart';
import 'test_utils.dart';

void main() {
  group('TableEntry', () {
    test('matches values within range', () {
      const entry = TableEntry(minValue: 5, maxValue: 8, result: 'test');
      
      expect(entry.matches(4), isFalse);
      expect(entry.matches(5), isTrue);
      expect(entry.matches(6), isTrue);
      expect(entry.matches(8), isTrue);
      expect(entry.matches(9), isFalse);
    });

    test('handles single value range', () {
      const entry = TableEntry(minValue: 7, maxValue: 7, result: 'exact');
      
      expect(entry.matches(6), isFalse);
      expect(entry.matches(7), isTrue);
      expect(entry.matches(8), isFalse);
    });
  });

  group('LookupTable', () {
    test('lookup returns correct result', () {
      final table = LookupTable<String>(
        name: 'Test Table',
        entries: [
          const TableEntry(minValue: 1, maxValue: 3, result: 'low'),
          const TableEntry(minValue: 4, maxValue: 6, result: 'mid'),
          const TableEntry(minValue: 7, maxValue: 10, result: 'high'),
        ],
      );

      expect(table.lookup(1), equals('low'));
      expect(table.lookup(3), equals('low'));
      expect(table.lookup(4), equals('mid'));
      expect(table.lookup(6), equals('mid'));
      expect(table.lookup(7), equals('high'));
      expect(table.lookup(10), equals('high'));
    });

    test('lookup returns null for out of range', () {
      final table = LookupTable<String>(
        name: 'Test Table',
        entries: [
          const TableEntry(minValue: 2, maxValue: 6, result: 'only'),
        ],
      );

      expect(table.lookup(1), isNull);
      expect(table.lookup(7), isNull);
    });

    test('range returns min and max values', () {
      final table = LookupTable<String>(
        name: 'Test Table',
        entries: [
          const TableEntry(minValue: 2, maxValue: 4, result: 'a'),
          const TableEntry(minValue: 5, maxValue: 8, result: 'b'),
          const TableEntry(minValue: 9, maxValue: 12, result: 'c'),
        ],
      );

      final (min, max) = table.range;
      expect(min, equals(2));
      expect(max, equals(12));
    });

    test('range handles empty table', () {
      final table = LookupTable<String>(
        name: 'Empty',
        entries: [],
      );

      final (min, max) = table.range;
      expect(min, equals(0));
      expect(max, equals(0));
    });
  });

  group('TableRoller', () {
    late TableRoller roller;
    late LookupTable<String> testTable;

    setUp(() {
      roller = TableRoller(SeededRandom(42));
      testTable = LookupTable<String>(
        name: '2d6 Table',
        entries: [
          const TableEntry(minValue: 2, maxValue: 4, result: 'low'),
          const TableEntry(minValue: 5, maxValue: 9, result: 'mid'),
          const TableEntry(minValue: 10, maxValue: 12, result: 'high'),
        ],
      );
    });

    test('rollOnTable returns valid result', () {
      final result = roller.rollOnTable(
        table: testTable,
        diceCount: 2,
        diceSides: 6,
      );

      expect(result, isNotNull);
      expect(result!.tableName, equals('2d6 Table'));
      expect(result.rollValue, greaterThanOrEqualTo(2));
      expect(result.rollValue, lessThanOrEqualTo(12));
      expect(['low', 'mid', 'high'], contains(result.result));
    });

    test('rollOnTable applies modifier', () {
      final withMod = TableRoller(SeededRandom(42));
      final withoutMod = TableRoller(SeededRandom(42));

      final resultWithMod = withMod.rollOnTable(
        table: testTable,
        diceCount: 2,
        diceSides: 6,
        modifier: 2,
      );

      final resultWithoutMod = withoutMod.rollOnTable(
        table: testTable,
        diceCount: 2,
        diceSides: 6,
        modifier: 0,
      );

      expect(resultWithMod!.rollValue, equals(resultWithoutMod!.rollValue + 2));
    });

    test('roll2d6 rolls correctly', () {
      final result = roller.roll2d6(testTable);

      expect(result, isNotNull);
      expect(result!.rollValue, greaterThanOrEqualTo(2));
      expect(result.rollValue, lessThanOrEqualTo(12));
    });

    test('rollPercentile rolls correctly', () {
      final percentileTable = LookupTable<String>(
        name: 'Percentile',
        entries: [
          const TableEntry(minValue: 1, maxValue: 50, result: 'lower half'),
          const TableEntry(minValue: 51, maxValue: 100, result: 'upper half'),
        ],
      );

      final result = roller.rollPercentile(percentileTable);

      expect(result, isNotNull);
      expect(result!.rollValue, greaterThanOrEqualTo(1));
      expect(result.rollValue, lessThanOrEqualTo(100));
      expect(['lower half', 'upper half'], contains(result.result));
    });
  });

  group('TableLookupResult', () {
    test('toString provides readable output', () {
      final result = TableLookupResult<String>(
        tableName: 'Test',
        rollValue: 7,
        result: 'success',
      );

      expect(result.toString(), contains('Test'));
      expect(result.toString(), contains('7'));
      expect(result.toString(), contains('success'));
    });
  });
}

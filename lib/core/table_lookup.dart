import 'dart:math';

/// A table entry with a range of values and the result.
class TableEntry<T> {
  final int minValue;
  final int maxValue;
  final T result;

  const TableEntry({
    required this.minValue,
    required this.maxValue,
    required this.result,
  });

  bool matches(int value) => value >= minValue && value <= maxValue;
}

/// A lookup table that maps dice roll ranges to results.
class LookupTable<T> {
  final String name;
  final List<TableEntry<T>> entries;

  const LookupTable({
    required this.name,
    required this.entries,
  });

  /// Look up a result based on the roll value.
  T? lookup(int value) {
    for (final entry in entries) {
      if (entry.matches(value)) {
        return entry.result;
      }
    }
    return null;
  }

  /// Get the valid range for this table.
  (int min, int max) get range {
    if (entries.isEmpty) return (0, 0);
    int minVal = entries.first.minValue;
    int maxVal = entries.first.maxValue;
    for (final entry in entries) {
      if (entry.minValue < minVal) minVal = entry.minValue;
      if (entry.maxValue > maxVal) maxVal = entry.maxValue;
    }
    return (minVal, maxVal);
  }
}

/// Result from a table lookup roll.
class TableLookupResult<T> {
  final String tableName;
  final int rollValue;
  final T result;

  const TableLookupResult({
    required this.tableName,
    required this.rollValue,
    required this.result,
  });

  @override
  String toString() => '$tableName: rolled $rollValue -> $result';
}

/// Table roller that combines rolling with table lookups.
class TableRoller {
  final Random _random;

  TableRoller([Random? random]) : _random = random ?? Random();

  /// Roll on a table using the specified dice.
  TableLookupResult<T>? rollOnTable<T>({
    required LookupTable<T> table,
    required int diceCount,
    required int diceSides,
    int modifier = 0,
  }) {
    int sum = 0;
    for (int i = 0; i < diceCount; i++) {
      sum += _random.nextInt(diceSides) + 1;
    }
    sum += modifier;

    final result = table.lookup(sum);
    if (result == null) return null;

    return TableLookupResult(
      tableName: table.name,
      rollValue: sum,
      result: result,
    );
  }

  /// Roll on a table using a d100 (percentile).
  TableLookupResult<T>? rollPercentile<T>(LookupTable<T> table, {int modifier = 0}) {
    return rollOnTable(
      table: table,
      diceCount: 1,
      diceSides: 100,
      modifier: modifier,
    );
  }

  /// Roll on a table using 2d6.
  TableLookupResult<T>? roll2d6<T>(LookupTable<T> table, {int modifier = 0}) {
    return rollOnTable(
      table: table,
      diceCount: 2,
      diceSides: 6,
      modifier: modifier,
    );
  }
}

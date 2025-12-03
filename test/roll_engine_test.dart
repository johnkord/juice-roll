import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/core/roll_engine.dart';
import 'test_utils.dart';

void main() {
  group('RollEngine', () {
    late RollEngine engine;

    setUp(() {
      engine = RollEngine(SeededRandom(42));
    });

    group('rollDie', () {
      test('returns value between 1 and sides inclusive', () {
        final results = <int>[];
        // Use fresh engine for each roll to get different values
        for (int i = 0; i < 100; i++) {
          final testEngine = RollEngine(SeededRandom(i));
          results.add(testEngine.rollDie(6));
        }

        expect(results.every((r) => r >= 1 && r <= 6), isTrue);
      });

      test('throws for invalid sides', () {
        expect(() => engine.rollDie(0), throwsArgumentError);
        expect(() => engine.rollDie(-1), throwsArgumentError);
      });

      test('handles d1', () {
        expect(engine.rollDie(1), equals(1));
      });
    });

    group('rollDice', () {
      test('returns correct number of dice', () {
        final result = engine.rollDice(3, 6);
        expect(result.length, equals(3));
      });

      test('all values are within range', () {
        final result = engine.rollDice(10, 20);
        expect(result.every((r) => r >= 1 && r <= 20), isTrue);
      });

      test('throws for invalid count', () {
        expect(() => engine.rollDice(0, 6), throwsArgumentError);
        expect(() => engine.rollDice(-1, 6), throwsArgumentError);
      });
    });

    group('rollNdX', () {
      test('returns sum of dice', () {
        final seededEngine = RollEngine(SeededRandom(123));
        final result = seededEngine.rollNdX(2, 6);
        // Just verify it's within the expected range for 2d6
        expect(result, greaterThanOrEqualTo(2));
        expect(result, lessThanOrEqualTo(12));
      });

      test('2d6 is between 2 and 12', () {
        for (int i = 0; i < 100; i++) {
          final testEngine = RollEngine(SeededRandom(i));
          final result = testEngine.rollNdX(2, 6);
          expect(result, greaterThanOrEqualTo(2));
          expect(result, lessThanOrEqualTo(12));
        }
      });
    });

    group('rollFateDie', () {
      test('returns -1, 0, or 1', () {
        final results = <int>{};
        for (int i = 0; i < 100; i++) {
          final testEngine = RollEngine(SeededRandom(i));
          results.add(testEngine.rollFateDie());
        }
        
        // Should only contain -1, 0, 1
        expect(results.difference({-1, 0, 1}), isEmpty);
      });
    });

    group('rollFateDice', () {
      test('returns correct number of dice', () {
        final result = engine.rollFateDice(4);
        expect(result.length, equals(4));
      });

      test('all values are -1, 0, or 1', () {
        final result = engine.rollFateDice(10);
        expect(result.every((r) => r >= -1 && r <= 1), isTrue);
      });

      test('throws for invalid count', () {
        expect(() => engine.rollFateDice(0), throwsArgumentError);
      });
    });

    group('rollFate', () {
      test('4dF is between -4 and 4', () {
        for (int i = 0; i < 100; i++) {
          final testEngine = RollEngine(SeededRandom(i));
          final result = testEngine.rollFate(4);
          expect(result, greaterThanOrEqualTo(-4));
          expect(result, lessThanOrEqualTo(4));
        }
      });
    });

    group('rollWithAdvantage', () {
      test('returns the higher of two rolls', () {
        final result = engine.rollWithAdvantage(1, 20);
        expect(result.chosenSum, equals(result.sum1 >= result.sum2 ? result.sum1 : result.sum2));
      });

      test('tracks both rolls', () {
        final result = engine.rollWithAdvantage(2, 6);
        expect(result.roll1.length, equals(2));
        expect(result.roll2.length, equals(2));
        expect(result.sum1, equals(result.roll1.reduce((a, b) => a + b)));
        expect(result.sum2, equals(result.roll2.reduce((a, b) => a + b)));
      });

      test('usedFirst indicates which roll was chosen', () {
        final result = engine.rollWithAdvantage(1, 20);
        if (result.usedFirst) {
          expect(result.chosenSum, equals(result.sum1));
          expect(result.chosenRoll, equals(result.roll1));
        } else {
          expect(result.chosenSum, equals(result.sum2));
          expect(result.chosenRoll, equals(result.roll2));
        }
      });
    });

    group('rollWithDisadvantage', () {
      test('returns the lower of two rolls', () {
        final result = engine.rollWithDisadvantage(1, 20);
        expect(result.chosenSum, equals(result.sum1 <= result.sum2 ? result.sum1 : result.sum2));
      });

      test('tracks discarded roll', () {
        final result = engine.rollWithDisadvantage(2, 6);
        expect(result.discardedSum, equals(result.usedFirst ? result.sum2 : result.sum1));
      });
    });

    group('rollSkewedD6', () {
      test('with zero skew returns standard d6', () {
        final result = engine.rollSkewedD6(0);
        expect(result, greaterThanOrEqualTo(1));
        expect(result, lessThanOrEqualTo(6));
      });

      test('positive skew favors higher values', () {
        // With positive skew, we take the max of multiple dice
        // So statistically we should see higher average
        int sumPositive = 0;
        int sumNeutral = 0;
        
        for (int i = 0; i < 1000; i++) {
          final positiveEngine = RollEngine(SeededRandom(i));
          final neutralEngine = RollEngine(SeededRandom(i + 10000));
          sumPositive += positiveEngine.rollSkewedD6(2);
          sumNeutral += neutralEngine.rollSkewedD6(0);
        }
        
        expect(sumPositive / 1000, greaterThan(sumNeutral / 1000));
      });

      test('negative skew favors lower values', () {
        // With negative skew, we take the min of multiple dice
        int sumNegative = 0;
        int sumNeutral = 0;
        
        for (int i = 0; i < 1000; i++) {
          final negativeEngine = RollEngine(SeededRandom(i));
          final neutralEngine = RollEngine(SeededRandom(i + 10000));
          sumNegative += negativeEngine.rollSkewedD6(-2);
          sumNeutral += neutralEngine.rollSkewedD6(0);
        }
        
        expect(sumNegative / 1000, lessThan(sumNeutral / 1000));
      });

      test('results are still between 1 and 6', () {
        for (int skew = -3; skew <= 3; skew++) {
          for (int i = 0; i < 50; i++) {
            final testEngine = RollEngine(SeededRandom(i + skew * 100));
            final result = testEngine.rollSkewedD6(skew);
            expect(result, greaterThanOrEqualTo(1));
            expect(result, lessThanOrEqualTo(6));
          }
        }
      });
    });
  });

  group('RollWithAdvantageResult', () {
    test('toString provides meaningful output', () {
      final result = RollWithAdvantageResult(
        roll1: [4, 3],
        roll2: [2, 5],
        sum1: 7,
        sum2: 7,
        chosenSum: 7,
        usedFirst: true,
      );
      expect(result.toString(), contains('7'));
    });
  });
}

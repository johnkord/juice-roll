import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Name Generator preset for the Juice Oracle.
/// Generates fantasy names using 3d20 syllable tables.
/// 
/// Based on meaning-name-generator.md.
/// Roll with advantage (@+) for feminine names.
/// Roll with disadvantage (@-) for masculine names.
class NameGenerator {
  final RollEngine _rollEngine;

  /// Syllable table (d20) - First column
  static const List<String> syllables1 = [
    'A',    // 1
    'Bri',  // 2
    'Ca',   // 3
    'Da',   // 4
    'E',    // 5
    'Fa',   // 6
    'Ga',   // 7
    'Ha',   // 8
    'I',    // 9
    'Ja',   // 10
    'Ka',   // 11
    'La',   // 12
    'Ma',   // 13
    'Na',   // 14
    'O',    // 15
    'Pa',   // 16
    'Ra',   // 17
    'Sa',   // 18
    'Ta',   // 19
    'Va',   // 20
  ];

  /// Syllable table (d20) - Second column
  static const List<String> syllables2 = [
    'al',   // 1
    'bar',  // 2
    'cen',  // 3
    'dan',  // 4
    'el',   // 5
    'fen',  // 6
    'gar',  // 7
    'hal',  // 8
    'in',   // 9
    'jan',  // 10
    'kel',  // 11
    'len',  // 12
    'mar',  // 13
    'nar',  // 14
    'or',   // 15
    'pen',  // 16
    'ren',  // 17
    'sar',  // 18
    'tar',  // 19
    'val',  // 20
  ];

  /// Syllable table (d20) - Third column
  static const List<String> syllables3 = [
    'a',    // 1
    'ax',   // 2
    'cia',  // 3
    'dra',  // 4
    'eth',  // 5
    'fyn',  // 6
    'gon',  // 7
    'hir',  // 8
    'ia',   // 9
    'jan',  // 10
    'ka',   // 11
    'lin',  // 12
    'mir',  // 13
    'na',   // 14
    'or',   // 15
    'pha',  // 16
    'ric',  // 17
    'sha',  // 18
    'tha',  // 19
    'vyn',  // 20
  ];

  NameGenerator([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a random name (neutral).
  NameResult generate() {
    final roll1 = _rollEngine.rollDie(20);
    final roll2 = _rollEngine.rollDie(20);
    final roll3 = _rollEngine.rollDie(20);

    return _buildResult(roll1, roll2, roll3, NameStyle.neutral);
  }

  /// Generate a name with masculine tendency (@-).
  /// Uses disadvantage (lower values) which tend to produce harder sounds.
  NameResult generateMasculine() {
    final result1 = _rollEngine.rollWithDisadvantage(1, 20);
    final result2 = _rollEngine.rollWithDisadvantage(1, 20);
    final result3 = _rollEngine.rollWithDisadvantage(1, 20);

    return _buildResult(
      result1.chosenSum,
      result2.chosenSum,
      result3.chosenSum,
      NameStyle.masculine,
    );
  }

  /// Generate a name with feminine tendency (@+).
  /// Uses advantage (higher values) which tend to produce softer sounds.
  NameResult generateFeminine() {
    final result1 = _rollEngine.rollWithAdvantage(1, 20);
    final result2 = _rollEngine.rollWithAdvantage(1, 20);
    final result3 = _rollEngine.rollWithAdvantage(1, 20);

    return _buildResult(
      result1.chosenSum,
      result2.chosenSum,
      result3.chosenSum,
      NameStyle.feminine,
    );
  }

  NameResult _buildResult(int roll1, int roll2, int roll3, NameStyle style) {
    final syl1 = syllables1[roll1 - 1];
    final syl2 = syllables2[roll2 - 1];
    final syl3 = syllables3[roll3 - 1];

    // Capitalize first letter
    final name = '${syl1}${syl2}${syl3}';
    final capitalizedName = name[0].toUpperCase() + name.substring(1).toLowerCase();

    return NameResult(
      rolls: [roll1, roll2, roll3],
      syllables: [syl1, syl2, syl3],
      name: capitalizedName,
      style: style,
    );
  }
}

/// Name style/tendency.
enum NameStyle {
  neutral,
  masculine,
  feminine,
}

extension NameStyleDisplay on NameStyle {
  String get displayText {
    switch (this) {
      case NameStyle.neutral:
        return 'Neutral';
      case NameStyle.masculine:
        return 'Masculine (M@-)';
      case NameStyle.feminine:
        return 'Feminine (F@+)';
    }
  }
}

/// Result of name generation.
class NameResult extends RollResult {
  final List<int> rolls;
  final List<String> syllables;
  final String name;
  final NameStyle style;

  NameResult({
    required this.rolls,
    required this.syllables,
    required this.name,
    required this.style,
  }) : super(
          type: RollType.nameGenerator,
          description: 'Name Generator (${style.displayText})',
          diceResults: rolls,
          total: rolls.reduce((a, b) => a + b),
          interpretation: name,
          metadata: {
            'syllables': syllables,
            'name': name,
            'style': style.name,
          },
        );

  @override
  String toString() => 'Name: $name (${style.displayText})';
}

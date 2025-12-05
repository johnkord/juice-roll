import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Name Generator preset for the Juice Oracle.
/// Generates fantasy names using d20 syllable tables.
/// 
/// Based on Juice instructions (pages 61-64).
/// 
/// **Simple Method**: Roll 3d20 on columns 1, 2, 3 for a random name.
/// Alternatively, roll on column 1 three times for a similar effect.
/// 
/// **Pattern Method**: Roll 1d20 to select a pattern, then follow it.
/// - Roll with disadvantage (@-) on the pattern roll for masculine names
/// - Roll with advantage (@+) on the pattern roll for feminine names
/// - The pattern itself determines which columns/modifiers to use
/// 
/// Column 1, rows 1-5: Use vowels (a,e,i,o,u) at start, or consonant pairs mid/end.
/// Column 3, rows 1-10: Masculine endings; rows 11-20: Feminine endings.
class NameGenerator {
  final RollEngine _rollEngine;

  /// Syllable table (d20) - First column
  /// Rows 1-5 have alternate forms: (f)a, (p)e, (v)i, (n)o, (s)u
  /// Use the vowel form at the start of a name, consonant form otherwise.
  static const List<String> syllables1 = [
    'a',    // 1 - or 'fa' if not at start
    'e',    // 2 - or 'pe' if not at start
    'i',    // 3 - or 'vi' if not at start
    'o',    // 4 - or 'no' if not at start
    'u',    // 5 - or 'su' if not at start
    'de',   // 6
    'ka',   // 7
    'li',   // 8
    'ma',   // 9
    'ro',   // 10
    'be',   // 11
    'da',   // 12
    'ki',   // 13
    'le',   // 14
    'mi',   // 15
    'ne',   // 16
    'ru',   // 17
    'si',   // 18
    'ta',   // 19
    'to',   // 20
  ];

  /// Alternate forms for syllables1 rows 1-5 (consonant + vowel)
  /// Used when this syllable is not at the start of the name.
  static const List<String> syllables1Alt = [
    'fa',   // 1
    'pe',   // 2
    'vi',   // 3
    'no',   // 4
    'su',   // 5
  ];

  /// Syllable table (d20) - Second column
  static const List<String> syllables2 = [
    'hal',   // 1
    'ris',   // 2
    'del',   // 3
    'mor',   // 4
    'bar',   // 5
    'net',   // 6
    'kel',   // 7
    'lim',   // 8
    'tur',   // 9
    'pen',   // 10
    'rond',  // 11
    'kay',   // 12
    'jam',   // 13
    'vash',  // 14
    'zab',   // 15
    'yos',   // 16
    'gran',  // 17
    'ched',  // 18
    'sark',  // 19
    'kic',   // 20
  ];

  /// Syllable table (d20) - Third column
  /// Rows 1-10: masculine-sounding endings
  /// Rows 11-20: feminine-sounding endings
  static const List<String> syllables3 = [
    'an',    // 1 - masculine
    'ar',    // 2 - masculine
    'er',    // 3 - masculine
    'ian',   // 4 - masculine
    'ic',    // 5 - masculine
    'in',    // 6 - masculine
    'o',     // 7 - masculine
    'on',    // 8 - masculine
    'or',    // 9 - masculine
    'us',    // 10 - masculine
    'a',     // 11 - feminine
    'aea',   // 12 - feminine
    'aya',   // 13 - feminine
    'elle',  // 14 - feminine
    'ene',   // 15 - feminine
    'ess',   // 16 - feminine
    'ette',  // 17 - feminine
    'ice',   // 18 - feminine
    'id',    // 19 - feminine
    'osa',   // 20 - feminine
  ];

  NameGenerator([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  // ============================================================
  // SIMPLE METHOD - Roll 3d20 on columns 1, 2, 3
  // ============================================================

  /// Generate a random name using the Simple Method (3d20).
  /// Rolls on columns 1, 2, and 3 for a straightforward random name.
  NameResult generate() {
    final roll1 = _rollEngine.rollDie(20);
    final roll2 = _rollEngine.rollDie(20);
    final roll3 = _rollEngine.rollDie(20);

    return _buildSimpleResult(roll1, roll2, roll3);
  }

  /// Generate a name using only Column 1 (3 times).
  /// Alternative simple method from the instructions.
  NameResult generateColumn1Only() {
    final roll1 = _rollEngine.rollDie(20);
    final roll2 = _rollEngine.rollDie(20);
    final roll3 = _rollEngine.rollDie(20);

    return _buildColumn1Result(roll1, roll2, roll3);
  }

  NameResult _buildSimpleResult(int roll1, int roll2, int roll3) {
    // For first syllable, use vowel form (rows 1-5) or regular form
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
      style: NameStyle.neutral,
      method: NameMethod.simple,
    );
  }

  NameResult _buildColumn1Result(int roll1, int roll2, int roll3) {
    // First syllable uses vowel form if 1-5
    final syl1 = syllables1[roll1 - 1];
    // Second and third syllables use consonant form if 1-5
    final syl2 = roll2 <= 5 ? syllables1Alt[roll2 - 1] : syllables1[roll2 - 1];
    final syl3 = roll3 <= 5 ? syllables1Alt[roll3 - 1] : syllables1[roll3 - 1];

    final name = '${syl1}${syl2}${syl3}';
    final capitalizedName = name[0].toUpperCase() + name.substring(1).toLowerCase();

    return NameResult(
      rolls: [roll1, roll2, roll3],
      syllables: [syl1, syl2, syl3],
      name: capitalizedName,
      style: NameStyle.neutral,
      method: NameMethod.column1,
    );
  }

  // ============================================================
  // PATTERN METHOD - Roll 1d20 for pattern, then follow it
  // ============================================================

  /// Generate a name using the Pattern Method (neutral).
  /// Rolls 1d20 to select a pattern, then follows it.
  NameResult generatePatternNeutral() {
    final patternRoll = _rollEngine.rollDie(20);
    return _generateFromPattern(patternRoll, NameStyle.neutral);
  }

  /// Generate a name with masculine tendency using Pattern Method.
  /// Uses disadvantage (@-) on the pattern roll, which skews toward
  /// patterns that produce more masculine-sounding names.
  NameResult generateMasculine() {
    final result = _rollEngine.rollWithDisadvantage(1, 20);
    return _generateFromPattern(result.chosenSum, NameStyle.masculine);
  }

  /// Generate a name with feminine tendency using Pattern Method.
  /// Uses advantage (@+) on the pattern roll, which skews toward
  /// patterns that produce more feminine-sounding names.
  NameResult generateFeminine() {
    final result = _rollEngine.rollWithAdvantage(1, 20);
    return _generateFromPattern(result.chosenSum, NameStyle.feminine);
  }

  /// Internal method to generate a name from a pattern roll.
  /// The pattern determines which columns to use and whether to add suffixes.
  /// Patterns: 12o, 12, 23-, 123-o, 123-, 111, 123, 12a, 12i, 23-a, 23-i, 23+, 123-a, 123-i, 123+
  NameResult _generateFromPattern(int patternRoll, NameStyle style) {
    final pattern = _patterns[patternRoll.clamp(1, 20) - 1];
    final rolls = <int>[patternRoll]; // Include the pattern roll
    final syllables = <String>[];
    String suffix = '';

    // Parse pattern and generate syllables
    for (int i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      if (char == '1') {
        final roll = _rollEngine.rollDie(20);
        rolls.add(roll);
        // Use vowel form only if this is the first syllable
        if (syllables.isEmpty && roll <= 5) {
          syllables.add(syllables1[roll - 1]); // vowel form
        } else if (roll <= 5) {
          syllables.add(syllables1Alt[roll - 1]); // consonant form
        } else {
          syllables.add(syllables1[roll - 1]);
        }
      } else if (char == '2') {
        final roll = _rollEngine.rollDie(20);
        rolls.add(roll);
        syllables.add(syllables2[roll - 1]);
      } else if (char == '3') {
        // Check for +/- modifier
        bool hasPlus = i + 1 < pattern.length && pattern[i + 1] == '+';
        bool hasMinus = i + 1 < pattern.length && pattern[i + 1] == '-';
        int roll;
        if (hasPlus) {
          roll = _rollEngine.rollDie(10) + 10; // 11-20 (feminine)
          i++; // skip the +
        } else if (hasMinus) {
          roll = _rollEngine.rollDie(10); // 1-10 (masculine)
          i++; // skip the -
        } else {
          roll = _rollEngine.rollDie(20);
        }
        rolls.add(roll);
        syllables.add(syllables3[roll - 1]);
      } else if (char == 'o' || char == 'a' || char == 'i') {
        suffix = char;
      }
    }

    final name = syllables.join('') + suffix;
    final capitalizedName = name[0].toUpperCase() + name.substring(1).toLowerCase();

    return NameResult(
      rolls: rolls,
      syllables: syllables,
      name: capitalizedName,
      style: style,
      method: NameMethod.pattern,
      pattern: pattern,
    );
  }

  /// Pattern definitions from the instructions
  static const List<String> _patterns = [
    '12o',    // 1
    '12',     // 2
    '12',     // 3
    '23-o',   // 4
    '23-',    // 5
    '23-',    // 6
    '123-o',  // 7
    '123-',   // 8
    '123-',   // 9
    '111',    // 10
    '111',    // 11
    '123',    // 12
    '12a',    // 13
    '12i',    // 14
    '23-a',   // 15
    '23-i',   // 16
    '23+',    // 17
    '123-a',  // 18
    '123-i',  // 19
    '123+',   // 20
  ];
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
        return 'Masculine (@-)';
      case NameStyle.feminine:
        return 'Feminine (@+)';
    }
  }
}

/// The method used to generate the name.
enum NameMethod {
  simple,   // 3d20 on columns 1, 2, 3
  column1,  // 3d20 on column 1 only
  pattern,  // Roll pattern, then follow it
}

extension NameMethodDisplay on NameMethod {
  String get displayText {
    switch (this) {
      case NameMethod.simple:
        return 'Simple (3d20)';
      case NameMethod.column1:
        return 'Column 1 Only';
      case NameMethod.pattern:
        return 'Pattern';
    }
  }
}

/// Result of name generation.
class NameResult extends RollResult {
  final List<int> rolls;
  final List<String> syllables;
  final String name;
  final NameStyle style;
  final NameMethod method;
  final String? pattern;

  NameResult({
    required this.rolls,
    required this.syllables,
    required this.name,
    required this.style,
    required this.method,
    this.pattern,
    List<int>? syllableRolls,
    DateTime? timestamp,
  }) : super(
          type: RollType.nameGenerator,
          description: _buildDescription(style, method, pattern),
          diceResults: syllableRolls ?? rolls,
          total: rolls.reduce((a, b) => a + b),
          interpretation: name,
          timestamp: timestamp,
          metadata: {
            'syllables': syllables,
            'name': name,
            'style': style.name,
            'method': method.name,
            if (pattern != null) 'pattern': pattern,
          },
        );

  @override
  String get className => 'NameResult';

  factory NameResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    final syllables = (meta['syllables'] as List).cast<String>();
    return NameResult(
      rolls: diceResults,
      syllables: syllables,
      name: meta['name'] as String,
      style: NameStyle.values.firstWhere(
        (s) => s.name == meta['style'],
        orElse: () => NameStyle.neutral,
      ),
      method: NameMethod.values.firstWhere(
        (m) => m.name == meta['method'],
        orElse: () => NameMethod.simple,
      ),
      pattern: meta['pattern'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildDescription(NameStyle style, NameMethod method, String? pattern) {
    if (method == NameMethod.pattern && pattern != null) {
      return 'Name Generator (${style.displayText}, Pattern: $pattern)';
    }
    return 'Name Generator (${method.displayText})';
  }

  @override
  String toString() => 'Name: $name (${method.displayText}${style != NameStyle.neutral ? ', ${style.displayText}' : ''})';
}

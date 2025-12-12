import '../roll_result.dart';

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
  simple, // 3d20 on columns 1, 2, 3
  column1, // 3d20 on column 1 only
  pattern, // Roll pattern, then follow it
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

  static String _buildDescription(
      NameStyle style, NameMethod method, String? pattern) {
    if (method == NameMethod.pattern && pattern != null) {
      return 'Name Generator (${style.displayText}, Pattern: $pattern)';
    }
    return 'Name Generator (${method.displayText})';
  }

  @override
  String toString() =>
      'Name: $name (${method.displayText}${style != NameStyle.neutral ? ', ${style.displayText}' : ''})';
}

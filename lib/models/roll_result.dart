/// Types of rolls that can be performed.
enum RollType {
  // Basic dice
  standard,
  fate,
  advantage,
  disadvantage,
  skewed,
  tableLookup,
  
  // Core Oracle
  fateCheck,
  nextScene,
  randomEvent,
  discoverMeaning,
  expectationCheck,
  
  // NPC & Dialog
  npcAction,
  dialog,
  
  // Plot & Story
  payThePrice,
  quest,
  interruptPlotPoint,
  
  // Exploration
  weather,
  encounter,
  dungeon,
  location,
  
  // Generation
  settlement,
  objectTreasure,
  challenge,
  details,
  immersion,
  nameGenerator,
  scale,
  
  // Abstract Icons
  abstractIcons,
}

/// Represents the result of any roll.
class RollResult {
  final RollType type;
  final String description;
  final List<int> diceResults;
  final int total;
  final String? interpretation;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? imagePath;

  RollResult({
    required this.type,
    required this.description,
    required this.diceResults,
    required this.total,
    this.interpretation,
    DateTime? timestamp,
    this.metadata,
    this.imagePath,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(description);
    buffer.write(': ${diceResults.join(', ')} = $total');
    if (interpretation != null) {
      buffer.write(' ($interpretation)');
    }
    return buffer.toString();
  }
}

/// Represents a Fate dice result with symbolic representation.
class FateRollResult extends RollResult {
  FateRollResult({
    required super.description,
    required super.diceResults,
    required super.total,
    super.interpretation,
    super.timestamp,
    super.metadata,
  }) : super(type: RollType.fate);

  /// Get symbolic representation of Fate dice.
  /// Uses Unicode minus (−), circle (○), and plus (+) for consistency.
  String get symbols {
    return diceResults.map((d) {
      switch (d) {
        case -1:
          return '−';  // Unicode minus sign (U+2212)
        case 0:
          return '○';  // White circle (U+25CB)
        case 1:
          return '+';
        default:
          return '?';
      }
    }).join(' ');
  }

  @override
  String toString() {
    return '$description: [$symbols] = $total${interpretation != null ? ' ($interpretation)' : ''}';
  }
}

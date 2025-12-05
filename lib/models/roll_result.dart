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

  /// Get the class name for serialization.
  /// Subclasses should override this to return their specific class name.
  String get className => 'RollResult';

  /// Serialize to JSON for persistence.
  /// Includes className for proper reconstruction on import.
  Map<String, dynamic> toJson() => {
    'className': className,
    'type': type.name,
    'description': description,
    'diceResults': diceResults,
    'total': total,
    'interpretation': interpretation,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
    'imagePath': imagePath,
  };

  /// Deserialize from JSON.
  /// Returns a base RollResult that preserves all display information.
  factory RollResult.fromJson(Map<String, dynamic> json) {
    return RollResult(
      type: RollType.values.byName(json['type'] as String),
      description: json['description'] as String,
      diceResults: (json['diceResults'] as List<dynamic>).cast<int>(),
      total: json['total'] as int,
      interpretation: json['interpretation'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map) 
          : null,
      imagePath: json['imagePath'] as String?,
    );
  }

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

  @override
  String get className => 'FateRollResult';

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

  factory FateRollResult.fromJson(Map<String, dynamic> json) {
    return FateRollResult(
      description: json['description'] as String,
      diceResults: (json['diceResults'] as List<dynamic>).cast<int>(),
      total: json['total'] as int,
      interpretation: json['interpretation'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'] as Map) 
          : null,
    );
  }

  @override
  String toString() {
    return '$description: [$symbols] = $total${interpretation != null ? ' ($interpretation)' : ''}';
  }
}

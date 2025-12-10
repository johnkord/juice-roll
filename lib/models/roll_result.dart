import 'results/result_types.dart';

/// Types of rolls that can be performed.
enum RollType {
  // Basic dice
  standard,
  fate,
  advantage,
  disadvantage,
  skewed,
  tableLookup,
  
  // Ironsworn/Starforged
  ironswornAction,
  ironswornProgress,
  ironswornOracle,
  
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
/// 
/// This is the base class for all roll results in the application.
/// It provides:
/// - Core data: type, description, dice results, total, interpretation
/// - Serialization: toJson/fromJson with className for type preservation
/// - Display hints: displayType and sections for generic UI rendering
/// 
/// ## IMPORTANT: Creating a new RollResult subclass
/// 
/// When creating a new subclass, you MUST:
/// 
/// 1. Override [className] to return your class name as a String
///    ```dart
///    @override
///    String get className => 'MyNewResult';
///    ```
/// 
/// 2. Implement a `fromJson` factory constructor
///    ```dart
///    factory MyNewResult.fromJson(Map<String, dynamic> json) { ... }
///    ```
/// 
/// 3. **Register your class in [RollResultFactory]** (lib/models/roll_result_factory.dart)
///    Add an entry to the `_registry` map:
///    ```dart
///    'MyNewResult': MyNewResult.fromJson,
///    ```
///    
///    ⚠️ If you skip this step, your result will not survive app reload!
///    The history will fall back to a generic RollResult and lose its
///    custom display formatting.
/// 
/// 4. Optionally add a display builder in `result_display_builder.dart`
///    for custom UI rendering.
class RollResult {
  final RollType type;
  final String description;
  final List<int> diceResults;
  final int total;
  final String? interpretation;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? imagePath;
  
  /// Display type hint for the UI layer.
  /// Defaults to [ResultDisplayType.standard] if not specified.
  final ResultDisplayType displayType;
  
  /// Structured display sections for generic rendering.
  /// When provided, the UI can render this result without type-specific code.
  final List<ResultSection> sections;

  RollResult({
    required this.type,
    required this.description,
    required this.diceResults,
    required this.total,
    this.interpretation,
    DateTime? timestamp,
    this.metadata,
    this.imagePath,
    this.displayType = ResultDisplayType.standard,
    this.sections = const [],
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
    'displayType': displayType.name,
    // Only serialize sections if non-empty to save space
    if (sections.isNotEmpty) 'sections': sections.map((s) => s.toJson()).toList(),
  };

  /// Deserialize from JSON.
  /// Returns a base RollResult that preserves all display information.
  factory RollResult.fromJson(Map<String, dynamic> json) {
    // Parse displayType with fallback to standard
    ResultDisplayType displayType = ResultDisplayType.standard;
    if (json['displayType'] != null) {
      try {
        displayType = ResultDisplayType.values.byName(json['displayType'] as String);
      } catch (_) {
        // Keep default if parsing fails
      }
    }
    
    // Parse sections if present
    List<ResultSection> sections = const [];
    if (json['sections'] != null) {
      sections = (json['sections'] as List)
          .map((s) => ResultSection.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    
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
      displayType: displayType,
      sections: sections,
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

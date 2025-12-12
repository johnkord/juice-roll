import '../roll_result.dart';
import 'details_result.dart';
import 'json_utils.dart';
import 'name_result.dart';
import 'next_scene_result.dart';

/// NPC Disposition determines the die size for Action/Combat tables.
/// Passive NPCs roll d6, Active NPCs roll d10.
enum NpcDisposition {
  passive,  // d6 - gravitates toward helpful actions
  active,   // d10 - full range of actions including combat
}

/// NPC Context determines the skew for Action table.
/// Active context = advantage, Passive context = disadvantage.
enum NpcContext {
  passive,  // Roll with disadvantage
  active,   // Roll with advantage
}

/// NPC Focus determines the die size for Combat table.
/// Passive focus = d6, Active focus = d10.
enum NpcFocus {
  passive,  // d6 - defensive/warning actions
  active,   // d10 - full combat actions
}

/// NPC Objective determines the skew for Combat table.
/// Defensive = disadvantage, Offensive = advantage.
enum NpcObjective {
  defensive,  // Roll with disadvantage
  offensive,  // Roll with advantage
}

/// NPC Need skew for Maslow's hierarchy.
/// Disadvantage = more primitive needs, Advantage = more complex needs.
enum NeedSkew {
  none,          // Straight roll
  primitive,     // Disadvantage - basic needs (sustenance, shelter, etc.)
  complex,       // Advantage - higher needs (status, recognition, fulfillment)
}

/// NPC column types for action rolls.
enum NpcColumn {
  personality,
  need,
  motive,
  action,
  combat,
}

extension NpcColumnDisplay on NpcColumn {
  String get displayText {
    switch (this) {
      case NpcColumn.personality:
        return 'Personality';
      case NpcColumn.need:
        return 'Need';
      case NpcColumn.motive:
        return 'Motive/Topic';
      case NpcColumn.action:
        return 'Action';
      case NpcColumn.combat:
        return 'Combat';
    }
  }
}

/// Result of a single NPC column roll.
class NpcActionResult extends RollResult {
  final NpcColumn column;
  final int roll;
  final String result;
  final int? dieSize;
  final List<int>? allRolls;
  final NpcDisposition? disposition;
  final NpcContext? context;
  final NpcFocus? focus;
  final NpcObjective? objective;
  final NeedSkew? needSkew;

  NpcActionResult({
    required this.column,
    required this.roll,
    required this.result,
    this.dieSize,
    this.allRolls,
    this.disposition,
    this.context,
    this.focus,
    this.objective,
    this.needSkew,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: _buildDescription(column, dieSize, disposition, context, focus, objective, needSkew),
          diceResults: allRolls ?? [roll],
          total: roll,
          interpretation: result,
          timestamp: timestamp,
          metadata: _buildMetadata(column, result, roll, dieSize, disposition, context, focus, objective, needSkew, allRolls),
        );

  @override
  String get className => 'NpcActionResult';

  factory NpcActionResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return NpcActionResult(
      column: NpcColumn.values.firstWhere(
        (e) => e.name == (meta['column'] as String),
        orElse: () => NpcColumn.action,
      ),
      roll: meta['roll'] as int? ?? diceResults.first,
      result: meta['result'] as String,
      dieSize: meta['dieSize'] as int?,
      allRolls: (meta['allRolls'] as List?)?.cast<int>() ?? diceResults,
      disposition: meta['disposition'] != null 
          ? NpcDisposition.values.firstWhere((e) => e.name == meta['disposition'])
          : null,
      context: meta['context'] != null
          ? NpcContext.values.firstWhere((e) => e.name == meta['context'])
          : null,
      focus: meta['focus'] != null
          ? NpcFocus.values.firstWhere((e) => e.name == meta['focus'])
          : null,
      objective: meta['objective'] != null
          ? NpcObjective.values.firstWhere((e) => e.name == meta['objective'])
          : null,
      needSkew: meta['needSkew'] != null
          ? NeedSkew.values.firstWhere((e) => e.name == meta['needSkew'])
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildDescription(
    NpcColumn column,
    int? dieSize,
    NpcDisposition? disposition,
    NpcContext? context,
    NpcFocus? focus,
    NpcObjective? objective,
    NeedSkew? needSkew,
  ) {
    final base = 'NPC ${column.displayText}';
    final parts = <String>[];
    
    if (dieSize != null) {
      parts.add('d$dieSize');
    }
    if (disposition != null) {
      parts.add(disposition == NpcDisposition.passive ? 'Passive' : 'Active');
    }
    if (context != null) {
      parts.add(context == NpcContext.active ? '@+' : '@-');
    }
    if (focus != null) {
      parts.add(focus == NpcFocus.passive ? 'Passive' : 'Active');
    }
    if (objective != null) {
      parts.add(objective == NpcObjective.offensive ? '@+' : '@-');
    }
    if (needSkew != null && needSkew != NeedSkew.none) {
      parts.add(needSkew == NeedSkew.primitive ? '@- Primitive' : '@+ Complex');
    }
    
    if (parts.isEmpty) return base;
    return '$base (${parts.join(' ')})';
  }

  static Map<String, dynamic> _buildMetadata(
    NpcColumn column,
    String result,
    int roll,
    int? dieSize,
    NpcDisposition? disposition,
    NpcContext? context,
    NpcFocus? focus,
    NpcObjective? objective,
    NeedSkew? needSkew,
    List<int>? allRolls,
  ) {
    return {
      'column': column.name,
      'result': result,
      'roll': roll,
      if (dieSize != null) 'dieSize': dieSize,
      if (disposition != null) 'disposition': disposition.name,
      if (context != null) 'context': context.name,
      if (focus != null) 'focus': focus.name,
      if (objective != null) 'objective': objective.name,
      if (needSkew != null) 'needSkew': needSkew.name,
      if (allRolls != null) 'allRolls': allRolls,
    };
  }

  @override
  String toString() => 'NPC ${column.displayText}: $result';
}

/// Result of a motive roll with automatic follow-up.
/// If motive is "History", includes the History table result.
/// If motive is "Focus", includes the Focus table result, and if that Focus
/// is italic (Monster/Event/Environment/Person/Location/Object), includes
/// the expanded value from the appropriate sub-table.
class MotiveWithFollowUpResult extends RollResult {
  final int roll;
  final String motive;
  final DetailResult? historyResult;
  final FocusResult? focusResult;
  /// Sub-roll for expanding italic Focus entries
  final int? focusExpansionRoll;
  /// Expanded value from the sub-table (e.g., "Noble" for Person)
  final String? focusExpanded;

  MotiveWithFollowUpResult({
    required this.roll,
    required this.motive,
    this.historyResult,
    this.focusResult,
    this.focusExpansionRoll,
    this.focusExpanded,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: 'NPC Motive',
          diceResults: _buildDiceResults(roll, historyResult, focusResult, focusExpansionRoll),
          total: roll,
          interpretation: _buildInterpretation(motive, historyResult, focusResult, focusExpanded),
          timestamp: timestamp,
          metadata: _buildMetadataMap(roll, motive, historyResult, focusResult, focusExpansionRoll, focusExpanded),
        );

  @override
  String get className => 'MotiveWithFollowUpResult';

  factory MotiveWithFollowUpResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return MotiveWithFollowUpResult(
      roll: meta['roll'] as int? ?? (json['diceResults'] as List).first as int,
      motive: meta['motive'] as String,
      focusExpansionRoll: meta['focusExpansionRoll'] as int?,
      focusExpanded: meta['focusExpanded'] as String?,
      // Note: historyResult and focusResult cannot be fully reconstructed
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static List<int> _buildDiceResults(
    int roll,
    DetailResult? historyResult,
    FocusResult? focusResult,
    int? focusExpansionRoll,
  ) {
    final results = [roll];
    if (historyResult != null) {
      results.addAll(historyResult.diceResults);
    }
    if (focusResult != null) {
      results.addAll(focusResult.diceResults);
    }
    if (focusExpansionRoll != null) {
      results.add(focusExpansionRoll);
    }
    return results;
  }

  static String _buildInterpretation(
    String motive,
    DetailResult? historyResult,
    FocusResult? focusResult,
    String? focusExpanded,
  ) {
    if (historyResult != null) {
      return 'History → ${historyResult.result}';
    }
    if (focusResult != null) {
      if (focusExpanded != null) {
        return 'Focus → ${focusResult.focus} → $focusExpanded';
      }
      return 'Focus → ${focusResult.focus}';
    }
    return motive;
  }

  static Map<String, dynamic> _buildMetadataMap(
    int roll,
    String motive,
    DetailResult? historyResult,
    FocusResult? focusResult,
    int? focusExpansionRoll,
    String? focusExpanded,
  ) {
    return {
      'column': 'motive',
      'roll': roll,
      'motive': motive,
      if (historyResult != null) 'history': historyResult.result,
      if (focusResult != null) 'focus': focusResult.focus,
      if (focusExpansionRoll != null) 'focusExpansionRoll': focusExpansionRoll,
      if (focusExpanded != null) 'focusExpanded': focusExpanded,
    };
  }

  /// Whether this result has a follow-up roll.
  bool get hasFollowUp => historyResult != null || focusResult != null;

  /// Whether the focus was further expanded.
  bool get hasFocusExpansion => focusExpanded != null;

  /// The follow-up text (either history or focus result, with expansion if available).
  String? get followUpText {
    if (historyResult != null) return historyResult!.result;
    if (focusResult != null) {
      if (focusExpanded != null) {
        return '${focusResult!.focus} → $focusExpanded';
      }
      return focusResult!.focus;
    }
    return null;
  }

  @override
  String toString() {
    if (historyResult != null) {
      return 'NPC Motive: History → ${historyResult!.result}';
    }
    if (focusResult != null) {
      if (focusExpanded != null) {
        return 'NPC Motive: Focus → ${focusResult!.focus} → $focusExpanded';
      }
      return 'NPC Motive: Focus → ${focusResult!.focus}';
    }
    return 'NPC Motive: $motive';
  }
}

/// Result of generating a simple NPC profile.
/// Per instructions (page 128): Simple NPC includes just:
/// - 1 Personality trait
/// - Need
/// - Motive (with automatic expansion for History/Focus)
class SimpleNpcProfileResult extends RollResult {
  final int personalityRoll;
  final String personality;
  final int needRoll;
  final String need;
  final int motiveRoll;
  final String motive;
  final NeedSkew? needSkew;
  final List<int>? needAllRolls;
  /// History result when motive is "History"
  final DetailResult? historyResult;
  /// Focus result when motive is "Focus"
  final FocusResult? focusResult;
  /// Sub-roll for expanding italic Focus entries
  final int? focusExpansionRoll;
  /// Expanded value from the sub-table (e.g., "Noble" for Person)
  final String? focusExpanded;

  SimpleNpcProfileResult({
    required this.personalityRoll,
    required this.personality,
    required this.needRoll,
    required this.need,
    required this.motiveRoll,
    required this.motive,
    this.needSkew,
    this.needAllRolls,
    this.historyResult,
    this.focusResult,
    this.focusExpansionRoll,
    this.focusExpanded,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: needSkew != null && needSkew != NeedSkew.none
              ? 'NPC Simple Profile (Need: ${needSkew == NeedSkew.primitive ? '@- Primitive' : '@+ Complex'})'
              : 'NPC Simple Profile',
          diceResults: _buildDiceResults(personalityRoll, needRoll, motiveRoll, historyResult, focusResult, focusExpansionRoll),
          total: personalityRoll + needRoll + motiveRoll,
          interpretation: _buildInterpretation(personality, need, motive, historyResult, focusResult, focusExpanded),
          timestamp: timestamp,
          metadata: {
            'personality': personality,
            'personalityRoll': personalityRoll,
            'need': need,
            'needRoll': needRoll,
            'motive': motive,
            'motiveRoll': motiveRoll,
            if (needSkew != null) 'needSkew': needSkew.name,
            if (needAllRolls != null) 'needAllRolls': needAllRolls,
            if (historyResult != null) 'history': historyResult.result,
            if (focusResult != null) 'focus': focusResult.focus,
            if (focusExpansionRoll != null) 'focusExpansionRoll': focusExpansionRoll,
            if (focusExpanded != null) 'focusExpanded': focusExpanded,
          },
        );

  static List<int> _buildDiceResults(
    int personalityRoll,
    int needRoll,
    int motiveRoll,
    DetailResult? historyResult,
    FocusResult? focusResult,
    int? focusExpansionRoll,
  ) {
    final results = [personalityRoll, needRoll, motiveRoll];
    if (historyResult != null) {
      results.addAll(historyResult.diceResults);
    }
    if (focusResult != null) {
      results.addAll(focusResult.diceResults);
    }
    if (focusExpansionRoll != null) {
      results.add(focusExpansionRoll);
    }
    return results;
  }

  static String _buildInterpretation(
    String personality,
    String need,
    String motive,
    DetailResult? historyResult,
    FocusResult? focusResult,
    String? focusExpanded,
  ) {
    String motiveDisplay = motive;
    if (historyResult != null) {
      motiveDisplay = 'History → ${historyResult.result}';
    } else if (focusResult != null) {
      if (focusExpanded != null) {
        motiveDisplay = 'Focus → ${focusResult.focus} → $focusExpanded';
      } else {
        motiveDisplay = 'Focus → ${focusResult.focus}';
      }
    }
    return '$personality / $need / $motiveDisplay';
  }

  @override
  String get className => 'SimpleNpcProfileResult';

  factory SimpleNpcProfileResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return SimpleNpcProfileResult(
      personalityRoll: meta['personalityRoll'] as int? ?? diceResults[0],
      personality: meta['personality'] as String,
      needRoll: meta['needRoll'] as int? ?? diceResults[1],
      need: meta['need'] as String,
      motiveRoll: meta['motiveRoll'] as int? ?? diceResults[2],
      motive: meta['motive'] as String,
      needSkew: meta['needSkew'] != null
          ? NeedSkew.values.firstWhere((e) => e.name == meta['needSkew'])
          : null,
      needAllRolls: (meta['needAllRolls'] as List?)?.cast<int>(),
      focusExpansionRoll: meta['focusExpansionRoll'] as int?,
      focusExpanded: meta['focusExpanded'] as String?,
      // Note: historyResult and focusResult cannot be fully reconstructed
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Get the full motive display text (with expansion if available).
  String get motiveDisplay {
    if (historyResult != null) {
      return 'History → ${historyResult!.result}';
    }
    if (focusResult != null) {
      if (focusExpanded != null) {
        return 'Focus → ${focusResult!.focus} → $focusExpanded';
      }
      return 'Focus → ${focusResult!.focus}';
    }
    return motive;
  }

  @override
  String toString() =>
      'NPC Simple Profile: $personality (needs $need, motivated by $motiveDisplay)';
}

/// Result of generating a full NPC profile.
/// Per instructions (page 128-129): Full NPC profile includes:
/// - 2 Personality traits (primary + secondary)
/// - Need (with optional skew)
/// - Motive (with automatic expansion for History/Focus)
/// - Color (1d10)
/// - Two Properties (1d10+1d6 each)
class NpcProfileResult extends RollResult {
  final int primaryPersonalityRoll;
  final String primaryPersonality;
  final int secondaryPersonalityRoll;
  final String secondaryPersonality;
  final int needRoll;
  final String need;
  final int motiveRoll;
  final String motive;
  final NeedSkew? needSkew;
  final List<int>? needAllRolls;
  /// History result when motive is "History"
  final DetailResult? historyResult;
  /// Focus result when motive is "Focus"
  final FocusResult? focusResult;
  /// Sub-roll for expanding italic Focus entries
  final int? focusExpansionRoll;
  /// Expanded value from the sub-table (e.g., "Noble" for Person)
  final String? focusExpanded;
  /// Color (1d10)
  final DetailResult color;
  /// First property (1d10+1d6)
  final PropertyResult property1;
  /// Second property (1d10+1d6)
  final PropertyResult property2;

  NpcProfileResult({
    required this.primaryPersonalityRoll,
    required this.primaryPersonality,
    required this.secondaryPersonalityRoll,
    required this.secondaryPersonality,
    required this.needRoll,
    required this.need,
    required this.motiveRoll,
    required this.motive,
    this.needSkew,
    this.needAllRolls,
    this.historyResult,
    this.focusResult,
    this.focusExpansionRoll,
    this.focusExpanded,
    required this.color,
    required this.property1,
    required this.property2,
    DateTime? timestamp,
  }) : super(
          type: RollType.npcAction,
          description: needSkew != null && needSkew != NeedSkew.none
              ? 'NPC Full Profile (Need: ${needSkew == NeedSkew.primitive ? '@- Primitive' : '@+ Complex'})'
              : 'NPC Full Profile',
          diceResults: _buildDiceResults(
            primaryPersonalityRoll, secondaryPersonalityRoll, needRoll, motiveRoll, 
            historyResult, focusResult, focusExpansionRoll, color, property1, property2,
          ),
          total: primaryPersonalityRoll + secondaryPersonalityRoll + needRoll + motiveRoll,
          interpretation: _buildInterpretation(
            primaryPersonality, secondaryPersonality, need, motive, 
            historyResult, focusResult, focusExpanded, color, property1, property2,
          ),
          timestamp: timestamp,
          metadata: {
            'primaryPersonality': primaryPersonality,
            'primaryPersonalityRoll': primaryPersonalityRoll,
            'secondaryPersonality': secondaryPersonality,
            'secondaryPersonalityRoll': secondaryPersonalityRoll,
            'need': need,
            'needRoll': needRoll,
            'motive': motive,
            'motiveRoll': motiveRoll,
            if (needSkew != null) 'needSkew': needSkew.name,
            if (needAllRolls != null) 'needAllRolls': needAllRolls,
            if (historyResult != null) 'history': historyResult.result,
            if (focusResult != null) 'focus': focusResult.focus,
            if (focusExpansionRoll != null) 'focusExpansionRoll': focusExpansionRoll,
            if (focusExpanded != null) 'focusExpanded': focusExpanded,
            'color': color.result,
            'property1': '${property1.intensityDescription} ${property1.property}',
            'property2': '${property2.intensityDescription} ${property2.property}',
          },
        );

  static List<int> _buildDiceResults(
    int persRoll1, int persRoll2, int needRoll, int motiveRoll,
    DetailResult? historyResult, FocusResult? focusResult, int? focusExpansionRoll,
    DetailResult color, PropertyResult prop1, PropertyResult prop2,
  ) {
    final results = [persRoll1, persRoll2, needRoll, motiveRoll];
    if (historyResult != null) {
      results.addAll(historyResult.diceResults);
    }
    if (focusResult != null) {
      results.addAll(focusResult.diceResults);
    }
    if (focusExpansionRoll != null) {
      results.add(focusExpansionRoll);
    }
    results.add(color.roll);
    results.addAll([prop1.propertyRoll, prop1.intensityRoll]);
    results.addAll([prop2.propertyRoll, prop2.intensityRoll]);
    return results;
  }

  static String _buildInterpretation(
    String primaryPersonality, String secondaryPersonality,
    String need, String motive,
    DetailResult? historyResult, FocusResult? focusResult, String? focusExpanded,
    DetailResult color, PropertyResult prop1, PropertyResult prop2,
  ) {
    String motiveDisplay = motive;
    if (historyResult != null) {
      motiveDisplay = 'History → ${historyResult.result}';
    } else if (focusResult != null) {
      if (focusExpanded != null) {
        motiveDisplay = 'Focus → ${focusResult.focus} → $focusExpanded';
      } else {
        motiveDisplay = 'Focus → ${focusResult.focus}';
      }
    }
    return '$primaryPersonality, yet $secondaryPersonality / $need / $motiveDisplay\n'
           '${color.emoji ?? ''} ${color.result}\n'
           '${prop1.intensityDescription} ${prop1.property} + ${prop2.intensityDescription} ${prop2.property}';
  }

  @override
  String get className => 'NpcProfileResult';

  factory NpcProfileResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    
    // For backward compatibility, check if old format (single personality)
    final hasSinglePersonality = meta.containsKey('personality') && !meta.containsKey('primaryPersonality');
    
    return NpcProfileResult(
      primaryPersonalityRoll: meta['primaryPersonalityRoll'] as int? ?? 
          (hasSinglePersonality ? meta['personalityRoll'] as int? ?? diceResults[0] : diceResults[0]),
      primaryPersonality: meta['primaryPersonality'] as String? ?? 
          (hasSinglePersonality ? meta['personality'] as String : 'Unknown'),
      secondaryPersonalityRoll: meta['secondaryPersonalityRoll'] as int? ?? diceResults[1],
      secondaryPersonality: meta['secondaryPersonality'] as String? ?? 'Unknown',
      needRoll: meta['needRoll'] as int? ?? diceResults[2],
      need: meta['need'] as String,
      motiveRoll: meta['motiveRoll'] as int? ?? diceResults[3],
      motive: meta['motive'] as String,
      needSkew: meta['needSkew'] != null
          ? NeedSkew.values.firstWhere((e) => e.name == meta['needSkew'])
          : null,
      needAllRolls: (meta['needAllRolls'] as List?)?.cast<int>(),
      focusExpansionRoll: meta['focusExpansionRoll'] as int?,
      focusExpanded: meta['focusExpanded'] as String?,
      // Note: historyResult, focusResult, color, property1, property2 cannot be fully reconstructed
      color: DetailResult(
        detailType: DetailType.color,
        roll: 0,
        result: meta['color'] as String? ?? 'Unknown',
      ),
      property1: PropertyResult(
        propertyRoll: 0,
        intensityRoll: 1,
        property: 'Unknown',
      ),
      property2: PropertyResult(
        propertyRoll: 0,
        intensityRoll: 1,
        property: 'Unknown',
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Get personality display text.
  /// If both personalities are the same, show "Very [Personality]" instead of "X, yet X"
  String get personalityDisplay => primaryPersonality == secondaryPersonality
      ? 'Very $primaryPersonality'
      : '$primaryPersonality, yet $secondaryPersonality';

  /// Get the full motive display text (with expansion if available).
  String get motiveDisplay {
    if (historyResult != null) {
      return 'History → ${historyResult!.result}';
    }
    if (focusResult != null) {
      if (focusExpanded != null) {
        return 'Focus → ${focusResult!.focus} → $focusExpanded';
      }
      return 'Focus → ${focusResult!.focus}';
    }
    return motive;
  }

  /// Get properties display text.
  String get propertiesDisplay =>
      '${property1.intensityDescription} ${property1.property} + ${property2.intensityDescription} ${property2.property}';

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Personality: $personalityDisplay');
    buffer.writeln('Need: $need');
    buffer.writeln('Motive: $motiveDisplay');
    buffer.writeln('Color: ${color.emoji ?? ''} ${color.result}');
    buffer.writeln('Properties: $propertiesDisplay');
    return buffer.toString().trim();
  }
}

/// Result of rolling dual personality traits.
/// Per instructions: "You can optionally give them a secondary personality trait."
/// Example: "Confident, yet Reserved"
class DualPersonalityResult extends RollResult {
  final int primaryRoll;
  final String primary;
  final int secondaryRoll;
  final String secondary;

  DualPersonalityResult({
    required this.primaryRoll,
    required this.primary,
    required this.secondaryRoll,
    required this.secondary,
  }) : super(
          type: RollType.npcAction,
          description: 'Dual Personality',
          diceResults: [primaryRoll, secondaryRoll],
          total: primaryRoll + secondaryRoll,
          interpretation: '$primary, yet $secondary',
          metadata: {
            'primary': primary,
            'secondary': secondary,
          },
        );

  @override
  String get className => 'DualPersonalityResult';

  /// Serialization - keep in sync with fromJson below.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'metadata': {
      'primary': primary,
      'secondary': secondary,
    },
  };

  /// Deserialization - keep in sync with toJson above.
  factory DualPersonalityResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DualPersonalityResult(
      primaryRoll: diceResults[0],
      primary: meta['primary'] as String,
      secondaryRoll: diceResults[1],
      secondary: meta['secondary'] as String,
    );
  }

  @override
  String toString() => 'Personality: $primary, yet $secondary';
}

/// Result of generating a complex NPC.
/// Per instructions (page 128-129): Complex NPCs include:
/// - Name (optional)
/// - 2 Personality traits (primary + optional secondary)
/// - Need (with advantage for people, disadvantage for monsters)
/// - Motive (with automatic expansion for History/Focus)
/// - Color (1d10)
/// - Two Properties (1d10+1d6 each)
class ComplexNpcResult extends RollResult {
  final NameResult? name;
  final int primaryPersonalityRoll;
  final String primaryPersonality;
  final int? secondaryPersonalityRoll;
  final String? secondaryPersonality;
  final int needRoll;
  final String need;
  final NeedSkew needSkew;
  final List<int> needAllRolls;
  final int motiveRoll;
  final String motive;
  /// History result when motive is "History"
  final DetailResult? historyResult;
  /// Focus result when motive is "Focus"
  final FocusResult? focusResult;
  /// Sub-roll for expanding italic Focus entries
  final int? focusExpansionRoll;
  /// Expanded value from the sub-table (e.g., "Noble" for Person)
  final String? focusExpanded;
  final DetailResult color;
  final PropertyResult property1;
  final PropertyResult property2;

  ComplexNpcResult({
    this.name,
    required this.primaryPersonalityRoll,
    required this.primaryPersonality,
    this.secondaryPersonalityRoll,
    this.secondaryPersonality,
    required this.needRoll,
    required this.need,
    required this.needSkew,
    required this.needAllRolls,
    required this.motiveRoll,
    required this.motive,
    this.historyResult,
    this.focusResult,
    this.focusExpansionRoll,
    this.focusExpanded,
    required this.color,
    required this.property1,
    required this.property2,
  }) : super(
          type: RollType.npcAction,
          description: 'Complex NPC',
          diceResults: _buildDiceResults(
            name, primaryPersonalityRoll, secondaryPersonalityRoll, 
            needAllRolls, motiveRoll, historyResult, focusResult, focusExpansionRoll,
            color, property1, property2,
          ),
          total: primaryPersonalityRoll + needRoll + motiveRoll,
          interpretation: _buildInterpretation(
            name, primaryPersonality, secondaryPersonality, need, motive,
            historyResult, focusResult, focusExpanded,
            color, property1, property2,
          ),
          metadata: _buildMetadata(
            name, primaryPersonality, secondaryPersonality, need, motive,
            historyResult, focusResult, focusExpansionRoll, focusExpanded,
            needSkew, color, property1, property2,
          ),
        );

  static List<int> _buildDiceResults(
    NameResult? name, int persRoll1, int? persRoll2,
    List<int> needRolls, int motiveRoll,
    DetailResult? historyResult, FocusResult? focusResult, int? focusExpansionRoll,
    DetailResult color,
    PropertyResult prop1, PropertyResult prop2,
  ) {
    return [
      if (name != null) ...name.diceResults,
      persRoll1,
      if (persRoll2 != null) persRoll2,
      ...needRolls,
      motiveRoll,
      if (historyResult != null) ...historyResult.diceResults,
      if (focusResult != null) ...focusResult.diceResults,
      if (focusExpansionRoll != null) focusExpansionRoll,
      color.roll,
      prop1.propertyRoll, prop1.intensityRoll,
      prop2.propertyRoll, prop2.intensityRoll,
    ];
  }

  static String _buildInterpretation(
    NameResult? name, String primary, String? secondary,
    String need, String motive,
    DetailResult? historyResult, FocusResult? focusResult, String? focusExpanded,
    DetailResult color,
    PropertyResult prop1, PropertyResult prop2,
  ) {
    final namePart = name != null ? '${name.name}: ' : '';
    final personalityPart = secondary != null 
        ? '$primary, yet $secondary' 
        : primary;
    String motiveDisplay = motive;
    if (historyResult != null) {
      motiveDisplay = 'History → ${historyResult.result}';
    } else if (focusResult != null) {
      if (focusExpanded != null) {
        motiveDisplay = 'Focus → ${focusResult.focus} → $focusExpanded';
      } else {
        motiveDisplay = 'Focus → ${focusResult.focus}';
      }
    }
    return '$namePart$personalityPart / $need / $motiveDisplay\n'
           '${color.emoji ?? ''} ${color.result}\n'
           '${prop1.intensityDescription} ${prop1.property} + ${prop2.intensityDescription} ${prop2.property}';
  }

  static Map<String, dynamic> _buildMetadata(
    NameResult? name, String primary, String? secondary,
    String need, String motive,
    DetailResult? historyResult, FocusResult? focusResult, int? focusExpansionRoll, String? focusExpanded,
    NeedSkew needSkew,
    DetailResult color, PropertyResult prop1, PropertyResult prop2,
  ) {
    return {
      if (name != null) 'nameJson': name.toJson(),
      'primaryPersonality': primary,
      if (secondary != null) 'secondaryPersonality': secondary,
      'need': need,
      'motive': motive,
      if (historyResult != null) 'historyJson': historyResult.toJson(),
      if (focusResult != null) 'focusJson': focusResult.toJson(),
      if (focusExpansionRoll != null) 'focusExpansionRoll': focusExpansionRoll,
      if (focusExpanded != null) 'focusExpanded': focusExpanded,
      'needSkew': needSkew.name,
      'colorJson': color.toJson(),
      'property1Json': prop1.toJson(),
      'property2Json': prop2.toJson(),
    };
  }

  /// Get personality display text.
  /// If both personalities are the same, show "Very [Personality]" instead of "X, yet X"
  String get personalityDisplay {
    if (secondaryPersonality == null) return primaryPersonality;
    if (primaryPersonality == secondaryPersonality) return 'Very $primaryPersonality';
    return '$primaryPersonality, yet $secondaryPersonality';
  }

  /// Get the full motive display text (with expansion if available).
  String get motiveDisplay {
    if (historyResult != null) {
      return 'History → ${historyResult!.result}';
    }
    if (focusResult != null) {
      if (focusExpanded != null) {
        return 'Focus → ${focusResult!.focus} → $focusExpanded';
      }
      return 'Focus → ${focusResult!.focus}';
    }
    return motive;
  }

  /// Get properties display text.
  String get propertiesDisplay =>
      '${property1.intensityDescription} ${property1.property} + ${property2.intensityDescription} ${property2.property}';

  @override
  String get className => 'ComplexNpcResult';

  /// Serialization - keep in sync with fromJson below.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'metadata': {
      if (name != null) 'nameJson': name!.toJson(),
      'primaryPersonalityRoll': primaryPersonalityRoll,
      'primaryPersonality': primaryPersonality,
      if (secondaryPersonalityRoll != null) 'secondaryPersonalityRoll': secondaryPersonalityRoll,
      if (secondaryPersonality != null) 'secondaryPersonality': secondaryPersonality,
      'needRoll': needRoll,
      'need': need,
      'needSkew': needSkew.name,
      'needAllRolls': needAllRolls,
      'motiveRoll': motiveRoll,
      'motive': motive,
      if (historyResult != null) 'historyJson': historyResult!.toJson(),
      if (focusResult != null) 'focusJson': focusResult!.toJson(),
      if (focusExpansionRoll != null) 'focusExpansionRoll': focusExpansionRoll,
      if (focusExpanded != null) 'focusExpanded': focusExpanded,
      'colorJson': color.toJson(),
      'property1Json': property1.toJson(),
      'property2Json': property2.toJson(),
    },
  };

  /// Deserialization - keep in sync with toJson above.
  factory ComplexNpcResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    
    // Safely cast nested Maps (JSON may return Map<dynamic, dynamic>)
    final nameJson = safeMap(meta['nameJson']);
    final historyJson = safeMap(meta['historyJson']);
    final focusJson = safeMap(meta['focusJson']);
    final colorJson = requireMap(meta['colorJson'], 'colorJson');
    final prop1Json = requireMap(meta['property1Json'], 'property1Json');
    final prop2Json = requireMap(meta['property2Json'], 'property2Json');
    
    return ComplexNpcResult(
      name: nameJson != null ? NameResult.fromJson(nameJson) : null,
      primaryPersonalityRoll: meta['primaryPersonalityRoll'] as int? ?? 0,
      primaryPersonality: meta['primaryPersonality'] as String,
      secondaryPersonalityRoll: meta['secondaryPersonalityRoll'] as int?,
      secondaryPersonality: meta['secondaryPersonality'] as String?,
      needRoll: meta['needRoll'] as int? ?? 0,
      need: meta['need'] as String,
      needSkew: NeedSkew.values.byName(meta['needSkew'] as String),
      needAllRolls: safeIntListOrEmpty(meta['needAllRolls']),
      motiveRoll: meta['motiveRoll'] as int? ?? 0,
      motive: meta['motive'] as String,
      historyResult: historyJson != null ? DetailResult.fromJson(historyJson) : null,
      focusResult: focusJson != null ? FocusResult.fromJson(focusJson) : null,
      focusExpansionRoll: meta['focusExpansionRoll'] as int?,
      focusExpanded: meta['focusExpanded'] as String?,
      color: DetailResult.fromJson(colorJson),
      property1: PropertyResult.fromJson(prop1Json),
      property2: PropertyResult.fromJson(prop2Json),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (name != null) {
      buffer.writeln('Name: ${name!.name}');
    }
    buffer.writeln('Personality: $personalityDisplay');
    buffer.writeln('Need: $need (${needSkew.name})');
    buffer.writeln('Motive: $motiveDisplay');
    buffer.writeln('Color: ${color.emoji ?? ''} ${color.result}');
    buffer.writeln('Properties: $propertiesDisplay');
    return buffer.toString().trim();
  }
}

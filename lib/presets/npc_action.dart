import '../core/roll_engine.dart';
import '../data/npc_action_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/npc_action_result.dart';

import '../models/results/npc_action_result.dart';
import 'details.dart';
import 'dungeon_generator.dart';
import 'name_generator.dart';
import 'next_scene.dart';
import 'random_event.dart';
import 'settlement.dart';
import 'wilderness.dart';

/// NPC Action preset for the Juice Oracle.
/// Determines NPC behavior using npc-action.md tables.
/// 
/// Header notation: Disp: d 10A/6P; Ctx: @+A/-P; WH: ΔCtx, SH: ΔCtx & +/-1
/// - Disposition: d10 for Active, d6 for Passive
/// - Context: Roll with Advantage for Active, Disadvantage for Passive
/// - Weak Hit (social check): Change Context
/// - Strong Hit (social check): Change Context AND add/subtract 1 from roll
/// 
/// **Data Separation:**
/// Static table data is stored in data/npc_action_data.dart.
/// This class provides backward-compatible static accessors.
class NpcAction {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Personality traits - d10 (0-9 mapped to 1-10)
  static List<String> get personalities => data.npcPersonalities;

  /// NPC needs - d10
  static List<String> get needs => data.npcNeeds;

  /// Motive/Topic - d10
  static List<String> get motives => data.npcMotives;

  /// Actions - d10
  static List<String> get actions => data.npcActions;

  /// Combat actions - d10
  static List<String> get combatActions => data.npcCombatActions;

  /// Focus entries that require sub-rolls (italic in the original table)
  static const Set<String> _italicFocuses = {
    'Monster', 'Event', 'Environment', 'Person', 'Location', 'Object'
  };

  late final Details _details;
  late final NextScene _nextScene;
  
  // Lazy settlement to avoid circular dependency with Settlement -> NpcAction
  Settlement? _settlement;
  Settlement get _settlementLazy => _settlement ??= Settlement(_rollEngine);

  NpcAction([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine() {
    _details = Details(_rollEngine);
    _nextScene = NextScene(_rollEngine);
  }

  /// Helper to get index from roll (handles 10 -> 9)
  int _getIndex(int roll) => roll == 10 ? 9 : roll - 1;

  /// Roll for a single NPC action with disposition and context.
  /// 
  /// Per the instructions:
  /// - Passive Disposition: Roll d6
  /// - Active Disposition: Roll d10
  /// - Active Context: Roll with advantage
  /// - Passive Context: Roll with disadvantage
  NpcActionResult rollAction({
    NpcDisposition disposition = NpcDisposition.active,
    NpcContext context = NpcContext.active,
  }) {
    final dieSize = disposition == NpcDisposition.passive ? 6 : 10;
    int roll;
    List<int> allRolls = [];
    
    if (context == NpcContext.active) {
      // Roll with advantage
      final result = _rollEngine.rollWithAdvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    } else if (context == NpcContext.passive) {
      // Roll with disadvantage
      final result = _rollEngine.rollWithDisadvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    } else {
      roll = _rollEngine.rollDie(dieSize);
      allRolls = [roll];
    }
    
    final index = _getIndex(roll);
    final action = actions[index];

    return NpcActionResult(
      column: NpcColumn.action,
      roll: roll,
      result: action,
      dieSize: dieSize,
      allRolls: allRolls,
      disposition: disposition,
      context: context,
    );
  }

  /// Roll for NPC personality (2 traits recommended for primary/secondary).
  NpcActionResult rollPersonality() {
    final roll = _rollEngine.rollDie(10);
    final index = _getIndex(roll);
    final personality = personalities[index];

    return NpcActionResult(
      column: NpcColumn.personality,
      roll: roll,
      result: personality,
    );
  }

  /// Roll for NPC need with optional skew.
  /// Disadvantage = more primitive needs (sustenance, shelter)
  /// Advantage = more complex needs (status, recognition, fulfillment)
  NpcActionResult rollNeed({NeedSkew skew = NeedSkew.none}) {
    final (:roll, :allRolls) = _rollEngine.rollWithSkewEnum(
      10,
      skew,
      noneValue: NeedSkew.none,
      advantageValue: NeedSkew.complex,
    );
    
    final index = _getIndex(roll);
    final need = needs[index];

    return NpcActionResult(
      column: NpcColumn.need,
      roll: roll,
      result: need,
      allRolls: allRolls,
      needSkew: skew,
    );
  }

  /// Roll for NPC motive/topic.
  /// Note: If result is "History" or "Focus", roll on those respective tables.
  NpcActionResult rollMotive() {
    final roll = _rollEngine.rollDie(10);
    final index = _getIndex(roll);
    final motive = motives[index];

    return NpcActionResult(
      column: NpcColumn.motive,
      roll: roll,
      result: motive,
    );
  }

  /// Expand a focus entry by rolling on the appropriate sub-table.
  /// Returns [subRoll, expandedValue] or null if no expansion needed.
  /// 
  /// Italic Focus entries that need expansion:
  /// - Monster → Monster Descriptors table
  /// - Event → Event table
  /// - Environment → Environment table
  /// - Person → Person table
  /// - Location → Settlement Name
  /// - Object → Object table
  List<dynamic>? _expandFocus(String focus) {
    if (!_italicFocuses.contains(focus)) return null;

    final subRoll = _rollEngine.rollDie(10);
    final subIndex = subRoll == 10 ? 9 : subRoll - 1;
    String expanded;

    switch (focus) {
      case 'Monster':
        // Use monster descriptors from dungeon generator
        expanded = DungeonGenerator.monsterDescriptors[subIndex];
        break;
      case 'Event':
        // Use event words from random event
        expanded = RandomEvent.eventWords[subIndex];
        break;
      case 'Environment':
        // Use wilderness environments
        expanded = Wilderness.environments[subIndex];
        break;
      case 'Person':
        // Use person words from random event
        expanded = RandomEvent.personWords[subIndex];
        break;
      case 'Location':
        // Generate a settlement name for location
        final name = _settlementLazy.generateName();
        return [subRoll, name.name];
      case 'Object':
        // Use object words from random event
        expanded = RandomEvent.objectWords[subIndex];
        break;
      default:
        return null;
    }
    return [subRoll, expanded];
  }

  /// Expand a motive into History or Focus sub-rolls if applicable.
  /// 
  /// If motive is "History", rolls on the History table.
  /// If motive is "Focus", rolls on the Focus table and potentially
  /// expands further for italic focus entries.
  /// 
  /// Returns a record with all expansion fields (null if not applicable).
  ({
    DetailResult? historyResult,
    FocusResult? focusResult,
    int? focusExpansionRoll,
    String? focusExpanded,
  }) _expandMotive(String motive) {
    if (motive == 'History') {
      return (
        historyResult: _details.rollHistory(),
        focusResult: null,
        focusExpansionRoll: null,
        focusExpanded: null,
      );
    } else if (motive == 'Focus') {
      final focusResult = _nextScene.rollFocus();
      final expansion = _expandFocus(focusResult.focus);
      return (
        historyResult: null,
        focusResult: focusResult,
        focusExpansionRoll: expansion?[0] as int?,
        focusExpanded: expansion?[1] as String?,
      );
    }
    return (
      historyResult: null,
      focusResult: null,
      focusExpansionRoll: null,
      focusExpanded: null,
    );
  }

  /// Roll for NPC motive/topic with automatic follow-up.
  /// If result is "History", automatically rolls on the History table.
  /// If result is "Focus", automatically rolls on the Focus table,
  /// and if that Focus is italic (Monster/Event/Environment/Person/Location/Object),
  /// further expands it by rolling on the appropriate sub-table.
  MotiveWithFollowUpResult rollMotiveWithFollowUp() {
    final roll = _rollEngine.rollDie(10);
    final index = _getIndex(roll);
    final motive = motives[index];

    final expansion = _expandMotive(motive);

    return MotiveWithFollowUpResult(
      roll: roll,
      motive: motive,
      historyResult: expansion.historyResult,
      focusResult: expansion.focusResult,
      focusExpansionRoll: expansion.focusExpansionRoll,
      focusExpanded: expansion.focusExpanded,
    );
  }

  /// Roll for combat action with focus and objective.
  /// 
  /// Per the instructions:
  /// - Passive Focus: Roll d6 (defensive/warning actions)
  /// - Active Focus: Roll d10 (full combat actions)
  /// - Defensive Objective: Roll with disadvantage
  /// - Offensive Objective: Roll with advantage
  NpcActionResult rollCombatAction({
    NpcFocus focus = NpcFocus.active,
    NpcObjective objective = NpcObjective.offensive,
  }) {
    final dieSize = focus == NpcFocus.passive ? 6 : 10;
    int roll;
    List<int> allRolls = [];
    
    if (objective == NpcObjective.offensive) {
      // Roll with advantage
      final result = _rollEngine.rollWithAdvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    } else {
      // Roll with disadvantage
      final result = _rollEngine.rollWithDisadvantage(1, dieSize);
      roll = result.chosenSum;
      allRolls = [result.sum1, result.sum2];
    }
    
    final index = _getIndex(roll);
    final combatAction = combatActions[index];

    return NpcActionResult(
      column: NpcColumn.combat,
      roll: roll,
      result: combatAction,
      dieSize: dieSize,
      allRolls: allRolls,
      focus: focus,
      objective: objective,
    );
  }

  /// Generate a full NPC profile.
  /// Per instructions (page 128-129): Full NPC profile includes:
  /// - 2 Personality traits (primary + secondary)
  /// - Need (with optional skew - advantage for people, disadvantage for monsters)
  /// - Motive (with automatic expansion for History/Focus)
  /// - Color (1d10)
  /// - Two Properties (1d10+1d6 each)
  NpcProfileResult generateProfile({NeedSkew needSkew = NeedSkew.none}) {
    // Two personality traits
    final persRoll1 = _rollEngine.rollDie(10);
    final persRoll2 = _rollEngine.rollDie(10);
    final primaryPersonality = personalities[_getIndex(persRoll1)];
    final secondaryPersonality = personalities[_getIndex(persRoll2)];
    
    // Handle need with skew
    final (roll: needRoll, allRolls: needAllRolls) = _rollEngine.rollWithSkewEnum(
      10,
      needSkew,
      noneValue: NeedSkew.none,
      advantageValue: NeedSkew.complex,
    );
    
    final motiveRoll = _rollEngine.rollDie(10);

    final need = needs[_getIndex(needRoll)];
    final motive = motives[_getIndex(motiveRoll)];
    
    // Handle motive expansion for History and Focus
    final motiveExpansion = _expandMotive(motive);
    
    // Color (1d10)
    final colorResult = _details.rollColor();
    
    // Two Properties (1d10+1d6 each)
    final property1 = _details.rollProperty();
    final property2 = _details.rollProperty();

    return NpcProfileResult(
      primaryPersonalityRoll: persRoll1,
      primaryPersonality: primaryPersonality,
      secondaryPersonalityRoll: persRoll2,
      secondaryPersonality: secondaryPersonality,
      needRoll: needRoll,
      need: need,
      motiveRoll: motiveRoll,
      motive: motive,
      needSkew: needSkew,
      needAllRolls: needAllRolls,
      historyResult: motiveExpansion.historyResult,
      focusResult: motiveExpansion.focusResult,
      focusExpansionRoll: motiveExpansion.focusExpansionRoll,
      focusExpanded: motiveExpansion.focusExpanded,
      color: colorResult,
      property1: property1,
      property2: property2,
    );
  }

  /// Generate a simple NPC profile (personality + need + motive only).
  /// Per instructions (page 128): Simple NPC has just:
  /// - 1 Personality trait
  /// - Need
  /// - Motive (with automatic expansion for History/Focus)
  /// Used for NPCs like shop owners where you don't need full detail.
  SimpleNpcProfileResult generateSimpleProfile({NeedSkew needSkew = NeedSkew.none}) {
    final persRoll = _rollEngine.rollDie(10);
    
    // Handle need with skew
    final (roll: needRoll, allRolls: needAllRolls) = _rollEngine.rollWithSkewEnum(
      10,
      needSkew,
      noneValue: NeedSkew.none,
      advantageValue: NeedSkew.complex,
    );
    
    final motiveRoll = _rollEngine.rollDie(10);

    final personality = personalities[_getIndex(persRoll)];
    final need = needs[_getIndex(needRoll)];
    final motive = motives[_getIndex(motiveRoll)];
    
    // Handle motive expansion for History and Focus
    final motiveExpansion = _expandMotive(motive);

    return SimpleNpcProfileResult(
      personalityRoll: persRoll,
      personality: personality,
      needRoll: needRoll,
      need: need,
      motiveRoll: motiveRoll,
      motive: motive,
      needSkew: needSkew,
      needAllRolls: needAllRolls,
      historyResult: motiveExpansion.historyResult,
      focusResult: motiveExpansion.focusResult,
      focusExpansionRoll: motiveExpansion.focusExpansionRoll,
      focusExpanded: motiveExpansion.focusExpanded,
    );
  }

  /// Generate a dual personality (primary + secondary traits).
  /// Per instructions: "You can optionally give them a secondary personality trait."
  /// Example: "Confident, yet Reserved"
  DualPersonalityResult rollDualPersonality() {
    final roll1 = _rollEngine.rollDie(10);
    final roll2 = _rollEngine.rollDie(10);
    
    final primary = personalities[_getIndex(roll1)];
    final secondary = personalities[_getIndex(roll2)];
    
    return DualPersonalityResult(
      primaryRoll: roll1,
      primary: primary,
      secondaryRoll: roll2,
      secondary: secondary,
    );
  }

  /// Generate a complex NPC profile.
  /// Per instructions (page 128-129): For complex NPCs like sidekicks:
  /// - Name (via NameGenerator)
  /// - 2 Personality traits (primary, optionally secondary)
  /// - Need (with advantage for people, disadvantage for monsters)
  /// - Motive (with automatic expansion for History/Focus)
  /// - Color (1d10)
  /// - Two Properties (1d10+1d6 each)
  /// 
  /// Example from instructions:
  /// "Demor is someone with high self esteem who always sees the best in people,
  /// and yearns for people to someday see the best in them as well. They are
  /// trying to earn money. Demor has average looks and is pretty thin."
  ComplexNpcResult generateComplexNpc({
    NeedSkew needSkew = NeedSkew.complex, // Default to @+ for people NPCs
    bool includeName = true,
    bool dualPersonality = true,
  }) {
    final details = Details(_rollEngine);
    
    // Name (optional)
    NameResult? nameResult;
    if (includeName) {
      final nameGen = NameGenerator(_rollEngine);
      nameResult = nameGen.generatePatternNeutral();
    }
    
    // Personality (1 or 2 traits)
    final persRoll1 = _rollEngine.rollDie(10);
    final primary = personalities[_getIndex(persRoll1)];
    int? persRoll2;
    String? secondary;
    if (dualPersonality) {
      persRoll2 = _rollEngine.rollDie(10);
      secondary = personalities[_getIndex(persRoll2)];
    }
    
    // Need with skew
    final (roll: needRoll, allRolls: needAllRolls) = _rollEngine.rollWithSkewEnum(
      10,
      needSkew,
      noneValue: NeedSkew.none,
      advantageValue: NeedSkew.complex,
    );
    final need = needs[_getIndex(needRoll)];
    
    // Motive with expansion for History/Focus
    final motiveRoll = _rollEngine.rollDie(10);
    final motive = motives[_getIndex(motiveRoll)];
    
    // Handle motive expansion for History and Focus
    final motiveExpansion = _expandMotive(motive);
    
    // Color (1d10)
    final colorResult = details.rollColor();
    
    // Two Properties (1d10+1d6 each)
    final property1 = details.rollProperty();
    final property2 = details.rollProperty();
    
    return ComplexNpcResult(
      name: nameResult,
      primaryPersonalityRoll: persRoll1,
      primaryPersonality: primary,
      secondaryPersonalityRoll: persRoll2,
      secondaryPersonality: secondary,
      needRoll: needRoll,
      need: need,
      needSkew: needSkew,
      needAllRolls: needAllRolls,
      motiveRoll: motiveRoll,
      motive: motive,
      historyResult: motiveExpansion.historyResult,
      focusResult: motiveExpansion.focusResult,
      focusExpansionRoll: motiveExpansion.focusExpansionRoll,
      focusExpanded: motiveExpansion.focusExpanded,
      color: colorResult,
      property1: property1,
      property2: property2,
    );
  }
}

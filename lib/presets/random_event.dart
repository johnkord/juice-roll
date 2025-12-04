import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Random Event preset for the Juice Oracle.
/// Generates random events using the tables from random-event-challenge.md and random-tables.md.
/// Uses 3d10: Event Focus + Modifier + Idea.
class RandomEvent {
  final RollEngine _rollEngine;

  /// Event focus types - d10 (from random-event-challenge.md)
  static const List<String> eventFocusTypes = [
    'Advance Time',    // 1
    'Close Thread',    // 2
    'Converge Thread', // 3
    'Diverge Thread',  // 4
    'Immersion',       // 5
    'Keyed Event',     // 6
    'New Character',   // 7
    'NPC Action',      // 8
    'Plot Armor',      // 9
    'Remote Event',    // 0/10
  ];

  /// Modifier words - d10 (from random-tables.md)
  static const List<String> modifierWords = [
    'Change',     // 1
    'Continue',   // 2
    'Decrease',   // 3
    'Extra',      // 4
    'Increase',   // 5
    'Mundane',    // 6
    'Mysterious', // 7
    'Start',      // 8
    'Stop',       // 9
    'Strange',    // 0/10
  ];

  /// Idea words (1-3) - d10
  static const List<String> ideaWords = [
    'Attention',     // 1
    'Communication', // 2
    'Danger',        // 3
    'Element',       // 4
    'Food',          // 5
    'Home',          // 6
    'Resource',      // 7
    'Rumor',         // 8
    'Secret',        // 9
    'Vow',           // 0/10
  ];

  /// Event words (4-6) - d10
  static const List<String> eventWords = [
    'Ambush',    // 1
    'Anomaly',   // 2
    'Blessing',  // 3
    'Caravan',   // 4
    'Curse',     // 5
    'Discovery', // 6
    'Escape',    // 7
    'Journey',   // 8
    'Prophecy',  // 9
    'Ritual',    // 0/10
  ];

  /// Person words (7-8) - d10
  static const List<String> personWords = [
    'Criminal',    // 1
    'Entertainer', // 2
    'Expert',      // 3
    'Mage',        // 4
    'Mercenary',   // 5
    'Noble',       // 6
    'Priest',      // 7
    'Ranger',      // 8
    'Soldier',     // 9
    'Transporter', // 0/10
  ];

  /// Object words (9-0) - d10
  static const List<String> objectWords = [
    'Arrow',     // 1
    'Candle',    // 2
    'Cauldron',  // 3
    'Chain',     // 4
    'Claw',      // 5
    'Hook',      // 6
    'Hourglass', // 7
    'Quill',     // 8
    'Rose',      // 9
    'Skull',     // 0/10
  ];

  RandomEvent([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a random event (3d10).
  RandomEventResult generate() {
    // Roll for focus type (d10)
    final focusRoll = _rollEngine.rollDie(10);
    final focusIndex = focusRoll == 10 ? 9 : focusRoll - 1;
    final focus = eventFocusTypes[focusIndex];

    // Roll for modifier (d10)
    final modifierRoll = _rollEngine.rollDie(10);
    final modifierIndex = modifierRoll == 10 ? 9 : modifierRoll - 1;
    final modifier = modifierWords[modifierIndex];

    // Roll for idea category (d10) - separate from word roll
    final categoryRoll = _rollEngine.rollDie(10);
    
    // Roll for word within category (d10)
    final ideaRoll = _rollEngine.rollDie(10);
    final ideaIndex = ideaRoll == 10 ? 9 : ideaRoll - 1;
    
    // Determine which idea list based on category roll
    String idea;
    String ideaCategory;
    if (categoryRoll >= 1 && categoryRoll <= 3) {
      idea = ideaWords[ideaIndex];
      ideaCategory = 'Idea';
    } else if (categoryRoll >= 4 && categoryRoll <= 6) {
      idea = eventWords[ideaIndex];
      ideaCategory = 'Event';
    } else if (categoryRoll >= 7 && categoryRoll <= 8) {
      idea = personWords[ideaIndex];
      ideaCategory = 'Person';
    } else {
      idea = objectWords[ideaIndex];
      ideaCategory = 'Object';
    }

    return RandomEventResult(
      focusRoll: focusRoll,
      focus: focus,
      modifierRoll: modifierRoll,
      modifier: modifier,
      ideaRoll: ideaRoll,
      idea: idea,
      ideaCategory: ideaCategory,
    );
  }

  /// Generate just a modifier + idea pair (for Alter Scene).
  /// If category is specified, uses that category's word list.
  IdeaResult generateIdea({IdeaCategory? category}) {
    final modifierRoll = _rollEngine.rollDie(10);
    final modifierIndex = modifierRoll == 10 ? 9 : modifierRoll - 1;
    final modifier = modifierWords[modifierIndex];

    final ideaRoll = _rollEngine.rollDie(10);
    final ideaIndex = ideaRoll == 10 ? 9 : ideaRoll - 1;
    
    String idea;
    String ideaCategory;
    IdeaCategory resolvedCategory;
    
    if (category != null) {
      // Use the specified category
      resolvedCategory = category;
    } else {
      // Roll separately to determine category (1-3: Idea, 4-6: Event, 7-8: Person, 9-0: Object)
      final categoryRoll = _rollEngine.rollDie(10);
      if (categoryRoll >= 1 && categoryRoll <= 3) {
        resolvedCategory = IdeaCategory.idea;
      } else if (categoryRoll >= 4 && categoryRoll <= 6) {
        resolvedCategory = IdeaCategory.event;
      } else if (categoryRoll >= 7 && categoryRoll <= 8) {
        resolvedCategory = IdeaCategory.person;
      } else {
        resolvedCategory = IdeaCategory.object;
      }
    }
    
    // Use the resolved category to pick the word
    switch (resolvedCategory) {
      case IdeaCategory.idea:
        idea = ideaWords[ideaIndex];
        ideaCategory = 'Idea';
      case IdeaCategory.event:
        idea = eventWords[ideaIndex];
        ideaCategory = 'Event';
      case IdeaCategory.person:
        idea = personWords[ideaIndex];
        ideaCategory = 'Person';
      case IdeaCategory.object:
        idea = objectWords[ideaIndex];
        ideaCategory = 'Object';
    }

    return IdeaResult(
      modifierRoll: modifierRoll,
      modifier: modifier,
      ideaRoll: ideaRoll,
      idea: idea,
      ideaCategory: ideaCategory,
    );
  }

  /// Generate a random event focus only (for Fate Check triggers).
  RandomEventFocusResult generateFocus() {
    final focusRoll = _rollEngine.rollDie(10);
    final focusIndex = focusRoll == 10 ? 9 : focusRoll - 1;
    final focus = eventFocusTypes[focusIndex];

    return RandomEventFocusResult(
      focusRoll: focusRoll,
      focus: focus,
    );
  }

  /// Roll on the Modifier table only (d10).
  SingleTableResult rollModifier() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    return SingleTableResult(
      roll: roll,
      result: modifierWords[index],
      tableName: 'Modifier',
    );
  }

  /// Roll on the Idea table only (d10).
  SingleTableResult rollIdea() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    return SingleTableResult(
      roll: roll,
      result: ideaWords[index],
      tableName: 'Idea',
    );
  }

  /// Roll on the Event table only (d10).
  SingleTableResult rollEvent() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    return SingleTableResult(
      roll: roll,
      result: eventWords[index],
      tableName: 'Event',
    );
  }

  /// Roll on the Person table only (d10).
  SingleTableResult rollPerson() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    return SingleTableResult(
      roll: roll,
      result: personWords[index],
      tableName: 'Person',
    );
  }

  /// Roll on the Object table only (d10).
  SingleTableResult rollObject() {
    final roll = _rollEngine.rollDie(10);
    final index = roll == 10 ? 9 : roll - 1;
    return SingleTableResult(
      roll: roll,
      result: objectWords[index],
      tableName: 'Object',
    );
  }

  /// Roll Modifier + Idea (2d10) - replaces Random Event in Simple mode.
  /// Also used when Next Scene is "Altered".
  IdeaResult rollModifierPlusIdea() {
    final modifierRoll = _rollEngine.rollDie(10);
    final modifierIndex = modifierRoll == 10 ? 9 : modifierRoll - 1;
    final modifier = modifierWords[modifierIndex];

    final ideaRoll = _rollEngine.rollDie(10);
    final ideaIndex = ideaRoll == 10 ? 9 : ideaRoll - 1;
    final idea = ideaWords[ideaIndex];

    return IdeaResult(
      modifierRoll: modifierRoll,
      modifier: modifier,
      ideaRoll: ideaRoll,
      idea: idea,
      ideaCategory: 'Idea',
    );
  }
}

/// Categories for idea generation
enum IdeaCategory {
  idea,   // 1-3 on d10
  event,  // 4-6 on d10
  person, // 7-8 on d10
  object, // 9-0 on d10
}

/// Result of a Random Event generation.
class RandomEventResult extends RollResult {
  final int focusRoll;
  final String focus;
  final int modifierRoll;
  final String modifier;
  final int ideaRoll;
  final String idea;
  final String ideaCategory;

  RandomEventResult({
    required this.focusRoll,
    required this.focus,
    required this.modifierRoll,
    required this.modifier,
    required this.ideaRoll,
    required this.idea,
    required this.ideaCategory,
  }) : super(
          type: RollType.randomEvent,
          description: 'Random Event',
          diceResults: [focusRoll, modifierRoll, ideaRoll],
          total: focusRoll + modifierRoll + ideaRoll,
          interpretation: '$focus: $modifier $idea',
          metadata: {
            'focus': focus,
            'modifier': modifier,
            'idea': idea,
            'ideaCategory': ideaCategory,
          },
        );

  String get eventPhrase => '$modifier $idea';

  @override
  String toString() => 'Random Event: $focus - $modifier $idea';
}

/// Result of an Idea generation (modifier + idea).
class IdeaResult extends RollResult {
  final int modifierRoll;
  final String modifier;
  final int ideaRoll;
  final String idea;
  final String ideaCategory;

  IdeaResult({
    required this.modifierRoll,
    required this.modifier,
    required this.ideaRoll,
    required this.idea,
    required this.ideaCategory,
  }) : super(
          type: RollType.randomEvent,
          description: ideaCategory,
          diceResults: [modifierRoll, ideaRoll],
          total: modifierRoll + ideaRoll,
          interpretation: '$modifier $idea',
          metadata: {
            'modifier': modifier,
            'idea': idea,
            'ideaCategory': ideaCategory,
          },
        );

  String get phrase => '$modifier $idea';

  @override
  String toString() => '$ideaCategory: $modifier $idea';
}

/// Result of a Random Event Focus generation (for Fate Check triggers).
class RandomEventFocusResult extends RollResult {
  final int focusRoll;
  final String focus;

  RandomEventFocusResult({
    required this.focusRoll,
    required this.focus,
  }) : super(
          type: RollType.randomEvent,
          description: 'Random Event Focus',
          diceResults: [focusRoll],
          total: focusRoll,
          interpretation: focus,
          metadata: {
            'focus': focus,
          },
        );

  @override
  String toString() => 'Random Event: $focus';
}

/// Result of rolling on a single table (Modifier, Idea, Event, Person, or Object).
class SingleTableResult extends RollResult {
  final int roll;
  final String result;
  final String tableName;

  SingleTableResult({
    required this.roll,
    required this.result,
    required this.tableName,
  }) : super(
          type: RollType.randomEvent,
          description: tableName,
          diceResults: [roll],
          total: roll,
          interpretation: result,
          metadata: {
            'tableName': tableName,
            'result': result,
          },
        );

  @override
  String toString() => '$tableName: $result';
}

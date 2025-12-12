import '../core/roll_engine.dart';
import '../data/random_event_data.dart' as data;

// Re-export result classes for backward compatibility
export '../models/results/random_event_result.dart';

import '../models/results/random_event_result.dart';

/// Random Event preset for the Juice Oracle.
/// Generates random events using the tables from random-event-challenge.md and random-tables.md.
/// Uses 3d10: Event Focus + Modifier + Idea.
class RandomEvent {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Event focus types - d10 (from random-event-challenge.md)
  static List<String> get eventFocusTypes => data.eventFocusTypes;

  /// Modifier words - d10 (from random-tables.md)
  static List<String> get modifierWords => data.modifierWords;

  /// Idea words (1-3) - d10
  static List<String> get ideaWords => data.ideaWords;

  /// Event words (4-6) - d10
  static List<String> get eventWords => data.eventWords;

  /// Person words (7-8) - d10
  static List<String> get personWords => data.personWords;

  /// Object words (9-0) - d10
  static List<String> get objectWords => data.objectWords;

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

import '../roll_result.dart';

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
    this.ideaCategory = 'Idea',
    DateTime? timestamp,
  }) : super(
          type: RollType.randomEvent,
          description: 'Random Event',
          diceResults: [focusRoll, modifierRoll, ideaRoll],
          total: focusRoll + modifierRoll + ideaRoll,
          interpretation: '$focus: $modifier $idea',
          timestamp: timestamp,
          metadata: {
            'focus': focus,
            'focusRoll': focusRoll,
            'modifier': modifier,
            'modifierRoll': modifierRoll,
            'idea': idea,
            'ideaRoll': ideaRoll,
            'ideaCategory': ideaCategory,
          },
        );

  @override
  String get className => 'RandomEventResult';

  factory RandomEventResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return RandomEventResult(
      focusRoll: meta['focusRoll'] as int? ?? (json['diceResults'] as List).first as int,
      focus: meta['focus'] as String,
      modifierRoll: meta['modifierRoll'] as int? ?? 0,
      modifier: meta['modifier'] as String,
      ideaRoll: meta['ideaRoll'] as int? ?? 0,
      idea: meta['idea'] as String,
      ideaCategory: meta['ideaCategory'] as String? ?? 'Idea',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.randomEvent,
          description: ideaCategory,
          diceResults: [modifierRoll, ideaRoll],
          total: modifierRoll + ideaRoll,
          interpretation: '$modifier $idea',
          timestamp: timestamp,
          metadata: {
            'modifier': modifier,
            'modifierRoll': modifierRoll,
            'idea': idea,
            'ideaRoll': ideaRoll,
            'ideaCategory': ideaCategory,
          },
        );

  @override
  String get className => 'IdeaResult';

  factory IdeaResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IdeaResult(
      modifierRoll: meta['modifierRoll'] as int? ?? 0,
      modifier: meta['modifier'] as String,
      ideaRoll: meta['ideaRoll'] as int? ?? 0,
      idea: meta['idea'] as String,
      ideaCategory: meta['ideaCategory'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.randomEvent,
          description: 'Random Event Focus',
          diceResults: [focusRoll],
          total: focusRoll,
          interpretation: focus,
          timestamp: timestamp,
          metadata: {
            'focus': focus,
            'focusRoll': focusRoll,
          },
        );

  @override
  String get className => 'RandomEventFocusResult';

  factory RandomEventFocusResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return RandomEventFocusResult(
      focusRoll: meta['focusRoll'] as int? ?? (json['diceResults'] as List).first as int,
      focus: meta['focus'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

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
    DateTime? timestamp,
  }) : super(
          type: RollType.randomEvent,
          description: tableName,
          diceResults: [roll],
          total: roll,
          interpretation: result,
          timestamp: timestamp,
          metadata: {
            'tableName': tableName,
            'result': result,
            'roll': roll,
          },
        );

  @override
  String get className => 'SingleTableResult';

  factory SingleTableResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return SingleTableResult(
      roll: meta['roll'] as int? ?? (json['diceResults'] as List).first as int,
      result: meta['result'] as String,
      tableName: meta['tableName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => '$tableName: $result';
}

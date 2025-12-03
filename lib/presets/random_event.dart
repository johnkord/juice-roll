import '../core/roll_engine.dart';
import '../core/table_lookup.dart';
import '../models/roll_result.dart';

/// Random Event preset for the Juice Oracle.
/// Generates random events using modifier + idea (action + subject) tables.
class RandomEvent {
  final RollEngine _rollEngine;

  /// Event focus table (what the event is about) - 2d6.
  static final LookupTable<EventFocus> _focusTable = LookupTable(
    name: 'Event Focus',
    entries: [
      const TableEntry(minValue: 2, maxValue: 3, result: EventFocus.pc),
      const TableEntry(minValue: 4, maxValue: 5, result: EventFocus.npc),
      const TableEntry(minValue: 6, maxValue: 8, result: EventFocus.current),
      const TableEntry(minValue: 9, maxValue: 10, result: EventFocus.remote),
      const TableEntry(minValue: 11, maxValue: 12, result: EventFocus.thread),
    ],
  );

  /// Action words for idea generation.
  static const List<String> actionWords = [
    'Attainment', 'Starting', 'Neglect', 'Fight', 'Recruit',
    'Triumph', 'Violate', 'Oppose', 'Malice', 'Communicate',
    'Persecute', 'Increase', 'Decrease', 'Abandon', 'Gratify',
    'Inquire', 'Antagonize', 'Move', 'Waste', 'Truce',
    'Release', 'Befriend', 'Judge', 'Desert', 'Dominate',
    'Procrastinate', 'Praise', 'Separate', 'Take', 'Break',
    'Heal', 'Delay', 'Stop', 'Lie', 'Return',
    'Immitate', 'Struggle', 'Inform', 'Bestow', 'Postpone',
    'Expose', 'Haggle', 'Imprison', 'Release', 'Celebrate',
    'Develop', 'Travel', 'Block', 'Harm', 'Debase',
    'Overindulge', 'Adjourn', 'Adversity', 'Kill', 'Disrupt',
    'Usurp', 'Create', 'Betray', 'Agree', 'Abuse',
    'Oppress', 'Inspect', 'Ambush', 'Spy', 'Attach',
    'Carry', 'Open', 'Carelessness', 'Ruin', 'Extravagance',
    'Trick', 'Arrive', 'Propose', 'Divide', 'Refuse',
    'Mistrust', 'Deceive', 'Cruelty', 'Intolerance', 'Trust',
    'Excitement', 'Activity', 'Assist', 'Care', 'Negligence',
    'Passion', 'Work', 'Control', 'Attract', 'Failure',
    'Pursue', 'Vengeance', 'Proceedings', 'Dispute', 'Punish',
    'Guide', 'Transform', 'Overthrow', 'Oppress', 'Change',
  ];

  /// Subject words for idea generation.
  static const List<String> subjectWords = [
    'Goals', 'Dreams', 'Environment', 'Outside', 'Inside',
    'Reality', 'Allies', 'Enemies', 'Evil', 'Good',
    'Emotions', 'Opposition', 'War', 'Peace', 'Innocent',
    'Love', 'Spirit', 'Intellect', 'Ideas', 'Joy',
    'Messages', 'Energy', 'Balance', 'Tension', 'Friendship',
    'Physical', 'Project', 'Pleasures', 'Pain', 'Possessions',
    'Status', 'Revenge', 'Illness', 'Food', 'Attention',
    'Success', 'Failure', 'Travel', 'Jealousy', 'Dispute',
    'Home', 'Investment', 'Suffering', 'Wishes', 'Tactics',
    'Stalemate', 'Randomness', 'Misfortune', 'Death', 'Disruption',
    'Power', 'Burden', 'Intrigues', 'Fears', 'Ambush',
    'Rumor', 'Wounds', 'Extravagance', 'Representative', 'Adversities',
    'Opulence', 'Liberty', 'Military', 'Mundane', 'Trials',
    'Masses', 'Vehicle', 'Art', 'Victory', 'Dispute',
    'Riches', 'Normal', 'Technology', 'Hope', 'Magic',
    'Illusions', 'Portals', 'Danger', 'Weapons', 'Animals',
    'Weather', 'Elements', 'Nature', 'Masses', 'Leadership',
    'Fame', 'Anger', 'Information', 'Bureaucracy', 'Business',
    'Path', 'News', 'Exterior', 'Advice', 'Plot',
    'Competition', 'Prison', 'Allies', 'Stranger', 'Benefits',
  ];

  RandomEvent([RollEngine? rollEngine]) 
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a random event.
  RandomEventResult generate() {
    // Roll for focus (2d6)
    final focusDice = _rollEngine.rollDice(2, 6);
    final focusSum = focusDice.reduce((a, b) => a + b);
    final focus = _focusTable.lookup(focusSum) ?? EventFocus.current;

    // Roll for action (d100)
    final actionRoll = _rollEngine.rollDie(100);
    final action = actionWords[(actionRoll - 1) % actionWords.length];

    // Roll for subject (d100)
    final subjectRoll = _rollEngine.rollDie(100);
    final subject = subjectWords[(subjectRoll - 1) % subjectWords.length];

    return RandomEventResult(
      focusDice: focusDice,
      focusTotal: focusSum,
      focus: focus,
      actionRoll: actionRoll,
      action: action,
      subjectRoll: subjectRoll,
      subject: subject,
    );
  }

  /// Generate just an idea (action + subject) without focus.
  IdeaResult generateIdea() {
    final actionRoll = _rollEngine.rollDie(100);
    final action = actionWords[(actionRoll - 1) % actionWords.length];

    final subjectRoll = _rollEngine.rollDie(100);
    final subject = subjectWords[(subjectRoll - 1) % subjectWords.length];

    return IdeaResult(
      actionRoll: actionRoll,
      action: action,
      subjectRoll: subjectRoll,
      subject: subject,
    );
  }
}

/// What the random event focuses on.
enum EventFocus {
  pc,       // Player character related
  npc,      // Non-player character related
  current,  // Current scene/situation
  remote,   // Something happening elsewhere
  thread,   // Related to an ongoing plot thread
}

extension EventFocusDisplay on EventFocus {
  String get displayText {
    switch (this) {
      case EventFocus.pc:
        return 'PC Focus';
      case EventFocus.npc:
        return 'NPC Focus';
      case EventFocus.current:
        return 'Current Scene';
      case EventFocus.remote:
        return 'Remote Event';
      case EventFocus.thread:
        return 'Plot Thread';
    }
  }

  String get description {
    switch (this) {
      case EventFocus.pc:
        return 'The event directly involves a player character.';
      case EventFocus.npc:
        return 'The event involves an NPC from the story.';
      case EventFocus.current:
        return 'The event relates to the current scene or situation.';
      case EventFocus.remote:
        return 'Something is happening somewhere else that affects the story.';
      case EventFocus.thread:
        return 'The event connects to an ongoing plot or storyline.';
    }
  }
}

/// Result of a Random Event generation.
class RandomEventResult extends RollResult {
  final List<int> focusDice;
  final int focusTotal;
  final EventFocus focus;
  final int actionRoll;
  final String action;
  final int subjectRoll;
  final String subject;

  RandomEventResult({
    required this.focusDice,
    required this.focusTotal,
    required this.focus,
    required this.actionRoll,
    required this.action,
    required this.subjectRoll,
    required this.subject,
  }) : super(
          type: RollType.randomEvent,
          description: 'Random Event',
          diceResults: [...focusDice, actionRoll, subjectRoll],
          total: focusTotal,
          interpretation: '$action / $subject (${focus.displayText})',
          metadata: {
            'focus': focus.name,
            'action': action,
            'subject': subject,
          },
        );

  String get idea => '$action / $subject';

  @override
  String toString() {
    return 'Random Event:\n  Focus: ${focus.displayText}\n  Idea: $action / $subject';
  }
}

/// Result of an Idea generation (just action + subject).
class IdeaResult extends RollResult {
  final int actionRoll;
  final String action;
  final int subjectRoll;
  final String subject;

  IdeaResult({
    required this.actionRoll,
    required this.action,
    required this.subjectRoll,
    required this.subject,
  }) : super(
          type: RollType.randomEvent,
          description: 'Idea',
          diceResults: [actionRoll, subjectRoll],
          total: actionRoll + subjectRoll,
          interpretation: '$action / $subject',
          metadata: {
            'action': action,
            'subject': subject,
          },
        );

  String get idea => '$action / $subject';

  @override
  String toString() => 'Idea: $action / $subject';
}

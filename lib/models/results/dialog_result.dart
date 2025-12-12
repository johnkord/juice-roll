import '../roll_result.dart';

/// Result of a dialog generation.
/// Part of the 5x5 Dialog Grid mini-game for NPC conversations.
class DialogResult extends RollResult {
  final int directionRoll;
  final int subjectRoll;
  final String direction;
  final String tone;
  final String subject;
  final int oldRow;
  final int oldCol;
  final String oldFragment;
  final int newRow;
  final int newCol;
  final String newFragment;
  final bool isPast;
  final bool isDoubles;
  final String fragmentDescription;

  DialogResult({
    required this.directionRoll,
    required this.subjectRoll,
    required this.direction,
    required this.tone,
    required this.subject,
    required this.oldRow,
    required this.oldCol,
    required this.oldFragment,
    required this.newRow,
    required this.newCol,
    required this.newFragment,
    required this.isPast,
    required this.isDoubles,
    required this.fragmentDescription,
    DateTime? timestamp,
  }) : super(
          type: RollType.dialog,
          description: 'Dialog',
          diceResults: [directionRoll, subjectRoll],
          total: directionRoll + subjectRoll,
          interpretation: _buildInterpretation(
            direction,
            tone,
            subject,
            newFragment,
            isPast,
            isDoubles,
          ),
          timestamp: timestamp,
          metadata: {
            'direction': direction,
            'directionRoll': directionRoll,
            'tone': tone,
            'subject': subject,
            'subjectRoll': subjectRoll,
            'oldFragment': oldFragment,
            'oldRow': oldRow,
            'oldCol': oldCol,
            'newFragment': newFragment,
            'isPast': isPast,
            'isDoubles': isDoubles,
            'row': newRow,
            'col': newCol,
            'fragmentDescription': fragmentDescription,
          },
        );

  @override
  String get className => 'DialogResult';

  factory DialogResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    return DialogResult(
      directionRoll: meta['directionRoll'] as int? ?? diceResults[0],
      subjectRoll: meta['subjectRoll'] as int? ?? diceResults[1],
      direction: meta['direction'] as String,
      tone: meta['tone'] as String,
      subject: meta['subject'] as String,
      oldRow: meta['oldRow'] as int? ?? 2,
      oldCol: meta['oldCol'] as int? ?? 2,
      oldFragment: meta['oldFragment'] as String,
      newRow: meta['row'] as int,
      newCol: meta['col'] as int,
      newFragment: meta['newFragment'] as String,
      isPast: meta['isPast'] as bool,
      isDoubles: meta['isDoubles'] as bool,
      fragmentDescription:
          meta['fragmentDescription'] as String? ?? meta['newFragment'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(
    String direction,
    String tone,
    String subject,
    String fragment,
    bool isPast,
    bool isDoubles,
  ) {
    if (isDoubles) {
      return '[$tone tone about $subject] DOUBLES - Conversation Ends';
    }
    final tense = isPast ? 'Past' : 'Present';
    return '→ $fragment ($tense) [$tone tone about $subject]';
  }

  /// Whether the conversation should end.
  bool get conversationEnds => isDoubles;

  /// Get a movement description
  String get movementDescription {
    if (isDoubles) return 'Conversation ends (doubles)';
    final moved = direction == 'up'
        ? '↑'
        : direction == 'down'
            ? '↓'
            : direction == 'left'
                ? '←'
                : '→';
    return '$oldFragment $moved $newFragment';
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Dialog ($directionRoll,$subjectRoll): ');
    if (isDoubles) {
      buffer.write('DOUBLES - Conversation Ends');
    } else {
      buffer.write('$oldFragment → $newFragment');
      buffer.write(' [$tone/$subject]');
      if (isPast) buffer.write(' (Past)');
    }
    return buffer.toString();
  }
}

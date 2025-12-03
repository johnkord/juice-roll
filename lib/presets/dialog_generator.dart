import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Dialog Generator preset for the Juice Oracle.
/// Uses a 2d10 matrix system from dialog.md.
/// 
/// First d10: Direction (Neutral/Defensive/Aggressive/Helpful)
/// Second d10: Tone (Them/Me/You/Us)
/// Cross-reference for conversation subject.
/// Doubles end the conversation.
class DialogGenerator {
  final RollEngine _rollEngine;

  /// Direction categories (first d10)
  static const Map<int, String> directions = {
    1: 'Neutral',
    2: 'Neutral',
    3: 'Neutral',
    4: 'Defensive',
    5: 'Defensive',
    6: 'Aggressive',
    7: 'Aggressive',
    8: 'Helpful',
    9: 'Helpful',
    10: 'Helpful',
  };

  /// Tone categories (second d10)
  static const Map<int, String> tones = {
    1: 'Them',
    2: 'Them',
    3: 'Them',
    4: 'Me',
    5: 'Me',
    6: 'You',
    7: 'You',
    8: 'Us',
    9: 'Us',
    10: 'Us',
  };

  /// Subject matrix: Direction × Tone → Subject
  /// Format: directions[direction][tone] = subject
  static const Map<String, Map<String, String>> subjectMatrix = {
    'Neutral': {
      'Them': 'Third party situation',
      'Me': 'Personal circumstance',
      'You': 'Your appearance/gear',
      'Us': 'Current surroundings',
    },
    'Defensive': {
      'Them': 'External threat',
      'Me': 'Personal struggles',
      'You': 'Your intentions',
      'Us': 'Shared danger',
    },
    'Aggressive': {
      'Them': 'Enemy actions',
      'Me': 'My superiority',
      'You': 'Your failures',
      'Us': 'Challenge/demand',
    },
    'Helpful': {
      'Them': 'Useful contact',
      'Me': 'Offer of service',
      'You': 'Your needs',
      'Us': 'Mutual benefit',
    },
  };

  /// Neutral subjects (more detailed) - for rolls 1-3
  static const List<String> neutralSubjects = [
    'Recent local news',
    'Weather or travel conditions',
    'General inquiry about you',
  ];

  /// Defensive subjects (more detailed) - for rolls 4-5
  static const List<String> defensiveSubjects = [
    'Warning about danger',
    'Request for reassurance',
  ];

  /// Aggressive subjects (more detailed) - for rolls 6-7
  static const List<String> aggressiveSubjects = [
    'Accusation or insult',
    'Demand or ultimatum',
  ];

  /// Helpful subjects (more detailed) - for rolls 8-10
  static const List<String> helpfulSubjects = [
    'Offer of aid',
    'Sharing of information',
    'Invitation or welcome',
  ];

  DialogGenerator([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a dialog topic (2d10).
  DialogResult generate() {
    final directionRoll = _rollEngine.rollDie(10);
    final toneRoll = _rollEngine.rollDie(10);

    final direction = directions[directionRoll] ?? 'Neutral';
    final tone = tones[toneRoll] ?? 'Them';
    
    // Check for doubles
    final isDoubles = directionRoll == toneRoll;
    
    // Get subject from matrix
    final subject = subjectMatrix[direction]?[tone] ?? 'General conversation';

    return DialogResult(
      directionRoll: directionRoll,
      direction: direction,
      toneRoll: toneRoll,
      tone: tone,
      subject: subject,
      isDoubles: isDoubles,
    );
  }

  /// Generate multiple dialog exchanges until doubles.
  List<DialogResult> generateConversation({int maxExchanges = 10}) {
    final results = <DialogResult>[];
    
    for (int i = 0; i < maxExchanges; i++) {
      final result = generate();
      results.add(result);
      
      if (result.isDoubles) {
        break; // Conversation ends
      }
    }
    
    return results;
  }
}

/// Result of a dialog generation.
class DialogResult extends RollResult {
  final int directionRoll;
  final String direction;
  final int toneRoll;
  final String tone;
  final String subject;
  final bool isDoubles;

  DialogResult({
    required this.directionRoll,
    required this.direction,
    required this.toneRoll,
    required this.tone,
    required this.subject,
    required this.isDoubles,
  }) : super(
          type: RollType.dialog,
          description: 'Dialog',
          diceResults: [directionRoll, toneRoll],
          total: directionRoll + toneRoll,
          interpretation: _buildInterpretation(direction, tone, subject, isDoubles),
          metadata: {
            'direction': direction,
            'tone': tone,
            'subject': subject,
            'isDoubles': isDoubles,
          },
        );

  static String _buildInterpretation(
    String direction,
    String tone,
    String subject,
    bool isDoubles,
  ) {
    final buffer = StringBuffer();
    buffer.write('$direction ($tone): $subject');
    if (isDoubles) {
      buffer.write(' [CONVERSATION ENDS]');
    }
    return buffer.toString();
  }

  /// Whether the conversation should end.
  bool get conversationEnds => isDoubles;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Dialog: $direction/$tone → $subject');
    if (isDoubles) {
      buffer.write(' [END]');
    }
    return buffer.toString();
  }
}

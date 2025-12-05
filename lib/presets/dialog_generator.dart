import '../core/roll_engine.dart';
import '../models/roll_result.dart';

/// Dialog Generator preset for the Juice Oracle.
/// 
/// The Dialog Grid is a 5x5 grid-based mini-game for generating NPC conversations.
/// You maintain state (position) throughout the conversation, moving around the grid
/// as dice are rolled.
/// 
/// How it works:
/// - Start at center "Fact" position (row 2, col 2, 0-indexed)
/// - Roll 2d10: First die = direction/tone, Second die = subject
/// - If doubles: conversation ends
/// - Move on grid based on first die, wrap at edges
/// - Top 2 rows (0,1) are about the past (italicized in the pocketfold)
/// - Bottom 3 rows (2,3,4) are about the present
class DialogGenerator {
  final RollEngine _rollEngine;
  
  // Current position on the 5x5 grid (row, col), 0-indexed
  int _currentRow = 2;
  int _currentCol = 2;
  
  // Track if conversation is active
  bool _conversationActive = false;

  /// The 5x5 Dialog Grid
  /// Row 0-1: Past tense (italics in pocketfold)
  /// Row 2-4: Present tense
  /// Center (2,2): "Fact" - starting position
  static const List<List<String>> grid = [
    // Row 0 (Past)
    ['Fact', 'Denial', 'Query', 'Denial', 'Action'],
    // Row 1 (Past)
    ['Want', 'Query', 'Need', 'Query', 'Fact'],
    // Row 2 (Present) - Center row
    ['Action', 'Need', 'Fact', 'Action', 'Denial'],
    // Row 3 (Present)
    ['Need', 'Query', 'Denial', 'Query', 'Want'],
    // Row 4 (Present)
    ['Query', 'Support', 'Query', 'Support', 'Need'],
  ];

  /// Direction mapping based on first d10 roll
  /// 1-2: Move up (Neutral tone)
  /// 3-5: Move left (Defensive tone)
  /// 6-8: Move right (Aggressive tone)
  /// 9-0: Move down (Helpful tone)
  static String getDirection(int roll) {
    final normalized = roll == 10 ? 0 : roll;
    if (normalized >= 1 && normalized <= 2) return 'up';
    if (normalized >= 3 && normalized <= 5) return 'left';
    if (normalized >= 6 && normalized <= 8) return 'right';
    return 'down'; // 9, 0
  }

  /// Tone mapping based on first d10 roll
  static String getTone(int roll) {
    final normalized = roll == 10 ? 0 : roll;
    if (normalized >= 1 && normalized <= 2) return 'Neutral';
    if (normalized >= 3 && normalized <= 5) return 'Defensive';
    if (normalized >= 6 && normalized <= 8) return 'Aggressive';
    return 'Helpful'; // 9, 0
  }

  /// Subject mapping based on second d10 roll
  static String getSubject(int roll) {
    final normalized = roll == 10 ? 0 : roll;
    if (normalized >= 1 && normalized <= 2) return 'Them';
    if (normalized >= 3 && normalized <= 5) return 'Me';
    if (normalized >= 6 && normalized <= 8) return 'You';
    return 'Us'; // 9, 0
  }

  /// Dialog fragment descriptions for each type
  static const Map<String, String> fragmentDescriptions = {
    'Fact': 'NPC states a fact or observation',
    'Query': 'NPC asks a question',
    'Need': 'NPC expresses a need or requirement',
    'Want': 'NPC expresses a desire or wish',
    'Action': 'NPC describes or suggests an action',
    'Denial': 'NPC denies, refuses, or disagrees',
    'Support': 'NPC offers support or agreement',
  };

  DialogGenerator([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Get current position as human-readable string
  String get currentPositionLabel => grid[_currentRow][_currentCol];
  
  /// Get whether current position is in the "past" rows
  bool get isCurrentPast => _currentRow <= 1;
  
  /// Get current row (0-indexed)
  int get currentRow => _currentRow;
  
  /// Get current column (0-indexed)
  int get currentCol => _currentCol;
  
  /// Whether a conversation is currently active
  bool get isConversationActive => _conversationActive;

  /// Start a new conversation at center "Fact"
  void startConversation() {
    _currentRow = 2;
    _currentCol = 2;
    _conversationActive = true;
  }
  
  /// End the current conversation
  void endConversation() {
    _conversationActive = false;
  }

  /// Reset to center (Fact) without ending conversation
  void resetPosition() {
    _currentRow = 2;
    _currentCol = 2;
  }

  /// Set position to a specific cell on the grid
  /// This starts a conversation if not already active
  void setPosition(int row, int col) {
    if (row >= 0 && row < 5 && col >= 0 && col < 5) {
      _currentRow = row;
      _currentCol = col;
      if (!_conversationActive) {
        _conversationActive = true;
      }
    }
  }

  /// Move in a direction with wrap-around
  void _move(String direction) {
    switch (direction) {
      case 'up':
        _currentRow = (_currentRow - 1 + 5) % 5;
        break;
      case 'down':
        _currentRow = (_currentRow + 1) % 5;
        break;
      case 'left':
        _currentCol = (_currentCol - 1 + 5) % 5;
        break;
      case 'right':
        _currentCol = (_currentCol + 1) % 5;
        break;
    }
  }

  /// Generate a dialog roll (2d10) and move on the grid.
  /// If this is the first roll without starting a conversation, auto-start.
  DialogResult generate() {
    // Auto-start conversation if not active
    if (!_conversationActive) {
      startConversation();
    }
    
    final directionRoll = _rollEngine.rollDie(10);
    final subjectRoll = _rollEngine.rollDie(10);
    
    // Check for doubles - conversation ends
    final isDoubles = directionRoll == subjectRoll;
    
    // Get direction/tone from first die
    final direction = getDirection(directionRoll);
    final tone = getTone(directionRoll);
    
    // Get subject from second die
    final subject = getSubject(subjectRoll);
    
    // Store old position for reference
    final oldRow = _currentRow;
    final oldCol = _currentCol;
    final oldFragment = grid[oldRow][oldCol];
    
    // Move on the grid (only if not ending)
    if (!isDoubles) {
      _move(direction);
    }
    
    // Get new position and fragment
    final newFragment = grid[_currentRow][_currentCol];
    final isPast = _currentRow <= 1;
    
    // End conversation if doubles
    if (isDoubles) {
      _conversationActive = false;
    }

    return DialogResult(
      directionRoll: directionRoll,
      subjectRoll: subjectRoll,
      direction: direction,
      tone: tone,
      subject: subject,
      oldRow: oldRow,
      oldCol: oldCol,
      oldFragment: oldFragment,
      newRow: _currentRow,
      newCol: _currentCol,
      newFragment: newFragment,
      isPast: isPast,
      isDoubles: isDoubles,
      fragmentDescription: fragmentDescriptions[newFragment] ?? newFragment,
    );
  }

  /// Generate multiple dialog exchanges until doubles or max reached.
  List<DialogResult> generateConversation({int maxExchanges = 10}) {
    startConversation();
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
  
  /// Get the entire grid for display purposes
  List<List<String>> getGrid() => grid;
  
  /// Get a visual representation of the current state
  String getGridDisplay() {
    final buffer = StringBuffer();
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final isCurrentPos = r == _currentRow && c == _currentCol;
        final cell = grid[r][c].padRight(8);
        if (isCurrentPos) {
          buffer.write('[${cell.trim()}]'.padRight(10));
        } else {
          buffer.write(' $cell ');
        }
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}

/// Result of a dialog generation.
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
            direction, tone, subject, 
            newFragment, isPast, isDoubles,
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
      fragmentDescription: meta['fragmentDescription'] as String? ?? meta['newFragment'] as String,
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
    final moved = direction == 'up' ? '↑' 
                : direction == 'down' ? '↓'
                : direction == 'left' ? '←'
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

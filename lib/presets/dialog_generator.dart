import '../core/roll_engine.dart';
import '../data/dialog_generator_data.dart' as data;

// Re-export result class for backward compatibility
export '../models/results/dialog_result.dart';

import '../models/results/dialog_result.dart';

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
  static List<List<String>> get grid => data.grid;

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
  static Map<String, String> get fragmentDescriptions => data.fragmentDescriptions;

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

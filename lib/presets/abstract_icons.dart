import '../models/roll_result.dart';
import '../core/roll_engine.dart';

/// Abstract Icons generator based on the Juice Oracle Right Extension.
/// Roll 1d10 + 1d6 to pick an icon. These selections were inspired by Rory's Story Cubes.
class AbstractIcons {
  final RollEngine _rollEngine;

  /// Row labels are 1-9, then 0 for the 10th row (matching the d10)
  static const List<int> rowLabels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
  
  /// Column labels are 1-6 (matching the d6)
  static const List<int> colLabels = [1, 2, 3, 4, 5, 6];

  AbstractIcons([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a random abstract icon by rolling 1d10 + 1d6
  AbstractIconResult generate() {
    // Roll 1d10 (1-10) for row
    final d10Result = _rollEngine.rollDie(10);
    // Convert to row label (1-9, then 0 for 10)
    final rowLabel = d10Result == 10 ? 0 : d10Result;
    
    // Roll 1d6 for column
    final d6Result = _rollEngine.rollDie(6);
    final colLabel = d6Result;
    
    final imagePath = 'assets/images/abstract_icons/${rowLabel}_$colLabel.png';
    
    return AbstractIconResult(
      d10Roll: d10Result,
      d6Roll: d6Result,
      rowLabel: rowLabel,
      colLabel: colLabel,
      imagePath: imagePath,
    );
  }

  /// Get the image path for a specific row and column
  static String getImagePath(int row, int col) {
    return 'assets/images/abstract_icons/${row}_$col.png';
  }

  /// Get all available image paths
  static List<String> getAllImagePaths() {
    final paths = <String>[];
    for (final row in rowLabels) {
      for (final col in colLabels) {
        paths.add(getImagePath(row, col));
      }
    }
    return paths;
  }
}

/// Result of an Abstract Icon roll.
class AbstractIconResult extends RollResult {
  final int d10Roll;
  final int d6Roll;
  final int rowLabel;
  final int colLabel;

  AbstractIconResult({
    required this.d10Roll,
    required this.d6Roll,
    required this.rowLabel,
    required this.colLabel,
    required String imagePath,
    super.timestamp,
  }) : super(
          type: RollType.abstractIcons,
          description: 'Abstract Icons',
          diceResults: [d10Roll, d6Roll],
          total: d10Roll + d6Roll,
          interpretation: '($rowLabel, $colLabel)',
          imagePath: imagePath,
          metadata: {
            'rowLabel': rowLabel,
            'colLabel': colLabel,
            'd10Roll': d10Roll,
            'd6Roll': d6Roll,
            'imagePath': imagePath,
          },
        );

  @override
  String get className => 'AbstractIconResult';

  factory AbstractIconResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    final diceResults = (json['diceResults'] as List).cast<int>();
    final rowLabel = meta['rowLabel'] as int;
    final colLabel = meta['colLabel'] as int;
    return AbstractIconResult(
      d10Roll: meta['d10Roll'] as int? ?? diceResults[0],
      d6Roll: meta['d6Roll'] as int? ?? diceResults[1],
      rowLabel: rowLabel,
      colLabel: colLabel,
      imagePath: meta['imagePath'] as String? ?? 'assets/images/abstract_icons/${rowLabel}_$colLabel.png',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Abstract Icons: 1d10=$d10Roll, 1d6=$d6Roll → ($rowLabel, $colLabel)';
}

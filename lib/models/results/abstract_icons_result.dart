import '../roll_result.dart';

/// Result of an Abstract Icon roll.
/// Contains the grid position and image path for the selected icon.
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
    DateTime? timestamp,
  }) : super(
          type: RollType.abstractIcons,
          description: 'Abstract Icons',
          diceResults: [d10Roll, d6Roll],
          total: d10Roll + d6Roll,
          interpretation: '($rowLabel, $colLabel)',
          imagePath: imagePath,
          timestamp: timestamp,
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
      imagePath: meta['imagePath'] as String? ??
          'assets/images/abstract_icons/${rowLabel}_$colLabel.png',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'Abstract Icons: 1d10=$d10Roll, 1d6=$d6Roll → ($rowLabel, $colLabel)';
}

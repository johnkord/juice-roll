import 'package:flutter/material.dart';

/// Utility class for formatting and displaying dice roll results consistently
/// across all parts of the application.
/// 
/// This provides standardized widgets and formatting for showing dice results
/// with their die type (e.g., "1d10: 7", "2d6: 4, 3", "4dF: + − ○ +").
class DiceDisplayFormatter {
  DiceDisplayFormatter._();

  /// Format a single die result with its type.
  /// Example: formatDie(10, 7) -> "d10: 7"
  static String formatDie(int sides, int result) {
    return 'd$sides: $result';
  }

  /// Format multiple dice of the same type.
  /// Example: formatDice(6, [3, 5, 2]) -> "3d6: [3, 5, 2]"
  static String formatDice(int sides, List<int> results) {
    return '${results.length}d$sides: [${results.join(', ')}]';
  }

  /// Format dice with a compact notation.
  /// Example: formatDiceCompact(6, [3, 5, 2]) -> "3d6: 3,5,2"
  static String formatDiceCompact(int sides, List<int> results) {
    return '${results.length}d$sides: ${results.join(',')}';
  }

  /// Format dice with sum included.
  /// Example: formatDiceWithSum(6, [3, 5, 2]) -> "3d6: [3, 5, 2] = 10"
  static String formatDiceWithSum(int sides, List<int> results) {
    final sum = results.fold<int>(0, (a, b) => a + b);
    return '${results.length}d$sides: [${results.join(', ')}] = $sum';
  }

  /// Build a styled widget for displaying dice results.
  static Widget buildDiceDisplay({
    required int sides,
    required List<int> results,
    required ThemeData theme,
    Color? backgroundColor,
    Color? textColor,
    bool showSum = false,
  }) {
    final text = showSum 
        ? formatDiceWithSum(sides, results)
        : formatDice(sides, results);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// Build a labeled dice display (e.g., "Physical: d10: 7").
  static Widget buildLabeledDiceDisplay({
    required String label,
    required int sides,
    required List<int> results,
    required ThemeData theme,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label ${results.length}d$sides: ${results.join(', ')}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          color: textColor,
        ),
      ),
    );
  }

  /// Build a compact inline dice chip display.
  static Widget buildDiceChip({
    required int sides,
    required List<int> results,
    required ThemeData theme,
    Color? color,
  }) {
    final chipColor = color ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${results.length}d$sides: ${results.join(',')}',
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }

  /// Build a dice display showing advantage/disadvantage rolls.
  /// Shows both rolls with the chosen one highlighted.
  static Widget buildAdvantageDisplay({
    required int sides,
    required List<int> allRolls,
    required int chosen,
    required bool isAdvantage,
    required ThemeData theme,
  }) {
    final skewSymbol = isAdvantage ? '@+' : '@-';
    final chosenColor = isAdvantage ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'd$sides$skewSymbol: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          ...allRolls.asMap().entries.map((entry) {
            final isChosen = entry.value == chosen;
            return Padding(
              padding: EdgeInsets.only(left: entry.key > 0 ? 4 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isChosen ? chosenColor.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isChosen ? Border.all(color: chosenColor) : null,
                ),
                child: Text(
                  '${entry.value}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                    color: isChosen ? chosenColor : Colors.grey,
                    decoration: isChosen ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build a display showing multiple dice groups with their labels.
  /// Example: diceGroups: [(label: '2d10', values: [7, 3]), (label: 'd6', values: [4])]
  /// This is useful for compound rolls like "2d10 + d6".
  static Widget buildMultipleDiceDisplay({
    required List<({String label, List<int> values})> diceGroups,
    required ThemeData theme,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: diceGroups.asMap().entries.map((entry) {
          final group = entry.value;
          final isFirst = entry.key == 0;
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFirst) 
                const Text(' + ', style: TextStyle(color: Colors.grey)),
              Text(
                '${group.label}: [${group.values.join(", ")}]',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Build a multi-die type display (for rolls using different die types).
  /// Example: for "2dF + 1d6", shows each type separately.
  static Widget buildMultiDiceDisplay({
    required List<DiceGroup> diceGroups,
    required ThemeData theme,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: diceGroups.asMap().entries.map((entry) {
          final group = entry.value;
          final isFirst = entry.key == 0;
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFirst) 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('+', style: TextStyle(color: Colors.grey[600])),
                ),
              Text(
                group.isFate 
                    ? '${group.count}dF: ${group.fateSymbols}'
                    : '${group.count}d${group.sides}: ${group.results.join(',')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Get color based on die size for visual distinction.
  static Color getDieColor(int sides) {
    switch (sides) {
      case 4: return Colors.purple;
      case 6: return Colors.blue;
      case 8: return Colors.teal;
      case 10: return Colors.orange;
      case 12: return Colors.pink;
      case 20: return Colors.green;
      case 100: return Colors.brown;
      default: return Colors.grey;
    }
  }
}

/// Represents a group of dice of the same type for display.
class DiceGroup {
  final int count;
  final int sides;
  final List<int> results;
  final bool isFate;

  const DiceGroup({
    required this.count,
    required this.sides,
    required this.results,
    this.isFate = false,
  });

  /// Get fate dice symbols if this is a fate dice group.
  String get fateSymbols {
    if (!isFate) return results.join(',');
    return results.map((d) {
      switch (d) {
        case -1: return '−';
        case 0: return '○';
        case 1: return '+';
        default: return '?';
      }
    }).join(' ');
  }
}

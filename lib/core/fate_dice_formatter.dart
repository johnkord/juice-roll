import 'package:flutter/material.dart';
import '../ui/theme/juice_theme.dart';

/// Utility class for formatting and displaying Fate dice results consistently
/// across all parts of the application.
/// 
/// Fate dice have three possible values:
/// - +1 (plus): Displayed as '+'
/// - 0 (blank): Displayed as '○'
/// - -1 (minus): Displayed as '−'
class FateDiceFormatter {
  FateDiceFormatter._();

  /// Convert a single fate die value to its symbol.
  static String dieToSymbol(int value) {
    switch (value) {
      case -1:
        return '−';
      case 0:
        return '○';
      case 1:
        return '+';
      default:
        return '?';
    }
  }

  /// Convert a list of fate dice values to a space-separated symbol string.
  /// Example: [1, -1, 0] -> '+ − ○'
  static String diceToSymbols(List<int> dice) {
    return dice.map(dieToSymbol).join(' ');
  }

  /// Build a styled widget for displaying fate dice symbols.
  /// This provides consistent styling across all fate dice displays.
  static Widget buildFateDiceDisplay({
    required List<int> dice,
    required ThemeData theme,
    Color? backgroundColor,
    double? letterSpacing,
    TextStyle? textStyle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? JuiceTheme.ink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.parchmentDark.withOpacity(0.2)),
      ),
      child: Text(
        diceToSymbols(dice),
        style: textStyle ?? theme.textTheme.titleMedium?.copyWith(
          fontFamily: JuiceTheme.fontFamilyMono,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing ?? 4,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }

  /// Build a compact inline fate dice display (for smaller spaces).
  static Widget buildCompactFateDiceDisplay({
    required List<int> dice,
    required ThemeData theme,
    Color? color,
  }) {
    return Text(
      diceToSymbols(dice),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: JuiceTheme.fontFamilyMono,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: color ?? JuiceTheme.parchment,
      ),
    );
  }

  /// Build a labeled fate dice display (e.g., "2dF: + −").
  static Widget buildLabeledFateDiceDisplay({
    required String label,
    required List<int> dice,
    required ThemeData theme,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? JuiceTheme.ink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.parchmentDark.withOpacity(0.2)),
      ),
      child: Text(
        '$label: ${diceToSymbols(dice)}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: JuiceTheme.fontFamilyMono,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }

  /// Get a color based on the overall result of the fate dice.
  /// Positive sum -> success, negative sum -> danger, zero -> neutral.
  static Color getResultColor(List<int> dice) {
    final sum = dice.fold<int>(0, (a, b) => a + b);
    if (sum > 0) return JuiceTheme.success;
    if (sum < 0) return JuiceTheme.danger;
    return JuiceTheme.parchmentDark;
  }
}

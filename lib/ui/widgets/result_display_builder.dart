/// Result Display Builder - Entry point for rendering roll result widgets.
///
/// This file provides the [ResultDisplayBuilder] class which delegates to
/// the [ResultDisplayRegistry] for type-specific result displays.
///
/// ## Architecture
///
/// All type-specific display logic has been migrated to modular display files
/// in the `result_displays/` directory. This file now only handles:
/// 1. Registry lookup for typed results
/// 2. Generic dice roll displays (advantage/disadvantage/skewed)
/// 3. Default fallback display
///
/// ## Adding New Result Types
///
/// 1. Create result class in appropriate preset file
/// 2. Register JSON serialization in RollResultFactory
/// 3. Add display function to appropriate display module in result_displays/
/// 4. Register display in that module's register function
///
/// See result_displays/result_displays.dart for the complete list of
/// registered display types.
library;

import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../theme/juice_theme.dart';
import 'result_display_registry.dart';

/// Centralized result display builder.
///
/// Call [buildDisplay] with any RollResult to get the appropriate widget.
///
/// Uses [ResultDisplayRegistry] for all type-specific result displays.
/// Falls back to generic dice display for standard roll types.
class ResultDisplayBuilder {
  final ThemeData theme;

  const ResultDisplayBuilder(this.theme);

  /// Build the display widget for any result type.
  Widget buildDisplay(RollResult result) {
    // PRIMARY: Use registry pattern for all specific result types
    final registryWidget = ResultDisplayRegistry.build(result, theme);
    if (registryWidget != null) {
      return registryWidget;
    }

    // FALLBACK: Handle generic dice rolls and default display
    // All specific result types have been migrated to result_displays/*.dart:
    // - ironsworn_displays.dart (6 types)
    // - oracle_displays.dart (9 types)
    // - npc_displays.dart (4 types)
    // - settlement_displays.dart (5 types)
    // - challenge_displays.dart (4 types)
    // - immersion_displays.dart (3 types)
    // - details_displays.dart (4 types)
    // - wilderness_displays.dart (7 types)
    // - dungeon_displays.dart (9 types)
    // - misc_displays.dart (13 types)

    // Handle standard dice roll types
    if (result.type == RollType.standard ||
        result.type == RollType.advantage ||
        result.type == RollType.disadvantage ||
        result.type == RollType.skewed) {
      return _buildGenericDiceRollDisplay(result);
    }

    // Default fallback
    return _buildDefaultDisplay(result);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERIC DICE DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGenericDiceRollDisplay(RollResult result) {
    // Determine theme colors based on roll type
    Color themeColor;
    IconData typeIcon;
    String? typeLabel;

    switch (result.type) {
      case RollType.advantage:
        themeColor = JuiceTheme.success;
        typeIcon = Icons.thumb_up;
        typeLabel = 'ADV';
        break;
      case RollType.disadvantage:
        themeColor = JuiceTheme.danger;
        typeIcon = Icons.thumb_down;
        typeLabel = 'DIS';
        break;
      case RollType.skewed:
        final skew = result.metadata?['skew'] as int? ?? 0;
        themeColor = skew > 0 ? JuiceTheme.success : JuiceTheme.danger;
        typeIcon = skew > 0 ? Icons.arrow_upward : Icons.arrow_downward;
        typeLabel = 'SKEW ${skew > 0 ? '+$skew' : '$skew'}';
        break;
      default:
        themeColor = JuiceTheme.rust;
        typeIcon = Icons.casino;
        typeLabel = null;
    }

    // Extract discarded roll info for advantage/disadvantage
    final discardedRoll = result.metadata?['discarded'] as List<dynamic>?;
    final discardedSum = result.metadata?['discardedSum'] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main dice display row
        Row(
          children: [
            // Dice values container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Individual dice values
                  ...result.diceResults.asMap().entries.map((entry) {
                    final isLast = entry.key == result.diceResults.length - 1;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDieValue(entry.value, themeColor),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: themeColor.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Equals and total
            Text(
              '=',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: JuiceTheme.parchmentDark,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withOpacity(0.25),
                    themeColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withOpacity(0.5)),
              ),
              child: Text(
                '${result.total}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: themeColor,
                ),
              ),
            ),
            // Type badge (advantage/disadvantage/skew)
            if (typeLabel != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 12, color: themeColor),
                    const SizedBox(width: 4),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        // Discarded roll info for advantage/disadvantage
        if (discardedRoll != null && discardedSum != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 14,
                color: JuiceTheme.parchmentDark.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Discarded: ',
                style: TextStyle(
                  fontSize: 11,
                  color: JuiceTheme.parchmentDark.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: JuiceTheme.ink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '[${discardedRoll.join(', ')}] = $discardedSum',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.parchmentDark.withOpacity(0.6),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: JuiceTheme.parchmentDark.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build a single die value display
  Widget _buildDieValue(int value, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: JuiceTheme.fontFamilyMono,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDefaultDisplay(RollResult result) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.ink.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '[${result.diceResults.join(', ')}]',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.parchment,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '= ${result.total}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: JuiceTheme.gold,
          ),
        ),
        if (result.interpretation != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.interpretation!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: JuiceTheme.parchment,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

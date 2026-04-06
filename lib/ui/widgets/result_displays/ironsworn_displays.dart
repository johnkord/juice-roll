import 'package:flutter/material.dart';

import '../../../models/results/ironsworn_result.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Ironsworn/Starforged result display builders.
///
/// This module handles display widgets for all Ironsworn-related results:
/// - IronswornActionResult - Action rolls (d6+stat vs 2d10)
/// - IronswornProgressResult - Progress rolls (progress vs 2d10)
/// - IronswornOracleResult - Oracle table rolls
/// - IronswornYesNoResult - Yes/No oracle with odds
/// - IronswornCursedOracleResult - Oracle with curse die
/// - IronswornMomentumBurnResult - Momentum burn outcomes

/// Ironsworn theme color (Indigo)
const _ironswornColor = Color(0xFF8595d8);

/// Registers all Ironsworn display builders with the registry.
///
/// Call this during app initialization:
/// ```dart
/// void main() {
///   registerIronswornDisplays();
///   runApp(const MyApp());
/// }
/// ```
void registerIronswornDisplays() {
  ResultDisplayRegistry.register<IronswornActionResult>(
      buildIronswornActionDisplay);
  ResultDisplayRegistry.register<IronswornProgressResult>(
      buildIronswornProgressDisplay);
  ResultDisplayRegistry.register<IronswornOracleResult>(
      buildIronswornOracleDisplay);
  ResultDisplayRegistry.register<IronswornYesNoResult>(
      buildIronswornYesNoDisplay);
  ResultDisplayRegistry.register<IronswornCursedOracleResult>(
      buildIronswornCursedOracleDisplay);
  ResultDisplayRegistry.register<IronswornMomentumBurnResult>(
      buildIronswornMomentumBurnDisplay);
}

// =============================================================================
// ACTION ROLL DISPLAY
// =============================================================================

Widget buildIronswornActionDisplay(
    IronswornActionResult result, ThemeData theme) {
  final outcomeColor = result.outcome == IronswornOutcome.strongHit
      ? JuiceTheme.success
      : result.outcome == IronswornOutcome.weakHit
          ? JuiceTheme.gold
          : JuiceTheme.danger;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice row: action die vs challenge dice
      Row(
        children: [
          // Action Die
          _buildIronswornDieBox(
            label: '1d6',
            value: result.actionDie,
            color: _ironswornColor,
          ),
          const SizedBox(width: 6),
          // Stat + Adds if present
          if (result.statBonus > 0 || result.adds > 0) ...[
            Text(
              '+${result.statBonus + result.adds}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: JuiceTheme.parchment,
              ),
            ),
            const SizedBox(width: 6),
          ],
          // Action Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _ironswornColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _ironswornColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              '= ${result.actionScore}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: _ironswornColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // "vs" divider
          Text(
            'vs',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
            ),
          ),
          const SizedBox(width: 10),
          // Challenge Dice
          _buildIronswornDieBox(
            label: 'd10',
            value: result.challengeDice[0],
            color:
                _getChallengeColor(result.actionScore, result.challengeDice[0]),
            isBeaten: result.actionScore > result.challengeDice[0],
          ),
          const SizedBox(width: 6),
          _buildIronswornDieBox(
            label: 'd10',
            value: result.challengeDice[1],
            color:
                _getChallengeColor(result.actionScore, result.challengeDice[1]),
            isBeaten: result.actionScore > result.challengeDice[1],
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Outcome row
      Row(
        children: [
          _buildOutcomeChip(result.outcome, outcomeColor),
          if (result.isMatch) ...[
            const SizedBox(width: 10),
            _buildMatchIndicator(result.outcome.isSuccess),
          ],
        ],
      ),
    ],
  );
}

// =============================================================================
// PROGRESS ROLL DISPLAY
// =============================================================================

Widget buildIronswornProgressDisplay(
    IronswornProgressResult result, ThemeData theme) {
  final outcomeColor = result.outcome == IronswornOutcome.strongHit
      ? JuiceTheme.success
      : result.outcome == IronswornOutcome.weakHit
          ? JuiceTheme.gold
          : JuiceTheme.danger;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Progress vs Challenge row
      Row(
        children: [
          // Progress Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _ironswornColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ironswornColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 10,
                    color: _ironswornColor.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '${result.progressScore}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _ironswornColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'vs',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
            ),
          ),
          const SizedBox(width: 12),
          // Challenge Dice
          _buildIronswornDieBox(
            label: 'd10',
            value: result.challengeDice[0],
            color: _getChallengeColor(
                result.progressScore, result.challengeDice[0]),
            isBeaten: result.progressScore > result.challengeDice[0],
          ),
          const SizedBox(width: 6),
          _buildIronswornDieBox(
            label: 'd10',
            value: result.challengeDice[1],
            color: _getChallengeColor(
                result.progressScore, result.challengeDice[1]),
            isBeaten: result.progressScore > result.challengeDice[1],
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Outcome row
      Row(
        children: [
          _buildOutcomeChip(result.outcome, outcomeColor),
          if (result.isMatch) ...[
            const SizedBox(width: 10),
            _buildMatchIndicator(result.outcome.isSuccess),
          ],
        ],
      ),
    ],
  );
}

// =============================================================================
// ORACLE ROLL DISPLAY
// =============================================================================

Widget buildIronswornOracleDisplay(
    IronswornOracleResult result, ThemeData theme) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _ironswornColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _ironswornColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.casino,
              size: 20,
              color: _ironswornColor,
            ),
            const SizedBox(width: 8),
            Text(
              '1d${result.dieType}:',
              style: TextStyle(
                fontSize: 14,
                color: _ironswornColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${result.oracleRoll}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: _ironswornColor,
              ),
            ),
          ],
        ),
      ),
      if (result.oracleTable != null) ...[
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            result.oracleTable!,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
            ),
          ),
        ),
      ],
    ],
  );
}

// =============================================================================
// YES/NO ORACLE DISPLAY
// =============================================================================

Widget buildIronswornYesNoDisplay(
    IronswornYesNoResult result, ThemeData theme) {
  final isYes = result.isYes;
  final answerColor = isYes ? JuiceTheme.success : JuiceTheme.danger;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Roll display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _ironswornColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ironswornColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'd100:',
                  style: TextStyle(
                    fontSize: 12,
                    color: _ironswornColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${result.roll}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _ironswornColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Odds indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.mystic.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              result.odds.displayText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: JuiceTheme.mystic,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Threshold
          Text(
            '≥${result.odds.yesThreshold}',
            style: TextStyle(
              fontSize: 12,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.parchmentDark,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Answer display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              answerColor.withValues(alpha: 0.25),
              answerColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: answerColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isYes ? Icons.check_circle : Icons.cancel,
              size: 22,
              color: answerColor,
            ),
            const SizedBox(width: 8),
            Text(
              isYes ? 'YES' : 'NO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: answerColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      // Match indicator for extreme result
      if (result.isMatch) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: JuiceTheme.gold,
              ),
              const SizedBox(width: 4),
              Text(
                'Extreme Result!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.gold,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

// =============================================================================
// CURSED ORACLE DISPLAY
// =============================================================================

Widget buildIronswornCursedOracleDisplay(
    IronswornCursedOracleResult result, ThemeData theme) {
  const cursedColor = Color(0xFF9C27B0); // Purple for cursed

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Oracle roll
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _ironswornColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ironswornColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'd100:',
                  style: TextStyle(
                    fontSize: 12,
                    color: _ironswornColor.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${result.oracleRoll}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _ironswornColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Cursed die
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (result.isCursed ? cursedColor : JuiceTheme.parchmentDark)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    (result.isCursed ? cursedColor : JuiceTheme.parchmentDark)
                        .withValues(alpha: 0.4),
                width: result.isCursed ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  result.isCursed ? Icons.warning_amber : Icons.shield_outlined,
                  size: 16,
                  color:
                      result.isCursed ? cursedColor : JuiceTheme.parchmentDark,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cursed d10:',
                  style: TextStyle(
                    fontSize: 11,
                    color: (result.isCursed
                            ? cursedColor
                            : JuiceTheme.parchmentDark)
                        .withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.cursedDie}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: result.isCursed
                        ? cursedColor
                        : JuiceTheme.parchmentDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Curse triggered banner
      if (result.isCursed) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cursedColor.withValues(alpha: 0.25),
                cursedColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cursedColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 22,
                color: cursedColor,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURSE TRIGGERED!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cursedColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Draw from curse deck or consult curse table',
                    style: TextStyle(
                      fontSize: 11,
                      color: JuiceTheme.parchmentDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

// =============================================================================
// MOMENTUM BURN DISPLAY
// =============================================================================

Widget buildIronswornMomentumBurnDisplay(
    IronswornMomentumBurnResult result, ThemeData theme) {
  final outcomeColor = result.burnedOutcome == IronswornOutcome.strongHit
      ? JuiceTheme.success
      : result.burnedOutcome == IronswornOutcome.weakHit
          ? JuiceTheme.gold
          : JuiceTheme.danger;

  final originalOutcome = result.originalOutcome;
  final originalColor = originalOutcome == IronswornOutcome.strongHit
      ? JuiceTheme.success
      : originalOutcome == IronswornOutcome.weakHit
          ? JuiceTheme.gold
          : JuiceTheme.danger;

  final improved = result.wasUpgraded;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Original roll info
      Row(
        children: [
          _buildIronswornDieBox(
            label: '1d6',
            value: result.actionDie,
            color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          if (result.statBonus > 0 || result.adds > 0) ...[
            Text(
              '+${result.statBonus + result.adds}',
              style: TextStyle(
                fontSize: 14,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 6),
          ],
          // Original action score (struck through)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: originalColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${result.originalActionScore}',
              style: TextStyle(
                fontSize: 14,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Arrow to momentum
          Icon(
            Icons.arrow_forward,
            size: 16,
            color: JuiceTheme.gold,
          ),
          const SizedBox(width: 10),
          // Momentum value (the new action score)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: JuiceTheme.gold,
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.momentumValue}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'vs',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchmentDark,
            ),
          ),
          const SizedBox(width: 10),
          // Challenge Dice
          _buildIronswornDieBox(
            label: 'd10',
            value: result.challengeDice[0],
            color: _getChallengeColor(
                result.momentumValue, result.challengeDice[0]),
            isBeaten: result.momentumValue > result.challengeDice[0],
          ),
          const SizedBox(width: 6),
          _buildIronswornDieBox(
            label: 'd10',
            value: result.challengeDice[1],
            color: _getChallengeColor(
                result.momentumValue, result.challengeDice[1]),
            isBeaten: result.momentumValue > result.challengeDice[1],
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Outcome row with improvement indicator
      Row(
        children: [
          _buildOutcomeChip(result.burnedOutcome, outcomeColor),
          if (improved) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 14,
                    color: JuiceTheme.gold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Burned!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (result.isMatch) ...[
            const SizedBox(width: 8),
            _buildMatchIndicator(result.burnedOutcome.isSuccess),
          ],
        ],
      ),
    ],
  );
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

Widget _buildIronswornDieBox({
  required String label,
  required int value,
  required Color color,
  bool isBeaten = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: color,
            decoration: isBeaten ? TextDecoration.lineThrough : null,
            decorationColor: color.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );
}

Widget _buildOutcomeChip(IronswornOutcome outcome, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.15),
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          outcome == IronswornOutcome.strongHit
              ? Icons.check_circle
              : outcome == IronswornOutcome.weakHit
                  ? Icons.remove_circle
                  : Icons.cancel,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          outcome.displayText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildMatchIndicator(bool isSuccess) {
  final color = isSuccess ? JuiceTheme.success : JuiceTheme.danger;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.auto_awesome,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          'Match!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Color _getChallengeColor(int actionScore, int challengeValue) {
  return actionScore > challengeValue
      ? JuiceTheme.success.withValues(alpha: 0.8) // Beaten
      : JuiceTheme.danger.withValues(alpha: 0.8); // Not beaten
}

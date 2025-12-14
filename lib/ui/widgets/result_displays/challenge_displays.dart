/// Challenge Display Builders - Display widgets for challenge and DC roll results.
///
/// This module handles display for:
/// - [FullChallengeResult] - Full challenge with physical and mental options
/// - [ChallengeSkillResult] - Single challenge skill result
/// - [DcResult] - Difficulty class result with method
/// - [QuickDcResult] - Quick DC result from 2d6
library;

import 'package:flutter/material.dart';

import '../../../presets/challenge.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all Challenge display builders with the registry.
void registerChallengeDisplays() {
  ResultDisplayRegistry.register<FullChallengeResult>(_buildFullChallengeDisplay);
  ResultDisplayRegistry.register<ChallengeSkillResult>(_buildChallengeSkillDisplay);
  ResultDisplayRegistry.register<DcResult>(_buildDcDisplay);
  ResultDisplayRegistry.register<QuickDcResult>(_buildQuickDcDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// FULL CHALLENGE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildFullChallengeDisplay(FullChallengeResult result, ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        _buildChallengeOptionChip(result.physicalSkill, result.physicalDc, result.physicalRoll, JuiceTheme.danger, theme),
        const SizedBox(width: 12),
        _buildChallengeOptionChip(result.mentalSkill, result.mentalDc, result.mentalRoll, JuiceTheme.info, theme),
      ]),
      const SizedBox(height: 6),
      Text('(${result.dcMethod})', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
    ],
  );
}

/// Builds a chip showing: "Skill DC X" with the roll indicator
Widget _buildChallengeOptionChip(String skill, int dc, int roll, Color color, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(skill, style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.parchment, fontSize: 13)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: JuiceTheme.gold20,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('DC $dc', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.gold, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 2),
        Text('Roll: $roll', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: color, fontSize: 10)),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// CHALLENGE SKILL DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildChallengeSkillDisplay(ChallengeSkillResult result, ThemeData theme) {
  final color = result.challengeType == ChallengeType.physical ? JuiceTheme.danger : JuiceTheme.info;
  return _buildChallengeChip(result.challengeType.name, result.skill, result.roll, color, theme);
}

Widget _buildChallengeChip(String label, String skill, int roll, Color color, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.4))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$roll', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: color, fontSize: 11)),
      const SizedBox(width: 6),
      Text(skill, style: TextStyle(fontWeight: FontWeight.w600, color: JuiceTheme.parchment, fontSize: 12)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// DC DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildDcDisplay(DcResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: JuiceTheme.gold15, borderRadius: BorderRadius.circular(6)),
      child: Text(result.diceResults.join(", "), style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11, color: JuiceTheme.gold)),
    ),
    const SizedBox(width: 8),
    Text('DC ${result.dc}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
    const SizedBox(width: 8),
    Text('(${result.method})', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK DC DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildQuickDcDisplay(QuickDcResult result, ThemeData theme) {
  return Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: JuiceTheme.gold15, borderRadius: BorderRadius.circular(6)),
      child: Text('2d6: [${result.dice.join(", ")}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11, color: JuiceTheme.gold)),
    ),
    const SizedBox(width: 8),
    Text('DC ${result.dc}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
  ]);
}

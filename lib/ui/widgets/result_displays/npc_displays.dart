/// NPC Display Builders - Display widgets for NPC-related roll results.
///
/// This module handles display for:
/// - [MotiveWithFollowUpResult] - Motive with optional history/focus follow-up
/// - [NpcActionResult] - NPC action table lookup results
/// - [NpcProfileResult] - Full NPC profile with personality, need, motive, etc.
/// - [ComplexNpcResult] - Complex NPC with name and dual personality
library;

import 'package:flutter/material.dart';

import '../../../presets/npc_action.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Register all NPC display builders with the registry.
void registerNpcDisplays() {
  ResultDisplayRegistry.register<MotiveWithFollowUpResult>(
      _buildMotiveWithFollowUpDisplay);
  ResultDisplayRegistry.register<NpcActionResult>(_buildNpcActionDisplay);
  ResultDisplayRegistry.register<NpcProfileResult>(_buildNpcProfileDisplay);
  ResultDisplayRegistry.register<ComplexNpcResult>(_buildComplexNpcDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// MOTIVE WITH FOLLOW-UP DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildMotiveWithFollowUpDisplay(
    MotiveWithFollowUpResult result, ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 1, 176, 159).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '1d10: ${result.roll}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 29, 170, 151),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Chip(
            label: const Text('Motive'),
            backgroundColor:
                const Color.fromARGB(255, 1, 176, 159).withOpacity(0.2),
            side: const BorderSide(color: Color.fromARGB(255, 1, 176, 159)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Text(
            result.motive,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      if (result.hasFollowUp) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'd10: ${result.historyResult?.roll ?? result.focusResult?.roll ?? "?"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.historyResult != null ? 'History' : 'Focus',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color.fromARGB(255, 161, 123, 226),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.followUpText ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.deepPurple[200],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NPC ACTION DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildNpcActionDisplay(NpcActionResult result, ThemeData theme) {
  final dieSize = result.dieSize ?? 10;
  final diceNotation = result.allRolls != null && result.allRolls!.length > 1
      ? 'd$dieSize@: ${result.allRolls!.join(", ")} → ${result.roll}'
      : '1d$dieSize: ${result.roll}';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 1, 176, 159).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          diceNotation,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 29, 170, 151),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Chip(
            label: Text(result.column.displayText),
            backgroundColor:
                const Color.fromARGB(255, 1, 176, 159).withOpacity(0.2),
            side: const BorderSide(color: Color.fromARGB(255, 1, 176, 159)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Text(
            result.result,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NPC PROFILE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildNpcProfileDisplay(NpcProfileResult result, ThemeData theme) {
  final charColor = JuiceTheme.categoryCharacter;

  String needSkewLabel = '';
  if (result.needSkew == NeedSkew.complex) {
    needSkewLabel = ' @+';
  } else if (result.needSkew == NeedSkew.primitive) {
    needSkewLabel = ' @-';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: charColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: charColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 12, color: charColor),
                const SizedBox(width: 4),
                Text(
                  'NPC PROFILE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: charColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          _buildNpcDiceBadge(
            'Pers',
            [result.primaryPersonalityRoll, result.secondaryPersonalityRoll],
            charColor,
            theme,
          ),
          _buildNpcDiceBadge(
            'Need$needSkewLabel',
            result.needAllRolls ?? [result.needRoll],
            JuiceTheme.mystic,
            theme,
          ),
          _buildNpcDiceBadge(
            'Mot',
            [
              result.motiveRoll,
              if (result.historyResult != null) result.historyResult!.roll,
              if (result.focusResult != null) result.focusResult!.roll,
              if (result.focusExpansionRoll != null) result.focusExpansionRoll!,
            ],
            JuiceTheme.info,
            theme,
          ),
          _buildNpcDiceBadge(
            'Col',
            [result.color.roll],
            JuiceTheme.juiceOrange,
            theme,
          ),
          _buildNpcDiceBadge(
            'Prop',
            null,
            JuiceTheme.rust,
            theme,
            propFormat:
                '${result.property1.propertyRoll}+${result.property1.intensityRoll}, ${result.property2.propertyRoll}+${result.property2.intensityRoll}',
          ),
        ],
      ),
      const SizedBox(height: 8),
      _buildLabeledRow('Personality', result.personalityDisplay, theme),
      const SizedBox(height: 4),
      _buildLabeledRow('Need', result.need, theme),
      const SizedBox(height: 4),
      _buildLabeledRow('Motive', result.motiveDisplay, theme),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              'Color:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (result.color.emoji != null) ...[
            Text(result.color.emoji!, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              result.color.result,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _buildLabeledRow(
        'Properties',
        '${result.property1.intensityDescription} ${result.property1.property}, ${result.property2.intensityDescription} ${result.property2.property}',
        theme,
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPLEX NPC DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildComplexNpcDisplay(ComplexNpcResult result, ThemeData theme) {
  final charColor = JuiceTheme.categoryCharacter;

  String needSkewLabel = '';
  if (result.needSkew == NeedSkew.complex) {
    needSkewLabel = ' @+';
  } else if (result.needSkew == NeedSkew.primitive) {
    needSkewLabel = ' @-';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: charColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: charColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 12, color: charColor),
                const SizedBox(width: 4),
                Text(
                  'COMPLEX NPC',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: charColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          _buildNpcDiceBadge(
            'Pers',
            result.secondaryPersonalityRoll != null
                ? [
                    result.primaryPersonalityRoll,
                    result.secondaryPersonalityRoll!
                  ]
                : [result.primaryPersonalityRoll],
            charColor,
            theme,
          ),
          _buildNpcDiceBadge(
            'Need$needSkewLabel',
            result.needAllRolls,
            JuiceTheme.mystic,
            theme,
          ),
          _buildNpcDiceBadge(
            'Mot',
            [
              result.motiveRoll,
              if (result.historyResult != null) result.historyResult!.roll,
              if (result.focusResult != null) result.focusResult!.roll,
              if (result.focusExpansionRoll != null) result.focusExpansionRoll!,
            ],
            JuiceTheme.info,
            theme,
          ),
          _buildNpcDiceBadge(
            'Col',
            [result.color.roll],
            JuiceTheme.juiceOrange,
            theme,
          ),
          _buildNpcDiceBadge(
            'Prop',
            null,
            JuiceTheme.rust,
            theme,
            propFormat:
                '${result.property1.propertyRoll}+${result.property1.intensityRoll}, ${result.property2.propertyRoll}+${result.property2.intensityRoll}',
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (result.name != null) ...[
        Row(
          children: [
            Icon(Icons.badge, size: 14, color: charColor),
            const SizedBox(width: 6),
            Text(
              result.name!.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
              ),
            ),
          ],
        ),
        const Divider(height: 12),
      ],
      _buildLabeledRow('Personality', result.personalityDisplay, theme),
      const SizedBox(height: 4),
      _buildLabeledRow('Need', result.need, theme),
      const SizedBox(height: 4),
      _buildLabeledRow('Motive', result.motiveDisplay, theme),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              'Color:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (result.color.emoji != null) ...[
            Text(result.color.emoji!, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              result.color.result,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _buildLabeledRow(
        'Properties',
        '${result.property1.intensityDescription} ${result.property1.property}, ${result.property2.intensityDescription} ${result.property2.property}',
        theme,
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

Widget _buildNpcDiceBadge(
  String label,
  List<int>? dice,
  Color color,
  ThemeData theme, {
  String? propFormat,
}) {
  final displayText = propFormat ?? '[${dice!.join(", ")}]';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            color: color,
            fontSize: 10,
          ),
        ),
        Text(
          displayText,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

Widget _buildLabeledRow(String label, String value, ThemeData theme) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 70,
        child: Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

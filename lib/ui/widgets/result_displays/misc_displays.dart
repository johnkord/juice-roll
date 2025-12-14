/// Miscellaneous display builders for the result display registry.
///
/// Contains displays for:
/// - PayThePriceResult: Consequence with optional major twist
/// - QuestResult: Quest sentence with component chips
/// - InterruptPlotPointResult: Category and event display
/// - SimpleNpcResult: Simple NPC with name and profile
/// - ItemCreationResult: Item with base and properties
/// - ObjectTreasureResult: Treasure category with properties
/// - FateRollResult: Fate dice display
/// - DialogResult: Dialog with direction, tone, subject
/// - AbstractIconResult: Icon grid display
/// - InformationResult: Information type and topic
/// - CompanionResponseResult: Companion response display
/// - DialogTopicResult: Dialog topic display
/// - NameResult: Generated name with syllable breakdown
library;

import 'package:flutter/material.dart';
import '../result_display_registry.dart';
import '../../theme/juice_theme.dart';
import '../../../models/roll_result.dart';
import '../../../presets/pay_the_price.dart';
import '../../../presets/quest.dart';
import '../../../presets/interrupt_plot_point.dart';
import '../../../presets/settlement.dart';
import '../../../presets/object_treasure.dart';
import '../../../presets/abstract_icons.dart';
import '../../../presets/dialog_generator.dart';
import '../../../presets/extended_npc_conversation.dart';
import '../../../presets/name_generator.dart';
import '../../../core/fate_dice_formatter.dart';

/// Register all miscellaneous display builders with the registry.
void registerMiscDisplays() {
  ResultDisplayRegistry.register<PayThePriceResult>(buildPayThePriceDisplay);
  ResultDisplayRegistry.register<QuestResult>(buildQuestDisplay);
  ResultDisplayRegistry.register<InterruptPlotPointResult>(buildInterruptDisplay);
  ResultDisplayRegistry.register<SimpleNpcResult>(buildSimpleNpcDisplay);
  ResultDisplayRegistry.register<ItemCreationResult>(buildItemCreationDisplay);
  ResultDisplayRegistry.register<ObjectTreasureResult>(buildObjectTreasureDisplay);
  ResultDisplayRegistry.register<FateRollResult>(buildFateRollDisplay);
  ResultDisplayRegistry.register<DialogResult>(buildDialogDisplay);
  ResultDisplayRegistry.register<AbstractIconResult>(buildAbstractIconDisplay);
  ResultDisplayRegistry.register<InformationResult>(buildInformationDisplay);
  ResultDisplayRegistry.register<CompanionResponseResult>(buildCompanionResponseDisplay);
  ResultDisplayRegistry.register<DialogTopicResult>(buildDialogTopicDisplay);
  ResultDisplayRegistry.register<NameResult>(buildNameResultDisplay);
}

// ═══════════════════════════════════════════════════════════════════════════
// PAY THE PRICE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for PayThePriceResult - shows consequence with optional major twist.
Widget buildPayThePriceDisplay(RollResult r, ThemeData theme) {
  final result = r as PayThePriceResult;
  final color = result.isMajorTwist ? JuiceTheme.danger : JuiceTheme.rust;
  final icon = result.isMajorTwist ? Icons.bolt : Icons.warning_amber;
  final label = result.isMajorTwist ? 'MAJOR PLOT TWIST' : 'PAY THE PRICE';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: JuiceTheme.sepia10, borderRadius: BorderRadius.circular(4)),
            child: Text('1d10: ${result.roll}', style: TextStyle(fontSize: 9, fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.parchmentDark)),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(result.isMajorTwist ? Icons.error_outline : Icons.report_problem_outlined, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.result,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, color: JuiceTheme.parchment, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// QUEST DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for QuestResult - shows quest sentence with component chips.
Widget buildQuestDisplay(RollResult r, ThemeData theme) {
  final result = r as QuestResult;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Quest sentence with styled formatting
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: JuiceTheme.rust08,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: JuiceTheme.rust25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, size: 14, color: JuiceTheme.rust),
                const SizedBox(width: 6),
                Text('Quest Hook', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: JuiceTheme.rust, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              result.questSentence,
              style: TextStyle(fontFamily: JuiceTheme.fontFamilySerif, fontSize: 14, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: JuiceTheme.parchment, height: 1.3),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      // Roll breakdown in organized format
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _buildQuestComponentChip(roll: result.objectiveRoll, subRoll: null, label: result.objective, category: 'Objective', color: JuiceTheme.info),
          _buildQuestComponentChip(roll: result.descriptionRoll, subRoll: result.descriptionSubRoll, label: result.descriptionExpanded ?? result.description, category: result.descriptionExpanded != null ? result.description : null, color: JuiceTheme.success),
          _buildQuestComponentChip(roll: result.focusRoll, subRoll: result.focusSubRoll, label: result.focusExpanded ?? result.focus, category: result.focusExpanded != null ? result.focus : null, color: JuiceTheme.gold),
          _buildQuestComponentChip(roll: result.prepositionRoll, subRoll: null, label: result.preposition, category: null, color: JuiceTheme.mystic),
          _buildQuestComponentChip(roll: result.locationRoll, subRoll: result.locationSubRoll, label: result.locationExpanded ?? result.location, category: result.locationExpanded != null ? result.location : null, color: JuiceTheme.rust),
        ],
      ),
    ],
  );
}

/// Helper to build quest component chip.
Widget _buildQuestComponentChip({required int roll, required int? subRoll, required String label, required String? category, required Color color}) {
  final rollText = subRoll != null ? '$roll→$subRoll' : '$roll';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.4))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
          child: Text(rollText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: color)),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: JuiceTheme.parchment)),
            if (category != null) Text('($category)', style: TextStyle(fontSize: 9, color: color, fontStyle: FontStyle.italic)),
          ],
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// INTERRUPT DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for InterruptPlotPointResult - shows category and event.
Widget buildInterruptDisplay(RollResult r, ThemeData theme) {
  final result = r as InterruptPlotPointResult;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Category chip with roll
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.purple.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('d10: ${result.categoryRoll}', style: theme.textTheme.bodySmall?.copyWith(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: Colors.purple)),
                const SizedBox(width: 8),
                Text(result.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Event with roll
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text('d10: ${result.eventRoll}', style: theme.textTheme.bodySmall?.copyWith(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: Colors.purple)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(result.event, style: TextStyle(fontFamily: JuiceTheme.fontFamilySerif, fontSize: 14, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: JuiceTheme.parchment)),
            ),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SIMPLE NPC DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for SimpleNpcResult - shows NPC name and profile chips.
Widget buildSimpleNpcDisplay(RollResult r, ThemeData theme) {
  final result = r as SimpleNpcResult;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.categoryCharacter10, borderRadius: BorderRadius.circular(8)),
        child: Text('Name: ${result.name.rolls.length}d10, Profile: 3d10', style: theme.textTheme.bodySmall?.copyWith(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.categoryCharacter)),
      ),
      const SizedBox(height: 6),
      Text(result.name.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          Chip(
            avatar: const Icon(Icons.psychology, size: 14),
            label: Text(result.profile.personality),
            backgroundColor: Colors.purple.withOpacity(0.1),
            side: BorderSide(color: Colors.purple.withOpacity(0.3)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            labelStyle: const TextStyle(fontSize: 11),
          ),
          Chip(
            avatar: const Icon(Icons.favorite, size: 14),
            label: Text(result.profile.need),
            backgroundColor: Colors.red.withOpacity(0.1),
            side: BorderSide(color: Colors.red.withOpacity(0.3)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            labelStyle: const TextStyle(fontSize: 11),
          ),
          Chip(
            avatar: const Icon(Icons.trending_up, size: 14),
            label: Text(result.profile.motive),
            backgroundColor: Colors.blue.withOpacity(0.1),
            side: BorderSide(color: Colors.blue.withOpacity(0.3)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            labelStyle: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ITEM CREATION DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for ItemCreationResult - shows item with base and properties.
Widget buildItemCreationDisplay(RollResult r, ThemeData theme) {
  final result = r as ItemCreationResult;
  final categoryColor = _getTreasureCategoryColor(result.baseItem.category);
  final categoryIcon = _getTreasureCategoryIcon(result.baseItem.category);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: categoryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Icon(categoryIcon, size: 16, color: categoryColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.baseItem.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: categoryColor, letterSpacing: 0.5)),
                Text(result.baseItem.fullDescription, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, color: JuiceTheme.parchment)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: JuiceTheme.mystic08,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: JuiceTheme.mystic20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_fix_high, size: 12, color: JuiceTheme.mystic),
              const SizedBox(width: 4),
              Text('Properties', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: JuiceTheme.mystic)),
            ]),
            const SizedBox(height: 6),
            Text('${result.property1.intensityDescription} ${result.property1.property}', style: theme.textTheme.bodySmall),
            Text('${result.property2.intensityDescription} ${result.property2.property}', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      if (result.color != null) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: JuiceTheme.juiceOrange10, borderRadius: BorderRadius.circular(6)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.palette, size: 14, color: JuiceTheme.juiceOrange),
              const SizedBox(width: 6),
              Text(result.color!.result, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: JuiceTheme.juiceOrange)),
              if (result.color!.emoji != null) ...[const SizedBox(width: 4), Text(result.color!.emoji!, style: const TextStyle(fontSize: 14))],
            ],
          ),
        ),
      ],
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// OBJECT TREASURE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for ObjectTreasureResult - shows treasure category with properties.
Widget buildObjectTreasureDisplay(RollResult r, ThemeData theme) {
  final result = r as ObjectTreasureResult;
  final categoryColor = _getTreasureCategoryColor(result.category);
  final categoryIcon = _getTreasureCategoryIcon(result.category);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: categoryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Icon(categoryIcon, size: 16, color: categoryColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: categoryColor, letterSpacing: 0.5)),
                Text(result.fullDescription, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, color: JuiceTheme.parchment)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (result.rolls.isNotEmpty)
            _buildTreasurePropertyChip(
              result.columnLabels.isNotEmpty ? result.columnLabels[0] : 'Quality',
              result.quality,
              result.rolls.length > 1 ? result.rolls[1] : result.rolls[0],
              categoryColor,
            ),
          if (result.rolls.length > 2)
            _buildTreasurePropertyChip(
              result.columnLabels.length > 1 ? result.columnLabels[1] : 'Material',
              result.material,
              result.rolls[2],
              categoryColor,
            ),
          if (result.rolls.length > 3)
            _buildTreasurePropertyChip(
              result.columnLabels.length > 2 ? result.columnLabels[2] : 'Type',
              result.itemType,
              result.rolls[3],
              categoryColor,
            ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.inkDark, borderRadius: BorderRadius.circular(4)),
        child: Text('4d6: [${result.rolls.join(", ")}]', style: TextStyle(fontSize: 10, fontFamily: JuiceTheme.fontFamilyMono, color: Colors.grey.shade500)),
      ),
    ],
  );
}

/// Get color for treasure category.
Color _getTreasureCategoryColor(String category) {
  switch (category) {
    case 'Trinket':
      return JuiceTheme.sepia;
    case 'Treasure':
      return JuiceTheme.gold;
    case 'Document':
      return JuiceTheme.parchmentDark;
    case 'Accessory':
      return JuiceTheme.mystic;
    case 'Weapon':
      return JuiceTheme.danger;
    case 'Armor':
      return JuiceTheme.info;
    default:
      return JuiceTheme.gold;
  }
}

/// Get icon for treasure category.
IconData _getTreasureCategoryIcon(String category) {
  switch (category) {
    case 'Trinket':
      return Icons.auto_awesome;
    case 'Treasure':
      return Icons.paid;
    case 'Document':
      return Icons.description;
    case 'Accessory':
      return Icons.watch;
    case 'Weapon':
      return Icons.gpp_maybe;
    case 'Armor':
      return Icons.shield;
    default:
      return Icons.diamond;
  }
}

/// Build property chip for treasure.
Widget _buildTreasurePropertyChip(String label, String value, int roll, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.3))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, color: color)),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
          child: Text('$roll', style: TextStyle(fontSize: 9, fontFamily: JuiceTheme.fontFamilyMono, color: color)),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// FATE ROLL DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for FateRollResult - shows fate dice with symbols.
Widget buildFateRollDisplay(RollResult r, ThemeData theme) {
  final result = r as FateRollResult;
  final total = result.total;
  Color resultColor;
  String resultLabel;

  if (total > 0) {
    resultColor = JuiceTheme.success;
    resultLabel = 'Positive (+$total)';
  } else if (total < 0) {
    resultColor = JuiceTheme.danger;
    resultLabel = 'Negative ($total)';
  } else {
    resultColor = JuiceTheme.gold;
    resultLabel = 'Neutral (0)';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Fate dice display using formatter
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: resultColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: resultColor.withOpacity(0.3))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show each die face
            ...result.diceResults.map((value) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: JuiceTheme.parchment15,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: resultColor.withOpacity(0.5), width: 2),
                ),
                child: Center(child: Text(FateDiceFormatter.dieToSymbol(value), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: resultColor))),
              );
            }),
            const SizedBox(width: 12),
            // Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: resultColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('= $total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: resultColor)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Result interpretation
      Center(
        child: Chip(
          label: Text(resultLabel, style: TextStyle(color: resultColor, fontWeight: FontWeight.bold)),
          backgroundColor: resultColor.withOpacity(0.1),
          side: BorderSide(color: resultColor),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// DIALOG DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for DialogResult - shows the full Dialog Grid mini-game state.
/// 
/// Per Juice instructions, the Dialog Grid tracks:
/// - Fragment: The type of dialog (Fact, Query, Need, Want, Action, Denial, Support)
/// - Movement: Old position → New position on the 5x5 grid
/// - Tone: Neutral, Defensive, Aggressive, or Helpful (based on first d10)
/// - Subject: Who the NPC is referring to - Them, Me, You, Us (based on second d10)
/// - Tense: Past (rows 0-1) or Present (rows 2-4)
/// - Doubles: If both dice match, the conversation ends
Widget buildDialogDisplay(RollResult r, ThemeData theme) {
  final result = r as DialogResult;
  final hasDoubles = result.isDoubles;
  final accentColor = hasDoubles ? JuiceTheme.gold : JuiceTheme.info;
  final tenseColor = result.isPast ? JuiceTheme.juiceOrange : JuiceTheme.success;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice roll display with doubles indicator
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('2d10: [${result.directionRoll}, ${result.subjectRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: accentColor)),
          ),
          if (hasDoubles) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: JuiceTheme.gold20, borderRadius: BorderRadius.circular(6), border: Border.all(color: JuiceTheme.gold)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.star, size: 12, color: JuiceTheme.gold),
                const SizedBox(width: 4),
                Text('DOUBLES!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
              ]),
            ),
          ],
        ],
      ),
      const SizedBox(height: 12),

      // Main fragment display - the most important piece
      if (hasDoubles) ...[
        // Conversation ends display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: JuiceTheme.gold10,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: JuiceTheme.gold40),
          ),
          child: Column(
            children: [
              Icon(Icons.stop_circle_outlined, size: 28, color: JuiceTheme.gold),
              const SizedBox(height: 6),
              Text(
                'Conversation Ends',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: JuiceTheme.gold),
              ),
              const SizedBox(height: 4),
              Text(
                'The NPC wants to stop. They might be done talking, walk away, or retreat.',
                style: TextStyle(fontSize: 11, color: JuiceTheme.parchmentDark, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ] else ...[
        // Fragment movement: Old → New
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Movement indicator: Old Fragment → New Fragment
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result.oldFragment,
                    style: TextStyle(fontSize: 14, color: JuiceTheme.parchmentDark60),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    result.newFragment,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: JuiceTheme.parchment),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fragment description
              Text(
                result.fragmentDescription,
                style: TextStyle(fontSize: 12, color: JuiceTheme.parchmentDark, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Past/Present tense indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tenseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.isPast ? '📜 About the Past' : '📍 About the Present',
                  style: TextStyle(fontSize: 10, color: tenseColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 10),

      // Tone and Subject - the context for HOW the NPC says it
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildDialogComponentChip('Tone', result.tone, _getToneIcon(result.tone), accentColor),
          _buildDialogComponentChip('Subject', result.subject, _getSubjectIcon(result.subject), accentColor),
        ],
      ),
    ],
  );
}

/// Get an appropriate icon for the dialog tone.
IconData _getToneIcon(String tone) {
  switch (tone.toLowerCase()) {
    case 'neutral':
      return Icons.sentiment_neutral;
    case 'defensive':
      return Icons.shield;
    case 'aggressive':
      return Icons.local_fire_department;
    case 'helpful':
      return Icons.favorite;
    default:
      return Icons.mood;
  }
}

/// Get an appropriate icon for the dialog subject.
IconData _getSubjectIcon(String subject) {
  switch (subject.toLowerCase()) {
    case 'you':
      return Icons.person_outline; // Referring to the PC
    case 'me':
      return Icons.record_voice_over; // NPC talking about themselves
    case 'them':
      return Icons.groups; // Third parties
    case 'us':
      return Icons.handshake; // Mutual/shared
    default:
      return Icons.person;
  }
}

/// Helper to build dialog component chip.
Widget _buildDialogComponentChip(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            Text(value, style: TextStyle(fontSize: 12, color: JuiceTheme.parchment, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// ABSTRACT ICON DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for AbstractIconResult - shows icon grid lookup.
Widget buildAbstractIconDisplay(RollResult r, ThemeData theme) {
  final result = r as AbstractIconResult;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Grid coordinates
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: JuiceTheme.juiceOrange10, borderRadius: BorderRadius.circular(8)),
        child: Text('Grid: (${result.rowLabel}, ${result.colLabel})', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 14, color: JuiceTheme.juiceOrange)),
      ),
      const SizedBox(height: 12),
      // Icon image
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(color: JuiceTheme.parchment10, borderRadius: BorderRadius.circular(12), border: Border.all(color: JuiceTheme.juiceOrange40)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset(result.imagePath ?? '', fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 48, color: JuiceTheme.parchment50)),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// INFORMATION DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for InformationResult - shows type and topic.
Widget buildInformationDisplay(RollResult r, ThemeData theme) {
  final result = r as InformationResult;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.info10, borderRadius: BorderRadius.circular(8)),
        child: Text('2d100: [${result.typeRoll}, ${result.topicRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.info)),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Chip(label: Text(result.informationType), backgroundColor: JuiceTheme.info15, side: BorderSide(color: JuiceTheme.info), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
          const SizedBox(width: 8),
          Expanded(child: Text(result.topic, style: theme.textTheme.bodyMedium)),
        ],
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPANION RESPONSE DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for CompanionResponseResult - shows response.
Widget buildCompanionResponseDisplay(RollResult r, ThemeData theme) {
  final result = r as CompanionResponseResult;
  final isPositive = result.response.contains('Agree') || result.response.contains('Supportive');
  final color = isPositive ? JuiceTheme.success : JuiceTheme.danger;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('d100: ${result.roll}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: color)),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color),
          ),
          child: Text(
            result.response,
            style: TextStyle(fontSize: 13, color: color),
          ),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// DIALOG TOPIC DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for DialogTopicResult - shows topic.
Widget buildDialogTopicDisplay(RollResult r, ThemeData theme) {
  final result = r as DialogTopicResult;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: JuiceTheme.juiceOrange15, borderRadius: BorderRadius.circular(6), border: Border.all(color: JuiceTheme.juiceOrange40)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum, size: 12, color: JuiceTheme.juiceOrange),
                const SizedBox(width: 4),
                Text('DIALOG TOPIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: JuiceTheme.juiceOrange)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(color: JuiceTheme.juiceOrange10, borderRadius: BorderRadius.circular(4)),
            child: Text('1d100: ${result.roll}', style: TextStyle(fontSize: 10, fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: JuiceTheme.juiceOrange)),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: JuiceTheme.juiceOrange08, borderRadius: BorderRadius.circular(8), border: Border.all(color: JuiceTheme.juiceOrange20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.chat_bubble_outline, size: 16, color: JuiceTheme.juiceOrange70),
            const SizedBox(width: 8),
            Expanded(child: Text(result.topic, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, color: JuiceTheme.parchment, height: 1.3))),
          ],
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NAME RESULT DISPLAY
// ═══════════════════════════════════════════════════════════════════════════

/// Build display for NameResult - shows generated name with syllable breakdown.
Widget buildNameResultDisplay(RollResult r, ThemeData theme) {
  final result = r as NameResult;
  final characterColor = JuiceTheme.categoryCharacter;

  // Determine column labels based on method
  List<String> columnLabels;
  int rollOffset = 0;

  if (result.method == NameMethod.pattern && result.pattern != null) {
    columnLabels = [];
    for (final char in result.pattern!.split('')) {
      if (char == '1' || char == '2' || char == '3') {
        columnLabels.add('C$char');
      }
    }
    rollOffset = 1;
  } else if (result.method == NameMethod.column1) {
    columnLabels = ['C1', 'C1', 'C1'];
  } else {
    columnLabels = ['C1', 'C2', 'C3'];
  }

  // Get suffix from pattern if present
  String? suffix;
  if (result.pattern != null) {
    for (final char in ['o', 'a', 'i']) {
      if (result.pattern!.contains(char)) {
        suffix = char;
        break;
      }
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Generated name with style indicator
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: characterColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: characterColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.person, size: 20, color: characterColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.name,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, fontSize: 22, color: characterColor),
              ),
            ),
            if (result.style != NameStyle.neutral)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: characterColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: characterColor.withOpacity(0.4)),
                ),
                child: Text(result.style == NameStyle.masculine ? '♂ Masc' : '♀ Fem', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: characterColor)),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),

      // Pattern method indicator
      if (result.method == NameMethod.pattern && result.pattern != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: JuiceTheme.juiceOrange10,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: JuiceTheme.juiceOrange30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.casino, size: 12, color: JuiceTheme.juiceOrange),
              const SizedBox(width: 6),
              Text('d20: ${result.rolls.isNotEmpty ? result.rolls[0] : "?"}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 10, fontWeight: FontWeight.bold, color: JuiceTheme.juiceOrange)),
              const SizedBox(width: 8),
              Text('→', style: TextStyle(color: JuiceTheme.parchment50, fontSize: 10)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: JuiceTheme.juiceOrange15, borderRadius: BorderRadius.circular(4)),
                child: Text('Pattern: ${result.pattern}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11, fontWeight: FontWeight.bold, color: JuiceTheme.juiceOrange)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],

      // Syllable breakdown
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: characterColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: characterColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            for (int i = 0; i < result.syllables.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('+', style: TextStyle(color: characterColor.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(color: characterColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i < columnLabels.length) Text(columnLabels[i], style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: characterColor.withOpacity(0.6), letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(result.syllables[i], style: TextStyle(fontFamily: JuiceTheme.fontFamilySerif, fontWeight: FontWeight.bold, color: characterColor, fontSize: 15)),
                      const SizedBox(height: 2),
                      if (i + rollOffset < result.rolls.length)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: characterColor.withOpacity(0.15), borderRadius: BorderRadius.circular(3)),
                          child: Text('d20: ${result.rolls[i + rollOffset]}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 8, color: characterColor.withOpacity(0.8))),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            // Suffix if pattern has one
            if (suffix != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('+', style: TextStyle(color: characterColor.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: characterColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SUFFIX', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: characterColor.withOpacity(0.6), letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(suffix, style: TextStyle(fontFamily: JuiceTheme.fontFamilySerif, fontWeight: FontWeight.bold, color: characterColor, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),

      // Method indicator for non-pattern methods
      if (result.method != NameMethod.pattern) ...[
        const SizedBox(height: 4),
        Text(
          result.method == NameMethod.simple ? 'Method: 3d20 across columns 1-2-3' : 'Method: 3d20 on column 1 only',
          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: JuiceTheme.parchment50, fontSize: 10),
        ),
      ],
    ],
  );
}

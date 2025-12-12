import 'package:flutter/material.dart';
import '../../../core/fate_dice_formatter.dart';
import '../../../data/random_event_data.dart' as random_event_data;
import '../../../presets/fate_check.dart';
import '../../../presets/expectation_check.dart';
import '../../../presets/scale.dart';
import '../../../presets/next_scene.dart';
import '../../../presets/random_event.dart';
import '../../../presets/discover_meaning.dart';
import '../../theme/juice_theme.dart';
import '../result_display_registry.dart';

/// Oracle result display builders.
/// 
/// This module handles display widgets for all Oracle-related results:
/// - FateCheckResult - Yes/No with modifiers and special triggers
/// - ExpectationCheckResult - Testing assumptions
/// - ScaleResult - Increase/decrease scales
/// - NextSceneResult - Scene type determination
/// - NextSceneWithFollowUpResult - Scene with auto-rolled follow-ups
/// - RandomEventResult - Full random event (focus + modifier + idea)
/// - RandomEventFocusResult - Just the focus
/// - IdeaResult - Modifier + Idea pair
/// - SingleTableResult - Individual table rolls (Modifier, Idea, Event, Person, Object)
/// - DiscoverMeaningResult - Adjective + Noun pair

/// Registers all Oracle display builders with the registry.
void registerOracleDisplays() {
  ResultDisplayRegistry.register<FateCheckResult>(buildFateCheckDisplay);
  ResultDisplayRegistry.register<ExpectationCheckResult>(buildExpectationCheckDisplay);
  ResultDisplayRegistry.register<ScaleResult>(buildScaleDisplay);
  ResultDisplayRegistry.register<NextSceneResult>(buildNextSceneDisplay);
  ResultDisplayRegistry.register<NextSceneWithFollowUpResult>(buildNextSceneWithFollowUpDisplay);
  ResultDisplayRegistry.register<RandomEventResult>(buildRandomEventDisplay);
  ResultDisplayRegistry.register<RandomEventFocusResult>(buildRandomEventFocusDisplay);
  ResultDisplayRegistry.register<IdeaResult>(buildIdeaDisplay);
  ResultDisplayRegistry.register<SingleTableResult>(buildSingleTableDisplay);
  ResultDisplayRegistry.register<DiscoverMeaningResult>(buildDiscoverMeaningDisplay);
}

// =============================================================================
// FATE CHECK DISPLAY
// =============================================================================

Widget buildFateCheckDisplay(FateCheckResult result, ThemeData theme) {
  final isPositive = result.outcome.isYes;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Fate dice symbols with label
          FateDiceFormatter.buildLabeledFateDiceDisplay(
            label: '2dF',
            dice: result.fateDice,
            theme: theme,
          ),
          const SizedBox(width: 12),
          // Intensity die with label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.mystic.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
            ),
            child: Text(
              '1d6: ${result.intensity}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: JuiceTheme.mystic,
              ),
            ),
          ),
          const Spacer(),
          // Outcome chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? JuiceTheme.success.withValues(alpha: 0.2)
                  : JuiceTheme.danger.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPositive ? JuiceTheme.success : JuiceTheme.danger,
              ),
            ),
            child: Text(
              result.outcome.displayText,
              style: TextStyle(
                color: isPositive ? JuiceTheme.success : JuiceTheme.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      // Special trigger (Random Event / Invalid Assumption)
      if (result.hasSpecialTrigger) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: result.specialTrigger == SpecialTrigger.randomEvent
                ? JuiceTheme.gold.withValues(alpha: 0.2)
                : JuiceTheme.mystic.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: result.specialTrigger == SpecialTrigger.randomEvent
                  ? JuiceTheme.gold
                  : JuiceTheme.mystic,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result.specialTrigger == SpecialTrigger.randomEvent
                    ? Icons.flash_on
                    : Icons.warning_amber,
                size: 16,
                color: result.specialTrigger == SpecialTrigger.randomEvent
                    ? JuiceTheme.gold
                    : JuiceTheme.mystic,
              ),
              const SizedBox(width: 4),
              Text(
                result.specialTrigger!.displayText,
                style: TextStyle(
                  color: result.specialTrigger == SpecialTrigger.randomEvent
                      ? JuiceTheme.gold
                      : JuiceTheme.mystic,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
      // Auto-rolled Random Event details
      if (result.hasRandomEvent) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: JuiceTheme.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus: ${result.randomEventResult!.focus}',
                style: TextStyle(
                  color: JuiceTheme.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${result.randomEventResult!.modifier} ${result.randomEventResult!.idea}',
                style: TextStyle(
                  color: JuiceTheme.parchment,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      // Intensity description
      const SizedBox(height: 4),
      Text(
        'Intensity: ${result.intensityDescription}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: JuiceTheme.parchmentDark,
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  );
}

// =============================================================================
// EXPECTATION CHECK DISPLAY
// =============================================================================

Widget buildExpectationCheckDisplay(ExpectationCheckResult result, ThemeData theme) {
  // Determine if outcome is positive based on outcome type
  final isPositive = result.outcome == ExpectationOutcome.expected ||
      result.outcome == ExpectationOutcome.expectedIntensified ||
      result.outcome == ExpectationOutcome.favorable;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Fate dice symbols
          FateDiceFormatter.buildLabeledFateDiceDisplay(
            label: '2dF',
            dice: result.fateDice,
            theme: theme,
          ),
          const SizedBox(width: 12),
          // Outcome chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? JuiceTheme.success.withValues(alpha: 0.2)
                  : JuiceTheme.danger.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPositive ? JuiceTheme.success : JuiceTheme.danger,
              ),
            ),
            child: Text(
              result.outcome.displayText,
              style: TextStyle(
                color: isPositive ? JuiceTheme.success : JuiceTheme.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      // Show auto-rolled meaning for Modified Idea outcome
      if (result.hasMeaning && result.meaningResult != null) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: JuiceTheme.mystic.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Text(
                result.meaningResult!.adjective,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.mystic,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                result.meaningResult!.noun,
                style: TextStyle(
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
// SCALE DISPLAY
// =============================================================================

Widget buildScaleDisplay(ScaleResult result, ThemeData theme) {
  // Determine color based on direction
  final color = result.isIncrease
      ? JuiceTheme.success
      : (result.isDecrease ? JuiceTheme.danger : JuiceTheme.parchmentDark);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Fate dice symbols
          FateDiceFormatter.buildLabeledFateDiceDisplay(
            label: '2dF',
            dice: result.fateDice,
            theme: theme,
          ),
          const SizedBox(width: 8),
          // Intensity die
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.mystic.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
            ),
            child: Text(
              '1d6: ${result.intensity}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: JuiceTheme.mystic,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Scale result chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color),
            ),
            child: Text(
              result.modifier,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// =============================================================================
// NEXT SCENE DISPLAY
// =============================================================================

Widget buildNextSceneDisplay(NextSceneResult result, ThemeData theme) {
  Color chipColor;
  switch (result.sceneType) {
    case SceneType.normal:
      chipColor = JuiceTheme.success;
      break;
    case SceneType.alterAdd:
    case SceneType.alterRemove:
      chipColor = JuiceTheme.gold;
      break;
    case SceneType.interruptFavorable:
      chipColor = JuiceTheme.info;
      break;
    case SceneType.interruptUnfavorable:
      chipColor = JuiceTheme.danger;
      break;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          FateDiceFormatter.buildLabeledFateDiceDisplay(
            label: '2dF',
            dice: result.fateDice,
            theme: theme,
          ),
          const SizedBox(width: 12),
          Chip(
            label: Text(
              result.sceneType.displayText,
              style: TextStyle(color: chipColor, fontWeight: FontWeight.w600),
            ),
            backgroundColor: chipColor.withValues(alpha: 0.2),
            side: BorderSide(color: chipColor),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      if (result.sceneType.requiresFollowUp) ...[
        const SizedBox(height: 4),
        Text(
          '→ Roll ${result.sceneType.followUpRoll}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: JuiceTheme.parchmentDark,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ],
  );
}

// =============================================================================
// NEXT SCENE WITH FOLLOW-UP DISPLAY
// =============================================================================

Widget buildNextSceneWithFollowUpDisplay(NextSceneWithFollowUpResult result, ThemeData theme) {
  final sceneResult = result.sceneResult;
  Color chipColor;
  switch (sceneResult.sceneType) {
    case SceneType.normal:
      chipColor = JuiceTheme.success;
      break;
    case SceneType.alterAdd:
    case SceneType.alterRemove:
      chipColor = JuiceTheme.gold;
      break;
    case SceneType.interruptFavorable:
      chipColor = JuiceTheme.info;
      break;
    case SceneType.interruptUnfavorable:
      chipColor = JuiceTheme.danger;
      break;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          FateDiceFormatter.buildLabeledFateDiceDisplay(
            label: '2dF',
            dice: sceneResult.fateDice,
            theme: theme,
          ),
          const SizedBox(width: 12),
          Chip(
            label: Text(
              sceneResult.sceneType.displayText,
              style: TextStyle(color: chipColor, fontWeight: FontWeight.w600),
            ),
            backgroundColor: chipColor.withValues(alpha: 0.2),
            side: BorderSide(color: chipColor),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      if (result.focusResult != null) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.arrow_forward, size: 16, color: JuiceTheme.parchmentDark),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'd10: ${result.focusResult!.roll}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Focus: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: JuiceTheme.parchmentDark),
            ),
            Chip(
              label: Text(result.focusResult!.focus),
              backgroundColor: JuiceTheme.categoryExplore.withValues(alpha: 0.2),
              side: BorderSide(color: JuiceTheme.categoryExplore),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
      if (result.ideaResult != null) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.arrow_forward, size: 16, color: JuiceTheme.parchmentDark),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '2d10: [${result.ideaResult!.modifierRoll}, ${result.ideaResult!.ideaRoll}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${result.ideaResult!.modifier} ${result.ideaResult!.idea}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
      if (result.plotPointResult != null) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.arrow_forward, size: 16, color: JuiceTheme.parchmentDark),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '2d10: [${result.plotPointResult!.categoryRoll}, ${result.plotPointResult!.eventRoll}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Chip(
              label: Text(result.plotPointResult!.category),
              backgroundColor: JuiceTheme.mystic.withValues(alpha: 0.2),
              side: BorderSide(color: JuiceTheme.mystic),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                result.plotPointResult!.event,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

// =============================================================================
// RANDOM EVENT DISPLAY
// =============================================================================

Widget buildRandomEventDisplay(RandomEventResult result, ThemeData theme) {
  final description = random_event_data.eventFocusDescriptions[result.focus] ?? '';
  final actions = random_event_data.eventFocusActions[result.focus] ?? [];
  
  // Special styling for Plot Armor - it's a gift!
  final isPlotArmor = result.focus == 'Plot Armor';
  final focusColor = isPlotArmor ? JuiceTheme.success : Colors.amber;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Plot Armor celebration banner
      if (isPlotArmor) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                JuiceTheme.success.withValues(alpha: 0.3),
                JuiceTheme.gold.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.success),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 18, color: JuiceTheme.success),
              const SizedBox(width: 8),
              Text(
                'Your problem is SOLVED!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, size: 18, color: JuiceTheme.success),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      
      // Dice rolls
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: focusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '3d10: ${result.focusRoll}, ${result.modifierRoll}, ${result.ideaRoll}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
          ),
        ),
      ),
      const SizedBox(height: 8),
      
      // Focus type with icon
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: focusColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: focusColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getEventFocusIcon(result.focus),
              size: 14,
              color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              result.focus,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade800,
              ),
            ),
          ],
        ),
      ),
      
      // Modifier + Idea phrase (the "meaning" component)
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: JuiceTheme.juiceOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16, color: JuiceTheme.juiceOrange),
            const SizedBox(width: 8),
            Text(
              '${result.modifier} ${result.idea}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: JuiceTheme.parchment,
              ),
            ),
          ],
        ),
      ),
      
      // Description / Guidance
      if (description.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.sepia.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.sepia.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: JuiceTheme.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: JuiceTheme.parchment,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      
      // Extended guidance for specific focuses (deeper context from Juice instructions)
      if (random_event_data.eventFocusExtendedGuidance.containsKey(result.focus)) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: JuiceTheme.mystic.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: JuiceTheme.mystic.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: JuiceTheme.mystic.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  random_event_data.eventFocusExtendedGuidance[result.focus]!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: JuiceTheme.parchmentDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      
      // Suggested follow-up actions
      if (actions.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          'Suggested Follow-up:',
          style: theme.textTheme.labelSmall?.copyWith(
            color: JuiceTheme.parchmentDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: actions.map((action) => _buildActionChip(action, theme)).toList(),
        ),
      ],
    ],
  );
}

// =============================================================================
// RANDOM EVENT FOCUS DISPLAY
// =============================================================================

Widget buildRandomEventFocusDisplay(RandomEventFocusResult result, ThemeData theme) {
  final description = random_event_data.eventFocusDescriptions[result.focus] ?? '';
  final actions = random_event_data.eventFocusActions[result.focus] ?? [];
  
  // Special styling for Plot Armor (it's a gift!)
  final isPlotArmor = result.focus == 'Plot Armor';
  final focusColor = isPlotArmor ? JuiceTheme.success : Colors.amber;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Plot Armor celebration banner
      if (isPlotArmor) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                JuiceTheme.success.withValues(alpha: 0.3),
                JuiceTheme.gold.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.success),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 18, color: JuiceTheme.success),
              const SizedBox(width: 8),
              Text(
                'Your problem is SOLVED!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, size: 18, color: JuiceTheme.success),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      
      // Dice roll display
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '1d10: ${result.focusRoll}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Focus type chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: focusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEventFocusIcon(result.focus),
                  size: 14,
                  color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  result.focus,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Description / Guidance
      if (description.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.sepia.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.sepia.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: JuiceTheme.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: JuiceTheme.parchment,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      
      // Extended guidance for specific focuses (deeper context from Juice instructions)
      if (random_event_data.eventFocusExtendedGuidance.containsKey(result.focus)) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: JuiceTheme.mystic.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: JuiceTheme.mystic.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: JuiceTheme.mystic.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  random_event_data.eventFocusExtendedGuidance[result.focus]!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: JuiceTheme.parchmentDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      
      // Suggested follow-up actions
      if (actions.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          'Suggested Follow-up:',
          style: theme.textTheme.labelSmall?.copyWith(
            color: JuiceTheme.parchmentDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: actions.map((action) => _buildActionChip(action, theme)).toList(),
        ),
      ],
    ],
  );
}

/// Get appropriate icon for each event focus type.
IconData _getEventFocusIcon(String focus) {
  switch (focus) {
    case 'Advance Time':
      return Icons.schedule;
    case 'Close Thread':
      return Icons.cancel_outlined;
    case 'Converge Thread':
      return Icons.merge;
    case 'Diverge Thread':
      return Icons.call_split;
    case 'Immersion':
      return Icons.self_improvement;
    case 'Keyed Event':
      return Icons.vpn_key;
    case 'New Character':
      return Icons.person_add;
    case 'NPC Action':
      return Icons.directions_run;
    case 'Plot Armor':
      return Icons.shield;
    case 'Remote Event':
      return Icons.public;
    default:
      return Icons.flash_on;
  }
}

/// Build a compact action chip for suggested follow-ups.
Widget _buildActionChip(random_event_data.EventFocusAction action, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: JuiceTheme.mystic.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: JuiceTheme.mystic.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          action.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: JuiceTheme.mystic,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '• ${action.hint}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: JuiceTheme.parchmentDark,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
// IDEA DISPLAY
// =============================================================================

/// Display for Modifier + Idea results.
/// In "Simple Mode", this replaces the Random Event Focus table.
/// Reference: Juice instructions - Pro Tip about Simple Mode.
Widget buildIdeaDisplay(IdeaResult result, ThemeData theme) {
  final categoryDescription = random_event_data.ideaCategoryDescriptions[result.ideaCategory] ?? '';
  final categoryRange = random_event_data.ideaCategoryRanges[result.ideaCategory] ?? '';
  
  // Color coding by category
  Color categoryColor;
  IconData categoryIcon;
  switch (result.ideaCategory) {
    case 'Idea':
      categoryColor = JuiceTheme.mystic;
      categoryIcon = Icons.lightbulb_outline;
    case 'Event':
      categoryColor = JuiceTheme.danger;
      categoryIcon = Icons.flash_on;
    case 'Person':
      categoryColor = JuiceTheme.info;
      categoryIcon = Icons.person;
    case 'Object':
      categoryColor = JuiceTheme.success;
      categoryIcon = Icons.category;
    default:
      categoryColor = JuiceTheme.gold;
      categoryIcon = Icons.auto_awesome;
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Dice rolls with category context
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: JuiceTheme.juiceOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '2d10: ${result.modifierRoll}, ${result.ideaRoll}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: JuiceTheme.juiceOrange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: categoryColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoryIcon, size: 12, color: categoryColor),
                const SizedBox(width: 4),
                Text(
                  result.ideaCategory,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  categoryRange,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: categoryColor.withOpacity(0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      
      // The main phrase - prominently displayed
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: JuiceTheme.juiceOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16, color: JuiceTheme.juiceOrange),
            const SizedBox(width: 8),
            Text(
              '${result.modifier} ${result.idea}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: JuiceTheme.parchment,
              ),
            ),
          ],
        ),
      ),
      
      // Category guidance
      if (categoryDescription.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              categoryIcon,
              size: 14,
              color: categoryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                categoryDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.parchmentDark,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
      
      // Simple Mode tip
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: JuiceTheme.gold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: JuiceTheme.gold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.tips_and_updates, size: 12, color: JuiceTheme.gold),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Simple Mode: Use this in place of the Random Event Focus table.',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// =============================================================================
// SINGLE TABLE DISPLAY
// =============================================================================

/// Display for individual table rolls (Modifier, Idea, Event, Person, Object).
/// These are the building blocks of Random Events and Meaning tables.
Widget buildSingleTableDisplay(SingleTableResult result, ThemeData theme) {
  // Get appropriate icon and color based on table name
  final (IconData icon, Color color) = _getTableStyle(result.tableName);
  
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Icon for the table type
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
      const SizedBox(width: 10),
      // Roll display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '1d10: ${result.roll}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ),
      const SizedBox(width: 10),
      // Result word - prominent display
      Expanded(
        child: Text(
          result.result,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ],
  );
}

/// Get icon and color for each table type.
(IconData, Color) _getTableStyle(String tableName) {
  switch (tableName.toLowerCase()) {
    case 'modifier':
      return (Icons.change_circle_outlined, JuiceTheme.juiceOrange);
    case 'idea':
      return (Icons.lightbulb_outline, JuiceTheme.gold);
    case 'event':
      return (Icons.flash_on, JuiceTheme.rust);
    case 'person':
      return (Icons.person_outline, JuiceTheme.mystic);
    case 'object':
      return (Icons.category_outlined, JuiceTheme.success);
    default:
      return (Icons.casino, JuiceTheme.parchmentDark);
  }
}

// =============================================================================
// DISCOVER MEANING DISPLAY
// =============================================================================

Widget buildDiscoverMeaningDisplay(DiscoverMeaningResult result, ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: JuiceTheme.juiceOrange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.3)),
        ),
        child: Text(
          '2d20: ${result.adjectiveRoll}, ${result.nounRoll}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: JuiceTheme.juiceOrange,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: JuiceTheme.mystic.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
            ),
            child: Text(
              result.adjective,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: JuiceTheme.mystic,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: JuiceTheme.gold.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border(
                top: BorderSide(color: JuiceTheme.gold.withValues(alpha: 0.5)),
                bottom: BorderSide(color: JuiceTheme.gold.withValues(alpha: 0.5)),
                right: BorderSide(color: JuiceTheme.gold.withValues(alpha: 0.5)),
              ),
            ),
            child: Text(
              result.noun,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: JuiceTheme.gold,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

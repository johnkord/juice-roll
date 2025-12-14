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
import '../../../data/fate_check_intensity_examples.dart';

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
  final isContextual = result.outcome.isContextual;
  
  // Determine colors based on outcome type
  // Contextual results (Favorable/Unfavorable) use neutral colors
  // since the Yes/No depends on context, not the dice
  Color outcomeColor;
  Color outcomeBgColor;
  if (isContextual) {
    // Use gold for contextual results - indicates "you decide based on context"
    outcomeColor = JuiceTheme.gold;
    outcomeBgColor = JuiceTheme.gold.withValues(alpha: 0.2);
  } else if (isPositive) {
    outcomeColor = JuiceTheme.success;
    outcomeBgColor = JuiceTheme.success.withValues(alpha: 0.2);
  } else {
    outcomeColor = JuiceTheme.danger;
    outcomeBgColor = JuiceTheme.danger.withValues(alpha: 0.2);
  }

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
          // Outcome chip - hide for Invalid Assumption since that IS the answer
          if (result.specialTrigger != SpecialTrigger.invalidAssumption)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: outcomeBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outcomeColor),
              ),
              child: Text(
                result.outcome.displayText,
                style: TextStyle(
                  color: outcomeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      // Contextual guidance for Favorable/Unfavorable results
      if (isContextual) ...[
        const SizedBox(height: 8),
        _buildContextualGuidanceWidget(result.outcome, theme),
      ],
      // Guidance for "Because" results - use Intensity to craft reason
      if (result.outcome.isBecause) ...[
        const SizedBox(height: 8),
        _buildBecauseGuidanceWidget(result.outcome, result.intensity, result.intensityDescription, theme),
      ],
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
      // Invalid Assumption guidance
      if (result.specialTrigger == SpecialTrigger.invalidAssumption) ...[
        const SizedBox(height: 8),
        _buildInvalidAssumptionGuidanceWidget(result.specialTrigger!, theme),
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

/// Builds a contextual guidance widget for Favorable/Unfavorable outcomes.
/// 
/// These outcomes are unique in Juice because they don't provide a direct Yes/No
/// answer. Instead, the player must determine what answer would most help or hurt
/// their character in the current situation.
Widget _buildContextualGuidanceWidget(FateCheckOutcome outcome, ThemeData theme) {
  final isFavorable = outcome == FateCheckOutcome.favorable;
  final guidance = outcome.contextualGuidance;
  final examples = outcome.exampleInterpretations;
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: JuiceTheme.gold.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Row(
          children: [
            Icon(
              isFavorable ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
              size: 16,
              color: JuiceTheme.gold,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isFavorable 
                    ? 'What helps your character?' 
                    : 'What hurts your character?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Guidance text
        if (guidance != null) ...[
          const SizedBox(height: 6),
          Text(
            guidance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        // Example interpretations
        if (examples != null && examples.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examples:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $example',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.parchment.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// Builds a guidance widget for Invalid Assumption results.
/// 
/// Invalid Assumption is unique because it means the question itself was based
/// on a false premise. The player must re-examine what they thought was true.
Widget _buildInvalidAssumptionGuidanceWidget(SpecialTrigger trigger, ThemeData theme) {
  final guidance = trigger.contextualGuidance;
  final examples = trigger.exampleInterpretations;
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: JuiceTheme.mystic.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Row(
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 16,
              color: JuiceTheme.mystic,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'What assumption was wrong?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.mystic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Guidance text
        if (guidance != null) ...[
          const SizedBox(height: 6),
          Text(
            guidance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        // Example interpretations
        if (examples != null && examples.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examples:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $example',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.parchment.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// Builds a guidance widget for "Because" results (Yes, because... / No, because...).
/// 
/// These outcomes require the player to use the Intensity roll to craft a reason
/// WHY the answer is Yes or No. Higher intensity = more significant reason.
Widget _buildBecauseGuidanceWidget(FateCheckOutcome outcome, int intensity, String intensityDescription, ThemeData theme) {
  final isYes = outcome == FateCheckOutcome.yesBecause;
  final guidance = outcome.contextualGuidance;
  final examples = outcome.exampleInterpretations;
  
  // Color based on Yes/No
  final color = isYes ? JuiceTheme.success : JuiceTheme.danger;

  // Get compact example for this intensity
  final example = fateCheckIntensityExamples[intensity] ?? '';
  final prompt = fateCheckIntensityPrompts[intensity] ?? '';

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon - emphasize Intensity
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Why? Intensity: $intensityDescription ($intensity)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Compact example for this intensity
        if (example.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            example,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchmentDark,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
        ],
        // Compact narrative prompt for this intensity
        if (prompt.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            prompt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
        // Intensity scale visualization
        const SizedBox(height: 6),
        _buildIntensityScale(intensity, color, theme),
      ],
    ),
  );
}

/// Builds a visual intensity scale showing where the rolled value falls.
Widget _buildIntensityScale(int intensity, Color activeColor, ThemeData theme) {
  return Row(
    children: [
      Text(
        'Minor',
        style: theme.textTheme.labelSmall?.copyWith(
          color: JuiceTheme.parchmentDark,
          fontSize: 10,
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            final value = index + 1;
            final isActive = value == intensity;
            final isPast = value < intensity;
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive 
                    ? activeColor 
                    : isPast 
                        ? activeColor.withValues(alpha: 0.3)
                        : JuiceTheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isActive ? activeColor : JuiceTheme.parchmentDark.withValues(alpha: 0.3),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive 
                        ? JuiceTheme.surface 
                        : JuiceTheme.parchmentDark,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        'Major',
        style: theme.textTheme.labelSmall?.copyWith(
          color: JuiceTheme.parchmentDark,
          fontSize: 10,
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
      result.outcome == ExpectationOutcome.expectedIntensified;
  final isContextual = result.outcome.isContextual;
  
  // Determine colors based on outcome type
  // Contextual results (Favorable/Unfavorable) use neutral colors
  Color outcomeColor;
  Color outcomeBgColor;
  if (isContextual) {
    outcomeColor = JuiceTheme.gold;
    outcomeBgColor = JuiceTheme.gold.withValues(alpha: 0.2);
  } else if (isPositive) {
    outcomeColor = JuiceTheme.success;
    outcomeBgColor = JuiceTheme.success.withValues(alpha: 0.2);
  } else {
    outcomeColor = JuiceTheme.danger;
    outcomeBgColor = JuiceTheme.danger.withValues(alpha: 0.2);
  }

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
              color: outcomeBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: outcomeColor),
            ),
            child: Text(
              result.outcome.displayText,
              style: TextStyle(
                color: outcomeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      // Contextual guidance for Favorable/Unfavorable
      if (isContextual) ...[
        const SizedBox(height: 8),
        _buildExpectationContextualGuidance(result.outcome, theme),
      ],
      // Show guidance and auto-rolled meaning for Modified Idea outcome
      if (result.outcome.isModifiedIdea && result.hasMeaning && result.meaningResult != null) ...[
        const SizedBox(height: 8),
        _buildModifiedIdeaGuidanceWidget(result.outcome, result.meaningResult!, theme),
      ],
    ],
  );
}

/// Builds contextual guidance for Expectation Check Favorable/Unfavorable.
/// 
/// Unlike Fate Check, these modify your expectation rather than answering
/// a yes/no question. The player still needs to determine how their
/// expectation is twisted to help or hurt them.
Widget _buildExpectationContextualGuidance(ExpectationOutcome outcome, ThemeData theme) {
  final isFavorable = outcome == ExpectationOutcome.favorable;
  final guidance = outcome.contextualGuidance;
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: JuiceTheme.gold.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isFavorable ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
              size: 16,
              color: JuiceTheme.gold,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isFavorable 
                    ? 'Expectation twisted in your favor' 
                    : 'Expectation twisted against you',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (guidance != null) ...[
          const SizedBox(height: 6),
          Text(
            guidance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Builds a guidance widget for "Modified Idea" results in Expectation Check.
/// 
/// This is triggered by double blanks (00) and provides a Modifier + Idea pair
/// that the player uses to creatively alter their expectation in an unexpected way.
Widget _buildModifiedIdeaGuidanceWidget(ExpectationOutcome outcome, DiscoverMeaningResult meaningResult, ThemeData theme) {
  final guidance = outcome.contextualGuidance;
  final prompts = outcome.modifiedIdeaPrompts;
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: JuiceTheme.juiceOrange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Row(
          children: [
            Icon(
              Icons.shuffle,
              size: 16,
              color: JuiceTheme.juiceOrange,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Use this to twist your expectation:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.juiceOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // The Modifier + Idea words - prominently displayed with labels
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: JuiceTheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modifier column
              Column(
                children: [
                  Text(
                    'Modifier',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: JuiceTheme.parchmentDark,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    meaningResult.adjective,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.mystic,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Idea column
              Column(
                children: [
                  Text(
                    'Idea',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: JuiceTheme.parchmentDark,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    meaningResult.noun,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Guidance text
        if (guidance != null) ...[
          const SizedBox(height: 8),
          Text(
            guidance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        // Interpretation prompts
        if (prompts != null && prompts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask yourself:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...prompts.map((prompt) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $prompt',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.parchment.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

// =============================================================================
// ALTER SCENE GUIDANCE WIDGET
// =============================================================================

/// Builds a guidance widget for Alter (Add/Remove Focus) scene results.
/// Explains how to interpret "Add" vs "Remove" with examples.
Widget _buildAlterSceneGuidanceWidget(SceneType sceneType, String focus, ThemeData theme) {
  final guidance = sceneType.alterGuidance;
  final examples = sceneType.alterExamples;
  final isAdd = sceneType == SceneType.alterAdd;
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: JuiceTheme.gold.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and action verb
        Row(
          children: [
            Icon(
              isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 16,
              color: JuiceTheme.gold,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                isAdd ? 'Add "$focus" to the scene' : 'Remove "$focus" from the scene',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Guidance text
        if (guidance != null) ...[
          const SizedBox(height: 6),
          Text(
            guidance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        // Examples section
        if (examples != null && examples.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examples:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...examples.take(2).map((example) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: JuiceTheme.parchment.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: '${example.$1}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: example.$2),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    ),
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
      // Math breakdown showing how dice combine
      const SizedBox(height: 8),
      _buildScaleMathBreakdown(result, color, theme),
      // Guidance with examples
      const SizedBox(height: 8),
      _buildScaleGuidanceWidget(result, color, theme),
    ],
  );
}

/// Builds a widget showing the math breakdown for Scale.
/// Shows: "(+1) + (+1) + 3 = 5 → +10%"
Widget _buildScaleMathBreakdown(ScaleResult result, Color color, ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: JuiceTheme.surface.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: JuiceTheme.parchmentDark.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calculate_outlined,
          size: 14,
          color: JuiceTheme.parchmentDark,
        ),
        const SizedBox(width: 6),
        Text(
          result.mathBreakdown,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            color: JuiceTheme.parchmentDark,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          result.modifier,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

/// Builds guidance widget for Scale results with examples.
Widget _buildScaleGuidanceWidget(ScaleResult result, Color color, ThemeData theme) {
  final examples = result.exampleUseCases;
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with guidance
        Row(
          children: [
            Icon(
              result.isNoChange
                  ? Icons.balance
                  : (result.isIncrease ? Icons.trending_up : Icons.trending_down),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                result.contextualGuidance,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        // Examples
        if (examples.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examples:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $example',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.parchment.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    ),
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
        // Add guidance for Alter scene types
        if (sceneResult.sceneType.isAlter) ...[
          const SizedBox(height: 8),
          _buildAlterSceneGuidanceWidget(sceneResult.sceneType, result.focusResult!.focus, theme),
        ],
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
  // Special styling for Plot Armor - it's a gift!
  final isPlotArmor = result.focus == 'Plot Armor';
  final focusColor = isPlotArmor ? JuiceTheme.success : Colors.amber;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Compact dice roll display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: focusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '3d10: ${result.focusRoll}, ${result.modifierRoll}, ${result.ideaRoll}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: JuiceTheme.fontFamilyMono,
            fontWeight: FontWeight.bold,
            color: focusColor,
            fontSize: 10,
          ),
        ),
      ),
      const SizedBox(height: 6),
      
      // Focus type chip with icon
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: focusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: focusColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getEventFocusIcon(result.focus),
              size: 14,
              color: focusColor,
            ),
            const SizedBox(width: 6),
            Text(
              result.focus,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade800,
              ),
            ),
            if (isPlotArmor) ...[
              const SizedBox(width: 4),
              Icon(Icons.auto_awesome, size: 12, color: JuiceTheme.success),
            ],
          ],
        ),
      ),
      // One-line focus description (muted, italic)
      if (random_event_data.eventFocusDescriptions[result.focus]?.isNotEmpty ?? false) ...[
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
          child: Text(
            random_event_data.eventFocusDescriptions[result.focus]!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchmentDark70,
              fontStyle: FontStyle.italic,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
      ],
      const SizedBox(height: 6),
      
      // Modifier + Idea phrase (the "meaning" component)
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
            Icon(Icons.auto_awesome, size: 12, color: JuiceTheme.juiceOrange),
            const SizedBox(width: 6),
            Text(
              '${result.modifier} ${result.idea}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: JuiceTheme.parchment,
              ),
            ),
          ],
        ),
      ),
      
      // Compact prompt question
      if (random_event_data.eventFocusPrompts.containsKey(result.focus)) ...[
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline, size: 12, color: focusColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                random_event_data.eventFocusPrompts[result.focus]!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: focusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
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
// RANDOM EVENT FOCUS DISPLAY
// =============================================================================

/// Compact display for Random Event Focus (focus-only roll).
/// Shows: dice roll, focus chip with icon, prompt question.
Widget buildRandomEventFocusDisplay(RandomEventFocusResult result, ThemeData theme) {
  final isPlotArmor = result.focus == 'Plot Armor';
  final focusColor = isPlotArmor ? JuiceTheme.success : Colors.amber;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Compact row: dice + focus chip
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'd10: ${result.focusRoll}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Focus chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: focusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEventFocusIcon(result.focus),
                  size: 12,
                  color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  result.focus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // One-line focus description (muted, italic)
      if (random_event_data.eventFocusDescriptions[result.focus]?.isNotEmpty ?? false) ...[
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
          child: Text(
            random_event_data.eventFocusDescriptions[result.focus]!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchmentDark70,
              fontStyle: FontStyle.italic,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
      ],
      // Prompt question
      if (random_event_data.eventFocusPrompts.containsKey(result.focus)) ...[
        const SizedBox(height: 6),
        Text(
          random_event_data.eventFocusPrompts[result.focus]!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isPlotArmor ? JuiceTheme.success : Colors.amber.shade700,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
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
              color: JuiceTheme.juiceOrange10,
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
          color: JuiceTheme.juiceOrange10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: JuiceTheme.juiceOrange30),
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
          color: JuiceTheme.gold08,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: JuiceTheme.gold20),
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

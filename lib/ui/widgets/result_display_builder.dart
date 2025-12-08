/// Result Display Builder - Type-specific display widgets for roll results.
///
/// This file provides centralized display widgets for each result type,
/// replacing the ~6000 lines of legacy display methods in roll_history.dart.
///
/// Each method produces exactly the same visual output as the legacy methods,
/// ensuring visual parity during the migration.
library;

import 'package:flutter/material.dart';
import '../../core/fate_dice_formatter.dart';
import '../../models/roll_result.dart';
import '../../presets/fate_check.dart';
import '../../presets/next_scene.dart';
import '../../presets/random_event.dart';
import '../../presets/discover_meaning.dart';
import '../../presets/npc_action.dart';
import '../../presets/pay_the_price.dart';
import '../../presets/quest.dart';
import '../../presets/interrupt_plot_point.dart';
import '../../presets/settlement.dart';
import '../../presets/object_treasure.dart';
import '../../presets/challenge.dart';
import '../../presets/details.dart';
import '../../presets/immersion.dart';
import '../../presets/dialog_generator.dart';
import '../../presets/wilderness.dart';
import '../../presets/location.dart';
import '../../presets/expectation_check.dart';
import '../../presets/scale.dart';
import '../../presets/monster_encounter.dart';
import '../../presets/abstract_icons.dart';
import '../../presets/dungeon_generator.dart';
import '../../presets/extended_npc_conversation.dart';
import '../../presets/name_generator.dart';
import '../../models/results/ironsworn_result.dart';
import '../theme/juice_theme.dart';

/// Centralized result display builder.
///
/// Call [buildDisplay] with any RollResult to get the appropriate widget.
/// This replaces the massive if/else chain in roll_history.dart.
class ResultDisplayBuilder {
  final ThemeData theme;

  const ResultDisplayBuilder(this.theme);

  /// Build the display widget for any result type.
  Widget buildDisplay(RollResult result) {
    // Dispatch to type-specific builders
    if (result is FateCheckResult) {
      return _buildFateCheckDisplay(result);
    } else if (result is ExpectationCheckResult) {
      return _buildExpectationCheckDisplay(result);
    } else if (result is ScaleResult) {
      return _buildScaleDisplay(result);
    } else if (result is NextSceneWithFollowUpResult) {
      return _buildNextSceneWithFollowUpDisplay(result);
    } else if (result is NextSceneResult) {
      return _buildNextSceneDisplay(result);
    } else if (result is RandomEventResult) {
      return _buildRandomEventDisplay(result);
    } else if (result is RandomEventFocusResult) {
      return _buildRandomEventFocusDisplay(result);
    } else if (result is IdeaResult) {
      return _buildIdeaDisplay(result);
    } else if (result is DiscoverMeaningResult) {
      return _buildDiscoverMeaningDisplay(result);
    } else if (result is MotiveWithFollowUpResult) {
      return _buildMotiveWithFollowUpDisplay(result);
    } else if (result is NpcActionResult) {
      return _buildNpcActionDisplay(result);
    } else if (result is NpcProfileResult) {
      return _buildNpcProfileDisplay(result);
    } else if (result is ComplexNpcResult) {
      return _buildComplexNpcDisplay(result);
    } else if (result is PayThePriceResult) {
      return _buildPayThePriceDisplay(result);
    } else if (result is QuestResult) {
      return _buildQuestDisplay(result);
    } else if (result is InterruptPlotPointResult) {
      return _buildInterruptDisplay(result);
    } else if (result is SettlementNameResult) {
      return _buildSettlementNameDisplay(result);
    } else if (result is EstablishmentNameResult) {
      return _buildEstablishmentNameDisplay(result);
    } else if (result is SettlementPropertiesResult) {
      return _buildSettlementPropertiesDisplay(result);
    } else if (result is SimpleNpcResult) {
      return _buildSimpleNpcDisplay(result);
    } else if (result is CompleteSettlementResult) {
      return _buildCompleteSettlementDisplay(result);
    } else if (result is FullSettlementResult) {
      return _buildFullSettlementDisplay(result);
    } else if (result is ItemCreationResult) {
      return _buildItemCreationDisplay(result);
    } else if (result is ObjectTreasureResult) {
      return _buildObjectTreasureDisplay(result);
    } else if (result is FullChallengeResult) {
      return _buildFullChallengeDisplay(result);
    } else if (result is ChallengeSkillResult) {
      return _buildChallengeSkillDisplay(result);
    } else if (result is DcResult) {
      return _buildDcDisplay(result);
    } else if (result is QuickDcResult) {
      return _buildQuickDcDisplay(result);
    } else if (result is SensoryDetailResult) {
      return _buildSensoryDetailDisplay(result);
    } else if (result is EmotionalAtmosphereResult) {
      return _buildEmotionalAtmosphereDisplay(result);
    } else if (result is FullImmersionResult) {
      return _buildFullImmersionDisplay(result);
    } else if (result is DualPropertyResult) {
      return _buildDualPropertyResultDisplay(result);
    } else if (result is PropertyResult) {
      return _buildPropertyResultDisplay(result);
    } else if (result is DetailWithFollowUpResult) {
      return _buildDetailWithFollowUpDisplay(result);
    } else if (result is DetailResult) {
      return _buildDetailResultDisplay(result);
    } else if (result is FateRollResult) {
      return _buildFateRollDisplay(result);
    } else if (result is DialogResult) {
      return _buildDialogDisplay(result);
    } else if (result is WildernessAreaResult) {
      return _buildWildernessAreaDisplay(result);
    } else if (result is WildernessEncounterResult) {
      return _buildWildernessEncounterDisplay(result);
    } else if (result is WildernessWeatherResult) {
      return _buildWildernessWeatherDisplay(result);
    } else if (result is FullMonsterEncounterResult) {
      return _buildFullMonsterEncounterDisplay(result);
    } else if (result is MonsterEncounterResult) {
      return _buildMonsterEncounterDisplay(result);
    } else if (result is MonsterTracksResult) {
      return _buildMonsterTracksDisplay(result);
    } else if (result is LocationResult) {
      return _buildLocationDisplay(result);
    } else if (result is AbstractIconResult) {
      return _buildAbstractIconDisplay(result);
    } else if (result is DungeonEncounterResult) {
      return _buildDungeonEncounterDisplay(result);
    } else if (result is DungeonNameResult) {
      return _buildDungeonNameDisplay(result);
    } else if (result is DungeonAreaResult) {
      return _buildDungeonAreaDisplay(result);
    } else if (result is FullDungeonAreaResult) {
      return _buildFullDungeonAreaDisplay(result);
    } else if (result is TwoPassAreaResult) {
      return _buildTwoPassAreaDisplay(result);
    } else if (result is DungeonMonsterResult) {
      return _buildDungeonMonsterDisplay(result);
    } else if (result is DungeonTrapResult) {
      return _buildDungeonTrapDisplay(result);
    } else if (result is TrapProcedureResult) {
      return _buildTrapProcedureDisplay(result);
    } else if (result is DungeonDetailResult) {
      return _buildDungeonDetailDisplay(result);
    } else if (result is InformationResult) {
      return _buildInformationDisplay(result);
    } else if (result is CompanionResponseResult) {
      return _buildCompanionResponseDisplay(result);
    } else if (result is DialogTopicResult) {
      return _buildDialogTopicDisplay(result);
    } else if (result is NameResult) {
      return _buildNameResultDisplay(result);
    } else if (result is IronswornActionResult) {
      return _buildIronswornActionDisplay(result);
    } else if (result is IronswornProgressResult) {
      return _buildIronswornProgressDisplay(result);
    } else if (result is IronswornOracleResult) {
      return _buildIronswornOracleDisplay(result);
    } else if (result is IronswornYesNoResult) {
      return _buildIronswornYesNoDisplay(result);
    } else if (result is IronswornCursedOracleResult) {
      return _buildIronswornCursedOracleDisplay(result);
    } else if (result is IronswornMomentumBurnResult) {
      return _buildIronswornMomentumBurnDisplay(result);
    }

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
  // FATE CHECK & ORACLE DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFateCheckDisplay(FateCheckResult result) {
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
                color: JuiceTheme.mystic.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
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
                    ? JuiceTheme.success.withOpacity(0.2)
                    : JuiceTheme.danger.withOpacity(0.2),
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
                  ? JuiceTheme.gold.withOpacity(0.2)
                  : JuiceTheme.mystic.withOpacity(0.2),
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
              color: JuiceTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JuiceTheme.gold.withOpacity(0.4)),
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

  Widget _buildExpectationCheckDisplay(ExpectationCheckResult result) {
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
                    ? JuiceTheme.success.withOpacity(0.2)
                    : JuiceTheme.danger.withOpacity(0.2),
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
              color: JuiceTheme.mystic.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
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

  Widget _buildScaleDisplay(ScaleResult result) {
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
                color: JuiceTheme.mystic.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
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
                color: color.withOpacity(0.2),
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

  Widget _buildNextSceneDisplay(NextSceneResult result) {
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
              backgroundColor: chipColor.withOpacity(0.2),
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

  Widget _buildNextSceneWithFollowUpDisplay(NextSceneWithFollowUpResult result) {
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
              backgroundColor: chipColor.withOpacity(0.2),
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
                  color: JuiceTheme.ink.withOpacity(0.3),
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
                backgroundColor: JuiceTheme.categoryExplore.withOpacity(0.2),
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
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '2d10: [${result.ideaResult!.modifierRoll}, ${result.ideaResult!.ideaRoll}]',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
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
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '2d10: [${result.plotPointResult!.categoryRoll}, ${result.plotPointResult!.eventRoll}]',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Chip(
                label: Text(result.plotPointResult!.category),
                backgroundColor: Colors.purple.withOpacity(0.2),
                side: const BorderSide(color: Colors.purple),
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

  Widget _buildRandomEventDisplay(RandomEventResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '3d10: ${result.focusRoll}, ${result.modifierRoll}, ${result.ideaRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Chip(
          label: Text(result.focus),
          backgroundColor: Colors.amber.withOpacity(0.2),
          side: const BorderSide(color: Colors.amber),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        Text(
          '${result.modifier} ${result.idea}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildRandomEventFocusDisplay(RandomEventFocusResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1d10: ${result.focusRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(result.focus),
          backgroundColor: Colors.amber.withOpacity(0.2),
          side: const BorderSide(color: Colors.amber),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildIdeaDisplay(IdeaResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d10: ${result.modifierRoll}, ${result.ideaRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${result.modifier} ${result.idea}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverMeaningDisplay(DiscoverMeaningResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.juiceOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.3)),
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
                color: JuiceTheme.mystic.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
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
                color: JuiceTheme.gold.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  top: BorderSide(color: JuiceTheme.gold.withOpacity(0.5)),
                  bottom: BorderSide(color: JuiceTheme.gold.withOpacity(0.5)),
                  right: BorderSide(color: JuiceTheme.gold.withOpacity(0.5)),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // NPC & CHARACTER DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMotiveWithFollowUpDisplay(MotiveWithFollowUpResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1d10: ${result.roll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              label: const Text('Motive'),
              backgroundColor: Colors.teal.withOpacity(0.2),
              side: const BorderSide(color: Colors.teal),
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
                      color: Colors.deepPurple[300],
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

  Widget _buildNpcActionDisplay(NpcActionResult result) {
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
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            diceNotation,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              label: Text(result.column.displayText),
              backgroundColor: Colors.teal.withOpacity(0.2),
              side: const BorderSide(color: Colors.teal),
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

  Widget _buildNpcDiceBadge(
    String label,
    List<int>? dice,
    Color color, {
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

  Widget _buildLabeledRow(String label, String value) {
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

  Widget _buildNpcProfileDisplay(NpcProfileResult result) {
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
            ),
            _buildNpcDiceBadge(
              'Need$needSkewLabel',
              result.needAllRolls ?? [result.needRoll],
              JuiceTheme.mystic,
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
            ),
            _buildNpcDiceBadge(
              'Col',
              [result.color.roll],
              JuiceTheme.juiceOrange,
            ),
            _buildNpcDiceBadge(
              'Prop',
              null,
              JuiceTheme.rust,
              propFormat:
                  '${result.property1.propertyRoll}+${result.property1.intensityRoll}, ${result.property2.propertyRoll}+${result.property2.intensityRoll}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildLabeledRow('Personality', result.personalityDisplay),
        const SizedBox(height: 4),
        _buildLabeledRow('Need', result.need),
        const SizedBox(height: 4),
        _buildLabeledRow('Motive', result.motiveDisplay),
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
        ),
      ],
    );
  }

  Widget _buildComplexNpcDisplay(ComplexNpcResult result) {
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
                  ? [result.primaryPersonalityRoll, result.secondaryPersonalityRoll!]
                  : [result.primaryPersonalityRoll],
              charColor,
            ),
            _buildNpcDiceBadge(
              'Need$needSkewLabel',
              result.needAllRolls,
              JuiceTheme.mystic,
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
            ),
            _buildNpcDiceBadge(
              'Col',
              [result.color.roll],
              JuiceTheme.juiceOrange,
            ),
            _buildNpcDiceBadge(
              'Prop',
              null,
              JuiceTheme.rust,
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
        _buildLabeledRow('Personality', result.personalityDisplay),
        const SizedBox(height: 4),
        _buildLabeledRow('Need', result.need),
        const SizedBox(height: 4),
        _buildLabeledRow('Motive', result.motiveDisplay),
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
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STUB METHODS - TO BE IMPLEMENTED
  // These forward to a default display until fully implemented
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPayThePriceDisplay(PayThePriceResult result) {
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
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.sepia.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '1d10: ${result.roll}',
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
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
              Icon(
                result.isMajorTwist
                    ? Icons.error_outline
                    : Icons.report_problem_outlined,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.result,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: JuiceTheme.parchment,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestDisplay(QuestResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quest sentence with styled formatting
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.rust.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.rust.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quest label
              Row(
                children: [
                  Icon(Icons.auto_stories, size: 14, color: JuiceTheme.rust),
                  const SizedBox(width: 6),
                  Text(
                    'Quest Hook',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.rust,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Main quest sentence
              Text(
                result.questSentence,
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilySerif,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.parchment,
                  height: 1.3,
                ),
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
            _buildQuestComponentChip(
              roll: result.objectiveRoll,
              subRoll: null,
              label: result.objective,
              category: 'Objective',
              color: JuiceTheme.info,
            ),
            _buildQuestComponentChip(
              roll: result.descriptionRoll,
              subRoll: result.descriptionSubRoll,
              label: result.descriptionExpanded ?? result.description,
              category: result.descriptionExpanded != null ? result.description : null,
              color: JuiceTheme.success,
            ),
            _buildQuestComponentChip(
              roll: result.focusRoll,
              subRoll: result.focusSubRoll,
              label: result.focusExpanded ?? result.focus,
              category: result.focusExpanded != null ? result.focus : null,
              color: JuiceTheme.gold,
            ),
            _buildQuestComponentChip(
              roll: result.prepositionRoll,
              subRoll: null,
              label: result.preposition,
              category: null,
              color: JuiceTheme.mystic,
            ),
            _buildQuestComponentChip(
              roll: result.locationRoll,
              subRoll: result.locationSubRoll,
              label: result.locationExpanded ?? result.location,
              category: result.locationExpanded != null ? result.location : null,
              color: JuiceTheme.rust,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestComponentChip({
    required int roll,
    required int? subRoll,
    required String label,
    required String? category,
    required Color color,
  }) {
    final rollText = subRoll != null ? '$roll→$subRoll' : '$roll';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Roll number(s)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              rollText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Label with optional category
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: JuiceTheme.parchment,
                ),
              ),
              if (category != null)
                Text(
                  '($category)',
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterruptDisplay(InterruptPlotPointResult result) {
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
                  Text(
                    'd10: ${result.categoryRoll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
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
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'd10: ${result.eventRoll}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.event,
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: JuiceTheme.parchment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // ═══════════════════════════════════════════════════════════════════════════
  // SETTLEMENT DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSettlementNameDisplay(SettlementNameResult result) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d10: [${result.prefixRoll}, ${result.suffixRoll}]',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${result.prefix} + ${result.suffix}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstablishmentNameDisplay(EstablishmentNameResult result) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d10: [${result.colorRoll}, ${result.objectRoll}]',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${result.colorEmoji} ${result.name}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementPropertiesDisplay(SettlementPropertiesResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'd10+d6: [${result.property1.propertyRoll}+${result.property1.intensityRoll}], [${result.property2.propertyRoll}+${result.property2.intensityRoll}]',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(
              label: Text('${result.property1.intensityDescription} ${result.property1.property}'),
              backgroundColor: Colors.teal.withOpacity(0.2),
              side: const BorderSide(color: Colors.teal),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const Text('+'),
            Chip(
              label: Text('${result.property2.intensityDescription} ${result.property2.property}'),
              backgroundColor: Colors.teal.withOpacity(0.2),
              side: const BorderSide(color: Colors.teal),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleNpcDisplay(SimpleNpcResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.categoryCharacter.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Name: ${result.name.rolls.length}d10, Profile: 3d10',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.categoryCharacter,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          result.name.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildCompleteSettlementDisplay(CompleteSettlementResult result) {
    final typeLabel = result.settlementType == SettlementType.village ? 'Village' : 'City';
    final typeColor = result.settlementType == SettlementType.village 
        ? Colors.brown 
        : Colors.blueGrey;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: typeColor),
              ),
              child: Text(
                typeLabel,
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.name.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Establishments (${result.establishments.countResult.count}):',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        ...result.establishments.establishments.map((est) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '• ${est.result}',
            style: theme.textTheme.bodySmall,
          ),
        )),
        const SizedBox(height: 4),
        Text(
          'News: ${result.news.result}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFullSettlementDisplay(FullSettlementResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.name.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Has: ${result.establishment.result}',
          style: theme.textTheme.bodySmall,
        ),
        Text(
          'News: ${result.news.result}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TREASURE & ITEM DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Color _getTreasureCategoryColor(String category) {
    switch (category) {
      case 'Trinket': return JuiceTheme.sepia;
      case 'Treasure': return JuiceTheme.gold;
      case 'Document': return JuiceTheme.parchmentDark;
      case 'Accessory': return JuiceTheme.mystic;
      case 'Weapon': return JuiceTheme.danger;
      case 'Armor': return JuiceTheme.info;
      default: return JuiceTheme.gold;
    }
  }

  IconData _getTreasureCategoryIcon(String category) {
    switch (category) {
      case 'Trinket': return Icons.auto_awesome;
      case 'Treasure': return Icons.paid;
      case 'Document': return Icons.description;
      case 'Accessory': return Icons.watch;
      case 'Weapon': return Icons.gpp_maybe;
      case 'Armor': return Icons.shield;
      default: return Icons.diamond;
    }
  }

  Widget _buildTreasurePropertyChip(String label, String value, int roll, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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

  Widget _buildItemCreationDisplay(ItemCreationResult result) {
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
            color: JuiceTheme.mystic.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.mystic.withOpacity(0.2)),
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
            decoration: BoxDecoration(color: JuiceTheme.juiceOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
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

  Widget _buildObjectTreasureDisplay(ObjectTreasureResult result) {
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CHALLENGE & DC DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFullChallengeDisplay(FullChallengeResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _buildChallengeOptionChip(result.physicalSkill, result.physicalDc, result.physicalRoll, JuiceTheme.danger),
          const SizedBox(width: 12),
          _buildChallengeOptionChip(result.mentalSkill, result.mentalDc, result.mentalRoll, JuiceTheme.info),
        ]),
        const SizedBox(height: 6),
        Text('(${result.dcMethod})', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  /// Builds a chip showing: "Skill DC X" with the roll indicator
  Widget _buildChallengeOptionChip(String skill, int dc, int roll, Color color) {
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
                color: JuiceTheme.gold.withOpacity(0.2),
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

  Widget _buildChallengeChip(String label, String skill, int roll, Color color) {
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

  Widget _buildChallengeSkillDisplay(ChallengeSkillResult result) {
    final color = result.challengeType == ChallengeType.physical ? JuiceTheme.danger : JuiceTheme.info;
    return _buildChallengeChip(result.challengeType.name, result.skill, result.roll, color);
  }

  Widget _buildDcDisplay(DcResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text(result.diceResults.join(", "), style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11, color: JuiceTheme.gold)),
      ),
      const SizedBox(width: 8),
      Text('DC ${result.dc}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
      const SizedBox(width: 8),
      Text('(${result.method})', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
    ]);
  }

  Widget _buildQuickDcDisplay(QuickDcResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text('2d6: [${result.dice.join(", ")}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11, color: JuiceTheme.gold)),
      ),
      const SizedBox(width: 8),
      Text('DC ${result.dc}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMMERSION DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get icon for sense type
  IconData _getSenseIcon(String sense) {
    switch (sense.toLowerCase()) {
      case 'see': return Icons.visibility;
      case 'hear': return Icons.hearing;
      case 'smell': return Icons.air;
      case 'feel': return Icons.touch_app;
      default: return Icons.sensors;
    }
  }

  /// Get color for sense type
  Color _getSenseColor(String sense) {
    switch (sense.toLowerCase()) {
      case 'see': return JuiceTheme.info;
      case 'hear': return JuiceTheme.mystic;
      case 'smell': return JuiceTheme.success;
      case 'feel': return JuiceTheme.gold;
      default: return JuiceTheme.rust;
    }
  }

  Widget _buildSensoryDetailDisplay(SensoryDetailResult result) {
    final senseColor = _getSenseColor(result.sense);
    final senseIcon = _getSenseIcon(result.sense);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice indicators row
        Row(
          children: [
            // Sense die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: senseColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(senseIcon, size: 12, color: senseColor),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: senseColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.senseRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Detail die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.rust.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'd10',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.rust,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.rust.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.detailRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Where die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place, size: 12, color: JuiceTheme.info),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.info.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.whereRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Skew indicator if present
            if (result.skew != SkewType.none) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (result.skew == SkewType.advantage
                      ? JuiceTheme.success
                      : JuiceTheme.danger).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (result.skew == SkewType.advantage
                        ? JuiceTheme.success
                        : JuiceTheme.danger).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.skew == SkewType.advantage
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 12,
                      color: result.skew == SkewType.advantage
                          ? JuiceTheme.success
                          : JuiceTheme.danger,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      result.skew == SkewType.advantage ? 'Closer' : 'Further',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: result.skew == SkewType.advantage
                            ? JuiceTheme.success
                            : JuiceTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Sensory result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                senseColor.withOpacity(0.15),
                senseColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: senseColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(senseIcon, size: 16, color: senseColor),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: senseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.sense.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: senseColor,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: JuiceTheme.sepia,
                    height: 1.3,
                  ),
                  children: [
                    const TextSpan(text: 'You '),
                    TextSpan(
                      text: result.sense.toLowerCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: senseColor),
                    ),
                    const TextSpan(text: ' something '),
                    TextSpan(
                      text: result.detail.toLowerCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.rust),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: result.where.toLowerCase(),
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalAtmosphereDisplay(EmotionalAtmosphereResult result) {
    final polarityColor = result.isPositive ? JuiceTheme.success : JuiceTheme.danger;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice indicators row
        Row(
          children: [
            // Emotion die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.mystic.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mood, size: 12, color: JuiceTheme.mystic),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.mystic.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.emotionRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Cause die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.rust.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'd10',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.rust,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.rust.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.causeRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Fate die indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: polarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: polarityColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1dF',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: polarityColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: polarityColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Text(
                        result.isPositive ? '+' : '−',
                        style: TextStyle(
                          fontFamily: JuiceTheme.fontFamilyMono,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.parchment,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Skew indicator if present
            if (result.skew != SkewType.none) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (result.skew == SkewType.advantage
                      ? JuiceTheme.success
                      : JuiceTheme.danger).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (result.skew == SkewType.advantage
                        ? JuiceTheme.success
                        : JuiceTheme.danger).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.skew == SkewType.advantage
                          ? Icons.sentiment_very_satisfied
                          : Icons.sentiment_very_dissatisfied,
                      size: 12,
                      color: result.skew == SkewType.advantage
                          ? JuiceTheme.success
                          : JuiceTheme.danger,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      result.skew == SkewType.advantage ? 'Positive' : 'Negative',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: result.skew == SkewType.advantage
                            ? JuiceTheme.success
                            : JuiceTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Emotion result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                polarityColor.withOpacity(0.15),
                polarityColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: polarityColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emotion polarity and name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: polarityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      result.isPositive ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
                      size: 16,
                      color: polarityColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.selectedEmotion,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: polarityColor,
                    ),
                  ),
                  const Spacer(),
                  // Show the pair
                  Text(
                    result.isPositive
                        ? '(vs ${result.negativeEmotion})'
                        : '(vs ${result.positiveEmotion})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.parchmentDark.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Cause
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: JuiceTheme.sepia,
                  ),
                  children: [
                    const TextSpan(text: 'because '),
                    TextSpan(
                      text: result.cause,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: JuiceTheme.rust,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullImmersionDisplay(FullImmersionResult result) {
    final senseColor = _getSenseColor(result.sensory.sense);
    final senseIcon = _getSenseIcon(result.sensory.sense);
    final polarityColor = result.emotional.isPositive ? JuiceTheme.success : JuiceTheme.danger;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact dice summary
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Sensory dice group
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: senseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(senseIcon, size: 11, color: senseColor),
                    const SizedBox(width: 3),
                    Text(
                      '${result.sensory.senseRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: senseColor,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      ' · ${result.sensory.detailRoll} · ${result.sensory.whereRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: JuiceTheme.parchmentDark,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Emotional dice group
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mood, size: 11, color: JuiceTheme.mystic),
                    const SizedBox(width: 3),
                    Text(
                      '${result.emotional.emotionRoll} · ${result.emotional.causeRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: JuiceTheme.parchmentDark,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Fate die
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: polarityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: polarityColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1dF',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: polarityColor,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      result.emotional.isPositive ? '+' : '−',
                      style: TextStyle(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: polarityColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Sensory result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                senseColor.withOpacity(0.15),
                senseColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: senseColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: senseColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(senseIcon, size: 18, color: senseColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: JuiceTheme.sepia,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: 'You '),
                      TextSpan(
                        text: result.sensory.sense.toLowerCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: senseColor),
                      ),
                      const TextSpan(text: ' something '),
                      TextSpan(
                        text: result.sensory.detail.toLowerCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.rust),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: result.sensory.where.toLowerCase(),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Emotional result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                polarityColor.withOpacity(0.15),
                polarityColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: polarityColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: polarityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  result.emotional.isPositive
                      ? Icons.sentiment_satisfied
                      : Icons.sentiment_dissatisfied,
                  size: 18,
                  color: polarityColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: JuiceTheme.sepia,
                        ),
                        children: [
                          const TextSpan(text: 'It causes '),
                          TextSpan(
                            text: result.emotional.selectedEmotion.toLowerCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: polarityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: JuiceTheme.parchmentDark.withOpacity(0.8),
                        ),
                        children: [
                          const TextSpan(text: 'because '),
                          TextSpan(
                            text: result.emotional.cause,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: JuiceTheme.rust,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DETAILS & PROPERTIES DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDualPropertyResultDisplay(DualPropertyResult result) {
    const propertyColor = JuiceTheme.gold;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice display row - both properties' dice
        Row(
          children: [
            // First property dice
            _buildPropertyDicePair(
              result.property1.propertyRoll, 
              result.property1.intensityRoll, 
            ),
            const SizedBox(width: 8),
            Text('+', style: TextStyle(color: JuiceTheme.parchmentDark, fontSize: 12)),
            const SizedBox(width: 8),
            // Second property dice
            _buildPropertyDicePair(
              result.property2.propertyRoll, 
              result.property2.intensityRoll, 
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Property results
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildPropertyChip(result.property1, propertyColor),
            Icon(Icons.add, size: 14, color: JuiceTheme.parchmentDark),
            _buildPropertyChip(result.property2, propertyColor),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyDicePair(int d10Value, int d6Value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: JuiceTheme.rust.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'd10',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontSize: 9,
                  color: JuiceTheme.rust,
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: JuiceTheme.rust.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '$d10Value',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: JuiceTheme.parchment,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: JuiceTheme.info.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'd6',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontSize: 9,
                  color: JuiceTheme.info,
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: JuiceTheme.info.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '$d6Value',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: JuiceTheme.parchment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyChip(PropertyResult property, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            property.property,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              property.intensityDescription,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyResultDisplay(PropertyResult result) {
    const propertyColor = JuiceTheme.gold;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice display with property and intensity dice
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.rust.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'd10',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.rust,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.rust.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.propertyRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'd6',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.info,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.info.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${result.intensityRoll}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Property result display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                propertyColor.withOpacity(0.15),
                propertyColor.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: propertyColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 16, color: propertyColor),
              const SizedBox(width: 8),
              Text(
                result.property,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: propertyColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: propertyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.intensityDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: propertyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailWithFollowUpDisplay(DetailWithFollowUpResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text('d10: ${result.detailResult.roll}', style: TextStyle(fontSize: 10, fontFamily: JuiceTheme.fontFamilyMono, color: Colors.teal)),
        ),
        const SizedBox(width: 8),
        Chip(label: Text(result.detailResult.detailType.name), backgroundColor: Colors.teal.withOpacity(0.1), side: const BorderSide(color: Colors.teal), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
        const SizedBox(width: 8),
        Expanded(child: Text(result.detailResult.result, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
      ]),
      if (result.hasFollowUp && result.followUpText != null) ...[
        const SizedBox(height: 4),
        Text('→ ${result.followUpText}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey)),
      ],
    ]);
  }

  Widget _buildDetailResultDisplay(DetailResult result) {
    // Different styling based on detail type
    final isColor = result.detailType == DetailType.color;
    final isHistory = result.detailType == DetailType.history;
    
    // Theme colors based on type
    final Color accentColor;
    final IconData icon;
    if (isColor) {
      accentColor = const Color(0xFF6B8EAE); // Blue-ish for color
      icon = Icons.palette;
    } else if (isHistory) {
      accentColor = JuiceTheme.rust;
      icon = Icons.history;
    } else {
      accentColor = JuiceTheme.mystic;
      icon = Icons.help_outline;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.secondRoll != null ? 'd10 @' : 'd10',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  result.secondRoll != null 
                      ? '${result.roll}, ${result.secondRoll}'
                      : '${result.roll}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.parchment,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Result display - special treatment for Color
        if (isColor) ...[
          _buildColorResultDisplay(result),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.12),
                  accentColor.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  result.result,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorResultDisplay(DetailResult result) {
    // Map color names to actual colors for display
    final colorMap = {
      'Shade Black': Colors.black87,
      'Leather Brown': const Color(0xFF8B4513),
      'Highlight Yellow': Colors.yellow.shade600,
      'Forest Green': const Color(0xFF228B22),
      'Cobalt Blue': const Color(0xFF0047AB),
      'Crimson Red': const Color(0xFFDC143C),
      'Royal Violet': const Color(0xFF7851A9),
      'Metallic Silver': Colors.grey.shade400,
      'Midas Gold': const Color(0xFFFFD700),
      'Holy White': Colors.white70,
    };
    
    final displayColor = colorMap[result.result] ?? JuiceTheme.parchment;
    final isDark = displayColor.computeLuminance() < 0.5;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: displayColor.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color swatch
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: displayColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black26,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: displayColor.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Color name
          Text(
            result.result,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: JuiceTheme.parchment,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFateRollDisplay(FateRollResult result) {
    // Determine result color based on total
    final resultColor = result.total > 0
        ? JuiceTheme.success
        : result.total < 0
            ? JuiceTheme.danger
            : JuiceTheme.parchmentDark;
    
    return Row(
      children: [
        // Fate dice symbols with individual styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: JuiceTheme.mystic.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.mystic.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: result.diceResults.asMap().entries.map((entry) {
              final value = entry.value;
              final isLast = entry.key == result.diceResults.length - 1;
              
              // Determine symbol and color for this die
              String symbol;
              Color dieColor;
              if (value > 0) {
                symbol = '+';
                dieColor = JuiceTheme.success;
              } else if (value < 0) {
                symbol = '−';
                dieColor = JuiceTheme.danger;
              } else {
                symbol = '○';
                dieColor = JuiceTheme.parchmentDark;
              }
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: dieColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: dieColor.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: dieColor,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast) const SizedBox(width: 4),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 10),
        // Equals sign
        Text(
          '=',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: JuiceTheme.parchmentDark,
          ),
        ),
        const SizedBox(width: 6),
        // Total with gradient background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                resultColor.withOpacity(0.25),
                resultColor.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: resultColor.withOpacity(0.5)),
          ),
          child: Text(
            result.total >= 0 ? '+${result.total}' : '${result.total}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: resultColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDisplay(DialogResult result) {
    final tenseColor = result.isPast ? JuiceTheme.mystic : JuiceTheme.success;
    final tenseBg = result.isPast ? JuiceTheme.mystic.withOpacity(0.08) : JuiceTheme.success.withOpacity(0.08);
    
    // Direction arrow and color
    IconData directionIcon;
    switch (result.direction.toLowerCase()) {
      case 'up':
        directionIcon = Icons.arrow_upward;
        break;
      case 'down':
        directionIcon = Icons.arrow_downward;
        break;
      case 'left':
        directionIcon = Icons.arrow_back;
        break;
      case 'right':
        directionIcon = Icons.arrow_forward;
        break;
      default:
        directionIcon = Icons.circle;
    }
    
    // Tone color based on type
    Color toneColor;
    switch (result.tone.toLowerCase()) {
      case 'helpful':
        toneColor = JuiceTheme.success;
        break;
      case 'aggressive':
        toneColor = JuiceTheme.danger;
        break;
      case 'defensive':
        toneColor = JuiceTheme.gold;
        break;
      default: // neutral
        toneColor = JuiceTheme.info;
    }
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // If DOUBLES - prominent end indicator
      if (result.isDoubles) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stop_circle, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                'DOUBLES (${result.directionRoll}, ${result.subjectRoll}) — CONVERSATION ENDS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
      
      // Main response fragment - the most important part
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tenseBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tenseColor.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fragment type with tense badge
            Row(
              children: [
                Icon(Icons.chat, size: 16, color: tenseColor),
                const SizedBox(width: 6),
                Text(
                  result.newFragment.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tenseColor,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tenseColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result.isPast ? '📜 PAST' : '⚡ PRESENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tenseColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              result.fragmentDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: JuiceTheme.parchment.withOpacity(0.85),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      
      // Tone and Subject - the "how" and "about whom"
      Row(
        children: [
          // Tone chip
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: toneColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: toneColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.record_voice_over, size: 14, color: toneColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TONE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: toneColor.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          result.tone,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: toneColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Subject chip
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.info.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14, color: JuiceTheme.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUBJECT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: JuiceTheme.info.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          result.subject,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: JuiceTheme.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      
      // Grid movement visualization - compact footer
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: JuiceTheme.parchment.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Dice rolls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: JuiceTheme.juiceOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '2d10: ${result.directionRoll}, ${result.subjectRoll}',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.juiceOrange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Movement
            Icon(directionIcon, size: 12, color: JuiceTheme.parchment.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              result.oldFragment,
              style: TextStyle(
                fontSize: 10,
                color: JuiceTheme.parchment.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '→',
              style: TextStyle(
                fontSize: 10,
                color: JuiceTheme.parchment.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              result.newFragment,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: tenseColor,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WILDERNESS DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWildernessAreaDisplay(WildernessAreaResult result) {
    final exploreColor = JuiceTheme.categoryExplore;
    
    // For manual set, show a simpler display
    if (result.isManualSet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: JuiceTheme.juiceOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pin_drop, size: 12, color: JuiceTheme.juiceOrange),
                const SizedBox(width: 4),
                Text(
                  'POSITION SET',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: JuiceTheme.juiceOrange,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Result container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: exploreColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: exploreColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.landscape, size: 18, color: exploreColor),
                const SizedBox(width: 8),
                Text(
                  result.fullDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: exploreColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final fateSymbols = FateDiceFormatter.diceToSymbols(result.envFateDice);
    final typeSymbol = FateDiceFormatter.dieToSymbol(result.typeFateDie);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: exploreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: exploreColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(result.isTransition ? Icons.swap_horiz : Icons.explore, size: 12, color: exploreColor),
              const SizedBox(width: 4),
              Text(
                result.isTransition ? 'TRANSITION' : 'INITIALIZE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: exploreColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Dice display
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: exploreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '2dF ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: exploreColor,
                    ),
                  ),
                  Text(
                    fateSymbols,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1dF ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.info,
                    ),
                  ),
                  Text(
                    typeSymbol,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Transition arrow and result
        if (result.isTransition && result.previousEnvironment != null)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.previousEnvironment!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: JuiceTheme.sepia,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, size: 16, color: exploreColor),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: exploreColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: exploreColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.landscape, size: 16, color: exploreColor),
                      const SizedBox(width: 6),
                      Text(
                        result.fullDescription,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: JuiceTheme.fontFamilySerif,
                          color: exploreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: exploreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: exploreColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.landscape, size: 16, color: exploreColor),
                const SizedBox(width: 6),
                Text(
                  result.fullDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: exploreColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWildernessEncounterDisplay(WildernessEncounterResult result) {
    final exploreColor = JuiceTheme.categoryExplore;
    
    // Determine encounter color based on type
    Color encounterColor = exploreColor;
    IconData encounterIcon = Icons.explore;
    
    if (result.encounter == 'Natural Hazard') {
      encounterColor = JuiceTheme.danger;
      encounterIcon = Icons.warning;
    } else if (result.encounter == 'Monster') {
      encounterColor = JuiceTheme.categoryCombat;
      encounterIcon = Icons.pest_control;
    } else if (result.encounter == 'Destination/Lost') {
      encounterColor = result.becameLost ? JuiceTheme.juiceOrange : JuiceTheme.info;
      encounterIcon = result.becameLost ? Icons.explore_off : Icons.flag;
    } else if (result.encounter == 'River/Road') {
      encounterColor = result.becameFound ? JuiceTheme.info : JuiceTheme.mystic;
      encounterIcon = Icons.route;
    } else if (result.encounter == 'Weather') {
      encounterColor = JuiceTheme.info;
      encounterIcon = Icons.cloud;
    } else if (result.encounter == 'Challenge') {
      encounterColor = JuiceTheme.mystic;
      encounterIcon = Icons.fitness_center;
    } else if (result.encounter == 'Feature') {
      encounterColor = JuiceTheme.sepia;
      encounterIcon = Icons.auto_awesome;
    } else if (result.encounter == 'Dungeon') {
      encounterColor = JuiceTheme.rust;
      encounterIcon = Icons.castle;
    } else if (result.encounter.contains('Settlement') || result.encounter.contains('Camp')) {
      encounterColor = JuiceTheme.gold;
      encounterIcon = Icons.home;
    }
    
    // Build the encounter text with italic styling where appropriate
    Widget encounterText;
    if (result.partialItalic != null) {
      // Settlement/Camp - only "Settlement" is italic
      encounterText = RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: result.partialItalic!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: encounterColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text: '/${result.encounter.split('/').last}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: encounterColor,
              ),
            ),
          ],
        ),
      );
    } else {
      encounterText = Text(
        result.encounter,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: JuiceTheme.fontFamilySerif,
          color: encounterColor,
          fontStyle: result.isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge and dice display row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: exploreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: exploreColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shuffle, size: 12, color: exploreColor),
                  const SizedBox(width: 4),
                  Text(
                    'ENCOUNTER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: exploreColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.parchment.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'd${result.dieSize}${result.skewUsed != 'straight' ? '@${result.skewUsed[0].toUpperCase()}' : ''}: ${result.roll}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (result.wasLost) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.juiceOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_off, size: 10, color: JuiceTheme.juiceOrange),
                    const SizedBox(width: 3),
                    Text(
                      'LOST',
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.juiceOrange,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Result container
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: encounterColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: encounterColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(encounterIcon, size: 16, color: encounterColor),
                  const SizedBox(width: 6),
                  encounterText,
                ],
              ),
            ),
            if (result.becameLost) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.juiceOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_off, size: 12, color: JuiceTheme.juiceOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Now Lost!',
                      style: TextStyle(fontSize: 11, color: JuiceTheme.juiceOrange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            if (result.becameFound) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.success.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: JuiceTheme.success),
                    const SizedBox(width: 4),
                    Text(
                      'Found!',
                      style: TextStyle(fontSize: 11, color: JuiceTheme.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        // Show follow-up result with arrow notation if present
        if (result.followUpResult != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.subdirectory_arrow_right, size: 16, color: JuiceTheme.sepia),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getFollowUpThemeColor(result.encounter).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getFollowUpThemeColor(result.encounter).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: JuiceTheme.parchment.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'd10: ${result.followUpRoll}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: JuiceTheme.fontFamilyMono,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.followUpResult!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: JuiceTheme.fontFamilySerif,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (result.followUpData != null && result.encounter == 'Monster' && result.followUpData!['hasBoss'] == true) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: JuiceTheme.categoryCombat.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 12, color: JuiceTheme.categoryCombat),
                              const SizedBox(width: 4),
                              Text(
                                'Boss: ${result.followUpData!['bossMonster']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: JuiceTheme.categoryCombat,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ] else if (result.requiresFollowUp) ...[
          // Legacy display for old results without embedded follow-up
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.subdirectory_arrow_right, size: 14, color: JuiceTheme.sepia.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                _getFollowUpHint(result.encounter),
                style: TextStyle(
                  color: JuiceTheme.sepia.withOpacity(0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getFollowUpThemeColor(String encounter) {
    switch (encounter) {
      case 'Monster':
        return JuiceTheme.categoryCombat;
      case 'Natural Hazard':
        return JuiceTheme.danger;
      case 'Weather':
        return JuiceTheme.info;
      case 'Challenge':
        return JuiceTheme.mystic;
      case 'Dungeon':
        return JuiceTheme.rust;
      case 'Feature':
        return JuiceTheme.sepia;
      default:
        return JuiceTheme.categoryExplore;
    }
  }

  String _getFollowUpHint(String encounter) {
    switch (encounter) {
      case 'Monster':
        return 'Roll Monster Encounter';
      case 'Natural Hazard':
        return 'Roll Natural Hazard';
      case 'Weather':
        return 'Roll Weather';
      case 'Challenge':
        return 'Roll Challenge';
      case 'Dungeon':
        return 'Roll Dungeon';
      case 'Feature':
        return 'Roll Feature';
      default:
        return 'Roll for details';
    }
  }

  Widget _buildWildernessWeatherDisplay(WildernessWeatherResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('d6@${result.environmentSkew}: ${result.baseRoll}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: Colors.blue)),
      ),
      const SizedBox(width: 8),
      Text(result.weather, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MONSTER DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFullMonsterEncounterDisplay(FullMonsterEncounterResult result) {
    final combatColor = JuiceTheme.categoryCombat;
    
    final difficultyColor = switch (result.difficulty) {
      MonsterDifficulty.easy => JuiceTheme.success,
      MonsterDifficulty.medium => JuiceTheme.juiceOrange,
      MonsterDifficulty.hard => JuiceTheme.danger,
      MonsterDifficulty.boss => JuiceTheme.mystic,
    };

    // Parse dice results: first 1-2 dice are row roll (d6), last 2 are difficulty (d10)
    // Structure: [row dice...] + [diff d10, diff d10]
    final totalDice = result.diceResults.length;
    final rowDiceCount = totalDice - 2; // Last 2 are always the difficulty dice
    final rowDice = rowDiceCount > 0 ? result.diceResults.sublist(0, rowDiceCount) : <int>[];
    final diffDice = totalDice >= 2 ? result.diceResults.sublist(totalDice - 2) : <int>[];
    
    // Row dice label based on environment formula (advantage/disadvantage)
    final rowDiceLabel = rowDice.length == 2 ? '2d6' : '1d6';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: combatColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: combatColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups, size: 12, color: combatColor),
                  const SizedBox(width: 4),
                  Text(
                    'FULL ENCOUNTER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: combatColor,
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
        // Dice display row - show row dice and difficulty dice separately
        Row(
          children: [
            // Row dice (1d6 or 2d6 for environment)
            if (rowDice.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.categoryExplore.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Row $rowDiceLabel: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: JuiceTheme.categoryExplore,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '[${rowDice.join(", ")}]',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            if (rowDice.isNotEmpty && diffDice.isNotEmpty)
              const SizedBox(width: 6),
            // Difficulty dice (2d10)
            if (diffDice.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Diff 2d10: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: difficultyColor,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '[${diffDice.join(", ")}]',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        // Environment and formula info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.categoryExplore.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.landscape, size: 12, color: JuiceTheme.categoryExplore),
                  const SizedBox(width: 4),
                  Text(
                    MonsterEncounter.environmentNames[(result.environmentRow - 1).clamp(0, 9)],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.categoryExplore,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                result.environmentFormula,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Environment and difficulty row
        Row(
          children: [
            if (result.isForest && result.row == 10) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.categoryExplore.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.categoryExplore.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco, size: 10, color: JuiceTheme.categoryExplore),
                    const SizedBox(width: 3),
                    Text(
                      'FOREST→BLIGHTS',
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.categoryExplore,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: difficultyColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (result.difficulty == MonsterDifficulty.boss)
                    Icon(Icons.star, size: 12, color: difficultyColor),
                  if (result.difficulty == MonsterDifficulty.boss)
                    const SizedBox(width: 4),
                  Text(
                    MonsterEncounter.difficultyName(result.difficulty),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: difficultyColor,
                    ),
                  ),
                ],
              ),
            ),
            if (result.wasDoubles) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 10, color: JuiceTheme.mystic),
                    const SizedBox(width: 3),
                    Text(
                      'DOUBLES!',
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.mystic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Monster list
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: combatColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: combatColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.hasBoss && result.bossMonster != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: JuiceTheme.mystic.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: JuiceTheme.mystic),
                      const SizedBox(width: 6),
                      Text(
                        '1× ${result.bossMonster} (Boss)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: JuiceTheme.fontFamilySerif,
                          color: JuiceTheme.mystic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.monsters.any((m) => m.count > 0))
                  const SizedBox(height: 6),
              ],
              ...result.monsters.where((m) => m.count > 0).map((monster) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(Icons.pest_control, size: 12, color: combatColor.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      '${monster.count}× ${monster.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: JuiceTheme.fontFamilySerif,
                      ),
                    ),
                  ],
                ),
              )),
              if (result.monsters.every((m) => m.count == 0) && !result.hasBoss)
                Row(
                  children: [
                    Icon(Icons.sentiment_neutral, size: 14, color: JuiceTheme.sepia),
                    const SizedBox(width: 6),
                    Text(
                      'No monsters appeared (all rolled 0)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.sepia,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonsterEncounterDisplay(MonsterEncounterResult result) {
    final combatColor = JuiceTheme.categoryCombat;
    
    final difficultyColor = switch (result.difficulty) {
      MonsterDifficulty.easy => JuiceTheme.success,
      MonsterDifficulty.medium => JuiceTheme.juiceOrange,
      MonsterDifficulty.hard => JuiceTheme.danger,
      MonsterDifficulty.boss => JuiceTheme.mystic,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge and dice row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: combatColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: combatColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.casino, size: 12, color: combatColor),
                  const SizedBox(width: 4),
                  Text(
                    'ENCOUNTER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: combatColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (result.diceResults.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchment.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '2d10: [${result.diceResults.join(", ")}]',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // Difficulty and status flags
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: difficultyColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (result.difficulty == MonsterDifficulty.boss)
                    Icon(Icons.star, size: 12, color: difficultyColor),
                  if (result.difficulty == MonsterDifficulty.boss)
                    const SizedBox(width: 4),
                  Text(
                    MonsterEncounter.difficultyName(result.difficulty),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: difficultyColor,
                    ),
                  ),
                ],
              ),
            ),
            // Show DOUBLES! only if not Boss (Boss already implies doubles in its name)
            if (result.wasDoubles && result.difficulty != MonsterDifficulty.boss) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.mystic.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 10, color: JuiceTheme.mystic),
                    const SizedBox(width: 3),
                    Text(
                      'DOUBLES!',
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.mystic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (result.isDeadly) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: JuiceTheme.danger.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.danger.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '💀',
                      style: TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'DEADLY',
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Monster result
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: combatColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: combatColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pest_control, size: 16, color: combatColor),
              const SizedBox(width: 8),
              Text(
                result.monster,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: combatColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonsterTracksDisplay(MonsterTracksResult result) {
    final trackColor = JuiceTheme.sepia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge and dice row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: trackColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: trackColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets, size: 12, color: trackColor),
                  const SizedBox(width: 4),
                  Text(
                    'TRACKS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: trackColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (result.diceResults.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchment.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1d6-1@: [${result.diceResults.join(", ")}]',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // Modifier display
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 12, color: JuiceTheme.info),
                  const SizedBox(width: 4),
                  Text(
                    'Modifier: ${result.modifier >= 0 ? '+' : ''}${result.modifier}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tracks result
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: trackColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: trackColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, size: 16, color: trackColor),
              const SizedBox(width: 8),
              Text(
                result.tracks,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: trackColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION & ABSTRACT ICON DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLocationDisplay(LocationResult result) {
    final exploreColor = JuiceTheme.categoryExplore;
    final compassColor = JuiceTheme.info;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compass description - the main result
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: exploreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: exploreColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.explore, size: 18, color: exploreColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.compassDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: exploreColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: exploreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'd100: ${result.roll}',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: exploreColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 5x5 grid with selected cell highlighted
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuiceTheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: compassColor.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // North label
                Text('N', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // West label
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text('W', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
                    ),
                    // 5x5 grid
                    Column(
                      children: List.generate(5, (row) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (col) {
                            // Grid uses 1-indexed (row 1-5, col 1-5)
                            final isSelected = (row + 1) == result.row && (col + 1) == result.column;
                            final isCenter = row == 2 && col == 2;
                            final isClose = !isCenter && row >= 1 && row <= 3 && col >= 1 && col <= 3;
                            
                            Color cellColor;
                            if (isSelected) {
                              cellColor = JuiceTheme.juiceOrange;
                            } else if (isCenter) {
                              cellColor = JuiceTheme.gold;
                            } else if (isClose) {
                              cellColor = exploreColor;
                            } else {
                              cellColor = JuiceTheme.parchmentDark;
                            }
                            
                            return Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: cellColor.withOpacity(isSelected ? 0.6 : (isCenter ? 0.3 : 0.15)),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isSelected ? JuiceTheme.juiceOrange : cellColor.withOpacity(0.4),
                                  width: isSelected ? 2 : (isCenter ? 1 : 0.5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  isSelected ? '●' : (isCenter ? '◉' : (isClose ? '○' : '·')),
                                  style: TextStyle(
                                    fontSize: isSelected ? 10 : 8,
                                    color: isSelected ? Colors.white : cellColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                    // East label
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('E', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // South label
                Text('S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilyMono, color: compassColor)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        
        // Grid position footer
        Center(
          child: Text(
            'Grid [${result.row},${result.column}]',
            style: TextStyle(
              fontSize: 10,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.parchment.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbstractIconDisplay(AbstractIconResult result) {
    final mysticColor = JuiceTheme.mystic;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mysticColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: mysticColor.withOpacity(0.3)),
              ),
              child: Text(
                'd10+d6: [${result.d10Roll}, ${result.d6Roll}]',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: mysticColor,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${result.rowLabel}, ${result.colLabel})',
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchment.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Abstract icon - larger display
        if (result.imagePath != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: mysticColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: mysticColor.withOpacity(0.3)),
              ),
              child: Image.asset(
                result.imagePath!,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DUNGEON DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDungeonEncounterDisplay(DungeonEncounterResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.rust.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('Encounter: ${result.encounterRoll.result}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: JuiceTheme.rust)),
      ),
      if (result.monster != null) ...[
        const SizedBox(height: 4),
        Text('Monster: ${result.monster!.monsterDescription}', style: theme.textTheme.bodyMedium),
      ],
      if (result.trap != null) ...[
        const SizedBox(height: 4),
        Text('Trap: ${result.trap!.trapDescription}', style: theme.textTheme.bodyMedium),
      ],
    ]);
  }

  Widget _buildDungeonNameDisplay(DungeonNameResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.rust.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('3d10: [${result.typeRoll}, ${result.descriptionRoll}, ${result.subjectRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: JuiceTheme.rust)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(result.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif))),
    ]);
  }

  Widget _buildDungeonAreaDisplay(DungeonAreaResult result) {
    final phaseColor = result.phase == DungeonPhase.entering ? JuiceTheme.gold : JuiceTheme.success;
    final phaseLabel = result.phase == DungeonPhase.entering ? '@-' : '@+';
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, runSpacing: 4, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: phaseColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: phaseColor.withOpacity(0.5))),
          child: Text('${result.roll1},${result.roll2} $phaseLabel → ${result.chosenRoll}', style: TextStyle(fontWeight: FontWeight.bold, color: phaseColor, fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11)),
        ),
        if (result.isDoubles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber)),
            child: Text('🎲 DOUBLES!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 11)),
          ),
      ]),
      const SizedBox(height: 4),
      Text(result.areaType, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      if (result.passage != null) ...[
        const SizedBox(height: 4),
        Text('Passage: ${result.passage!.result}', style: theme.textTheme.bodySmall),
      ],
    ]);
  }

  Widget _buildFullDungeonAreaDisplay(FullDungeonAreaResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildDungeonAreaDisplay(result.area),
      const SizedBox(height: 6),
      Text('Condition: ${result.condition.result}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
    ]);
  }

  Widget _buildTwoPassAreaDisplay(TwoPassAreaResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: JuiceTheme.rust.withOpacity(0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: JuiceTheme.rust.withOpacity(0.5))),
        child: Text('${result.roll1},${result.roll2} → ${result.chosenRoll}', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.rust, fontFamily: JuiceTheme.fontFamilyMono, fontSize: 11)),
      ),
      const SizedBox(height: 4),
      Text(result.areaType, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('Condition: ${result.condition.result}', style: theme.textTheme.bodySmall),
      if (result.passage != null) Text('Passage: ${result.passage!.result}', style: theme.textTheme.bodySmall),
      if (result.isSecondDoubles) Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: JuiceTheme.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
        child: Text('⚡ Secret/Treasure!', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.gold, fontSize: 11)),
      ),
    ]);
  }

  Widget _buildDungeonMonsterDisplay(DungeonMonsterResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('2d10: [${result.descriptorRoll}, ${result.abilityRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.danger)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(result.monsterDescription, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildDungeonTrapDisplay(DungeonTrapResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('2d10: [${result.actionRoll}, ${result.subjectRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: Colors.orange)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(result.trapDescription, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildTrapProcedureDisplay(TrapProcedureResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildDungeonTrapDisplay(result.trap),
      const SizedBox(height: 6),
      Text('DC ${result.dc}', style: TextStyle(fontWeight: FontWeight.bold, color: JuiceTheme.gold)),
    ]);
  }

  Widget _buildDungeonDetailDisplay(DungeonDetailResult result) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.rust.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('d10: ${result.roll}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.rust)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(result.result, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXTENDED CONVERSATION DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInformationDisplay(InformationResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: JuiceTheme.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('2d100: [${result.typeRoll}, ${result.topicRoll}]', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: JuiceTheme.info)),
      ),
      const SizedBox(height: 6),
      Row(children: [
        Chip(label: Text(result.informationType), backgroundColor: JuiceTheme.info.withOpacity(0.15), side: BorderSide(color: JuiceTheme.info), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
        const SizedBox(width: 8),
        Expanded(child: Text(result.topic, style: theme.textTheme.bodyMedium)),
      ]),
    ]);
  }

  Widget _buildCompanionResponseDisplay(CompanionResponseResult result) {
    final isPositive = result.response.contains('Agree') || result.response.contains('Supportive');
    final color = isPositive ? JuiceTheme.success : JuiceTheme.danger;
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('d100: ${result.roll}', style: TextStyle(fontFamily: JuiceTheme.fontFamilyMono, color: color)),
      ),
      const SizedBox(width: 12),
      Chip(label: Text(result.response), backgroundColor: color.withOpacity(0.15), side: BorderSide(color: color), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
    ]);
  }

  Widget _buildDialogTopicDisplay(DialogTopicResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: JuiceTheme.juiceOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.4))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.forum, size: 12, color: JuiceTheme.juiceOrange),
            const SizedBox(width: 4),
            Text('DIALOG TOPIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: JuiceTheme.juiceOrange)),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(color: JuiceTheme.juiceOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text('1d100: ${result.roll}', style: TextStyle(fontSize: 10, fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: JuiceTheme.juiceOrange)),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: JuiceTheme.juiceOrange.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.2))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.chat_bubble_outline, size: 16, color: JuiceTheme.juiceOrange.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(result.topic, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: JuiceTheme.fontFamilySerif, color: JuiceTheme.parchment, height: 1.3))),
        ]),
      ),
    ]);
  }

  Widget _buildNameResultDisplay(NameResult result) {
    final characterColor = JuiceTheme.categoryCharacter;
    
    // Determine column labels based on method
    List<String> columnLabels;
    int rollOffset = 0; // Offset for pattern method (first roll is pattern selection)
    
    if (result.method == NameMethod.pattern && result.pattern != null) {
      // Parse pattern to get column labels
      columnLabels = [];
      for (final char in result.pattern!.split('')) {
        if (char == '1' || char == '2' || char == '3') {
          columnLabels.add('C$char');
        }
      }
      rollOffset = 1; // First roll is pattern selection, not syllable
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
        // Generated name with style indicator - prominent display
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontSize: 22,
                    color: characterColor,
                  ),
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
                  child: Text(
                    result.style == NameStyle.masculine ? '♂ Masc' : '♀ Fem',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: characterColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Pattern method indicator (if applicable)
        if (result.method == NameMethod.pattern && result.pattern != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: JuiceTheme.juiceOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.juiceOrange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.casino, size: 12, color: JuiceTheme.juiceOrange),
                const SizedBox(width: 6),
                Text(
                  'd20: ${result.rolls.isNotEmpty ? result.rolls[0] : "?"}',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilyMono,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.juiceOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '→',
                  style: TextStyle(
                    color: JuiceTheme.parchment.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: JuiceTheme.juiceOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Pattern: ${result.pattern}',
                    style: TextStyle(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.juiceOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        
        // Syllable breakdown - show column, roll, and syllable for each
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
                if (i > 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: characterColor.withOpacity(0.4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: characterColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Column label
                        if (i < columnLabels.length)
                          Text(
                            columnLabels[i],
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: characterColor.withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                        const SizedBox(height: 2),
                        // Syllable
                        Text(
                          result.syllables[i],
                          style: TextStyle(
                            fontFamily: JuiceTheme.fontFamilySerif,
                            fontWeight: FontWeight.bold,
                            color: characterColor,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Roll value
                        if (i + rollOffset < result.rolls.length)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: characterColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'd20: ${result.rolls[i + rollOffset]}',
                              style: TextStyle(
                                fontFamily: JuiceTheme.fontFamilyMono,
                                fontSize: 8,
                                color: characterColor.withOpacity(0.8),
                              ),
                            ),
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
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: characterColor.withOpacity(0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: characterColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SUFFIX',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: characterColor.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suffix,
                        style: TextStyle(
                          fontFamily: JuiceTheme.fontFamilySerif,
                          fontWeight: FontWeight.bold,
                          color: characterColor,
                          fontSize: 15,
                        ),
                      ),
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
            result.method == NameMethod.simple 
                ? 'Method: 3d20 across columns 1-2-3'
                : 'Method: 3d20 on column 1 only',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: JuiceTheme.parchment.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

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

  // ═══════════════════════════════════════════════════════════════════════════
  // IRONSWORN / STARFORGED DISPLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  static const _ironswornColor = Color(0xFF5C6BC0); // Indigo for Ironsworn

  Widget _buildIronswornActionDisplay(IronswornActionResult result) {
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
                color: _ironswornColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _ironswornColor.withOpacity(0.4)),
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
              color: _getChallengeColor(result.actionScore, result.challengeDice[0]),
              isBeaten: result.actionScore > result.challengeDice[0],
            ),
            const SizedBox(width: 6),
            _buildIronswornDieBox(
              label: 'd10',
              value: result.challengeDice[1],
              color: _getChallengeColor(result.actionScore, result.challengeDice[1]),
              isBeaten: result.actionScore > result.challengeDice[1],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Outcome row
        Row(
          children: [
            // Outcome chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    outcomeColor.withOpacity(0.3),
                    outcomeColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: outcomeColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    result.outcome == IronswornOutcome.strongHit
                        ? Icons.check_circle
                        : result.outcome == IronswornOutcome.weakHit
                            ? Icons.remove_circle
                            : Icons.cancel,
                    size: 18,
                    color: outcomeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    result.outcome.displayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: outcomeColor,
                    ),
                  ),
                ],
              ),
            ),
            // Match indicator
            if (result.isMatch) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (result.outcome.isSuccess 
                      ? JuiceTheme.success 
                      : JuiceTheme.danger).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (result.outcome.isSuccess 
                        ? JuiceTheme.success 
                        : JuiceTheme.danger).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: result.outcome.isSuccess 
                          ? JuiceTheme.success 
                          : JuiceTheme.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Match!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: result.outcome.isSuccess 
                            ? JuiceTheme.success 
                            : JuiceTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildIronswornProgressDisplay(IronswornProgressResult result) {
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
                color: _ironswornColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _ironswornColor.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 10,
                      color: _ironswornColor.withOpacity(0.8),
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
            // "vs" divider
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
              color: _getChallengeColor(result.progressScore, result.challengeDice[0]),
              isBeaten: result.progressScore > result.challengeDice[0],
            ),
            const SizedBox(width: 6),
            _buildIronswornDieBox(
              label: 'd10',
              value: result.challengeDice[1],
              color: _getChallengeColor(result.progressScore, result.challengeDice[1]),
              isBeaten: result.progressScore > result.challengeDice[1],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Outcome row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    outcomeColor.withOpacity(0.3),
                    outcomeColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: outcomeColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    result.outcome == IronswornOutcome.strongHit
                        ? Icons.check_circle
                        : result.outcome == IronswornOutcome.weakHit
                            ? Icons.remove_circle
                            : Icons.cancel,
                    size: 18,
                    color: outcomeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    result.outcome.displayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: outcomeColor,
                    ),
                  ),
                ],
              ),
            ),
            if (result.isMatch) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (result.outcome.isSuccess 
                      ? JuiceTheme.success 
                      : JuiceTheme.danger).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (result.outcome.isSuccess 
                        ? JuiceTheme.success 
                        : JuiceTheme.danger).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: result.outcome.isSuccess 
                          ? JuiceTheme.success 
                          : JuiceTheme.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Match!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: result.outcome.isSuccess 
                            ? JuiceTheme.success 
                            : JuiceTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildIronswornOracleDisplay(IronswornOracleResult result) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _ironswornColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _ironswornColor.withOpacity(0.4)),
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
                  color: _ironswornColor.withOpacity(0.8),
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

  Widget _buildIronswornYesNoDisplay(IronswornYesNoResult result) {
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
                color: _ironswornColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _ironswornColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'd100:',
                    style: TextStyle(
                      fontSize: 12,
                      color: _ironswornColor.withOpacity(0.8),
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
                color: JuiceTheme.mystic.withOpacity(0.15),
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
                answerColor.withOpacity(0.25),
                answerColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: answerColor.withOpacity(0.5)),
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
              color: JuiceTheme.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.gold.withOpacity(0.4)),
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

  Widget _buildIronswornCursedOracleDisplay(IronswornCursedOracleResult result) {
    final cursedColor = const Color(0xFF9C27B0); // Purple for cursed
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Oracle roll
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _ironswornColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _ironswornColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'd100:',
                    style: TextStyle(
                      fontSize: 12,
                      color: _ironswornColor.withOpacity(0.8),
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
                color: (result.isCursed 
                    ? cursedColor 
                    : JuiceTheme.parchmentDark).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (result.isCursed 
                      ? cursedColor 
                      : JuiceTheme.parchmentDark).withOpacity(0.4),
                  width: result.isCursed ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    result.isCursed ? Icons.warning_amber : Icons.shield_outlined,
                    size: 16,
                    color: result.isCursed 
                        ? cursedColor 
                        : JuiceTheme.parchmentDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cursed d10:',
                    style: TextStyle(
                      fontSize: 11,
                      color: (result.isCursed 
                          ? cursedColor 
                          : JuiceTheme.parchmentDark).withOpacity(0.8),
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
                  cursedColor.withOpacity(0.25),
                  cursedColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cursedColor.withOpacity(0.5)),
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

  Widget _buildIronswornMomentumBurnDisplay(IronswornMomentumBurnResult result) {
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
              color: JuiceTheme.parchmentDark.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            if (result.statBonus > 0 || result.adds > 0) ...[
              Text(
                '+${result.statBonus + result.adds}',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 6),
            ],
            // Original action score (struck through)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: originalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${result.originalActionScore}',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark.withOpacity(0.6),
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
                color: JuiceTheme.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.gold.withOpacity(0.5)),
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
              color: _getChallengeColor(result.momentumValue, result.challengeDice[0]),
              isBeaten: result.momentumValue > result.challengeDice[0],
            ),
            const SizedBox(width: 6),
            _buildIronswornDieBox(
              label: 'd10',
              value: result.challengeDice[1],
              color: _getChallengeColor(result.momentumValue, result.challengeDice[1]),
              isBeaten: result.momentumValue > result.challengeDice[1],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Outcome row with improvement indicator
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    outcomeColor.withOpacity(0.3),
                    outcomeColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: outcomeColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    result.burnedOutcome == IronswornOutcome.strongHit
                        ? Icons.check_circle
                        : result.burnedOutcome == IronswornOutcome.weakHit
                            ? Icons.remove_circle
                            : Icons.cancel,
                    size: 18,
                    color: outcomeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    result.burnedOutcome.displayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: outcomeColor,
                    ),
                  ),
                ],
              ),
            ),
            if (improved) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: JuiceTheme.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.gold.withOpacity(0.4)),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (result.burnedOutcome.isSuccess 
                      ? JuiceTheme.success 
                      : JuiceTheme.danger).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (result.burnedOutcome.isSuccess 
                        ? JuiceTheme.success 
                        : JuiceTheme.danger).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: result.burnedOutcome.isSuccess 
                          ? JuiceTheme.success 
                          : JuiceTheme.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Match!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: result.burnedOutcome.isSuccess 
                            ? JuiceTheme.success 
                            : JuiceTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildIronswornDieBox({
    required String label,
    required int value,
    required Color color,
    bool isBeaten = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withOpacity(0.7),
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
              decorationColor: color.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _getChallengeColor(int actionScore, int challengeValue) {
    return actionScore > challengeValue 
        ? JuiceTheme.success.withOpacity(0.8)  // Beaten
        : JuiceTheme.danger.withOpacity(0.8);  // Not beaten
  }
}

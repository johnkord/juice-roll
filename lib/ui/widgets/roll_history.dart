import 'package:flutter/material.dart';
import '../../core/fate_dice_formatter.dart';
import '../../core/dice_display_formatter.dart';
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
import '../theme/juice_theme.dart';

/// Scrollable roll history widget.
class RollHistory extends StatelessWidget {
  final List<RollResult> history;
  final void Function(int environmentRow, int typeRow)? onSetWildernessPosition;

  const RollHistory({
    super.key, 
    required this.history,
    this.onSetWildernessPosition,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final result = history[index];
        return _RollHistoryCard(
          key: ValueKey('${result.timestamp.millisecondsSinceEpoch}_$index'),
          result: result,
          index: index,
          onSetWildernessPosition: onSetWildernessPosition,
        );
      },
    );
  }
}

class _RollHistoryCard extends StatelessWidget {
  final RollResult result;
  final int index;
  final void Function(int environmentRow, int typeRow)? onSetWildernessPosition;

  const _RollHistoryCard({
    super.key, 
    required this.result, 
    required this.index,
    this.onSetWildernessPosition,
  });

  Color _getCategoryColor() {
    switch (result.type) {
      case RollType.fateCheck:
      case RollType.randomEvent:
      case RollType.discoverMeaning:
      case RollType.expectationCheck:
        return JuiceTheme.categoryOracle;
      case RollType.npcAction:
      case RollType.dialog:
      case RollType.nameGenerator:
        return JuiceTheme.categoryCharacter;
      case RollType.settlement:
      case RollType.location:
      case RollType.dungeon:
      case RollType.encounter:
      case RollType.weather:
        return JuiceTheme.categoryWorld;
      case RollType.challenge:
        return JuiceTheme.categoryCombat;
      case RollType.quest:
      case RollType.nextScene:
      case RollType.interruptPlotPoint:
        return JuiceTheme.categoryExplore;
      default:
        return JuiceTheme.sepia;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: categoryColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.description,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.parchment,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(result.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildResultDisplay(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (result.type) {
      case RollType.fateCheck:
        icon = Icons.help_outline;
        color = JuiceTheme.mystic;
        break;
      case RollType.nextScene:
        icon = Icons.theaters;
        color = JuiceTheme.info;
        break;
      case RollType.randomEvent:
        icon = Icons.flash_on;
        color = JuiceTheme.gold;
        break;
      case RollType.discoverMeaning:
        icon = Icons.lightbulb_outline;
        color = JuiceTheme.gold;
        break;
      case RollType.npcAction:
        icon = Icons.person;
        color = JuiceTheme.categoryCharacter;
        break;
      case RollType.payThePrice:
        icon = Icons.warning;
        color = JuiceTheme.danger;
        break;
      case RollType.quest:
        icon = Icons.map;
        color = JuiceTheme.rust;
        break;
      case RollType.interruptPlotPoint:
        icon = Icons.bolt;
        color = JuiceTheme.juiceOrange;
        break;
      case RollType.weather:
        icon = Icons.wb_sunny;
        color = JuiceTheme.info;
        break;
      case RollType.encounter:
        icon = Icons.explore;
        color = JuiceTheme.categoryExplore;
        break;
      case RollType.settlement:
        icon = Icons.location_city;
        color = JuiceTheme.categoryWorld;
        break;
      case RollType.objectTreasure:
        icon = Icons.diamond;
        color = JuiceTheme.gold;
        break;
      case RollType.challenge:
        icon = Icons.fitness_center;
        color = JuiceTheme.categoryCombat;
        break;
      case RollType.details:
        icon = Icons.palette;
        color = JuiceTheme.parchmentDark;
        break;
      case RollType.immersion:
        icon = Icons.visibility;
        color = JuiceTheme.juiceOrange;
        break;
      case RollType.location:
        icon = Icons.grid_on;
        color = JuiceTheme.rust;
        break;
      case RollType.abstractIcons:
        icon = Icons.image;
        color = JuiceTheme.success;
        break;
      case RollType.fate:
        icon = Icons.auto_awesome;
        color = JuiceTheme.mystic;
        break;
      case RollType.dialog:
        icon = Icons.chat;
        color = JuiceTheme.categoryCharacter;
        break;
      default:
        icon = Icons.casino;
        color = JuiceTheme.categoryUtility;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildResultDisplay(ThemeData theme) {
    // Special handling for different result types
    if (result is FateCheckResult) {
      return _buildFateCheckDisplay(result as FateCheckResult, theme);
    } else if (result is ExpectationCheckResult) {
      return _buildExpectationCheckDisplay(result as ExpectationCheckResult, theme);
    } else if (result is ScaleResult) {
      return _buildScaleDisplay(result as ScaleResult, theme);
    } else if (result is NextSceneWithFollowUpResult) {
      return _buildNextSceneWithFollowUpDisplay(result as NextSceneWithFollowUpResult, theme);
    } else if (result is NextSceneResult) {
      return _buildNextSceneDisplay(result as NextSceneResult, theme);
    } else if (result is RandomEventResult) {
      return _buildRandomEventDisplay(result as RandomEventResult, theme);
    } else if (result is RandomEventFocusResult) {
      return _buildRandomEventFocusDisplay(result as RandomEventFocusResult, theme);
    } else if (result is IdeaResult) {
      return _buildIdeaDisplay(result as IdeaResult, theme);
    } else if (result is DiscoverMeaningResult) {
      return _buildDiscoverMeaningDisplay(result as DiscoverMeaningResult, theme);
    } else if (result is MotiveWithFollowUpResult) {
      return _buildMotiveWithFollowUpDisplay(result as MotiveWithFollowUpResult, theme);
    } else if (result is NpcActionResult) {
      return _buildNpcActionDisplay(result as NpcActionResult, theme);
    } else if (result is NpcProfileResult) {
      return _buildNpcProfileDisplay(result as NpcProfileResult, theme);
    } else if (result is ComplexNpcResult) {
      return _buildComplexNpcDisplay(result as ComplexNpcResult, theme);
    } else if (result is PayThePriceResult) {
      return _buildPayThePriceDisplay(result as PayThePriceResult, theme);
    } else if (result is QuestResult) {
      return _buildQuestDisplay(result as QuestResult, theme);
    } else if (result is InterruptPlotPointResult) {
      return _buildInterruptDisplay(result as InterruptPlotPointResult, theme);
    } else if (result is SettlementNameResult) {
      return _buildSettlementNameDisplay(result as SettlementNameResult, theme);
    } else if (result is EstablishmentNameResult) {
      return _buildEstablishmentNameDisplay(result as EstablishmentNameResult, theme);
    } else if (result is SettlementPropertiesResult) {
      return _buildSettlementPropertiesDisplay(result as SettlementPropertiesResult, theme);
    } else if (result is SimpleNpcResult) {
      return _buildSimpleNpcDisplay(result as SimpleNpcResult, theme);
    } else if (result is CompleteSettlementResult) {
      return _buildCompleteSettlementDisplay(result as CompleteSettlementResult, theme);
    } else if (result is FullSettlementResult) {
      return _buildFullSettlementDisplay(result as FullSettlementResult, theme);
    } else if (result is ItemCreationResult) {
      return _buildItemCreationDisplay(result as ItemCreationResult, theme);
    } else if (result is ObjectTreasureResult) {
      return _buildObjectTreasureDisplay(result as ObjectTreasureResult, theme);
    } else if (result is FullChallengeResult) {
      return _buildFullChallengeDisplay(result as FullChallengeResult, theme);
    } else if (result is ChallengeSkillResult) {
      return _buildChallengeSkillDisplay(result as ChallengeSkillResult, theme);
    } else if (result is DcResult) {
      return _buildDcDisplay(result as DcResult, theme);
    } else if (result is QuickDcResult) {
      return _buildQuickDcDisplay(result as QuickDcResult, theme);
    } else if (result is SensoryDetailResult) {
      return _buildSensoryDetailDisplay(result as SensoryDetailResult, theme);
    } else if (result is EmotionalAtmosphereResult) {
      return _buildEmotionalAtmosphereDisplay(result as EmotionalAtmosphereResult, theme);
    } else if (result is FullImmersionResult) {
      return _buildFullImmersionDisplay(result as FullImmersionResult, theme);
    } else if (result is PropertyResult) {
      return _buildPropertyResultDisplay(result as PropertyResult, theme);
    } else if (result is DetailWithFollowUpResult) {
      return _buildDetailWithFollowUpDisplay(result as DetailWithFollowUpResult, theme);
    } else if (result is DetailResult) {
      return _buildDetailResultDisplay(result as DetailResult, theme);
    } else if (result is FateRollResult) {
      return _buildFateRollDisplay(result as FateRollResult, theme);
    } else if (result is DialogResult) {
      return _buildDialogDisplay(result as DialogResult, theme);
    } else if (result is WildernessAreaResult) {
      return _buildWildernessAreaDisplay(result as WildernessAreaResult, theme);
    } else if (result is WildernessEncounterResult) {
      return _buildWildernessEncounterDisplay(result as WildernessEncounterResult, theme);
    } else if (result is WildernessWeatherResult) {
      return _buildWildernessWeatherDisplay(result as WildernessWeatherResult, theme);
    } else if (result is FullMonsterEncounterResult) {
      return _buildFullMonsterEncounterDisplay(result as FullMonsterEncounterResult, theme);
    } else if (result is MonsterEncounterResult) {
      return _buildMonsterEncounterDisplay(result as MonsterEncounterResult, theme);
    } else if (result is MonsterTracksResult) {
      return _buildMonsterTracksDisplay(result as MonsterTracksResult, theme);
    } else if (result is LocationResult) {
      return _buildLocationDisplay(result as LocationResult, theme);
    } else if (result is AbstractIconResult) {
      return _buildAbstractIconDisplay(result as AbstractIconResult, theme);
    } else if (result is DungeonEncounterResult) {
      return _buildDungeonEncounterDisplay(result as DungeonEncounterResult, theme);
    } else if (result is DungeonNameResult) {
      return _buildDungeonNameDisplay(result as DungeonNameResult, theme);
    } else if (result is DungeonAreaResult) {
      return _buildDungeonAreaDisplay(result as DungeonAreaResult, theme);
    } else if (result is FullDungeonAreaResult) {
      return _buildFullDungeonAreaDisplay(result as FullDungeonAreaResult, theme);
    } else if (result is TwoPassAreaResult) {
      return _buildTwoPassAreaDisplay(result as TwoPassAreaResult, theme);
    } else if (result is DungeonMonsterResult) {
      return _buildDungeonMonsterDisplay(result as DungeonMonsterResult, theme);
    } else if (result is DungeonTrapResult) {
      return _buildDungeonTrapDisplay(result as DungeonTrapResult, theme);
    } else if (result is TrapProcedureResult) {
      return _buildTrapProcedureDisplay(result as TrapProcedureResult, theme);
    } else if (result is DungeonDetailResult) {
      return _buildDungeonDetailDisplay(result as DungeonDetailResult, theme);
    } else if (result is InformationResult) {
      return _buildInformationDisplay(result as InformationResult, theme);
    } else if (result is CompanionResponseResult) {
      return _buildCompanionResponseDisplay(result as CompanionResponseResult, theme);
    } else if (result is DialogTopicResult) {
      return _buildDialogTopicDisplay(result as DialogTopicResult, theme);
    }

    // Handle standard dice roll types with enhanced display
    if (result.type == RollType.standard || 
        result.type == RollType.advantage || 
        result.type == RollType.disadvantage || 
        result.type == RollType.skewed) {
      return _buildGenericDiceRollDisplay(result, theme);
    }

    // Default display
    return Row(
      children: [
        Text(
          '[${result.diceResults.join(', ')}]',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '= ${result.total}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (result.interpretation != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.interpretation!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFateCheckDisplay(FateCheckResult result, ThemeData theme) {
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
                color: isPositive ? JuiceTheme.success.withOpacity(0.2) : JuiceTheme.danger.withOpacity(0.2),
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

  Widget _buildNextSceneDisplay(NextSceneResult result, ThemeData theme) {
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
            // Fate dice symbols with label
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

  Widget _buildNextSceneWithFollowUpDisplay(NextSceneWithFollowUpResult result, ThemeData theme) {
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
            // Fate dice symbols with label
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
        // Show the follow-up result
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
                style: theme.textTheme.bodyMedium?.copyWith(color: JuiceTheme.parchmentDark),
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

  Widget _buildRandomEventDisplay(RandomEventResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice rolls display
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

  Widget _buildRandomEventFocusDisplay(RandomEventFocusResult result, ThemeData theme) {
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

  Widget _buildIdeaDisplay(IdeaResult result, ThemeData theme) {
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

  Widget _buildDiscoverMeaningDisplay(DiscoverMeaningResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
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
        // Two-word meaning display with distinct styling
        Row(
          children: [
            // Adjective/Verb (first word)
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
            // Noun (second word)
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

  Widget _buildMotiveWithFollowUpDisplay(MotiveWithFollowUpResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
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
        // Main motive
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
        // Follow-up if present
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

  Widget _buildNpcActionDisplay(NpcActionResult result, ThemeData theme) {
    // Build dice notation string
    final dieSize = result.dieSize ?? 10;
    final diceNotation = result.allRolls != null && result.allRolls!.length > 1
        ? 'd$dieSize@: ${result.allRolls!.join(", ")} → ${result.roll}'
        : '1d$dieSize: ${result.roll}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
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

  Widget _buildNpcProfileDisplay(NpcProfileResult result, ThemeData theme) {
    final charColor = JuiceTheme.categoryCharacter;
    
    // Build need skew indicator
    String needSkewLabel = '';
    if (result.needSkew == NeedSkew.complex) {
      needSkewLabel = ' @+';
    } else if (result.needSkew == NeedSkew.primitive) {
      needSkewLabel = ' @-';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: charColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: charColor.withValues(alpha: 0.4)),
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
        // Dice display row - labeled dice badges
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            // Personality dice (2 d10s)
            _buildNpcDiceBadge(
              'Pers',
              [result.primaryPersonalityRoll, result.secondaryPersonalityRoll],
              charColor,
              theme,
            ),
            // Need dice (1 or 2 d10s based on skew)
            _buildNpcDiceBadge(
              'Need$needSkewLabel',
              result.needAllRolls ?? [result.needRoll],
              JuiceTheme.mystic,
              theme,
            ),
            // Motive dice + any follow-up rolls
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
            // Color dice
            _buildNpcDiceBadge(
              'Col',
              [result.color.roll],
              JuiceTheme.juiceOrange,
              theme,
            ),
            // Property dice (d10+d6 × 2)
            _buildNpcDiceBadge(
              'Prop',
              null, // Use propFormat instead
              JuiceTheme.rust,
              theme,
              propFormat: '${result.property1.propertyRoll}+${result.property1.intensityRoll}, ${result.property2.propertyRoll}+${result.property2.intensityRoll}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Labeled fields for clarity
        _buildLabeledRow('Personality', result.personalityDisplay, theme),
        const SizedBox(height: 4),
        _buildLabeledRow('Need', result.need, theme),
        const SizedBox(height: 4),
        _buildLabeledRow('Motive', result.motiveDisplay, theme),
        const SizedBox(height: 6),
        // Color with emoji
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
        // Properties
        _buildLabeledRow(
          'Properties',
          '${result.property1.intensityDescription} ${result.property1.property}, ${result.property2.intensityDescription} ${result.property2.property}',
          theme,
        ),
      ],
    );
  }

  /// Helper to build a labeled row for NPC display
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

  Widget _buildComplexNpcDisplay(ComplexNpcResult result, ThemeData theme) {
    final charColor = JuiceTheme.categoryCharacter;
    
    // Build need skew indicator
    String needSkewLabel = '';
    if (result.needSkew == NeedSkew.complex) {
      needSkewLabel = ' @+';
    } else if (result.needSkew == NeedSkew.primitive) {
      needSkewLabel = ' @-';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: charColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: charColor.withValues(alpha: 0.4)),
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
        // Dice display row - labeled dice badges
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            // Personality dice (1 or 2 d10s)
            _buildNpcDiceBadge(
              'Pers',
              result.secondaryPersonalityRoll != null
                  ? [result.primaryPersonalityRoll, result.secondaryPersonalityRoll!]
                  : [result.primaryPersonalityRoll],
              charColor,
              theme,
            ),
            // Need dice (1 or 2 d10s based on skew)
            _buildNpcDiceBadge(
              'Need$needSkewLabel',
              result.needAllRolls,
              JuiceTheme.mystic,
              theme,
            ),
            // Motive dice + any follow-up rolls
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
            // Color dice
            _buildNpcDiceBadge(
              'Col',
              [result.color.roll],
              JuiceTheme.juiceOrange,
              theme,
            ),
            // Property dice (d10+d6 × 2)
            _buildNpcDiceBadge(
              'Prop',
              null, // Use propFormat instead
              JuiceTheme.rust,
              theme,
              propFormat: '${result.property1.propertyRoll}+${result.property1.intensityRoll}, ${result.property2.propertyRoll}+${result.property2.intensityRoll}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Name (if present) as header
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
        // Labeled fields for clarity
        _buildLabeledRow('Personality', result.personalityDisplay, theme),
        const SizedBox(height: 4),
        _buildLabeledRow('Need', result.need, theme),
        const SizedBox(height: 4),
        _buildLabeledRow('Motive', result.motiveDisplay, theme),
        const SizedBox(height: 6),
        // Color with emoji
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
        // Properties
        _buildLabeledRow(
          'Properties',
          '${result.property1.intensityDescription} ${result.property1.property}, ${result.property2.intensityDescription} ${result.property2.property}',
          theme,
        ),
      ],
    );
  }
  
  /// Helper to build a labeled dice badge for NPC displays
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
        color: color.withValues(alpha: 0.12),
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

  Widget _buildPayThePriceDisplay(PayThePriceResult result, ThemeData theme) {
    final color = result.isMajorTwist ? JuiceTheme.danger : JuiceTheme.rust;
    final icon = result.isMajorTwist ? Icons.bolt : Icons.warning_amber;
    final label = result.isMajorTwist ? 'MAJOR PLOT TWIST' : 'PAY THE PRICE';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge with dice roll
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
        // Result text in a styled container
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
                result.isMajorTwist ? Icons.error_outline : Icons.report_problem_outlined,
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

  Widget _buildQuestDisplay(QuestResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quest sentence with styled formatting
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.rust.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.rust.withValues(alpha: 0.25)),
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
              theme: theme,
            ),
            _buildQuestComponentChip(
              roll: result.descriptionRoll,
              subRoll: result.descriptionSubRoll,
              label: result.descriptionExpanded ?? result.description,
              category: result.descriptionExpanded != null ? result.description : null,
              color: JuiceTheme.success,
              theme: theme,
            ),
            _buildQuestComponentChip(
              roll: result.focusRoll,
              subRoll: result.focusSubRoll,
              label: result.focusExpanded ?? result.focus,
              category: result.focusExpanded != null ? result.focus : null,
              color: JuiceTheme.gold,
              theme: theme,
            ),
            _buildQuestComponentChip(
              roll: result.prepositionRoll,
              subRoll: null,
              label: result.preposition,
              category: null,
              color: JuiceTheme.mystic,
              theme: theme,
            ),
            _buildQuestComponentChip(
              roll: result.locationRoll,
              subRoll: result.locationSubRoll,
              label: result.locationExpanded ?? result.location,
              category: result.locationExpanded != null ? result.location : null,
              color: JuiceTheme.rust,
              theme: theme,
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
    required ThemeData theme,
  }) {
    final rollText = subRoll != null ? '$roll→$subRoll' : '$roll';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Roll number(s)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
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

  /// Generic chip used by various display methods (dungeon, etc.)
  Widget _buildQuestChip(String roll, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            roll,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: JuiceTheme.parchment,
            ),
          ),
        ],
      ),
    );
  }

  // ============ DUNGEON DISPLAY METHODS ============

  Widget _buildDungeonEncounterDisplay(DungeonEncounterResult result, ThemeData theme) {
    // Build the encounter type with embedded sub-roll using arrow notation
    final encounterType = result.encounterRoll.result;
    final encounterDice = result.encounterRoll.diceResults;
    
    // Build arrow notation for sub-rolls
    String? subRollText;
    String? subResultText;
    Color? subColor;
    
    if (result.monster != null) {
      subRollText = '${result.monster!.descriptorRoll},${result.monster!.abilityRoll}';
      subResultText = result.monster!.monsterDescription;
      subColor = Colors.red;
    } else if (result.trap != null) {
      subRollText = '${result.trap!.actionRoll},${result.trap!.subjectRoll}';
      subResultText = result.trap!.trapDescription;
      subColor = Colors.orange;
    } else if (result.feature != null) {
      subRollText = '${result.feature!.roll}';
      subResultText = result.feature!.result;
      subColor = Colors.teal;
    } else if (result.naturalHazard != null) {
      subRollText = '${result.naturalHazard!.roll}';
      subResultText = result.naturalHazard!.result;
      subColor = Colors.brown;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main encounter chip
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildQuestChip(
              encounterDice.length > 1 
                ? '${encounterDice[0]},${encounterDice[1]}' 
                : '${encounterDice[0]}',
              encounterType,
              Colors.purple,
              theme,
            ),
            // Show sub-roll with arrow if applicable
            if (subRollText != null && subResultText != null)
              _buildQuestChip(
                '→ $subRollText',
                subResultText,
                subColor ?? Colors.grey,
                theme,
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Full interpretation
        Text(
          result.interpretation ?? encounterType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDungeonNameDisplay(DungeonNameResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Roll breakdown
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildQuestChip('${result.typeRoll}', result.dungeonType, JuiceTheme.info, theme),
            _buildQuestChip('${result.descriptionRoll}', result.descriptionWord, JuiceTheme.mystic, theme),
            _buildQuestChip('${result.subjectRoll}', result.subject, JuiceTheme.categoryWorld, theme),
          ],
        ),
        const SizedBox(height: 4),
        // Full name
        Text(
          result.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDungeonAreaDisplay(DungeonAreaResult result, ThemeData theme) {
    final phaseColor = result.phase == DungeonPhase.entering ? JuiceTheme.gold : JuiceTheme.success;
    final phaseLabel = result.phase == DungeonPhase.entering ? '@-' : '@+';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice and phase indicator
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: phaseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: phaseColor.withOpacity(0.5)),
              ),
              child: Text(
                '${result.roll1},${result.roll2} $phaseLabel → ${result.chosenRoll}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: phaseColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Show embedded passage with arrow notation if present
            if (result.passage != null)
              _buildQuestChip(
                '→ ${result.passage!.diceResults.join(",")}',
                result.passage!.result,
                Colors.teal,
                theme,
              ),
            if (result.isDoubles)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  '🎲 DOUBLES!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Area type (with passage if present)
        Text(
          result.passage != null 
            ? '${result.areaType}: ${result.passage!.result}'
            : result.areaType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (result.phaseChange)
          Text(
            result.phase == DungeonPhase.entering 
              ? 'Switch to Exploring phase!' 
              : '',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.green.shade700,
            ),
          ),
      ],
    );
  }

  Widget _buildFullDungeonAreaDisplay(FullDungeonAreaResult result, ThemeData theme) {
    final area = result.area;
    final condition = result.condition;
    final phaseColor = area.phase == DungeonPhase.entering ? Colors.orange : Colors.green;
    final phaseLabel = area.phase == DungeonPhase.entering ? '@-' : '@+';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Area roll
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: phaseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: phaseColor.withOpacity(0.5)),
              ),
              child: Text(
                '${area.roll1},${area.roll2} $phaseLabel → ${area.chosenRoll}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: phaseColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Embedded passage with arrow notation if present
            if (area.passage != null)
              _buildQuestChip(
                '→ ${area.passage!.diceResults.join(",")}',
                area.passage!.result,
                Colors.teal,
                theme,
              ),
            // Condition roll
            _buildQuestChip(
              condition.diceResults.length > 1 
                ? '${condition.diceResults[0]},${condition.diceResults[1]}' 
                : '${condition.diceResults[0]}',
              condition.result,
              Colors.blueGrey,
              theme,
            ),
            if (area.isDoubles)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  '🎲 DOUBLES!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Full result (with passage if present)
        Text(
          area.passage != null
            ? '${area.areaType}: ${area.passage!.result} (${condition.result})'
            : '${area.areaType} (${condition.result})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (area.phaseChange)
          Text(
            'Switch to Exploring phase!',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.green.shade700,
            ),
          ),
      ],
    );
  }

  Widget _buildTwoPassAreaDisplay(TwoPassAreaResult result, ThemeData theme) {
    final phaseColor = result.hadFirstDoubles ? Colors.orange : Colors.green;
    final phaseLabel = result.hadFirstDoubles ? '@-' : '@+';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phase indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.indigo.withOpacity(0.3)),
          ),
          child: const Text(
            'Two-Pass Map Generation',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
        ),
        // Dice rolls
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: phaseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: phaseColor.withOpacity(0.5)),
              ),
              child: Text(
                '${result.roll1},${result.roll2} $phaseLabel → ${result.chosenRoll}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: phaseColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Condition
            _buildQuestChip(
              result.condition.diceResults.length > 1 
                ? '${result.condition.diceResults[0]},${result.condition.diceResults[1]}' 
                : '${result.condition.diceResults[0]}',
              result.condition.result,
              Colors.blueGrey,
              theme,
            ),
            // Passage if applicable
            if (result.passage != null)
              _buildQuestChip(
                '→ ${result.passage!.diceResults[0]}',
                result.passage!.result,
                Colors.teal,
                theme,
              ),
            // Doubles indicators
            if (result.isSecondDoubles)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  '🛑 2nd DOUBLES - STOP!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              )
            else if (result.isDoubles && !result.hadFirstDoubles)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  '🎲 1st DOUBLES!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Full result
        Text(
          result.interpretation ?? result.areaType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDungeonMonsterDisplay(DungeonMonsterResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildQuestChip('${result.descriptorRoll}', result.descriptor, JuiceTheme.danger, theme),
            _buildQuestChip('${result.abilityRoll}', result.ability, JuiceTheme.rust, theme),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          result.monsterDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDungeonTrapDisplay(DungeonTrapResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildQuestChip('${result.actionRoll}', result.action, JuiceTheme.gold, theme),
            _buildQuestChip('${result.subjectRoll}', result.subject, JuiceTheme.categoryWorld, theme),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          result.trapDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrapProcedureDisplay(TrapProcedureResult result, ThemeData theme) {
    final checkType = result.isSearching ? 'Active (10 min, @+)' : 'Passive';
    final outcomes = result.isSearching 
        ? 'Pass=AVOID, Fail=LOCATE' 
        : 'Pass=LOCATE, Fail=TRIGGER';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trap rolls with arrow to DC
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildQuestChip('${result.trap.actionRoll}', result.trap.action, JuiceTheme.gold, theme),
            _buildQuestChip('${result.trap.subjectRoll}', result.trap.subject, JuiceTheme.categoryWorld, theme),
            _buildQuestChip(
              '→ ${result.dcRolls.join(",")}',
              'DC ${result.dc}',
              JuiceTheme.danger,
              theme,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Trap description
        Text(
          result.trap.trapDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Check procedure
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$checkType: $outcomes',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDungeonDetailDisplay(DungeonDetailResult result, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            result.diceResults.length > 1 
              ? '${result.diceResults[0]},${result.diceResults[1]}' 
              : '${result.diceResults[0]}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            result.result,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============ END DUNGEON DISPLAY METHODS ============

  // ============ EXTENDED NPC CONVERSATION DISPLAY METHODS ============

  Widget _buildInformationDisplay(InformationResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.info.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_books, size: 12, color: JuiceTheme.info),
                  const SizedBox(width: 4),
                  Text(
                    'NPC KNOWLEDGE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: JuiceTheme.info,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dice rolls display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '2d100: [${result.typeRoll}, ${result.topicRoll}]',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Two-part result display
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.info.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information Type (first d100)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.mystic.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${result.typeRoll}',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.mystic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      result.informationType,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Topic (second d100)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${result.topicRoll}',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      result.topic,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.gold,
                      ),
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

  Widget _buildCompanionResponseDisplay(CompanionResponseResult result, ThemeData theme) {
    // Determine favor level color
    Color favorColor;
    IconData favorIcon;
    final roll = result.roll;
    
    if (roll <= 20) {
      favorColor = JuiceTheme.danger;  // Strongly Opposed
      favorIcon = Icons.thumb_down;
    } else if (roll <= 40) {
      favorColor = JuiceTheme.juiceOrange;  // Hesitant
      favorIcon = Icons.thumbs_up_down;
    } else if (roll <= 60) {
      favorColor = JuiceTheme.parchmentDark;  // Neutral
      favorIcon = Icons.help_outline;
    } else if (roll <= 80) {
      favorColor = JuiceTheme.info;  // Cautious Support
      favorIcon = Icons.thumb_up_outlined;
    } else {
      favorColor = JuiceTheme.success;  // Strongly In Favor
      favorIcon = Icons.thumb_up;
    }
    
    // Build skew indicator if present
    String skewLabel = '';
    if (result.skew == SkewType.advantage) {
      skewLabel = '@+ In Favor';
    } else if (result.skew == SkewType.disadvantage) {
      skewLabel = '@- Opposed';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with type badge and dice
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.question_answer, size: 12, color: JuiceTheme.success),
                  const SizedBox(width: 4),
                  Text(
                    'COMPANION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: JuiceTheme.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dice roll with skew
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.allRolls.length > 1
                    ? 'd100$skewLabel: [${result.allRolls.join(", ")}] → ${result.roll}'
                    : '1d100: ${result.roll}',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Favor level indicator
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: favorColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: favorColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(favorIcon, size: 14, color: favorColor),
                  const SizedBox(width: 4),
                  Text(
                    result.favorLevel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: favorColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Response text with speech styling
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.inkDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: favorColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, size: 16, color: favorColor.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  result.response,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
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

  Widget _buildDialogTopicDisplay(DialogTopicResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: JuiceTheme.juiceOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.forum, size: 12, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 4),
                  Text(
                    'DIALOG TOPIC',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: JuiceTheme.juiceOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dice roll
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.juiceOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '1d100: ${result.roll}',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.juiceOrange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Topic result with styled container
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JuiceTheme.juiceOrange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: JuiceTheme.juiceOrange.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.topic,
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

  // ============ END EXTENDED NPC CONVERSATION DISPLAY METHODS ============

  Widget _buildInterruptDisplay(InterruptPlotPointResult result, ThemeData theme) {
    // Get category color
    final categoryColor = _getInterruptCategoryColor(result.category);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chip with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: categoryColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getInterruptCategoryIcon(result.category), size: 14, color: categoryColor),
                  const SizedBox(width: 6),
                  Text(
                    result.category,
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Event name
            Expanded(
              child: Text(
                result.event,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.parchment,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Get color for interrupt category
  Color _getInterruptCategoryColor(String category) {
    switch (category) {
      case 'Action':
        return JuiceTheme.danger;
      case 'Tension':
        return JuiceTheme.juiceOrange;
      case 'Mystery':
        return JuiceTheme.mystic;
      case 'Social':
        return JuiceTheme.info;
      case 'Personal':
        return JuiceTheme.categoryCharacter;
      default:
        return JuiceTheme.parchmentDark;
    }
  }

  /// Get icon for interrupt category
  IconData _getInterruptCategoryIcon(String category) {
    switch (category) {
      case 'Action':
        return Icons.flash_on;
      case 'Tension':
        return Icons.warning_amber;
      case 'Mystery':
        return Icons.help_outline;
      case 'Social':
        return Icons.groups;
      case 'Personal':
        return Icons.person;
      default:
        return Icons.bolt;
    }
  }

  Widget _buildSettlementNameDisplay(SettlementNameResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d10: ${result.prefixRoll}, ${result.suffixRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          result.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEstablishmentNameDisplay(EstablishmentNameResult result, ThemeData theme) {
    return Row(
      children: [
        Text(
          result.colorEmoji,
          style: const TextStyle(fontSize: 18),
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
                '${result.color} + ${result.object}',
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

  Widget _buildSettlementPropertiesDisplay(SettlementPropertiesResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show dice rolls for both properties
        DiceDisplayFormatter.buildMultipleDiceDisplay(
          diceGroups: [
            (label: 'd10+d6', values: [result.property1.propertyRoll, result.property1.intensityRoll]),
            (label: 'd10+d6', values: [result.property2.propertyRoll, result.property2.intensityRoll]),
          ],
          theme: theme,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              label: Text('${result.property1.intensityDescription} ${result.property1.property}'),
              backgroundColor: Colors.teal.withValues(alpha: 0.2),
              side: const BorderSide(color: Colors.teal),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            const Text('+'),
            const SizedBox(width: 8),
            Chip(
              label: Text('${result.property2.intensityDescription} ${result.property2.property}'),
              backgroundColor: Colors.teal.withValues(alpha: 0.2),
              side: const BorderSide(color: Colors.teal),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleNpcDisplay(SimpleNpcResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice rolls for name and profile
        DiceDisplayFormatter.buildMultipleDiceDisplay(
          diceGroups: [
            (label: '${result.name.rolls.length}d10', values: result.name.rolls),
            (label: '3d10', values: [result.profile.personalityRoll, result.profile.needRoll, result.profile.motiveRoll]),
          ],
          theme: theme,
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
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              side: BorderSide(color: Colors.purple.withValues(alpha: 0.3)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              labelStyle: const TextStyle(fontSize: 11),
            ),
            Chip(
              avatar: const Icon(Icons.favorite, size: 14),
              label: Text(result.profile.need),
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              labelStyle: const TextStyle(fontSize: 11),
            ),
            Chip(
              avatar: const Icon(Icons.trending_up, size: 14),
              label: Text(result.profile.motive),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              labelStyle: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullSettlementDisplay(FullSettlementResult result, ThemeData theme) {
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

  Widget _buildCompleteSettlementDisplay(CompleteSettlementResult result, ThemeData theme) {
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
                color: typeColor.withValues(alpha: 0.2),
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

  /// Build a styled property chip for treasure display
  Widget _buildTreasurePropertyChip(String label, String value, int roll, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$roll',
              style: TextStyle(
                fontSize: 9,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get category color for treasure types
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

  /// Get category icon for treasure types
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

  Widget _buildObjectTreasureDisplay(ObjectTreasureResult result, ThemeData theme) {
    final categoryColor = _getTreasureCategoryColor(result.category);
    final categoryIcon = _getTreasureCategoryIcon(result.category);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(categoryIcon, size: 16, color: categoryColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    result.fullDescription,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.parchment,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Property breakdown
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
        
        // Dice summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.inkDark,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '4d6: [${result.rolls.join(", ")}]',
            style: TextStyle(
              fontSize: 10,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  /// Display for full Item Creation procedure results
  Widget _buildItemCreationDisplay(ItemCreationResult result, ThemeData theme) {
    final categoryColor = _getTreasureCategoryColor(result.baseItem.category);
    final categoryIcon = _getTreasureCategoryIcon(result.baseItem.category);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(categoryIcon, size: 16, color: categoryColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.baseItem.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    result.baseItem.fullDescription,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.parchment,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Properties section - the magic happens here
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: JuiceTheme.mystic.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_fix_high, size: 12, color: JuiceTheme.mystic),
                  const SizedBox(width: 4),
                  Text(
                    'Properties',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.mystic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Property 1
              _buildItemPropertyRow(
                result.property1.intensityDescription,
                result.property1.property,
                result.property1.propertyRoll,
                result.property1.intensityRoll,
              ),
              const SizedBox(height: 4),
              // Property 2
              _buildItemPropertyRow(
                result.property2.intensityDescription,
                result.property2.property,
                result.property2.propertyRoll,
                result.property2.intensityRoll,
              ),
            ],
          ),
        ),
        
        // Color if present
        if (result.color != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: JuiceTheme.juiceOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.palette, size: 14, color: JuiceTheme.juiceOrange),
                const SizedBox(width: 6),
                Text(
                  result.color!.result,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.juiceOrange,
                  ),
                ),
                if (result.color!.emoji != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    result.color!.emoji!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        // Dice summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.inkDark,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '4d6: [${result.baseItem.rolls.join(", ")}]  Props: [${result.property1.propertyRoll},${result.property1.intensityRoll}] [${result.property2.propertyRoll},${result.property2.intensityRoll}]${result.color != null ? "  Color: [${result.color!.roll}]" : ""}',
            style: TextStyle(
              fontSize: 9,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  /// Build a property row for item creation display
  Widget _buildItemPropertyRow(String intensity, String property, int propRoll, int intRoll) {
    // Get color based on intensity
    Color intensityColor;
    if (intensity.contains('Major') || intensity.contains('Extreme')) {
      intensityColor = JuiceTheme.success;
    } else if (intensity.contains('Minimal') || intensity.contains('Trace')) {
      intensityColor = JuiceTheme.rust;
    } else {
      intensityColor = JuiceTheme.info;
    }
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: intensityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            intensity,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: intensityColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          property,
          style: TextStyle(
            fontSize: 12,
            fontFamily: JuiceTheme.fontFamilySerif,
            color: JuiceTheme.parchment,
          ),
        ),
        const Spacer(),
        Text(
          '[$propRoll,$intRoll]',
          style: TextStyle(
            fontSize: 9,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ============ CHALLENGE DISPLAY METHODS ============

  Widget _buildFullChallengeDisplay(FullChallengeResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with DC method
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.categoryCombat.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 12, color: JuiceTheme.categoryCombat),
              const SizedBox(width: 4),
              Text(
                'CHALLENGE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: JuiceTheme.categoryCombat,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                result.dcMethod,
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Two-column challenge display
        Row(
          children: [
            // Physical challenge
            Expanded(
              child: _buildChallengePathCard(
                label: 'Physical',
                skill: result.physicalSkill,
                dc: result.physicalDc,
                roll: result.physicalRoll,
                color: JuiceTheme.rust,
                icon: Icons.directions_run,
              ),
            ),
            // OR divider
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 16,
                    color: JuiceTheme.sepia.withOpacity(0.3),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: JuiceTheme.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.gold,
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 16,
                    color: JuiceTheme.sepia.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            // Mental challenge
            Expanded(
              child: _buildChallengePathCard(
                label: 'Mental',
                skill: result.mentalSkill,
                dc: result.mentalDc,
                roll: result.mentalRoll,
                color: JuiceTheme.mystic,
                icon: Icons.psychology,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Helper text
        Text(
          'Choose ONE path to attempt • Fail = Pay The Price',
          style: TextStyle(
            fontSize: 9,
            fontStyle: FontStyle.italic,
            color: JuiceTheme.parchmentDark,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengePathCard({
    required String label,
    required String skill,
    required int dc,
    required int roll,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'd10: $roll',
                  style: TextStyle(
                    fontSize: 7,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Skill name
          Text(
            skill,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: JuiceTheme.parchment,
            ),
          ),
          const SizedBox(height: 4),
          // DC display
          Row(
            children: [
              Text(
                'DC',
                style: TextStyle(
                  fontSize: 10,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$dc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSkillDisplay(ChallengeSkillResult result, ThemeData theme) {
    final isPhysical = result.challengeType == ChallengeType.physical;
    final color = isPhysical ? JuiceTheme.rust : JuiceTheme.mystic;
    final icon = isPhysical ? Icons.directions_run : Icons.psychology;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge with roll
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(
                    result.challengeType.displayText.toUpperCase(),
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
        const SizedBox(height: 8),
        // Skill and DC
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              result.skill,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilySerif,
                color: JuiceTheme.parchment,
              ),
            ),
            const Spacer(),
            Text(
              'DC',
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchmentDark,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${result.suggestedDc}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDcDisplay(DcResult result, ThemeData theme) {
    // Color based on DC difficulty
    Color dcColor;
    String difficulty;
    if (result.dc >= 15) {
      dcColor = JuiceTheme.danger;
      difficulty = 'Hard';
    } else if (result.dc >= 12) {
      dcColor = JuiceTheme.gold;
      difficulty = 'Medium';
    } else {
      dcColor = JuiceTheme.success;
      difficulty = 'Easy';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Method and roll
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.sepia.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.gavel, size: 12, color: JuiceTheme.categoryCombat),
              const SizedBox(width: 4),
              Text(
                result.method,
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Roll: ${result.roll}',
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Big DC display
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'DC',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: JuiceTheme.parchmentDark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${result.dc}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: dcColor,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: dcColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: dcColor.withOpacity(0.3)),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: dcColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDcDisplay(QuickDcResult result, ThemeData theme) {
    // Color based on DC difficulty
    Color dcColor;
    String difficulty;
    if (result.dc >= 15) {
      dcColor = JuiceTheme.danger;
      difficulty = 'Hard';
    } else if (result.dc >= 12) {
      dcColor = JuiceTheme.gold;
      difficulty = 'Medium';
    } else {
      dcColor = JuiceTheme.success;
      difficulty = 'Easy';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.sepia.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.casino, size: 12, color: JuiceTheme.gold),
              const SizedBox(width: 4),
              Text(
                '2d6: ${result.dice.join(" + ")} + 6',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Big DC display
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'DC',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: JuiceTheme.parchmentDark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${result.dc}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: dcColor,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: dcColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: dcColor.withOpacity(0.3)),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: dcColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============ IMMERSION DISPLAY METHODS ============

  Widget _buildSensoryDetailDisplay(SensoryDetailResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '3d10: ${result.senseRoll}, ${result.detailRoll}, ${result.whereRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You ${result.sense.toLowerCase()} something ${result.detail.toLowerCase()} ${result.where.toLowerCase()}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalAtmosphereDisplay(EmotionalAtmosphereResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d10: ${result.emotionRoll}, ${result.causeRoll} + 1dF: ${result.isPositive ? "+" : "−"}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              avatar: Icon(
                result.isPositive ? Icons.add : Icons.remove,
                size: 16,
                color: result.isPositive ? Colors.green : Colors.red,
              ),
              label: Text(result.selectedEmotion),
              backgroundColor: (result.isPositive ? Colors.green : Colors.red).withOpacity(0.1),
              side: BorderSide(color: result.isPositive ? Colors.green : Colors.red),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        Text(
          'because ${result.cause}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFateRollDisplay(FateRollResult result, ThemeData theme) {
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
            color: JuiceTheme.mystic.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.3)),
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
                      color: dieColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: dieColor.withValues(alpha: 0.5)),
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
                resultColor.withValues(alpha: 0.25),
                resultColor.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: resultColor.withValues(alpha: 0.5)),
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

  /// Enhanced display for generic dice rolls (standard, advantage, disadvantage, skewed)
  Widget _buildGenericDiceRollDisplay(RollResult result, ThemeData theme) {
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
                color: themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
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
                        _buildDieValue(entry.value, themeColor, theme),
                        if (!isLast) 
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: themeColor.withValues(alpha: 0.6),
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
                    themeColor.withValues(alpha: 0.25),
                    themeColor.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withValues(alpha: 0.5)),
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
                  color: themeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withValues(alpha: 0.4)),
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
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Discarded: ',
                style: TextStyle(
                  fontSize: 11,
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: JuiceTheme.ink.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '[${discardedRoll.join(', ')}] = $discardedSum',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: JuiceTheme.parchmentDark.withValues(alpha: 0.4),
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
  Widget _buildDieValue(int value, Color color, ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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

  Widget _buildExpectationCheckDisplay(ExpectationCheckResult result, ThemeData theme) {
    // Determine color based on outcome type
    Color outcomeColor;
    if (result.outcome == ExpectationOutcome.expectedIntensified ||
        result.outcome == ExpectationOutcome.expected) {
      outcomeColor = Colors.green;
    } else if (result.outcome == ExpectationOutcome.oppositeIntensified ||
               result.outcome == ExpectationOutcome.opposite) {
      outcomeColor = Colors.red;
    } else if (result.outcome == ExpectationOutcome.favorable) {
      outcomeColor = Colors.lightGreen;
    } else if (result.outcome == ExpectationOutcome.unfavorable) {
      outcomeColor = Colors.orange;
    } else {
      outcomeColor = Colors.amber;
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
            const Spacer(),
            // Outcome chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: outcomeColor.withOpacity(0.2),
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
        // Show auto-rolled meaning if present
        if (result.hasMeaning) ...[  
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  'Modifier + Idea: ${result.meaningResult!.meaning}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScaleDisplay(ScaleResult result, ThemeData theme) {
    // Determine color based on scale direction
    Color scaleColor;
    IconData scaleIcon;
    if (result.isIncrease) {
      scaleColor = JuiceTheme.success;
      scaleIcon = Icons.trending_up;
    } else if (result.isDecrease) {
      scaleColor = JuiceTheme.danger;
      scaleIcon = Icons.trending_down;
    } else {
      scaleColor = JuiceTheme.parchmentDark;
      scaleIcon = Icons.trending_flat;
    }

    return Row(
      children: [
        // Fate dice symbols with label
        FateDiceFormatter.buildLabeledFateDiceDisplay(
          label: '2dF',
          dice: result.fateDice,
          theme: theme,
        ),
        const SizedBox(width: 10),
        // Intensity die (1d6) with label - using JuiceTheme
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
        // Scale result chip with icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scaleColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scaleColor.withOpacity(0.6), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(scaleIcon, size: 16, color: scaleColor),
              const SizedBox(width: 4),
              Text(
                result.modifier,
                style: TextStyle(
                  color: scaleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDisplay(DialogResult result, ThemeData theme) {
    final dialogColor = JuiceTheme.mystic;
    final toneColor = _getToneColor(result.tone);
    
    // Build a conversational prompt based on the result
    String getFragmentPrompt(String fragment) {
      switch (fragment) {
        case 'Fact': return 'states a fact about';
        case 'Query': return 'asks a question about';
        case 'Need': return 'expresses a need regarding';
        case 'Want': return 'expresses a desire about';
        case 'Action': return 'describes an action involving';
        case 'Denial': return 'denies or refuses regarding';
        case 'Support': return 'offers support about';
        default: return 'speaks about';
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll badge - compact
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: dialogColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '2d10: [${result.directionRoll}, ${result.subjectRoll}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            if (result.isDoubles) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.juiceOrange),
                ),
                child: const Text(
                  'DOUBLES!',
                  style: TextStyle(fontSize: 9, color: JuiceTheme.juiceOrange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Main conversational prompt - the key output
        if (!result.isDoubles) ...[
          // "NPC [tone] [fragment prompt] [subject]"
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: JuiceTheme.fontFamilySerif,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'NPC '),
                TextSpan(
                  text: '${result.tone.toLowerCase()} ',
                  style: TextStyle(
                    color: toneColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: getFragmentPrompt(result.newFragment)),
                TextSpan(
                  text: ' ${result.subject}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (result.isPast)
                  TextSpan(
                    text: ' (past)',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.sepia,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Movement indicator - subtle
          Row(
            children: [
              Text(
                result.oldFragment,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _getDirectionArrow(result.direction),
                  style: TextStyle(fontSize: 12, color: toneColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dialogColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.newFragment,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontStyle: result.isPast ? FontStyle.italic : FontStyle.normal,
                    color: dialogColor,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Conversation ended
          Row(
            children: [
              const Icon(Icons.stop_circle, size: 16, color: JuiceTheme.juiceOrange),
              const SizedBox(width: 6),
              Text(
                'Conversation has ended',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: JuiceTheme.juiceOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getDirectionArrow(String direction) {
    switch (direction) {
      case 'up': return '↑';
      case 'down': return '↓';
      case 'left': return '←';
      case 'right': return '→';
      default: return '·';
    }
  }

  Color _getToneColor(String tone) {
    switch (tone) {
      case 'Neutral': return JuiceTheme.info;
      case 'Defensive': return JuiceTheme.rust;
      case 'Aggressive': return JuiceTheme.danger;
      case 'Helpful': return JuiceTheme.success;
      default: return Colors.grey;
    }
  }

  Widget _buildFullImmersionDisplay(FullImmersionResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sensory dice display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '3d10: ${result.sensory.senseRoll}, ${result.sensory.detailRoll}, ${result.sensory.whereRoll} + 2d10: ${result.emotional.emotionRoll}, ${result.emotional.causeRoll} + 1dF',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You ${result.sensory.sense.toLowerCase()} something ${result.sensory.detail.toLowerCase()} ${result.sensory.where.toLowerCase()}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              result.emotional.isPositive ? Icons.add : Icons.remove,
              size: 16,
              color: result.emotional.isPositive ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              'It causes ${result.emotional.selectedEmotion.toLowerCase()}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          'because ${result.emotional.cause}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyResultDisplay(PropertyResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1d10: ${result.propertyRoll}, 1d6: ${result.intensityRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              label: Text(result.property),
              backgroundColor: Colors.pink.withOpacity(0.2),
              side: const BorderSide(color: Colors.pink),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text(
              result.intensityDescription,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailResultDisplay(DetailResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result.secondRoll != null
                ? '1d10@: ${result.roll}, ${result.secondRoll}'
                : '1d10: ${result.roll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (result.emoji != null) ...[
              Text(result.emoji!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
            ],
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

  Widget _buildDetailWithFollowUpDisplay(DetailWithFollowUpResult result, ThemeData theme) {
    // Build dice display for main detail
    final mainDiceLabel = result.detailResult.secondRoll != null ? '2d10' : 'd10';
    final mainDiceValues = result.detailResult.secondRoll != null
        ? '[${result.detailResult.roll}, ${result.detailResult.secondRoll}]'
        : '${result.detailResult.roll}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll for main detail
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$mainDiceLabel: $mainDiceValues',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Main detail result
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink.withValues(alpha: 0.4)),
              ),
              child: Text(
                result.detailResult.result,
                style: TextStyle(
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (result.hasFollowUp) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade600),
            ],
          ],
        ),
        // Follow-up result (History or Property)
        if (result.historyResult != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'd10: ${result.historyResult!.roll}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.history, size: 16, color: Colors.purple.shade600),
                const SizedBox(width: 6),
                Text(
                  result.historyResult!.result,
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.propertyResult != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'd10+d6: [${result.propertyResult!.propertyRoll}, ${result.propertyResult!.intensityRoll}]',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.tune, size: 16, color: Colors.teal.shade600),
                const SizedBox(width: 6),
                Text(
                  '${result.propertyResult!.property} (${result.propertyResult!.intensityDescription})',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWildernessAreaDisplay(WildernessAreaResult result, ThemeData theme) {
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
              color: JuiceTheme.juiceOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.4)),
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
              color: exploreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: exploreColor.withValues(alpha: 0.4)),
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
            color: exploreColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: exploreColor.withValues(alpha: 0.4)),
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
                color: exploreColor.withValues(alpha: 0.1),
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
                color: JuiceTheme.info.withValues(alpha: 0.1),
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
                  color: JuiceTheme.sepia.withValues(alpha: 0.1),
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
                    color: exploreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: exploreColor.withValues(alpha: 0.5)),
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
              color: exploreColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: exploreColor.withValues(alpha: 0.5)),
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

  Widget _buildWildernessEncounterDisplay(WildernessEncounterResult result, ThemeData theme) {
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
                color: exploreColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: exploreColor.withValues(alpha: 0.4)),
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
                color: JuiceTheme.parchment.withValues(alpha: 0.5),
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
                  color: JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.5)),
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
                color: encounterColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: encounterColor.withValues(alpha: 0.5)),
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
                  color: JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.5)),
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
                  color: JuiceTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.success.withValues(alpha: 0.5)),
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
                    color: _getFollowUpThemeColor(result.encounter).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getFollowUpThemeColor(result.encounter).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: JuiceTheme.parchment.withValues(alpha: 0.5),
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
                            color: JuiceTheme.categoryCombat.withValues(alpha: 0.2),
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
              Icon(Icons.subdirectory_arrow_right, size: 14, color: JuiceTheme.sepia.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(
                _getFollowUpHint(result.encounter),
                style: TextStyle(
                  color: JuiceTheme.sepia.withValues(alpha: 0.7),
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

  Widget _buildWildernessWeatherDisplay(WildernessWeatherResult result, ThemeData theme) {
    final exploreColor = JuiceTheme.categoryExplore;
    
    // Determine weather icon and color
    IconData weatherIcon;
    Color weatherColor;
    
    switch (result.weather) {
      case 'Blizzard':
        weatherIcon = Icons.ac_unit;
        weatherColor = const Color(0xFF64B5F6); // light blue
        break;
      case 'Snow Flurries':
        weatherIcon = Icons.cloudy_snowing;
        weatherColor = const Color(0xFF90CAF9); // lighter blue
        break;
      case 'Freezing Cold':
        weatherIcon = Icons.severe_cold;
        weatherColor = JuiceTheme.info;
        break;
      case 'Thunder Storm':
        weatherIcon = Icons.thunderstorm;
        weatherColor = JuiceTheme.mystic;
        break;
      case 'Heavy Rain':
        weatherIcon = Icons.water_drop;
        weatherColor = JuiceTheme.info;
        break;
      case 'Light Rain':
        weatherIcon = Icons.grain;
        weatherColor = JuiceTheme.sepia;
        break;
      case 'Heavy Clouds':
        weatherIcon = Icons.cloud;
        weatherColor = JuiceTheme.sepia;
        break;
      case 'High Winds':
        weatherIcon = Icons.air;
        weatherColor = JuiceTheme.mystic;
        break;
      case 'Clear Skies':
        weatherIcon = Icons.wb_sunny;
        weatherColor = JuiceTheme.gold;
        break;
      case 'Scorching Heat':
        weatherIcon = Icons.local_fire_department;
        weatherColor = JuiceTheme.danger;
        break;
      default:
        weatherIcon = Icons.cloud;
        weatherColor = JuiceTheme.sepia;
    }

    // Determine dice label based on whether there was a second roll (advantage/disadvantage)
    final diceLabel = result.secondRoll != null ? '2d6' : '1d6';
    final diceDisplay = result.secondRoll != null
        ? '[${result.baseRoll}, ${result.secondRoll}]'
        : '${result.baseRoll}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: exploreColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: exploreColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud, size: 12, color: exploreColor),
                  const SizedBox(width: 4),
                  Text(
                    'WEATHER',
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
                color: JuiceTheme.parchment.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$diceLabel: $diceDisplay',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: FontWeight.bold,
                ),
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
                color: JuiceTheme.sepia.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.landscape, size: 12, color: JuiceTheme.sepia),
                  const SizedBox(width: 4),
                  Text(
                    '${result.typeName} ${result.environment}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.sepia,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                result.formula,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Weather result
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: weatherColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: weatherColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(weatherIcon, color: weatherColor, size: 22),
              const SizedBox(width: 8),
              Text(
                result.weather,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: weatherColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullMonsterEncounterDisplay(FullMonsterEncounterResult result, ThemeData theme) {
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
                color: combatColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: combatColor.withValues(alpha: 0.4)),
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
                  color: JuiceTheme.categoryExplore.withValues(alpha: 0.15),
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
                  color: difficultyColor.withValues(alpha: 0.15),
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
                color: JuiceTheme.categoryExplore.withValues(alpha: 0.1),
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
                color: JuiceTheme.info.withValues(alpha: 0.1),
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
                  color: JuiceTheme.categoryExplore.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.categoryExplore.withValues(alpha: 0.4)),
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
                color: difficultyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: difficultyColor.withValues(alpha: 0.5)),
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
                  color: JuiceTheme.mystic.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
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
            color: combatColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: combatColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.hasBoss && result.bossMonster != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: JuiceTheme.mystic.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
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
                    Icon(Icons.pest_control, size: 12, color: combatColor.withValues(alpha: 0.6)),
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

  Widget _buildMonsterEncounterDisplay(MonsterEncounterResult result, ThemeData theme) {
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
                color: combatColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: combatColor.withValues(alpha: 0.4)),
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
                  color: JuiceTheme.parchment.withValues(alpha: 0.5),
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
                color: difficultyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: difficultyColor.withValues(alpha: 0.5)),
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
                  color: JuiceTheme.mystic.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.4)),
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
                  color: JuiceTheme.danger.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.4)),
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
            color: combatColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: combatColor.withValues(alpha: 0.3)),
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

  Widget _buildMonsterTracksDisplay(MonsterTracksResult result, ThemeData theme) {
    final combatColor = JuiceTheme.categoryCombat;
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
                color: trackColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: trackColor.withValues(alpha: 0.4)),
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
                  color: JuiceTheme.parchment.withValues(alpha: 0.5),
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
                color: JuiceTheme.info.withValues(alpha: 0.1),
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
            color: trackColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: trackColor.withValues(alpha: 0.3)),
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

  Widget _buildLocationDisplay(LocationResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'd100: ${result.roll}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cell [${result.row},${result.column}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Direction and distance result
        Row(
          children: [
            Icon(
              _getDirectionIcon(result.direction),
              color: _getDistanceColor(result.distance),
              size: 24,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDistanceColor(result.distance).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getDistanceColor(result.distance).withValues(alpha: 0.5)),
              ),
              child: Text(
                result.compassDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getDistanceColor(result.distance),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Visual grid map
        _buildLocationGrid(result, theme),
      ],
    );
  }

  Widget _buildLocationGrid(LocationResult result, ThemeData theme) {
    const cellSize = 18.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // North label
        const Text(
          'N',
          style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // West label
            const SizedBox(
              width: 12,
              child: Text(
                'W',
                style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            // Grid
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: List.generate(5, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (col) {
                      final isSelected = (row + 1) == result.row && (col + 1) == result.column;
                      final ring = Location.distanceRings[row][col];
                      
                      Color bgColor;
                      if (isSelected) {
                        bgColor = Colors.amber.withValues(alpha: 0.9);
                      } else {
                        // Ring-based coloring (bullseye pattern)
                        switch (ring) {
                          case 0: // Center
                            bgColor = Colors.green.withValues(alpha: 0.3);
                            break;
                          case 1: // Close
                            bgColor = Colors.blue.withValues(alpha: 0.15);
                            break;
                          default: // Far
                            bgColor = Colors.grey.withValues(alpha: 0.08);
                        }
                      }
                      
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border(
                            right: col < 4 ? BorderSide(color: Colors.grey.shade300, width: 0.5) : BorderSide.none,
                            bottom: row < 4 ? BorderSide(color: Colors.grey.shade300, width: 0.5) : BorderSide.none,
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
            // East label
            const SizedBox(
              width: 12,
              child: Text(
                'E',
                style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        // South label
        const Text(
          'S',
          style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  IconData _getDirectionIcon(CompassDirection direction) {
    switch (direction) {
      case CompassDirection.north:
        return Icons.north;
      case CompassDirection.northEast:
        return Icons.north_east;
      case CompassDirection.east:
        return Icons.east;
      case CompassDirection.southEast:
        return Icons.south_east;
      case CompassDirection.south:
        return Icons.south;
      case CompassDirection.southWest:
        return Icons.south_west;
      case CompassDirection.west:
        return Icons.west;
      case CompassDirection.northWest:
        return Icons.north_west;
      case CompassDirection.center:
        return Icons.my_location;
    }
  }

  Color _getDistanceColor(LocationDistance distance) {
    switch (distance) {
      case LocationDistance.center:
        return Colors.green;
      case LocationDistance.close:
        return Colors.blue;
      case LocationDistance.far:
        return Colors.brown;
    }
  }

  Widget _buildAbstractIconDisplay(AbstractIconResult result, ThemeData theme) {
    // Themed colors matching the Abstract Icons dialog
    const iconColor = JuiceTheme.success;
    const gridColor = JuiceTheme.mystic;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice rolls and grid position
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Row die (1d10)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JuiceTheme.rust.withValues(alpha: 0.2),
                    JuiceTheme.rust.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: JuiceTheme.rust.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 12,
                    color: JuiceTheme.rust.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Row ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.rust.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${result.d10Roll}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.rust,
                    ),
                  ),
                ],
              ),
            ),
            // Column die (1d6)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JuiceTheme.info.withValues(alpha: 0.2),
                    JuiceTheme.info.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: JuiceTheme.info.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: JuiceTheme.info.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Col ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: JuiceTheme.info.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${result.d6Roll}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.info,
                    ),
                  ),
                ],
              ),
            ),
            // Grid cell indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: gridColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: gridColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_on,
                    size: 14,
                    color: gridColor.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '[${result.rowLabel}, ${result.colLabel}]',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: FontWeight.w600,
                      color: gridColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Display the icon image with enhanced styling
        Center(
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.6),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  result.imagePath!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: JuiceTheme.parchment,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.description,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Dice: ${result.diceResults.join(', ')}'),
            Text('Total: ${result.total}'),
            if (result.interpretation != null)
              Text('Result: ${result.interpretation}'),
            const SizedBox(height: 16),
            Text(
              'Rolled at ${_formatFullTime(result.timestamp)}',
              style: const TextStyle(color: Colors.grey),
            ),
            // Show "Set as Current Position" for wilderness results
            if (result is WildernessAreaResult && onSetWildernessPosition != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final wilderness = result as WildernessAreaResult;
                    onSetWildernessPosition!(wilderness.envRoll, wilderness.typeRoll);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📍 Set position: ${wilderness.interpretation}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Set as Current Position'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatFullTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

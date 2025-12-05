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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(result.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
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
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (result.type) {
      case RollType.fateCheck:
        icon = Icons.help_outline;
        color = Colors.purple;
        break;
      case RollType.nextScene:
        icon = Icons.theaters;
        color = Colors.blue;
        break;
      case RollType.randomEvent:
        icon = Icons.flash_on;
        color = Colors.amber;
        break;
      case RollType.discoverMeaning:
        icon = Icons.lightbulb_outline;
        color = Colors.orange;
        break;
      case RollType.npcAction:
        icon = Icons.person;
        color = Colors.teal;
        break;
      case RollType.payThePrice:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case RollType.quest:
        icon = Icons.map;
        color = Colors.brown;
        break;
      case RollType.interruptPlotPoint:
        icon = Icons.bolt;
        color = Colors.deepPurple;
        break;
      case RollType.weather:
        icon = Icons.wb_sunny;
        color = Colors.cyan;
        break;
      case RollType.encounter:
        icon = Icons.explore;
        color = Colors.green;
        break;
      case RollType.settlement:
        icon = Icons.location_city;
        color = Colors.blueGrey;
        break;
      case RollType.objectTreasure:
        icon = Icons.diamond;
        color = Colors.amber;
        break;
      case RollType.challenge:
        icon = Icons.fitness_center;
        color = Colors.indigo;
        break;
      case RollType.details:
        icon = Icons.palette;
        color = Colors.pink;
        break;
      case RollType.immersion:
        icon = Icons.visibility;
        color = Colors.deepOrange;
        break;
      case RollType.location:
        icon = Icons.grid_on;
        color = Colors.brown;
        break;
      case RollType.abstractIcons:
        icon = Icons.image;
        color = Colors.lime;
        break;
      case RollType.fate:
        icon = Icons.auto_awesome;
        color = Colors.indigo;
        break;
      case RollType.dialog:
        icon = Icons.chat;
        color = Colors.pink;
        break;
      default:
        icon = Icons.casino;
        color = Colors.red;
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
    } else if (result is ObjectTreasureResult) {
      return _buildObjectTreasureDisplay(result as ObjectTreasureResult, theme);
    } else if (result is ChallengeSkillResult) {
      return _buildChallengeSkillDisplay(result as ChallengeSkillResult, theme);
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
    } else if (result is LocationResult) {
      return _buildLocationDisplay(result as LocationResult, theme);
    } else if (result is AbstractIconResult) {
      return _buildAbstractIconDisplay(result as AbstractIconResult, theme);
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
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Text(
                '1d6: ${result.intensity}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            const Spacer(),
            // Outcome chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                result.outcome.displayText,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
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
                  ? Colors.amber.withValues(alpha: 0.2)
                  : Colors.deepPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: result.specialTrigger == SpecialTrigger.randomEvent
                    ? Colors.amber
                    : Colors.deepPurple,
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
                      ? Colors.amber
                      : Colors.deepPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  result.specialTrigger!.displayText,
                  style: TextStyle(
                    color: result.specialTrigger == SpecialTrigger.randomEvent
                        ? Colors.amber.shade800
                        : Colors.deepPurple,
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
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus: ${result.randomEventResult!.focus}',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${result.randomEventResult!.modifier} ${result.randomEventResult!.idea}',
                  style: TextStyle(
                    color: Colors.amber.shade900,
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
            color: Colors.grey,
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
        chipColor = Colors.green;
        break;
      case SceneType.alterAdd:
      case SceneType.alterRemove:
        chipColor = Colors.amber;
        break;
      case SceneType.interruptFavorable:
        chipColor = Colors.blue;
        break;
      case SceneType.interruptUnfavorable:
        chipColor = Colors.red;
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
              label: Text(result.sceneType.displayText),
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
              color: Colors.grey,
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
        chipColor = Colors.green;
        break;
      case SceneType.alterAdd:
      case SceneType.alterRemove:
        chipColor = Colors.amber;
        break;
      case SceneType.interruptFavorable:
        chipColor = Colors.blue;
        break;
      case SceneType.interruptUnfavorable:
        chipColor = Colors.red;
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
              label: Text(sceneResult.sceneType.displayText),
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
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'd10: ${result.focusResult!.roll}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Focus: ',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Chip(
                label: Text(result.focusResult!.focus),
                backgroundColor: Colors.teal.withOpacity(0.2),
                side: const BorderSide(color: Colors.teal),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d20: ${result.adjectiveRoll}, ${result.nounRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          result.meaning,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.orange,
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice rolls display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '3d10: ${result.personalityRoll}, ${result.needRoll}, ${result.motiveRoll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          result.personality,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Needs ${result.need}, motivated by ${result.motive}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPayThePriceDisplay(PayThePriceResult result, ThemeData theme) {
    final color = result.isMajorTwist ? Colors.red : Colors.orange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1d10: ${result.roll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (result.isMajorTwist)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: const Text(
              '⚠️ MAJOR PLOT TWIST',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        Text(
          result.result,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestDisplay(QuestResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main quest sentence
        Text(
          result.questSentence,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        // Roll breakdown
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildQuestChip('${result.objectiveRoll}', result.objective, Colors.blue, theme),
            _buildQuestChip(
              result.descriptionSubRoll != null 
                ? '${result.descriptionRoll}→${result.descriptionSubRoll}' 
                : '${result.descriptionRoll}',
              result.descriptionDisplay,
              Colors.green,
              theme,
            ),
            _buildQuestChip(
              result.focusSubRoll != null 
                ? '${result.focusRoll}→${result.focusSubRoll}' 
                : '${result.focusRoll}',
              result.focusDisplay,
              Colors.orange,
              theme,
            ),
            _buildQuestChip('${result.prepositionRoll}', result.preposition, Colors.purple, theme),
            _buildQuestChip(
              result.locationSubRoll != null 
                ? '${result.locationRoll}→${result.locationSubRoll}' 
                : '${result.locationRoll}',
              result.locationDisplay,
              Colors.red,
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestChip(String roll, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
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
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildInterruptDisplay(InterruptPlotPointResult result, ThemeData theme) {
    return Row(
      children: [
        Chip(
          label: Text(result.category),
          backgroundColor: Colors.deepPurple.withOpacity(0.2),
          side: const BorderSide(color: Colors.deepPurple),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            result.event,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
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

  Widget _buildObjectTreasureDisplay(ObjectTreasureResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '4d6: ${result.rolls.join(", ")}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Chip(
          label: Text(result.category),
          backgroundColor: Colors.amber.withOpacity(0.2),
          side: const BorderSide(color: Colors.amber),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        Text(
          result.fullDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeSkillDisplay(ChallengeSkillResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1d10: ${result.roll}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              label: Text(result.challengeType.displayText),
              backgroundColor: Colors.indigo.withOpacity(0.2),
              side: const BorderSide(color: Colors.indigo),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text(
              '${result.skill} (DC ${result.suggestedDc})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDcDisplay(QuickDcResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '2d6: ${result.dice.join(", ")} + 6',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'DC',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${result.dc}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

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
    return Row(
      children: [
        // Fate dice symbols in styled container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result.symbols,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '= ${result.total >= 0 ? '+' : ''}${result.total}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: result.total > 0
                ? Colors.green
                : result.total < 0
                    ? Colors.red
                    : Colors.grey,
          ),
        ),
      ],
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
    if (result.isIncrease) {
      scaleColor = Colors.green;
    } else if (result.isDecrease) {
      scaleColor = Colors.red;
    } else {
      scaleColor = Colors.grey;
    }

    return Row(
      children: [
        // Fate dice symbols with label
        FateDiceFormatter.buildLabeledFateDiceDisplay(
          label: '2dF',
          dice: result.fateDice,
          theme: theme,
        ),
        const SizedBox(width: 12),
        // Intensity die (1d6) with label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Text(
            '1d6: ${result.intensity}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
        const Spacer(),
        // Scale result chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: scaleColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scaleColor),
          ),
          child: Text(
            result.modifier,
            style: TextStyle(
              color: scaleColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDisplay(DialogResult result, ThemeData theme) {
    final toneColor = _getToneColor(result.tone);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '2d10: ${result.directionRoll}, ${result.subjectRoll}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (result.isDoubles) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'DOUBLES',
                  style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Movement and fragment
        Row(
          children: [
            if (!result.isDoubles) ...[
              // Direction arrow
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: toneColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getDirectionArrow(result.direction),
                  style: TextStyle(fontSize: 16, color: toneColor),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Fragment chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: result.isDoubles 
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result.isDoubles ? Colors.orange : Colors.cyan,
                ),
              ),
              child: Text(
                result.newFragment,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: result.isPast ? FontStyle.italic : FontStyle.normal,
                  color: result.isDoubles ? Colors.orange : Colors.cyan,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Past/Present indicator
            Text(
              result.isPast ? '(Past)' : '(Present)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Tone and Subject
        Wrap(
          spacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: toneColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: toneColor.withOpacity(0.5)),
              ),
              child: Text(
                result.tone,
                style: TextStyle(fontSize: 11, color: toneColor, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'about ${result.subject}',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        // Conversation ended notice
        if (result.isDoubles) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.stop_circle_outlined, size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text(
                'Conversation has ended',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
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
      case 'Neutral': return Colors.grey;
      case 'Defensive': return Colors.blue;
      case 'Aggressive': return Colors.red;
      case 'Helpful': return Colors.green;
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
    // For manual set, show a simpler display
    if (result.isManualSet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Position Set',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                ),
                child: Text(
                  result.fullDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final fateSymbols = FateDiceFormatter.diceToSymbols(result.envFateDice);
    final typeSymbol = FateDiceFormatter.dieToSymbol(result.typeFateDie);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Fate dice for environment
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '2dF: $fateSymbols',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '1dF: $typeSymbol',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (result.isTransition && result.previousEnvironment != null) ...[
              Text(
                result.previousEnvironment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
              ),
              child: Text(
                result.fullDescription,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWildernessEncounterDisplay(WildernessEncounterResult result, ThemeData theme) {
    Color encounterColor = Colors.green;
    if (result.encounter == 'Natural Hazard' || result.encounter == 'Monster') {
      encounterColor = Colors.red;
    } else if (result.encounter == 'Destination/Lost') {
      encounterColor = result.becameLost ? Colors.orange : Colors.blue;
    } else if (result.encounter == 'River/Road') {
      encounterColor = result.becameFound ? Colors.blue : Colors.teal;
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
                color: encounterColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text: '/${result.encounter.split('/').last}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
          color: encounterColor,
          fontStyle: result.isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'd${result.dieSize}${result.skewUsed != 'straight' ? '@${result.skewUsed[0]}' : ''}: ${result.roll}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            if (result.wasLost) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LOST',
                  style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: encounterColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: encounterColor.withValues(alpha: 0.5)),
              ),
              child: encounterText,
            ),
            if (result.becameLost) ...[
              const SizedBox(width: 8),
              const Chip(
                label: Text('Now Lost!', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.orange,
                visualDensity: VisualDensity.compact,
              ),
            ],
            if (result.becameFound) ...[
              const SizedBox(width: 8),
              const Chip(
                label: Text('Found!', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.blue,
                visualDensity: VisualDensity.compact,
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
              Text(
                '→',
                style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getFollowUpColor(result.encounter).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getFollowUpColor(result.encounter).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'd10: ${result.followUpRoll}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.followUpResult!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (result.followUpData != null && result.encounter == 'Monster' && result.followUpData!['hasBoss'] == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Boss: ${result.followUpData!['bossMonster']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
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
              Text(
                '→',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                _getFollowUpHint(result.encounter),
                style: TextStyle(
                  color: Colors.grey[500],
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

  Color _getFollowUpColor(String encounter) {
    switch (encounter) {
      case 'Monster':
        return Colors.red;
      case 'Natural Hazard':
        return Colors.orange;
      case 'Weather':
        return Colors.blue;
      case 'Challenge':
        return Colors.purple;
      case 'Dungeon':
        return Colors.brown;
      case 'Feature':
        return Colors.teal;
      default:
        return Colors.grey;
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
    // Determine weather icon and color
    IconData weatherIcon;
    Color weatherColor;
    
    switch (result.weather) {
      case 'Blizzard':
        weatherIcon = Icons.ac_unit;
        weatherColor = Colors.lightBlue.shade300;
        break;
      case 'Snow Flurries':
        weatherIcon = Icons.cloudy_snowing;
        weatherColor = Colors.lightBlue.shade200;
        break;
      case 'Freezing Cold':
        weatherIcon = Icons.severe_cold;
        weatherColor = Colors.blue.shade300;
        break;
      case 'Thunder Storm':
        weatherIcon = Icons.thunderstorm;
        weatherColor = Colors.purple;
        break;
      case 'Heavy Rain':
        weatherIcon = Icons.water_drop;
        weatherColor = Colors.blue;
        break;
      case 'Light Rain':
        weatherIcon = Icons.grain;
        weatherColor = Colors.blueGrey;
        break;
      case 'Heavy Clouds':
        weatherIcon = Icons.cloud;
        weatherColor = Colors.grey;
        break;
      case 'High Winds':
        weatherIcon = Icons.air;
        weatherColor = Colors.teal;
        break;
      case 'Clear Skies':
        weatherIcon = Icons.wb_sunny;
        weatherColor = Colors.amber;
        break;
      case 'Scorching Heat':
        weatherIcon = Icons.local_fire_department;
        weatherColor = Colors.red;
        break;
      default:
        weatherIcon = Icons.cloud;
        weatherColor = Colors.grey;
    }

    // Determine dice label based on whether there was a second roll (advantage/disadvantage)
    final diceLabel = result.secondRoll != null ? '2d6' : '1d6';
    final diceDisplay = result.secondRoll != null
        ? '[${result.baseRoll}, ${result.secondRoll}]'
        : '${result.baseRoll}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$diceLabel: $diceDisplay',
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
                '${result.typeName} ${result.environment}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.formula,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(weatherIcon, color: weatherColor, size: 28),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: weatherColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: weatherColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                result.weather,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: weatherColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullMonsterEncounterDisplay(FullMonsterEncounterResult result, ThemeData theme) {
    final difficultyColor = switch (result.difficulty) {
      MonsterDifficulty.easy => Colors.green,
      MonsterDifficulty.medium => Colors.orange,
      MonsterDifficulty.hard => Colors.red,
      MonsterDifficulty.boss => Colors.purple,
    };

    // Determine dice display based on advantage type
    final diceLabel = result.diceResults.length > 1 ? '2d6' : '1d6';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dice roll with environment and formula info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$diceLabel: [${result.diceResults.join(", ")}]',
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                MonsterEncounter.environmentNames[(result.environmentRow - 1).clamp(0, 9)],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.environmentFormula,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (result.isForest && result.row == 10) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'FOREST→BLIGHTS',
                  style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: difficultyColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                MonsterEncounter.difficultyName(result.difficulty),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: difficultyColor,
                ),
              ),
            ),
            if (result.wasDoubles) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DOUBLES!',
                  style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Monster list
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.hasBoss && result.bossMonster != null) ...[
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text(
                      '1× ${result.bossMonster} (Boss)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                if (result.monsters.any((m) => m.count > 0))
                  const SizedBox(height: 4),
              ],
              ...result.monsters.where((m) => m.count > 0).map((monster) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${monster.count}× ${monster.name}',
                  style: theme.textTheme.bodyMedium,
                ),
              )),
              if (result.monsters.every((m) => m.count == 0) && !result.hasBoss)
                Text(
                  'No monsters appeared (all rolled 0)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.lime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '1d10: ${result.d10Roll}, 1d6: ${result.d6Roll}',
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
                'Cell [${result.rowLabel}, ${result.colLabel}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Display the icon image
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.lime.withValues(alpha: 0.5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                result.imagePath!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  );
                },
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

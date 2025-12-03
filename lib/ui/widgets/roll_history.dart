import 'package:flutter/material.dart';
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
            // Fate dice symbols
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.fateSymbols,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Intensity die
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on, size: 14, color: Colors.purple),
                  const SizedBox(width: 4),
                  Text(
                    '${result.intensity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
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
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.deepPurple.withOpacity(0.2),
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
            // Fate dice symbols
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.fateSymbols,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
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

  Widget _buildRandomEventDisplay(RandomEventResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    return Chip(
      label: Text(result.focus),
      backgroundColor: Colors.amber.withOpacity(0.2),
      side: const BorderSide(color: Colors.amber),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildIdeaDisplay(IdeaResult result, ThemeData theme) {
    return Text(
      '${result.modifier} ${result.idea}',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildDiscoverMeaningDisplay(DiscoverMeaningResult result, ThemeData theme) {
    return Text(
      result.meaning,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildNpcActionDisplay(NpcActionResult result, ThemeData theme) {
    return Row(
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
    );
  }

  Widget _buildNpcProfileDisplay(NpcProfileResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    return Text(
      result.questSentence,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
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
    return Text(
      result.name,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
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
    return Row(
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
    );
  }

  Widget _buildQuickDcDisplay(QuickDcResult result, ThemeData theme) {
    return Row(
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
    );
  }

  Widget _buildSensoryDetailDisplay(SensoryDetailResult result, ThemeData theme) {
    return Text(
      'You ${result.sense.toLowerCase()} something ${result.detail.toLowerCase()}',
      style: theme.textTheme.titleMedium?.copyWith(
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildEmotionalAtmosphereDisplay(EmotionalAtmosphereResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              result.where,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
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
        Text(
          '[${result.symbols}]',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _buildDialogDisplay(DialogResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(result.direction),
              backgroundColor: _getDirectionColor(result.direction).withOpacity(0.2),
              side: BorderSide(color: _getDirectionColor(result.direction)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(result.tone),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          result.subject,
          style: theme.textTheme.bodyMedium,
        ),
        if (result.isDoubles)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '⚡ Conversation ends',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Color _getDirectionColor(String direction) {
    switch (direction) {
      case 'Helpful (Me)':
        return Colors.green;
      case 'Aggressive (Us)':
        return Colors.red;
      case 'Neutral (Us)':
        return Colors.grey;
      case 'Passive (Them)':
        return Colors.blue;
      case 'Evasive (Them)':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFullImmersionDisplay(FullImmersionResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You ${result.sensory.sense.toLowerCase()} something ${result.sensory.detail.toLowerCase()}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${result.emotional.where}: ${result.emotional.negativeEmotion} ↔ ${result.emotional.positiveEmotion}',
          style: theme.textTheme.bodyMedium,
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
    return Row(
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
    );
  }

  Widget _buildDetailResultDisplay(DetailResult result, ThemeData theme) {
    return Row(
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

    final fateSymbols = result.envFateDice.map((f) {
      switch (f) {
        case -1: return '−';
        case 1: return '+';
        default: return '○';
      }
    }).join('');
    final typeSymbol = switch (result.typeFateDie) {
      -1 => '−',
      1 => '+',
      _ => '○',
    };

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
              child: Text(
                result.encounter,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: encounterColor,
                ),
              ),
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
            if (result.requiresFollowUp) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
            ],
          ],
        ),
      ],
    );
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

import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/fate_check.dart';
import '../../presets/next_scene.dart';
import '../../presets/random_event.dart';
import '../../presets/exploration.dart';
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

/// Scrollable roll history widget.
class RollHistory extends StatelessWidget {
  final List<RollResult> history;

  const RollHistory({super.key, required this.history});

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
        );
      },
    );
  }
}

class _RollHistoryCard extends StatelessWidget {
  final RollResult result;
  final int index;

  const _RollHistoryCard({super.key, required this.result, required this.index});

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
    } else if (result is WeatherResult) {
      return _buildWeatherDisplay(result as WeatherResult, theme);
    } else if (result is EncounterResult) {
      return _buildEncounterDisplay(result as EncounterResult, theme);
    } else if (result is SettlementNameResult) {
      return _buildSettlementNameDisplay(result as SettlementNameResult, theme);
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
          const Spacer(),
          Flexible(
            child: Chip(
              label: Text(
                result.interpretation!,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
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
        Text(
          result.where,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${result.negativeEmotion} ↔ ${result.positiveEmotion}',
          style: theme.textTheme.bodyMedium,
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

  Widget _buildWeatherDisplay(WeatherResult result, ThemeData theme) {
    return Row(
      children: [
        _getWeatherIcon(result.weather),
        const SizedBox(width: 8),
        Chip(
          label: Text(result.weather.displayText),
          backgroundColor: _getWeatherColor(result.weather).withOpacity(0.2),
          side: BorderSide(color: _getWeatherColor(result.weather)),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _getWeatherIcon(Weather weather) {
    switch (weather) {
      case Weather.extreme:
        return const Icon(Icons.thunderstorm, color: Colors.red);
      case Weather.harsh:
        return const Icon(Icons.grain, color: Colors.orange);
      case Weather.poor:
        return const Icon(Icons.cloud, color: Colors.grey);
      case Weather.normal:
        return const Icon(Icons.cloud_queue, color: Colors.blueGrey);
      case Weather.fair:
        return const Icon(Icons.wb_cloudy, color: Colors.lightBlue);
      case Weather.good:
        return const Icon(Icons.wb_sunny, color: Colors.amber);
      case Weather.perfect:
        return const Icon(Icons.brightness_high, color: Colors.yellow);
    }
  }

  Color _getWeatherColor(Weather weather) {
    switch (weather) {
      case Weather.extreme:
        return Colors.red;
      case Weather.harsh:
        return Colors.orange;
      case Weather.poor:
        return Colors.grey;
      case Weather.normal:
        return Colors.blueGrey;
      case Weather.fair:
        return Colors.lightBlue;
      case Weather.good:
        return Colors.amber;
      case Weather.perfect:
        return Colors.yellow;
    }
  }

  Widget _buildEncounterDisplay(EncounterResult result, ThemeData theme) {
    if (result.encounterType == EncounterType.nothing) {
      return const Text(
        'No encounter',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        Chip(
          label: Text(result.encounterType.displayText),
          backgroundColor: _getEncounterColor(result.encounterType).withOpacity(0.2),
          side: BorderSide(color: _getEncounterColor(result.encounterType)),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        if (result.distance != null)
          Chip(
            label: Text(result.distance!.displayText),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        if (result.disposition != null)
          Chip(
            label: Text(result.disposition!.displayText),
            backgroundColor: _getDispositionColor(result.disposition!).withOpacity(0.2),
            side: BorderSide(color: _getDispositionColor(result.disposition!)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Color _getEncounterColor(EncounterType type) {
    switch (type) {
      case EncounterType.majorThreat:
        return Colors.red;
      case EncounterType.minorThreat:
        return Colors.orange;
      case EncounterType.trap:
        return Colors.deepOrange;
      case EncounterType.obstacle:
        return Colors.blueGrey;
      case EncounterType.nothing:
        return Colors.grey;
      case EncounterType.clue:
        return Colors.blue;
      case EncounterType.discovery:
        return Colors.teal;
      case EncounterType.treasure:
        return Colors.amber;
      case EncounterType.puzzle:
        return Colors.purple;
      case EncounterType.special:
        return Colors.pink;
    }
  }

  Color _getDispositionColor(Disposition disposition) {
    switch (disposition) {
      case Disposition.hostile:
        return Colors.red;
      case Disposition.unfriendly:
        return Colors.orange;
      case Disposition.wary:
        return Colors.amber;
      case Disposition.neutral:
        return Colors.grey;
      case Disposition.curious:
        return Colors.blue;
      case Disposition.friendly:
        return Colors.green;
      case Disposition.helpful:
        return Colors.teal;
    }
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

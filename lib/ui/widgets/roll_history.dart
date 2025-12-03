import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/fate_check.dart';
import '../../presets/next_scene.dart';
import '../../presets/random_event.dart';
import '../../presets/exploration.dart';

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
        return _RollHistoryCard(result: result, index: index);
      },
    );
  }
}

class _RollHistoryCard extends StatelessWidget {
  final RollResult result;
  final int index;

  const _RollHistoryCard({required this.result, required this.index});

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
      case RollType.weather:
        icon = Icons.wb_sunny;
        color = Colors.cyan;
        break;
      case RollType.encounter:
        icon = Icons.explore;
        color = Colors.green;
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
    } else if (result is WeatherResult) {
      return _buildWeatherDisplay(result as WeatherResult, theme);
    } else if (result is EncounterResult) {
      return _buildEncounterDisplay(result as EncounterResult, theme);
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
          Chip(
            label: Text(
              result.interpretation!,
              style: const TextStyle(fontSize: 12),
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  Widget _buildFateCheckDisplay(FateCheckResult result, ThemeData theme) {
    final isPositive = result.outcome == FateCheckOutcome.yes ||
        result.outcome == FateCheckOutcome.yesAnd ||
        result.outcome == FateCheckOutcome.yesBut ||
        result.outcome == FateCheckOutcome.extremeYes;

    return Row(
      children: [
        Text(
          '[${result.diceResults.join('+')}]',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        if (result.modifier != 0)
          Text(
            result.modifier >= 0 ? '+${result.modifier}' : '${result.modifier}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          '= ${result.modifiedTotal}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
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
    );
  }

  Widget _buildNextSceneDisplay(NextSceneResult result, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '[${result.diceResults.join('+')}]',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(result.sceneType.displayText),
              backgroundColor: Colors.blue.withOpacity(0.2),
              side: const BorderSide(color: Colors.blue),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (result.isInterrupt) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Text(
              '⚡ INTERRUPT - Random Event!',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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
          label: Text(result.focus.displayText),
          backgroundColor: Colors.amber.withOpacity(0.2),
          side: const BorderSide(color: Colors.amber),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 4),
        Text(
          '${result.action} / ${result.subject}',
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
      '${result.action} / ${result.subject}',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
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
        return Colors.brown;
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

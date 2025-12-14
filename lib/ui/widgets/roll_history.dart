import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import 'result_display_builder.dart';
import '../../presets/wilderness.dart';
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

  // Cached shadow list to avoid recreating on every build
  static final _cardShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark60,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: categoryColor, width: 4),
        ),
        boxShadow: _cardShadows,
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

  /// Builds the result display using the centralized ResultDisplayBuilder.
  Widget _buildResultDisplay(ThemeData theme) {
    return ResultDisplayBuilder(theme).buildDisplay(result);
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

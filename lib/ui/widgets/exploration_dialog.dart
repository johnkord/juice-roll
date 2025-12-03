import 'package:flutter/material.dart';
import '../../presets/exploration.dart';
import '../../models/roll_result.dart';

/// Dialog for exploration rolls (weather and encounters).
class ExplorationDialog extends StatefulWidget {
  final Exploration exploration;
  final void Function(RollResult) onRoll;

  const ExplorationDialog({
    super.key,
    required this.exploration,
    required this.onRoll,
  });

  @override
  State<ExplorationDialog> createState() => _ExplorationDialogState();
}

class _ExplorationDialogState extends State<ExplorationDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Weather settings
  String _season = 'Spring';
  String _climate = 'Temperate';

  // Encounter settings
  String _locationType = 'Wilderness';
  int _dangerLevel = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exploration'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.wb_sunny), text: 'Weather'),
                Tab(icon: Icon(Icons.explore), text: 'Encounter'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeatherTab(),
                  _buildEncounterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _performRoll,
          icon: const Icon(Icons.casino),
          label: const Text('Roll'),
        ),
      ],
    );
  }

  Widget _buildWeatherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Season:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Exploration.seasonModifiers.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.key),
                selected: _season == entry.key,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _season = entry.key);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Climate:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Exploration.climateModifiers.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.key),
                selected: _climate == entry.key,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _climate = entry.key);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Total modifier: ${_getTotalWeatherModifier()}',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  String _getTotalWeatherModifier() {
    final seasonMod = Exploration.seasonModifiers[_season] ?? 0;
    final climateMod = Exploration.climateModifiers[_climate] ?? 0;
    final total = seasonMod + climateMod;
    return total >= 0 ? '+$total' : '$total';
  }

  Widget _buildEncounterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Wilderness', label: Text('Wilderness')),
              ButtonSegment(value: 'Dungeon', label: Text('Dungeon')),
            ],
            selected: {_locationType},
            onSelectionChanged: (selected) {
              setState(() => _locationType = selected.first);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Danger Level:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _dangerLevel.toDouble(),
                  min: -2,
                  max: 4,
                  divisions: 6,
                  label: _getDangerLabel(),
                  onChanged: (value) {
                    setState(() => _dangerLevel = value.round());
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  _getDangerLabel(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Higher danger = more likely to encounter threats',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  String _getDangerLabel() {
    switch (_dangerLevel) {
      case -2:
        return 'Safe';
      case -1:
        return 'Calm';
      case 0:
        return 'Normal';
      case 1:
        return 'Risky';
      case 2:
        return 'Dangerous';
      case 3:
        return 'Deadly';
      case 4:
        return 'Nightmare';
      default:
        return '$_dangerLevel';
    }
  }

  void _performRoll() {
    RollResult result;

    if (_tabController.index == 0) {
      // Weather roll
      result = widget.exploration.rollWeather(
        season: _season,
        climate: _climate,
      );
    } else {
      // Encounter roll
      if (_locationType == 'Wilderness') {
        result = widget.exploration.checkWildernessEncounter(
          dangerLevel: _dangerLevel,
        );
      } else {
        result = widget.exploration.checkDungeonEncounter(
          dangerLevel: _dangerLevel,
        );
      }
    }

    widget.onRoll(result);
    Navigator.pop(context);
  }
}

import 'package:flutter/material.dart';
import '../models/roll_result.dart';
import '../core/roll_engine.dart';
import '../presets/fate_check.dart';
import '../presets/next_scene.dart';
import '../presets/random_event.dart';
import '../presets/exploration.dart';
import '../presets/discover_meaning.dart';
import '../presets/npc_action.dart';
import '../presets/pay_the_price.dart';
import '../presets/quest.dart';
import '../presets/interrupt_plot_point.dart';
import '../presets/settlement.dart';
import '../presets/object_treasure.dart';
import '../presets/challenge.dart';
import '../presets/details.dart';
import '../presets/immersion.dart';
import 'widgets/roll_history.dart';
import 'widgets/dice_roll_dialog.dart';
import 'widgets/fate_check_dialog.dart';
import 'widgets/next_scene_dialog.dart';
import 'widgets/exploration_dialog.dart';

/// Home screen with roll buttons and history.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RollResult> _history = [];
  final RollEngine _rollEngine = RollEngine();
  
  // Core Oracle presets
  final FateCheck _fateCheck = FateCheck();
  final NextScene _nextScene = NextScene();
  final RandomEvent _randomEvent = RandomEvent();
  final Exploration _exploration = Exploration();
  
  // Meaning & Inspiration presets
  final DiscoverMeaning _discoverMeaning = DiscoverMeaning();
  final InterruptPlotPoint _interruptPlotPoint = InterruptPlotPoint();
  
  // Character & NPC presets
  final NpcAction _npcAction = NpcAction();
  
  // World-building presets
  final Settlement _settlement = Settlement();
  final ObjectTreasure _objectTreasure = ObjectTreasure();
  final Quest _quest = Quest();
  
  // Gameplay presets
  final Challenge _challenge = Challenge();
  final PayThePrice _payThePrice = PayThePrice();
  
  // Immersion presets
  final Details _details = Details();
  final Immersion _immersion = Immersion();

  void _addToHistory(RollResult result) {
    setState(() {
      _history.insert(0, result);
      // Keep only last 100 results
      if (_history.length > 100) {
        _history.removeLast();
      }
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  void _showDiceRollDialog() {
    showDialog(
      context: context,
      builder: (context) => DiceRollDialog(
        rollEngine: _rollEngine,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showFateCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => FateCheckDialog(
        fateCheck: _fateCheck,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showNextSceneDialog() {
    showDialog(
      context: context,
      builder: (context) => NextSceneDialog(
        nextScene: _nextScene,
        onRoll: _addToHistory,
      ),
    );
  }

  void _rollRandomEvent() {
    final result = _randomEvent.generate();
    _addToHistory(result);
  }

  void _rollIdea() {
    final result = _randomEvent.generateIdea();
    _addToHistory(result);
  }

  void _showExplorationDialog() {
    showDialog(
      context: context,
      builder: (context) => ExplorationDialog(
        exploration: _exploration,
        onRoll: _addToHistory,
      ),
    );
  }

  void _rollDiscoverMeaning() {
    final result = _discoverMeaning.generate();
    _addToHistory(result);
  }

  void _rollInterruptPlotPoint() {
    final result = _interruptPlotPoint.generate();
    _addToHistory(result);
  }

  void _showNpcActionDialog() {
    showDialog(
      context: context,
      builder: (context) => _NpcActionDialog(
        npcAction: _npcAction,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showSettlementDialog() {
    showDialog(
      context: context,
      builder: (context) => _SettlementDialog(
        settlement: _settlement,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showTreasureDialog() {
    showDialog(
      context: context,
      builder: (context) => _TreasureDialog(
        treasure: _objectTreasure,
        onRoll: _addToHistory,
      ),
    );
  }

  void _rollQuest() {
    final result = _quest.generate();
    _addToHistory(result);
  }

  void _showChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => _ChallengeDialog(
        challenge: _challenge,
        onRoll: _addToHistory,
      ),
    );
  }

  void _rollPayThePrice() {
    final result = _payThePrice.rollConsequence();
    _addToHistory(result);
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => _DetailsDialog(
        details: _details,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showImmersionDialog() {
    showDialog(
      context: context,
      builder: (context) => _ImmersionDialog(
        immersion: _immersion,
        onRoll: _addToHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JuiceRoll'),
        centerTitle: true,
        actions: [
          if (_history.isNotEmpty)
            Semantics(
              label: 'Clear roll history',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear History',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History?'),
                      content: const Text('This will remove all roll history.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearHistory();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Roll Buttons Section - Scrollable
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row 1: Core Oracle
                  _buildButtonRow([
                    _RollButton(
                      label: 'Fate',
                      icon: Icons.help_outline,
                      onPressed: _showFateCheckDialog,
                      color: Colors.purple,
                    ),
                    _RollButton(
                      label: 'Scene',
                      icon: Icons.theaters,
                      onPressed: _showNextSceneDialog,
                      color: Colors.blue,
                    ),
                    _RollButton(
                      label: 'Event',
                      icon: Icons.flash_on,
                      onPressed: _rollRandomEvent,
                      color: Colors.amber,
                    ),
                    _RollButton(
                      label: 'Meaning',
                      icon: Icons.lightbulb_outline,
                      onPressed: _rollDiscoverMeaning,
                      color: Colors.orange,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 2: Story
                  _buildButtonRow([
                    _RollButton(
                      label: 'Interrupt',
                      icon: Icons.bolt,
                      onPressed: _rollInterruptPlotPoint,
                      color: Colors.deepPurple,
                    ),
                    _RollButton(
                      label: 'Quest',
                      icon: Icons.map,
                      onPressed: _rollQuest,
                      color: Colors.brown,
                    ),
                    _RollButton(
                      label: 'NPC',
                      icon: Icons.person,
                      onPressed: _showNpcActionDialog,
                      color: Colors.teal,
                    ),
                    _RollButton(
                      label: 'Settle',
                      icon: Icons.location_city,
                      onPressed: _showSettlementDialog,
                      color: Colors.blueGrey,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 3: World
                  _buildButtonRow([
                    _RollButton(
                      label: 'Treasure',
                      icon: Icons.diamond,
                      onPressed: _showTreasureDialog,
                      color: Colors.amber,
                    ),
                    _RollButton(
                      label: 'Explore',
                      icon: Icons.explore,
                      onPressed: _showExplorationDialog,
                      color: Colors.green,
                    ),
                    _RollButton(
                      label: 'Challenge',
                      icon: Icons.fitness_center,
                      onPressed: _showChallengeDialog,
                      color: Colors.indigo,
                    ),
                    _RollButton(
                      label: 'Price',
                      icon: Icons.warning,
                      onPressed: _rollPayThePrice,
                      color: Colors.red,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 4: Extras
                  _buildButtonRow([
                    _RollButton(
                      label: 'Details',
                      icon: Icons.palette,
                      onPressed: _showDetailsDialog,
                      color: Colors.pink,
                    ),
                    _RollButton(
                      label: 'Immerse',
                      icon: Icons.visibility,
                      onPressed: _showImmersionDialog,
                      color: Colors.deepOrange,
                    ),
                    _RollButton(
                      label: 'Dice',
                      icon: Icons.casino,
                      onPressed: _showDiceRollDialog,
                      color: Colors.red,
                    ),
                    const SizedBox(), // Empty spacer for 4th slot
                  ]),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // History Section
          Expanded(
            flex: 1,
            child: _history.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.casino,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No rolls yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap a button above to roll',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RollHistory(history: _history),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Row(
      children: buttons.map((btn) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: btn,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A styled roll button.
class _RollButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _RollButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.white, shadows: [
            Shadow(color: color, blurRadius: 8),
            Shadow(color: Colors.black, blurRadius: 2),
          ]),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: color, blurRadius: 6),
                Shadow(color: Colors.black, blurRadius: 3),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Dialog for NPC action selection.
class _NpcActionDialog extends StatelessWidget {
  final NpcAction npcAction;
  final void Function(RollResult) onRoll;

  const _NpcActionDialog({required this.npcAction, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('NPC'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Full Profile',
            subtitle: 'Personality, Need, Motive',
            onTap: () {
              onRoll(npcAction.generateProfile());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Personality',
            onTap: () {
              onRoll(npcAction.rollPersonality());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Action',
            onTap: () {
              onRoll(npcAction.rollAction());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Combat Action',
            onTap: () {
              onRoll(npcAction.rollCombatAction());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Dialog for Settlement options.
class _SettlementDialog extends StatelessWidget {
  final Settlement settlement;
  final void Function(RollResult) onRoll;

  const _SettlementDialog({required this.settlement, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settlement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Full Settlement',
            subtitle: 'Name + Establishment + News',
            onTap: () {
              onRoll(settlement.generateFull());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Name Only',
            onTap: () {
              onRoll(settlement.generateName());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Dialog for Treasure options.
class _TreasureDialog extends StatelessWidget {
  final ObjectTreasure treasure;
  final void Function(RollResult) onRoll;

  const _TreasureDialog({required this.treasure, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Object / Treasure'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(
              title: 'Random Category',
              subtitle: 'Roll for type then generate',
              onTap: () {
                onRoll(treasure.generateRandom());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Trinket',
              onTap: () {
                onRoll(treasure.generateTrinket());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Treasure',
              subtitle: 'Container + Contents',
              onTap: () {
                onRoll(treasure.generateTreasure());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Document',
              onTap: () {
                onRoll(treasure.generateDocument());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Accessory',
              onTap: () {
                onRoll(treasure.generateAccessory());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Weapon',
              onTap: () {
                onRoll(treasure.generateWeapon());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Armor',
              onTap: () {
                onRoll(treasure.generateArmor());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Dialog for Challenge options.
class _ChallengeDialog extends StatelessWidget {
  final Challenge challenge;
  final void Function(RollResult) onRoll;

  const _ChallengeDialog({required this.challenge, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Challenge'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Quick DC',
            subtitle: 'Roll 2d6+6 for difficulty',
            onTap: () {
              onRoll(challenge.rollQuickDc());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Physical Challenge',
            subtitle: 'Skill + DC',
            onTap: () {
              onRoll(challenge.rollPhysicalChallenge());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Mental Challenge',
            subtitle: 'Skill + DC',
            onTap: () {
              onRoll(challenge.rollMentalChallenge());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Any Challenge',
            subtitle: '50/50 Physical or Mental',
            onTap: () {
              onRoll(challenge.rollAnyChallenge());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Dialog for Details options.
class _DetailsDialog extends StatelessWidget {
  final Details details;
  final void Function(RollResult) onRoll;

  const _DetailsDialog({required this.details, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Color',
            onTap: () {
              onRoll(details.rollColor());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Property',
            subtitle: 'With intensity',
            onTap: () {
              onRoll(details.rollProperty());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Detail',
            subtitle: 'Modifier or favor',
            onTap: () {
              onRoll(details.rollDetail());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'History',
            subtitle: 'Context reference',
            onTap: () {
              onRoll(details.rollHistory());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Dialog for Immersion options.
class _ImmersionDialog extends StatelessWidget {
  final Immersion immersion;
  final void Function(RollResult) onRoll;

  const _ImmersionDialog({required this.immersion, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Immersion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Sensory Detail',
            subtitle: 'Sense + Detail',
            onTap: () {
              onRoll(immersion.generateSensoryDetail());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Emotional Atmosphere',
            subtitle: 'Where + Emotion + Cause',
            onTap: () {
              onRoll(immersion.generateEmotionalAtmosphere());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Full Immersion',
            subtitle: 'Sensory + Emotional',
            onTap: () {
              onRoll(immersion.generateFullImmersion());
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// A dialog option button.
class _DialogOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _DialogOption({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

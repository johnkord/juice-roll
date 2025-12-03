import 'package:flutter/material.dart';
import '../models/roll_result.dart';
import '../core/roll_engine.dart';
import '../presets/fate_check.dart';
import '../presets/expectation_check.dart';
import '../presets/next_scene.dart';
import '../presets/random_event.dart';
import '../presets/discover_meaning.dart';
import '../presets/npc_action.dart';
import '../presets/dialog_generator.dart';
import '../presets/pay_the_price.dart';
import '../presets/quest.dart';
import '../presets/interrupt_plot_point.dart';
import '../presets/settlement.dart';
import '../presets/object_treasure.dart';
import '../presets/challenge.dart';
import '../presets/details.dart';
import '../presets/immersion.dart';
import '../presets/name_generator.dart';
import '../presets/dungeon_generator.dart';
import '../presets/scale.dart';
import '../presets/wilderness.dart';
import '../presets/monster_encounter.dart';
import '../presets/location.dart';
import 'widgets/roll_history.dart';
import 'widgets/dice_roll_dialog.dart';
import 'widgets/fate_check_dialog.dart';
import 'widgets/next_scene_dialog.dart';

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
  final ExpectationCheck _expectationCheck = ExpectationCheck();
  final NextScene _nextScene = NextScene();
  final RandomEvent _randomEvent = RandomEvent();
  
  // Meaning & Inspiration presets
  final DiscoverMeaning _discoverMeaning = DiscoverMeaning();
  final InterruptPlotPoint _interruptPlotPoint = InterruptPlotPoint();
  
  // Character & NPC presets
  final NpcAction _npcAction = NpcAction();
  final DialogGenerator _dialogGenerator = DialogGenerator();
  final NameGenerator _nameGenerator = NameGenerator();
  
  // World-building presets
  final Settlement _settlement = Settlement();
  final ObjectTreasure _objectTreasure = ObjectTreasure();
  final Quest _quest = Quest();
  final DungeonGenerator _dungeonGenerator = DungeonGenerator();
  final Wilderness _wilderness = Wilderness();
  
  // Gameplay presets
  final Challenge _challenge = Challenge();
  final PayThePrice _payThePrice = PayThePrice();
  final Scale _scale = Scale();
  
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

  void _showRandomTablesDialog() {
    showDialog(
      context: context,
      builder: (context) => _RandomTablesDialog(
        randomEvent: _randomEvent,
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

  void _showPayThePriceDialog() {
    showDialog(
      context: context,
      builder: (context) => _PayThePriceDialog(
        payThePrice: _payThePrice,
        onRoll: _addToHistory,
      ),
    );
  }

  void _rollScale() {
    final result = _scale.roll();
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

  void _showExpectationCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => _ExpectationCheckDialog(
        expectationCheck: _expectationCheck,
        onRoll: _addToHistory,
      ),
    );
  }

  void _rollDialog() {
    final result = _dialogGenerator.generate();
    _addToHistory(result);
  }

  void _showNameGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => _NameGeneratorDialog(
        nameGenerator: _nameGenerator,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showDungeonDialog() {
    showDialog(
      context: context,
      builder: (context) => _DungeonDialog(
        dungeonGenerator: _dungeonGenerator,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showWildernessDialog() {
    showDialog(
      context: context,
      builder: (context) => _WildernessDialog(
        wilderness: _wilderness,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showMonsterDialog() {
    showDialog(
      context: context,
      builder: (context) => _MonsterEncounterDialog(
        onRoll: _addToHistory,
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => _LocationDialog(
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
              padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row 1: Front Page (Details, Immersion) + Left Page (Fate, Scene)
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
                  ]),
                  const SizedBox(height: 6),
                  // Row 2: Left Page (Expect, Scale, Interrupt) + Right Page (Meaning)
                  _buildButtonRow([
                    _RollButton(
                      label: 'Expect',
                      icon: Icons.psychology,
                      onPressed: _showExpectationCheckDialog,
                      color: Colors.deepPurple,
                    ),
                    _RollButton(
                      label: 'Scale',
                      icon: Icons.swap_vert,
                      onPressed: _rollScale,
                      color: Colors.teal,
                    ),
                    _RollButton(
                      label: 'Interrupt',
                      icon: Icons.bolt,
                      onPressed: _rollInterruptPlotPoint,
                      color: Colors.deepOrange,
                    ),
                    _RollButton(
                      label: 'Meaning',
                      icon: Icons.lightbulb_outline,
                      onPressed: _rollDiscoverMeaning,
                      color: Colors.orange,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 3: Second Inside Folded (Name, Random) + Back Page (Quest, Challenge)
                  _buildButtonRow([
                    _RollButton(
                      label: 'Name',
                      icon: Icons.badge,
                      onPressed: _showNameGeneratorDialog,
                      color: Colors.indigo,
                    ),
                    _RollButton(
                      label: 'Random',
                      icon: Icons.casino,
                      onPressed: _showRandomTablesDialog,
                      color: Colors.amber,
                    ),
                    _RollButton(
                      label: 'Quest',
                      icon: Icons.map,
                      onPressed: _rollQuest,
                      color: Colors.brown,
                    ),
                    _RollButton(
                      label: 'Challenge',
                      icon: Icons.fitness_center,
                      onPressed: _showChallengeDialog,
                      color: Colors.lime,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 4: Back Page (Price) + First Inside Unfolded (Wilderness, Monster) + Second Inside Unfolded (NPC)
                  _buildButtonRow([
                    _RollButton(
                      label: 'Price',
                      icon: Icons.warning,
                      onPressed: _showPayThePriceDialog,
                      color: Colors.red,
                    ),
                    _RollButton(
                      label: 'Wilderness',
                      icon: Icons.forest,
                      onPressed: _showWildernessDialog,
                      color: Colors.green.shade800,
                    ),
                    _RollButton(
                      label: 'Monster',
                      icon: Icons.pest_control,
                      onPressed: _showMonsterDialog,
                      color: Colors.red.shade800,
                    ),
                    _RollButton(
                      label: 'NPC',
                      icon: Icons.person,
                      onPressed: _showNpcActionDialog,
                      color: Colors.teal,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 5: Second Inside Unfolded (Dialog, Settle) + Third Inside Unfolded (Treasure) + Fourth Inside Unfolded (Dungeon)
                  _buildButtonRow([
                    _RollButton(
                      label: 'Dialog',
                      icon: Icons.chat,
                      onPressed: _rollDialog,
                      color: Colors.cyan,
                    ),
                    _RollButton(
                      label: 'Settle',
                      icon: Icons.location_city,
                      onPressed: _showSettlementDialog,
                      color: Colors.blueGrey,
                    ),
                    _RollButton(
                      label: 'Treasure',
                      icon: Icons.diamond,
                      onPressed: _showTreasureDialog,
                      color: Colors.amber,
                    ),
                    _RollButton(
                      label: 'Dungeon',
                      icon: Icons.castle,
                      onPressed: _showDungeonDialog,
                      color: Colors.grey,
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Row 6: Fourth Inside Unfolded (Location) + Dice Utility
                  _buildButtonRow([
                    _RollButton(
                      label: 'Location',
                      icon: Icons.grid_on,
                      onPressed: _showLocationDialog,
                      color: Colors.brown,
                    ),
                    _RollButton(
                      label: 'Dice',
                      icon: Icons.casino,
                      onPressed: _showDiceRollDialog,
                      color: Colors.red,
                    ),
                    const SizedBox(), // Placeholder for consistent sizing
                    const SizedBox(), // Placeholder for consistent sizing
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
                : RollHistory(
                    history: _history,
                    onSetWildernessPosition: (envRow, typeRow) {
                      final result = _wilderness.initializeAt(envRow, typeRow: typeRow);
                      _addToHistory(result);
                    },
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 3),
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
              fontSize: 10,
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Settlement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Villages: 1d6@- count, d6 establishments\n'
              'Cities: 1d6@+ count, d10 establishments',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const Divider(),
            _DialogOption(
              title: 'Village',
              subtitle: 'Name + establishments (1d6@-) + news',
              onTap: () {
                onRoll(settlement.generateVillage());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'City',
              subtitle: 'Name + establishments (1d6@+) + news',
              onTap: () {
                onRoll(settlement.generateCity());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text(
              'Individual Rolls',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _DialogOption(
              title: 'Name Only',
              subtitle: 'Settlement name (2d10)',
              onTap: () {
                onRoll(settlement.generateName());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Establishment (Village)',
              subtitle: 'Single establishment (d6)',
              onTap: () {
                onRoll(settlement.rollEstablishment(isVillage: true));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Establishment (City)',
              subtitle: 'Single establishment (d10)',
              onTap: () {
                onRoll(settlement.rollEstablishment(isVillage: false));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Artisan',
              subtitle: 'Type of artisan (d10)',
              onTap: () {
                onRoll(settlement.rollArtisan());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'News',
              subtitle: 'Current events (d10)',
              onTap: () {
                onRoll(settlement.rollNews());
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
          _DialogOption(
            title: '% Chance',
            subtitle: 'Generate a percentage chance',
            onTap: () {
              onRoll(challenge.rollPercentageChance());
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

/// Dialog for Pay the Price options.
class _PayThePriceDialog extends StatelessWidget {
  final PayThePrice payThePrice;
  final void Function(RollResult) onRoll;

  const _PayThePriceDialog({required this.payThePrice, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pay the Price'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Standard Consequence',
            subtitle: 'Normal failure result',
            onTap: () {
              onRoll(payThePrice.rollConsequence());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Major Plot Twist',
            subtitle: 'Critical fail or miss with match',
            onTap: () {
              onRoll(payThePrice.rollMajorTwist());
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

/// Dialog for Expectation Check options.
class _ExpectationCheckDialog extends StatelessWidget {
  final ExpectationCheck expectationCheck;
  final void Function(RollResult) onRoll;

  const _ExpectationCheckDialog({required this.expectationCheck, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Expectation Check'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: SizedBox(
        width: 240,
        child: const Text(
          'Instead of asking "Is X true?", you assume X is true and test '
          'whether your expectation holds.\n\n'
          'Also works for NPC behavior: assume what an NPC will likely do, then test it.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onRoll(expectationCheck.check());
            Navigator.pop(context);
          },
          child: const Text('Roll'),
        ),
      ],
    );
  }
}

/// Dialog for Name Generator options.
class _NameGeneratorDialog extends StatelessWidget {
  final NameGenerator nameGenerator;
  final void Function(RollResult) onRoll;

  const _NameGeneratorDialog({required this.nameGenerator, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Name Generator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Neutral Name',
            subtitle: 'Standard 3d20',
            onTap: () {
              onRoll(nameGenerator.generate());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Masculine Name',
            subtitle: 'Roll with disadvantage (@-)',
            onTap: () {
              onRoll(nameGenerator.generateMasculine());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Feminine Name',
            subtitle: 'Roll with advantage (@+)',
            onTap: () {
              onRoll(nameGenerator.generateFeminine());
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

/// Dialog for Dungeon Generator options.
class _DungeonDialog extends StatefulWidget {
  final DungeonGenerator dungeonGenerator;
  final void Function(RollResult) onRoll;

  const _DungeonDialog({required this.dungeonGenerator, required this.onRoll});

  @override
  State<_DungeonDialog> createState() => _DungeonDialogState();
}

class _DungeonDialogState extends State<_DungeonDialog> {
  bool _isEntering = true;
  // Shared settings for Passage/Condition/Encounter tables
  bool _useD6 = false;  // false = d10, true = d6
  AdvantageType _skew = AdvantageType.none;

  String _getDieLabel() => _useD6 ? 'd6' : 'd10';
  String _getSkewLabel() {
    switch (_skew) {
      case AdvantageType.advantage: return '@+';
      case AdvantageType.disadvantage: return '@-';
      case AdvantageType.none: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phaseText = _isEntering
        ? 'Phase: Entering (@-) - Until doubles'
        : 'Phase: Exploring (@+) - After doubles';
    
    final screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('Dungeon'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.55,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading explanation
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NA: 1d10@- Until Doubles, Then NA: 1d10@+',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(phaseText, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Phase toggle
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Entering'),
                    selected: _isEntering,
                    onSelected: (selected) => setState(() => _isEntering = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Exploring'),
                    selected: !_isEntering,
                    onSelected: (selected) => setState(() => _isEntering = false),
                  ),
                ],
              ),
              const Divider(),
              const Text('Dungeon Generation', style: TextStyle(fontWeight: FontWeight.bold)),
              _DialogOption(
                title: 'Generate Name',
                subtitle: 'The [Descriptor] [Subject] (2d10)',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generateName());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Next Area',
                subtitle: _isEntering 
                    ? '1d10@- (Sprawling, Branching)'
                    : '1d10@+ (Interconnected, More Exits)',
                onTap: () {
                  final result = widget.dungeonGenerator.generateNextArea(isEntering: _isEntering);
                  widget.onRoll(result);
                  // Auto-switch phase if doubles
                  if (result.isDoubles && _isEntering) {
                    setState(() => _isEntering = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('DOUBLES! Switched to Exploring phase (@+)')),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Full Area',
                subtitle: 'Next Area + Condition (uses settings below)',
                onTap: () {
                  final result = widget.dungeonGenerator.generateFullArea(
                    isEntering: _isEntering,
                    isOccupied: !_useD6,
                    conditionSkew: _skew,
                  );
                  widget.onRoll(result);
                  if (result.area.isDoubles && _isEntering) {
                    setState(() => _isEntering = false);
                  }
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Combined settings section
              const Text('Table Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'd6: Linear/Unoccupied/Lingering\n'
                      'd10: Branching/Occupied/First Entry\n'
                      '@-: Smaller/Worse | @+: Larger/Better',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ChoiceChip(
                          label: const Text('d6'),
                          selected: _useD6,
                          onSelected: (s) => setState(() => _useD6 = true),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('d10'),
                          selected: !_useD6,
                          onSelected: (s) => setState(() => _useD6 = false),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('@-'),
                          selected: _skew == AdvantageType.disadvantage,
                          onSelected: (s) => setState(() => _skew = s ? AdvantageType.disadvantage : AdvantageType.none),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('@+'),
                          selected: _skew == AdvantageType.advantage,
                          onSelected: (s) => setState(() => _skew = s ? AdvantageType.advantage : AdvantageType.none),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Text('Individual Rolls', style: TextStyle(fontWeight: FontWeight.bold)),
              _DialogOption(
                title: 'Passage',
                subtitle: 'Passage type (${_getDieLabel()}${_getSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generatePassage(
                    useD6: _useD6,
                    skew: _skew,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Condition',
                subtitle: 'Room state (${_getDieLabel()}${_getSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generateCondition(
                    useD6: _useD6,
                    skew: _skew,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Encounter Type',
                subtitle: 'What do you find? (${_getDieLabel()}${_getSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollEncounterType(
                    isLingering: _useD6,
                    skew: _skew,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Full Encounter',
                subtitle: 'Type + details (${_getDieLabel()}${_getSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollFullEncounter(
                    isLingering: _useD6,
                    skew: _skew,
                  ));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text('Encounter Details', style: TextStyle(fontWeight: FontWeight.bold)),
              _DialogOption(
                title: 'Monster',
                subtitle: 'Descriptor + Ability (2d10)',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollMonsterDescription());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Trap',
                subtitle: 'Action + Subject (2d10)',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollTrap());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Feature',
                subtitle: 'Dungeon feature (1d10)',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollFeature());
                  Navigator.pop(context);
                },
              ),
              // Show trap procedure info
              const Divider(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trap Procedure:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    Text(
                      '• Active (10m, @+): Pass=Avoid, Fail=Locate\n'
                      '• Passive: Pass=Locate, Fail=Trigger',
                      style: TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
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

/// Dialog for Wilderness exploration options.
class _WildernessDialog extends StatefulWidget {
  final Wilderness wilderness;
  final void Function(RollResult) onRoll;

  const _WildernessDialog({required this.wilderness, required this.onRoll});

  @override
  State<_WildernessDialog> createState() => _WildernessDialogState();
}

class _WildernessDialogState extends State<_WildernessDialog> {
  bool _hasDangerousTerrain = false;
  bool _hasMapOrGuide = false;
  bool _showEnvironmentPicker = false;
  int _selectedEnvironment = 6; // Default to Forest
  int _selectedType = 6; // Default to Tropical

  @override
  Widget build(BuildContext context) {
    final state = widget.wilderness.state;
    final isInitialized = state != null;
    
    return AlertDialog(
      title: const Text('Wilderness'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show current state if initialized
            if (isInitialized) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current: ${state.fullDescription}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Weather modifier: +${state.typeModifier} @ ${state.environmentSkew}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (state.isLost)
                      const Text(
                        '⚠️ LOST (using d6 for encounters)',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text('Environment', style: TextStyle(fontWeight: FontWeight.bold)),
            if (!isInitialized) ...[
              _DialogOption(
                title: 'Initialize Random Area',
                subtitle: 'Start in a random environment (1d10 + 1dF)',
                onTap: () {
                  widget.onRoll(widget.wilderness.initializeRandom());
                  setState(() {});
                },
              ),
              _DialogOption(
                title: _showEnvironmentPicker ? 'Hide Environment Picker' : 'Set Known Position...',
                subtitle: 'Start from an existing location',
                onTap: () => setState(() => _showEnvironmentPicker = !_showEnvironmentPicker),
              ),
            ] else ...[
              _DialogOption(
                title: 'Transition to Next Hex',
                subtitle: 'Move to adjacent area (2dF env + 1dF type)',
                onTap: () {
                  widget.onRoll(widget.wilderness.transition());
                  setState(() {});
                },
              ),
              _DialogOption(
                title: _showEnvironmentPicker ? 'Hide Environment Picker' : 'Change Position...',
                subtitle: 'Set to a different location',
                onTap: () => setState(() => _showEnvironmentPicker = !_showEnvironmentPicker),
              ),
            ],
            // Environment picker
            if (_showEnvironmentPicker) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Environment dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedEnvironment,
                      decoration: const InputDecoration(
                        labelText: 'Environment',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(10, (i) {
                        final env = Wilderness.environments[i];
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}. $env'),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedEnvironment = v ?? 6),
                    ),
                    const SizedBox(height: 8),
                    // Type dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(10, (i) {
                        final type = Wilderness.types[i]['name'] as String;
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}. $type'),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedType = v ?? 6),
                    ),
                    const SizedBox(height: 8),
                    // Preview
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Preview: ${Wilderness.types[_selectedType - 1]['name']} ${Wilderness.environments[_selectedEnvironment - 1]}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final result = widget.wilderness.initializeAt(_selectedEnvironment, typeRow: _selectedType);
                          widget.onRoll(result);
                          setState(() => _showEnvironmentPicker = false);
                        },
                        icon: const Icon(Icons.location_on),
                        label: const Text('Set Position'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(),
            const Text('Encounters', style: TextStyle(fontWeight: FontWeight.bold)),
            // Skew toggles
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Dangerous', style: TextStyle(fontSize: 12)),
                    subtitle: const Text('Disadvantage', style: TextStyle(fontSize: 10)),
                    value: _hasDangerousTerrain,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _hasDangerousTerrain = v ?? false),
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Map/Guide', style: TextStyle(fontSize: 12)),
                    subtitle: const Text('Advantage', style: TextStyle(fontSize: 10)),
                    value: _hasMapOrGuide,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _hasMapOrGuide = v ?? false),
                  ),
                ),
              ],
            ),
            _DialogOption(
              title: 'Roll Encounter',
              subtitle: isInitialized 
                  ? 'What happens? (d${state.isLost ? 6 : 10}${_getSkewLabel()})'
                  : 'What happens? (d10)',
              onTap: () {
                widget.onRoll(widget.wilderness.rollEncounter(
                  hasDangerousTerrain: _hasDangerousTerrain,
                  hasMapOrGuide: _hasMapOrGuide,
                ));
                setState(() {});
              },
            ),
            if (isInitialized && state.isLost)
              _DialogOption(
                title: 'Mark as Found',
                subtitle: 'Manually reset orientation (back to d10)',
                onTap: () {
                  widget.wilderness.setLost(false);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No longer lost - using d10 for encounters')),
                  );
                },
              ),
            _DialogOption(
              title: 'Weather',
              subtitle: isInitialized
                  ? '1d6@${state.environmentSkew} + ${state.typeModifier}'
                  : 'Current conditions (needs state)',
              onTap: () {
                widget.onRoll(widget.wilderness.rollWeather());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Natural Hazard',
              subtitle: 'Environmental danger (1d10)',
              onTap: () {
                widget.onRoll(widget.wilderness.rollNaturalHazard());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Wilderness Feature',
              subtitle: 'Notable landmark (1d10)',
              onTap: () {
                widget.onRoll(widget.wilderness.rollFeature());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Monster Level', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: 'Roll Monster Level',
              subtitle: isInitialized
                  ? 'Based on ${state.environment} environment'
                  : '1d6+modifier with advantage/disadvantage',
              onTap: () {
                widget.onRoll(widget.wilderness.rollMonsterLevel());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getSkewLabel() {
    if (_hasDangerousTerrain && _hasMapOrGuide) return ''; // Cancel out
    if (_hasDangerousTerrain) return '@-';
    if (_hasMapOrGuide) return '@+';
    return '';
  }
}

/// Dialog for Monster Encounter options.
class _MonsterEncounterDialog extends StatelessWidget {
  final void Function(RollResult) onRoll;

  const _MonsterEncounterDialog({required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Monster Encounter'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 350,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MonsterEncounter.deadlyExplanation,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            const Divider(),
            _DialogOption(
              title: 'Roll Encounter',
              subtitle: '2d10 for row + difficulty, doubles = boss',
              onTap: () {
                onRoll(MonsterEncounter.rollEncounter());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Roll Tracks',
              subtitle: '1d6-1@ with disadvantage',
              onTap: () {
                onRoll(MonsterEncounter.rollTracks());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('By Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: 'Easy (1-4)',
              subtitle: 'Lower CR monsters',
              onTap: () {
                onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.easy));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Medium (5-8)',
              subtitle: 'Standard CR monsters',
              onTap: () {
                onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.medium));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Hard (9-0)',
              subtitle: 'Higher CR monsters',
              onTap: () {
                onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.hard));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Boss',
              subtitle: 'Legendary or unique monster',
              onTap: () {
                onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.boss));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Special Rows', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: '* (Nature/Plants)',
              subtitle: 'Blights, hags, plant creatures',
              onTap: () {
                onRoll(MonsterEncounter.rollSpecialRow(humanoid: false));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '** (Humanoids)',
              subtitle: 'Bandits, scouts, veterans',
              onTap: () {
                onRoll(MonsterEncounter.rollSpecialRow(humanoid: true));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Dialog for Random Tables options (Modifier + Idea, Event Focus).
class _RandomTablesDialog extends StatelessWidget {
  final RandomEvent randomEvent;
  final void Function(RollResult) onRoll;

  const _RandomTablesDialog({
    required this.randomEvent,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Random Tables'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RE / Alter: Modifier + Idea',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            const Text(
              'Used for inspiration, scene alterations, or as a quick Random Event in Simple Mode.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const Divider(),
            _DialogOption(
              title: 'Random Category',
              subtitle: '1-3 Idea, 4-6 Event, 7-8 Person, 9-0 Object',
              onTap: () {
                onRoll(randomEvent.generateIdea());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Idea',
              subtitle: 'Modifier + Idea word',
              onTap: () {
                onRoll(randomEvent.generateIdea(category: IdeaCategory.idea));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Event',
              subtitle: 'Modifier + Event word',
              onTap: () {
                onRoll(randomEvent.generateIdea(category: IdeaCategory.event));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Person',
              subtitle: 'Modifier + Person word',
              onTap: () {
                onRoll(randomEvent.generateIdea(category: IdeaCategory.person));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Object',
              subtitle: 'Modifier + Object word',
              onTap: () {
                onRoll(randomEvent.generateIdea(category: IdeaCategory.object));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text(
              'Random Event Focus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'For Fate Check triggers (double blanks with primary left).',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const Divider(),
            _DialogOption(
              title: 'Event Focus Only',
              subtitle: 'Advance Time, Close Thread, NPC Action, etc.',
              onTap: () {
                onRoll(randomEvent.generateFocus());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Full Random Event',
              subtitle: 'Focus + Modifier + Idea (3d10)',
              onTap: () {
                onRoll(randomEvent.generate());
                Navigator.pop(context);
              },
            ),
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Dialog for Location Grid options.
class _LocationDialog extends StatelessWidget {
  final void Function(RollResult) onRoll;

  const _LocationDialog({required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Grid'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.brown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A 5×5 bullseye grid. Roll 1d100 to get both a direction and a distance.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Text('Compass Method', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Imagine your PC at the center. Roll to get:\n'
                '• Direction (N, S, E, W, NE, NW, SE, SW)\n'
                '• Distance (Close or Far based on ring)\n\n'
                'Use for: next town location, hex map population, travel days, road directions.',
                style: TextStyle(fontSize: 11),
              ),
              const Divider(),
              const Text('Zoom Method', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Use iterative zooming:\n'
                '1. Grid overlays world map → roll to zoom in\n'
                '2. Grid overlays region → roll again\n'
                '3. Grid overlays settlement → roll for building\n'
                '4. Keep zooming until you have your answer\n\n'
                'Use for: Remote Events, finding hidden treasure locations.',
                style: TextStyle(fontSize: 11),
              ),
              const Divider(),
              // Show the grid legend
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grid Rings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('◉ Center (origin)', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 12),
                        Text('○ Close', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 12),
                        Text('· Far', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    onRoll(Location.roll());
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.casino),
                  label: const Text('Roll 1d100'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

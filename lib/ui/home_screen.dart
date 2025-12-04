import 'package:flutter/material.dart';
import '../models/roll_result.dart';
import '../core/roll_engine.dart';
import '../core/table_lookup.dart';
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
import '../presets/extended_npc_conversation.dart';
import '../presets/abstract_icons.dart';
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
  final ExtendedNpcConversation _extendedNpcConversation = ExtendedNpcConversation();
  
  // Gameplay presets
  final Challenge _challenge = Challenge();
  final PayThePrice _payThePrice = PayThePrice();
  final Scale _scale = Scale();
  
  // Immersion presets
  final Details _details = Details();
  final Immersion _immersion = Immersion();

  // Abstract Icons preset
  final AbstractIcons _abstractIcons = AbstractIcons();

  // Dungeon exploration phase state (persists across dialog opens)
  bool _isDungeonEntering = true;
  // Two-Pass map generation state (persists across dialog opens)
  bool _twoPassHasFirstDoubles = false;

  void _setDungeonPhase(bool isEntering) {
    setState(() => _isDungeonEntering = isEntering);
  }

  void _setTwoPassFirstDoubles(bool hasFirstDoubles) {
    setState(() => _twoPassHasFirstDoubles = hasFirstDoubles);
  }

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

  void _showDialogGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => _DialogGeneratorDialog(
        dialogGenerator: _dialogGenerator,
        onRoll: _addToHistory,
      ),
    );
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
        isEntering: _isDungeonEntering,
        onPhaseChange: _setDungeonPhase,
        twoPassHasFirstDoubles: _twoPassHasFirstDoubles,
        onTwoPassFirstDoublesChange: _setTwoPassFirstDoubles,
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
        wildernessState: _wilderness.state,
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

  void _showExtendedNpcDialog() {
    showDialog(
      context: context,
      builder: (context) => _ExtendedNpcConversationDialog(
        extendedNpcConversation: _extendedNpcConversation,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showAbstractIconsDialog() {
    showDialog(
      context: context,
      builder: (context) => _AbstractIconsDialog(
        abstractIcons: _abstractIcons,
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
                  // Row 5: Second Inside Unfolded (Dialog, Settlement) + Third Inside Unfolded (Treasure) + Fourth Inside Unfolded (Dungeon)
                  _buildButtonRow([
                    _RollButton(
                      label: 'Dialog',
                      icon: Icons.chat,
                      onPressed: _showDialogGeneratorDialog,
                      color: Colors.cyan,
                    ),
                    _RollButton(
                      label: 'Settlement',
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
                  // Row 6: Fourth Inside Unfolded (Location) + Left Extension (NPC Talk) + Right Extension (Abstract) + Dice Utility
                  _buildButtonRow([
                    _RollButton(
                      label: 'Location',
                      icon: Icons.grid_on,
                      onPressed: _showLocationDialog,
                      color: Colors.brown,
                    ),
                    _RollButton(
                      label: 'NPC Talk',
                      icon: Icons.record_voice_over,
                      onPressed: _showExtendedNpcDialog,
                      color: Colors.purple,
                    ),
                    _RollButton(
                      label: 'Abstract',
                      icon: Icons.image,
                      onPressed: _showAbstractIconsDialog,
                      color: Colors.lime,
                    ),
                    _RollButton(
                      label: 'Dice',
                      icon: Icons.casino,
                      onPressed: _showDiceRollDialog,
                      color: Colors.red,
                    ),
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
class _NpcActionDialog extends StatefulWidget {
  final NpcAction npcAction;
  final void Function(RollResult) onRoll;

  const _NpcActionDialog({required this.npcAction, required this.onRoll});

  @override
  State<_NpcActionDialog> createState() => _NpcActionDialogState();
}

class _NpcActionDialogState extends State<_NpcActionDialog> {
  // NPC Creation settings
  NeedSkew _needSkew = NeedSkew.none;
  
  // Action table settings
  NpcDisposition _disposition = NpcDisposition.active;
  NpcContext _context = NpcContext.active;
  
  // Combat table settings
  NpcFocus _focus = NpcFocus.active;
  NpcObjective _objective = NpcObjective.offensive;

  String _getActionDieLabel() => _disposition == NpcDisposition.passive ? 'd6' : 'd10';
  String _getActionSkewLabel() => _context == NpcContext.active ? '@+' : '@-';
  String _getCombatDieLabel() => _focus == NpcFocus.passive ? 'd6' : 'd10';
  String _getCombatSkewLabel() => _objective == NpcObjective.offensive ? '@+' : '@-';
  String _getNeedSkewLabel() {
    switch (_needSkew) {
      case NeedSkew.none: return '';
      case NeedSkew.primitive: return ' @- Primitive';
      case NeedSkew.complex: return ' @+ Complex';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('NPC'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.6,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disp: d10A/6P; Ctx: @+A/-P',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'WH: ΔCtx, SH: ΔCtx & +/-1',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // NPC Creation Section
              const Text('NPC Creation', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              // Need skew setting
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Skew (for people use @+, for monsters use @-)',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('None'),
                          selected: _needSkew == NeedSkew.none,
                          onSelected: (s) => setState(() => _needSkew = NeedSkew.none),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('@- Primitive'),
                          selected: _needSkew == NeedSkew.primitive,
                          onSelected: (s) => setState(() => _needSkew = NeedSkew.primitive),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('@+ Complex'),
                          selected: _needSkew == NeedSkew.complex,
                          onSelected: (s) => setState(() => _needSkew = NeedSkew.complex),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Full Profile',
                subtitle: 'Personality + Need${_getNeedSkewLabel()} + Motive',
                onTap: () {
                  widget.onRoll(widget.npcAction.generateProfile(needSkew: _needSkew));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Personality',
                subtitle: 'd10 - Roll 2 for primary/secondary traits',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollPersonality());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Need',
                subtitle: 'd10${_getNeedSkewLabel()}',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollNeed(skew: _needSkew));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Motive / Topic',
                subtitle: 'd10 - For History/Focus, roll those tables',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollMotive());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Complex NPC Section
              const Text('Complex NPC (Sidekick)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'For complex NPCs like sidekicks: Name + 2 Personalities + '
                  'Need + Motive + Color + 2 Properties.\n'
                  'Use @+ for people, @- for monsters.',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Complex NPC (Person)',
                subtitle: 'Name + 2 Personalities + Need@+ + Motive + Color + Properties',
                onTap: () {
                  widget.onRoll(widget.npcAction.generateComplexNpc(
                    needSkew: NeedSkew.complex,
                    includeName: true,
                    dualPersonality: true,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Complex NPC (Monster)',
                subtitle: 'Name + 2 Personalities + Need@- + Motive + Color + Properties',
                onTap: () {
                  widget.onRoll(widget.npcAction.generateComplexNpc(
                    needSkew: NeedSkew.primitive,
                    includeName: true,
                    dualPersonality: true,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Dual Personality',
                subtitle: '2d10 - "Primary, yet Secondary" (e.g., "Confident, yet Reserved")',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollDualPersonality());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Action Table Section
              const Text('Action Table', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disposition (static): Passive=d6, Active=d10\n'
                      'Context (changeable): Active=@+, Passive=@-',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Disp: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Passive (d6)'),
                          selected: _disposition == NpcDisposition.passive,
                          onSelected: (s) => setState(() => _disposition = NpcDisposition.passive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Active (d10)'),
                          selected: _disposition == NpcDisposition.active,
                          onSelected: (s) => setState(() => _disposition = NpcDisposition.active),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Ctx: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Passive (@-)'),
                          selected: _context == NpcContext.passive,
                          onSelected: (s) => setState(() => _context = NpcContext.passive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Active (@+)'),
                          selected: _context == NpcContext.active,
                          onSelected: (s) => setState(() => _context = NpcContext.active),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Roll Action',
                subtitle: '${_getActionDieLabel()}${_getActionSkewLabel()} - ${_disposition.name} / ${_context.name}',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollAction(
                    disposition: _disposition,
                    context: _context,
                  ));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Combat Table Section
              const Text('Combat Table', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Focus: Passive=d6 (warnings), Active=d10 (full combat)\n'
                      'Objective: Defensive=@-, Offensive=@+',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Focus: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Passive (d6)'),
                          selected: _focus == NpcFocus.passive,
                          onSelected: (s) => setState(() => _focus = NpcFocus.passive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Active (d10)'),
                          selected: _focus == NpcFocus.active,
                          onSelected: (s) => setState(() => _focus = NpcFocus.active),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Obj: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Defensive (@-)'),
                          selected: _objective == NpcObjective.defensive,
                          onSelected: (s) => setState(() => _objective = NpcObjective.defensive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Offensive (@+)'),
                          selected: _objective == NpcObjective.offensive,
                          onSelected: (s) => setState(() => _objective = NpcObjective.offensive),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Roll Combat',
                subtitle: '${_getCombatDieLabel()}${_getCombatSkewLabel()} - ${_focus.name} / ${_objective.name}',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollCombatAction(
                    focus: _focus,
                    objective: _objective,
                  ));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Social Check reminder
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Social Check Effects:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    Text(
                      '• Weak Hit: Change Context (Active↔Passive)\n'
                      '• Strong Hit: Change Context AND +/-1 to roll',
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

/// Dialog for Settlement options.
class _SettlementDialog extends StatelessWidget {
  final Settlement settlement;
  final void Function(RollResult) onRoll;

  const _SettlementDialog({required this.settlement, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settlement'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header explanation from Juice instructions
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Settlements are places to rest, stock up on supplies, '
                'collect quests, or chat with NPCs.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const Divider(),
            const Text(
              'Generate Settlement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Villages: 1d6@- count, d6 establishments (rural)',
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(
                    'Cities: 1d6@+ count, d10 establishments (urban)',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _DialogOption(
              title: 'Village',
              subtitle: 'Name + 1d6@- establishments (d6) + news',
              onTap: () {
                onRoll(settlement.generateVillage());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'City',
              subtitle: 'Name + 1d6@+ establishments (d10) + news',
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
              title: 'Name (2d10)',
              subtitle: 'Also usable for NPC last names',
              onTap: () {
                onRoll(settlement.generateName());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Establishment (d6)',
              subtitle: 'Village: Stable, Tavern, Inn, Entertainment, General Store, Artisan',
              onTap: () {
                onRoll(settlement.rollEstablishment(isVillage: true));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Establishment (d10)',
              subtitle: 'City: +Courier, Temple, Guild Hall, Magic Shop',
              onTap: () {
                onRoll(settlement.rollEstablishment(isVillage: false));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Artisan (d10)',
              subtitle: 'Artist, Baker, Tailor, Tanner, Archer, Blacksmith, Carpenter, Apothecary, Jeweler, Scribe',
              onTap: () {
                onRoll(settlement.rollArtisan());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text(
              'Naming & Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Use Color + Object for establishment names (e.g., "The Crimson Hourglass"). '
                'The color helps mark on maps, the object is their emblem.',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
            _DialogOption(
              title: 'Establishment Name',
              subtitle: 'Color + Object → "The [Color] [Object]"',
              onTap: () {
                onRoll(settlement.generateEstablishmentName());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Settlement Properties',
              subtitle: 'Two properties with intensity (e.g., "Major Style" + "Minimal Weight")',
              onTap: () {
                onRoll(settlement.generateProperties());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Simple NPC',
              subtitle: 'Name + Personality + Need + Motive (for establishment owners)',
              onTap: () {
                onRoll(settlement.generateSimpleNpc());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text(
              'News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Roll when entering a settlement or on "Advance Time" random event. '
                'With a Courier, ask for news from other settlements.',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
            _DialogOption(
              title: 'News (d10)',
              subtitle: 'War, Sickness, Disaster, Crime, Succession, Remote Event, Arrival, Mail, Sale, Celebration',
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
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Dialog for Treasure options.
class _TreasureDialog extends StatefulWidget {
  final ObjectTreasure treasure;
  final void Function(RollResult) onRoll;

  const _TreasureDialog({required this.treasure, required this.onRoll});

  @override
  State<_TreasureDialog> createState() => _TreasureDialogState();
}

class _TreasureDialogState extends State<_TreasureDialog> {
  SkewType _skew = SkewType.none;
  bool _includeColor = false;

  String _getSkewLabel() {
    switch (_skew) {
      case SkewType.advantage: return '@+ Better';
      case SkewType.disadvantage: return '@- Worse';
      case SkewType.none: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Treasure'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Creation Section (from instructions)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Creation Procedure:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. Roll 4d6 on Object/Treasure table\n'
                    '2. Roll two properties (1d10+1d6 each)\n'
                    '3. Optionally roll color for appearance/elemental',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Color toggle for Item Creation
            Row(
              children: [
                Checkbox(
                  value: _includeColor,
                  onChanged: (v) => setState(() => _includeColor = v ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                const Expanded(
                  child: Text(
                    'Include Color (for appearance or elemental powers)',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            _DialogOption(
              title: '⭐ Create Full Item',
              subtitle: '4d6 + 2 Properties${_includeColor ? ' + Color' : ''}${_skew != SkewType.none ? ' ${_getSkewLabel()}' : ''}',
              onTap: () {
                widget.onRoll(widget.treasure.generateFullItem(
                  skew: _skew,
                  includeColor: _includeColor,
                ));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            // Header explanation from Juice instructions
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Roll 4d6 to get a descriptive item. First die determines '
                'the category (1-6), next 3 dice determine the properties.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 8),
            // Skew settings
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skew: @+ = Better Item, @- = Worse Item',
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('None'),
                        selected: _skew == SkewType.none,
                        onSelected: (s) => setState(() => _skew = SkewType.none),
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('@- Worse'),
                        selected: _skew == SkewType.disadvantage,
                        onSelected: (s) => setState(() => _skew = SkewType.disadvantage),
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('@+ Better'),
                        selected: _skew == SkewType.advantage,
                        onSelected: (s) => setState(() => _skew = SkewType.advantage),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            const Text('Roll 4d6', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: 'Random Treasure (4d6)',
              subtitle: 'Category + Properties${_skew != SkewType.none ? ' ${_getSkewLabel()}' : ''}',
              onTap: () {
                widget.onRoll(widget.treasure.generate(skew: _skew));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('By Category (3d6)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Pick a specific category and roll 3d6 for properties:',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
            _DialogOption(
              title: '1: Trinket',
              subtitle: 'Quality + Material + Type',
              onTap: () {
                widget.onRoll(widget.treasure.generateTrinket(skew: _skew));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '2: Treasure',
              subtitle: 'Quality + Container + Contents',
              onTap: () {
                widget.onRoll(widget.treasure.generateTreasure(skew: _skew));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '3: Document',
              subtitle: 'Type + Content + Subject',
              onTap: () {
                widget.onRoll(widget.treasure.generateDocument(skew: _skew));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '4: Accessory',
              subtitle: 'Quality + Material + Type',
              onTap: () {
                widget.onRoll(widget.treasure.generateAccessory(skew: _skew));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '5: Weapon',
              subtitle: 'Quality + Material + Type',
              onTap: () {
                widget.onRoll(widget.treasure.generateWeapon(skew: _skew));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '6: Armor',
              subtitle: 'Quality + Material + Type',
              onTap: () {
                widget.onRoll(widget.treasure.generateArmor(skew: _skew));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            // Examples from Juice instructions
            const Text('Examples', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Basic 4d6:\n'
                '2,5,4,2: New satchel full of art.\n'
                '6,1,5,3: Broken Mithral gloves.\n'
                '4,4,1,1: Fine wooden headpiece (crown).\n\n'
                'Full Item Creation:\n'
                '4,3,4,5 → "Accessory: Simple Silver Necklace"\n'
                '  Property: 9,5 → Major Value\n'
                '  Property: 5,4 → Moderate Power\n'
                '(A normal-looking necklace that grants power!)',
                style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
              ),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation from the instructions
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.lime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Challenge Procedure (Mythic Scene + Skill Check + Pay The Price):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. Roll Physical + Mental challenge with DCs\n'
                    '2. Create a situation where both make sense\n'
                    '3. Choose ONE path - only need to pass one!\n'
                    '4. Fail = Pay The Price (may lock out other option)',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Text('Full Challenge', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Rolls 1 Physical + 1 Mental with separate DCs for each:',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
            _DialogOption(
              title: 'Challenge (Random DCs)',
              subtitle: 'Physical (DC) + Mental (DC) - each gets own DC',
              onTap: () {
                onRoll(challenge.rollFullChallenge());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Challenge (Easy DCs)',
              subtitle: 'Both DCs rolled with advantage (lower)',
              onTap: () {
                onRoll(challenge.rollFullChallenge(dcSkew: DcSkew.advantage));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Challenge (Hard DCs)',
              subtitle: 'Both DCs rolled with disadvantage (higher)',
              onTap: () {
                onRoll(challenge.rollFullChallenge(dcSkew: DcSkew.disadvantage));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('DC Methods', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              '5 ways to generate a DC:',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
            _DialogOption(
              title: 'Quick DC',
              subtitle: '2d6+6 (range 8-18)',
              onTap: () {
                onRoll(challenge.rollQuickDc());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Random DC',
              subtitle: '1d10 → DC 8-17',
              onTap: () {
                onRoll(challenge.rollDc());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Balanced DC',
              subtitle: '1d100 bell curve → middle DCs',
              onTap: () {
                onRoll(challenge.rollBalancedDc());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Easy DC',
              subtitle: '1d10 with advantage → lower DC',
              onTap: () {
                onRoll(challenge.rollDc(skew: DcSkew.advantage));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Hard DC',
              subtitle: '1d10 with disadvantage → higher DC',
              onTap: () {
                onRoll(challenge.rollDc(skew: DcSkew.disadvantage));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Individual Skills', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: 'Physical Challenge',
              subtitle: 'Skill only (no separate DC)',
              onTap: () {
                onRoll(challenge.rollPhysicalChallenge());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Mental Challenge',
              subtitle: 'Skill only (no separate DC)',
              onTap: () {
                onRoll(challenge.rollMentalChallenge());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Examples', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '8,2: Stealth or Nature - Capture an elusive creature.\n'
                '7,6: Sleight of Hand or Language - Communicate with natives.\n'
                '9,7: Acrobatics or Religion - Display martial arts/tai chi.',
                style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation from the Juice instructions
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'So you failed a challenge. Time to Pay The Price! '
              'Use this to determine the effect of your failure.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 12),
          _DialogOption(
            title: 'Pay The Price',
            subtitle: 'Standard consequence for normal failure (1d10)',
            onTap: () {
              onRoll(payThePrice.rollConsequence());
              Navigator.pop(context);
            },
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'If you "Miss with a Match" or "Critical Fail", use the Major Plot Twist table instead.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 8),
          _DialogOption(
            title: 'Major Plot Twist',
            subtitle: 'For Miss with Match or Critical Fail (1d10)',
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
      title: const Text('Details (Front Page)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogOption(
            title: 'Color',
            subtitle: 'd10 - eye/hair, armor, banners, etc.',
            onTap: () {
              onRoll(details.rollColor());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Property ×2',
            subtitle: 'd10+d6 twice - describe items, NPCs, settlements',
            onTap: () {
              onRoll(details.rollTwoProperties());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Property ×1',
            subtitle: 'd10+d6 once - single property with intensity',
            onTap: () {
              onRoll(details.rollProperty());
              Navigator.pop(context);
            },
          ),
          const Divider(),
          _DialogOption(
            title: 'Detail',
            subtitle: 'd10 - ground meaning to thread/character/emotion',
            onTap: () {
              final result = details.rollDetail();
              onRoll(result);
              // If result is History or Property, prompt for follow-up
              if (result.requiresFollowUp) {
                if (result.result == 'History') {
                  onRoll(details.rollHistory());
                } else if (result.result == 'Property') {
                  onRoll(details.rollProperty());
                }
              }
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Detail (Positive)',
            subtitle: 'd10 advantage - skew toward favorable',
            onTap: () {
              final result = details.rollDetail(skew: SkewType.advantage);
              onRoll(result);
              if (result.requiresFollowUp) {
                if (result.result == 'History') {
                  onRoll(details.rollHistory());
                } else if (result.result == 'Property') {
                  onRoll(details.rollProperty());
                }
              }
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Detail (Negative)',
            subtitle: 'd10 disadvantage - skew toward unfavorable',
            onTap: () {
              final result = details.rollDetail(skew: SkewType.disadvantage);
              onRoll(result);
              if (result.requiresFollowUp) {
                if (result.result == 'History') {
                  onRoll(details.rollHistory());
                } else if (result.result == 'Property') {
                  onRoll(details.rollProperty());
                }
              }
              Navigator.pop(context);
            },
          ),
          const Divider(),
          _DialogOption(
            title: 'History',
            subtitle: 'd10 - tie elements to the past',
            onTap: () {
              onRoll(details.rollHistory());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'History (Recent)',
            subtitle: 'd10 advantage - closer to present',
            onTap: () {
              onRoll(details.rollHistory(skew: SkewType.advantage));
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'History (Distant)',
            subtitle: 'd10 disadvantage - further into past',
            onTap: () {
              onRoll(details.rollHistory(skew: SkewType.disadvantage));
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(
              title: 'Full Immersion',
              subtitle: '5d10 + 1dF - Sense + Detail + Where + Emotion + Cause',
              onTap: () {
                onRoll(immersion.generateFullImmersion());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Sensory Detail (3d10)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _DialogOption(
              title: 'Sensory Detail',
              subtitle: 'd10 - all senses',
              onTap: () {
                onRoll(immersion.generateSensoryDetail());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Sensory (Closer)',
              subtitle: 'd10 advantage - it is closer to you',
              onTap: () {
                onRoll(immersion.generateSensoryDetail(skew: SkewType.advantage));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Sensory (Further)',
              subtitle: 'd10 disadvantage - it is further from you',
              onTap: () {
                onRoll(immersion.generateSensoryDetail(skew: SkewType.disadvantage));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Sensory (Distant Only)',
              subtitle: 'd6 - only distant senses (See, Hear)',
              onTap: () {
                onRoll(immersion.generateSensoryDetail(senseDie: 6));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Emotional Atmosphere (2d10 + 1dF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _DialogOption(
              title: 'Emotional Atmosphere',
              subtitle: 'd10 - extended emotions',
              onTap: () {
                onRoll(immersion.generateEmotionalAtmosphere());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Emotion (Positive)',
              subtitle: 'd10 advantage - roughly positive',
              onTap: () {
                onRoll(immersion.generateEmotionalAtmosphere(skew: SkewType.advantage));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Emotion (Negative)',
              subtitle: 'd10 disadvantage - more negative',
              onTap: () {
                onRoll(immersion.generateEmotionalAtmosphere(skew: SkewType.disadvantage));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Emotion (Basic Only)',
              subtitle: 'd6 - basic emotions (joy, sadness, fear, anger, disgust, surprise)',
              onTap: () {
                onRoll(immersion.generateEmotionalAtmosphere(emotionDie: 6));
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
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instead of asking "Is X true?", you assume X is true and test '
              'whether your expectation holds.\n\n'
              'Also works for NPC behavior: assume what an NPC will likely do, then test it.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('++ = Expected (Intensified)', style: TextStyle(fontSize: 11)),
                  Text('+0 = Expected', style: TextStyle(fontSize: 11)),
                  Text('+- or -+ = Next Most Expected', style: TextStyle(fontSize: 11)),
                  Text('0+ = Favorable', style: TextStyle(fontSize: 11)),
                  Text('00 = Modified Idea (roll Modifier+Idea)', style: TextStyle(fontSize: 11)),
                  Text('0- = Unfavorable', style: TextStyle(fontSize: 11)),
                  Text('-0 = Opposite', style: TextStyle(fontSize: 11)),
                  Text('-- = Opposite (Intensified)', style: TextStyle(fontSize: 11)),
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
        ElevatedButton(
          onPressed: () {
            onRoll(expectationCheck.check());
            Navigator.pop(context);
          },
          child: const Text('Roll 2dF'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple Method section
          const Text('Simple Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          _DialogOption(
            title: '3d20 (Columns 1,2,3)',
            subtitle: 'Roll on all three columns',
            onTap: () {
              onRoll(nameGenerator.generate());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: '3d20 (Column 1 Only)',
            subtitle: 'Roll on column 1 three times',
            onTap: () {
              onRoll(nameGenerator.generateColumn1Only());
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // Pattern Method section
          const Text('Pattern Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          _DialogOption(
            title: 'Neutral',
            subtitle: 'Roll 1d20 for pattern',
            onTap: () {
              onRoll(nameGenerator.generatePatternNeutral());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Masculine (@-)',
            subtitle: 'Roll 1d20 with disadvantage for pattern',
            onTap: () {
              onRoll(nameGenerator.generateMasculine());
              Navigator.pop(context);
            },
          ),
          _DialogOption(
            title: 'Feminine (@+)',
            subtitle: 'Roll 1d20 with advantage for pattern',
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
/// Based on Juice Oracle Inside 4 page - Dungeon Generator.
class _DungeonDialog extends StatefulWidget {
  final DungeonGenerator dungeonGenerator;
  final void Function(RollResult) onRoll;
  final bool isEntering;
  final void Function(bool) onPhaseChange;
  final bool twoPassHasFirstDoubles;
  final void Function(bool) onTwoPassFirstDoublesChange;

  const _DungeonDialog({
    required this.dungeonGenerator,
    required this.onRoll,
    required this.isEntering,
    required this.onPhaseChange,
    required this.twoPassHasFirstDoubles,
    required this.onTwoPassFirstDoublesChange,
  });

  @override
  State<_DungeonDialog> createState() => _DungeonDialogState();
}

class _DungeonDialogState extends State<_DungeonDialog> {
  late bool _isEntering;
  // Passage/Condition table die size
  // d6 = Linear/Unoccupied, d10 = Branching/Occupied
  bool _useD6ForPassage = false;
  // Passage/Condition skew
  // Disadvantage = Smaller/Worse, Advantage = Larger/Better
  AdvantageType _passageConditionSkew = AdvantageType.none;
  
  // Encounter table settings
  // d6 = Lingering (10+ min in unsafe area), d10 = First entry
  bool _isLingering = false;
  // Advantage = Better Encounters, Disadvantage = Worse Encounters
  AdvantageType _encounterSkew = AdvantageType.none;

  // Two-Pass state is managed by parent widget via widget.twoPassHasFirstDoubles

  @override
  void initState() {
    super.initState();
    _isEntering = widget.isEntering;
  }

  void _setPhase(bool isEntering) {
    setState(() => _isEntering = isEntering);
    widget.onPhaseChange(isEntering);
  }

  String _getPassageDieLabel() => _useD6ForPassage ? 'd6' : 'd10';
  String _getPassageSkewLabel() {
    switch (_passageConditionSkew) {
      case AdvantageType.advantage: return '@+';
      case AdvantageType.disadvantage: return '@-';
      case AdvantageType.none: return '';
    }
  }
  
  String _getEncounterDieLabel() => _isLingering ? 'd6' : 'd10';
  String _getEncounterSkewLabel() {
    switch (_encounterSkew) {
      case AdvantageType.advantage: return '@+';
      case AdvantageType.disadvantage: return '@-';
      case AdvantageType.none: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phaseText = _isEntering
        ? 'Entering: 1d10@- (Sprawling, Branching)'
        : 'Exploring: 1d10@+ (Interconnected, More Exits)';
    
    final screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('Dungeon Generator'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.65,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading explanation from Juice instructions
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NA: 1d10@- Until Doubles, Then NA: 1d10@+',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(phaseText, style: TextStyle(
                      fontStyle: FontStyle.italic, 
                      fontSize: 12,
                      color: _isEntering ? Colors.orange : Colors.green,
                    )),
                    const SizedBox(height: 6),
                    const Text(
                      'Roll until doubles switch you from Entering to Exploring. '
                      'Mimics "Skyrim" style: long way in, shortcut out.',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Phase toggle
              Row(
                children: [
                  ChoiceChip(
                    label: Text('Entering (@-)', style: TextStyle(
                      color: _isEntering ? Colors.white : null,
                    )),
                    selected: _isEntering,
                    selectedColor: Colors.orange,
                    onSelected: (selected) => _setPhase(true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Exploring (@+)', style: TextStyle(
                      color: !_isEntering ? Colors.white : null,
                    )),
                    selected: !_isEntering,
                    selectedColor: Colors.green,
                    onSelected: (selected) => _setPhase(false),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _setPhase(true),
                    child: const Text('Reset', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              const Divider(),
              const Text('Dungeon Name', style: TextStyle(fontWeight: FontWeight.bold)),
              _DialogOption(
                title: 'Generate Name (3d10)',
                subtitle: '[Dungeon] of the [Description] [Subject]',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generateName());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text('Next Area Table', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '@- = Sprawling, Branching Dungeons\n'
                  '@+ = Interconnected, More Exits',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              _DialogOption(
                title: 'Next Area',
                subtitle: _isEntering 
                    ? '1d10@- (roll until doubles!)'
                    : '1d10@+ (after doubles)',
                onTap: () {
                  final result = widget.dungeonGenerator.generateNextArea(isEntering: _isEntering);
                  widget.onRoll(result);
                  // If result is "Passage", also roll on Passage table
                  if (result.areaType == 'Passage') {
                    widget.onRoll(widget.dungeonGenerator.generatePassage(
                      useD6: _useD6ForPassage,
                      skew: _passageConditionSkew,
                    ));
                  }
                  // Auto-switch phase if doubles while entering
                  if (result.isDoubles && _isEntering) {
                    _setPhase(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎲 DOUBLES! Switched to Exploring phase (@+)'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Full Area + Condition',
                subtitle: 'Next Area + Condition roll',
                onTap: () {
                  final result = widget.dungeonGenerator.generateFullArea(
                    isEntering: _isEntering,
                    isOccupied: !_useD6ForPassage,
                    conditionSkew: _passageConditionSkew,
                  );
                  widget.onRoll(result);
                  // If result is "Passage", also roll on Passage table
                  if (result.area.areaType == 'Passage') {
                    widget.onRoll(widget.dungeonGenerator.generatePassage(
                      useD6: _useD6ForPassage,
                      skew: _passageConditionSkew,
                    ));
                  }
                  // Auto-switch phase if doubles while entering
                  if (result.area.isDoubles && _isEntering) {
                    _setPhase(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎲 DOUBLES! Switched to Exploring phase (@+)'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Two-Pass Method Section
              const Text('Two-Pass Method (Map Pre-Generation)', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PASS 1: Pre-generate the entire map (no encounters)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Start with 1d10@+ (interconnected, more exits)\n'
                      '• 1st doubles → switch to 1d10@- (adds dead ends)\n'
                      '• 2nd doubles → STOP (remaining paths = Small Chamber: 1 Door)',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.twoPassHasFirstDoubles 
                                ? Colors.orange.withValues(alpha: 0.2) 
                                : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: widget.twoPassHasFirstDoubles ? Colors.orange : Colors.green,
                            ),
                          ),
                          child: Text(
                            widget.twoPassHasFirstDoubles
                                ? 'MAP: 1d10@- (after 1st doubles)'
                                : 'MAP: 1d10@+ (until 1st doubles)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.twoPassHasFirstDoubles ? Colors.orange.shade800 : Colors.green.shade800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            widget.onTwoPassFirstDoublesChange(false);
                            Navigator.pop(context);
                          },
                          child: const Text('Reset Map', style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Two-Pass Map Generation Buttons
              _DialogOption(
                title: 'Next Area (Map)',
                subtitle: widget.twoPassHasFirstDoubles
                    ? '1d10@- - layout only, no encounters'
                    : '1d10@+ - layout only, no encounters',
                onTap: () {
                  final result = widget.dungeonGenerator.generateTwoPassArea(
                    hasFirstDoubles: widget.twoPassHasFirstDoubles,
                    useD6ForPassage: _useD6ForPassage,
                    passageSkew: _passageConditionSkew,
                  );
                  widget.onRoll(result);
                  
                  // Handle doubles transitions
                  if (result.isSecondDoubles) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎲 2nd DOUBLES! STOP MAP GENERATION\nAll remaining paths → Small Chamber: 1 Door'),
                        backgroundColor: Colors.red.shade700,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } else if (result.isDoubles && !widget.twoPassHasFirstDoubles) {
                    widget.onTwoPassFirstDoublesChange(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎲 1st DOUBLES! Switching to @- for remaining areas'),
                        backgroundColor: Colors.orange.shade700,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Passage (Map)',
                subtitle: 'If area is Passage, roll type (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generatePassage(
                    useD6: _useD6ForPassage,
                    skew: _passageConditionSkew,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Condition (Map)',
                subtitle: 'Room state for map (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generateCondition(
                    useD6: _useD6ForPassage,
                    skew: _passageConditionSkew,
                  ));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              // Pass 2 - Exploration
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PASS 2: Explore the pre-made map',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'After map is drawn, traverse it room by room.\n'
                      'Roll encounters when entering each new area.\n'
                      '(Use Encounter buttons below for this phase)',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Passage & Condition Settings
              const Text('Passage & Condition Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Passage: d6=Linear, d10=Branching\n'
                      'Condition: d6=Unoccupied, d10=Occupied\n'
                      '@-=Smaller/Worse, @+=Larger/Better',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ChoiceChip(
                          label: const Text('d6'),
                          selected: _useD6ForPassage,
                          onSelected: (s) => setState(() => _useD6ForPassage = true),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('d10'),
                          selected: !_useD6ForPassage,
                          onSelected: (s) => setState(() => _useD6ForPassage = false),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('@-'),
                          selected: _passageConditionSkew == AdvantageType.disadvantage,
                          onSelected: (s) => setState(() => _passageConditionSkew = s ? AdvantageType.disadvantage : AdvantageType.none),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('@+'),
                          selected: _passageConditionSkew == AdvantageType.advantage,
                          onSelected: (s) => setState(() => _passageConditionSkew = s ? AdvantageType.advantage : AdvantageType.none),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DialogOption(
                title: 'Passage',
                subtitle: 'Passage type (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generatePassage(
                    useD6: _useD6ForPassage,
                    skew: _passageConditionSkew,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Condition',
                subtitle: 'Room state (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.generateCondition(
                    useD6: _useD6ForPassage,
                    skew: _passageConditionSkew,
                  ));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Encounter Settings
              const Text('Dungeon Encounter', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '10m 1d6 (NH: d6); Trap: 10m AP@+ A/L, PP L/T',
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'd6 = Lingering 10+ min in unsafe area\n'
                      'd10 = Entering area first time\n'
                      '@+ = Better Encounters, @- = Worse',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ChoiceChip(
                          label: const Text('d6 (Linger)'),
                          selected: _isLingering,
                          onSelected: (s) => setState(() => _isLingering = true),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('d10 (Entry)'),
                          selected: !_isLingering,
                          onSelected: (s) => setState(() => _isLingering = false),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('@-'),
                          selected: _encounterSkew == AdvantageType.disadvantage,
                          onSelected: (s) => setState(() => _encounterSkew = s ? AdvantageType.disadvantage : AdvantageType.none),
                          visualDensity: VisualDensity.compact,
                        ),
                        ChoiceChip(
                          label: const Text('@+'),
                          selected: _encounterSkew == AdvantageType.advantage,
                          onSelected: (s) => setState(() => _encounterSkew = s ? AdvantageType.advantage : AdvantageType.none),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DialogOption(
                title: 'Encounter Type',
                subtitle: 'What do you find? (${_getEncounterDieLabel()}${_getEncounterSkewLabel()})',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollEncounterType(
                    isLingering: _isLingering,
                    skew: _encounterSkew,
                  ));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Full Encounter',
                subtitle: 'Type + Monster/Trap/Feature if applicable',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollFullEncounter(
                    isLingering: _isLingering,
                    skew: _encounterSkew,
                  ));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text('Encounter Details', style: TextStyle(fontWeight: FontWeight.bold)),
              _DialogOption(
                title: 'Monster (2d10)',
                subtitle: 'Descriptor + Ability',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollMonsterDescription());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Trap (2d10)',
                subtitle: 'Action + Subject',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollTrap());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Trap Procedure (Searching)',
                subtitle: 'Trap + DC (10 min, @+): Pass=Avoid, Fail=Locate',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollTrapProcedure(isSearching: true));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Trap Procedure (Passive)',
                subtitle: 'Trap + DC (Passive): Pass=Locate, Fail=Trigger',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollTrapProcedure(isSearching: false));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Feature (1d10)',
                subtitle: 'Library, Mural, Mushrooms, Prison...',
                onTap: () {
                  widget.onRoll(widget.dungeonGenerator.rollFeature());
                  Navigator.pop(context);
                },
              ),
              // Show trap procedure info
              const Divider(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trap Procedure:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    SizedBox(height: 4),
                    Text(
                      '1. BEFORE encounter: decide to search (10 min) or not\n'
                      '2. If searching: Active Perception @+ vs DC\n'
                      '   • Pass = AVOID (completely bypass)\n'
                      '   • Fail = LOCATE (must disarm/bypass)\n'
                      '3. If NOT searching: Passive Perception vs DC\n'
                      '   • Pass = LOCATE (must disarm/bypass)\n'
                      '   • Fail = TRIGGER (suffer consequences)\n\n'
                      'Note: Lingering >10 min in non-Safety room = roll\n'
                      'another encounter (d6). Only 1 action per room is "free".',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Reference for encounter types
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Encounter Reference:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    SizedBox(height: 4),
                    Text(
                      '1: Monster    6: Known\n'
                      '2: Nat Hazard 7: Trap\n'
                      '3: Challenge  8: Feature\n'
                      '4: Immersion  9: Key\n'
                      '5: Safety     0: Treasure',
                      style: TextStyle(fontSize: 9, fontFamily: 'monospace'),
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
class _MonsterEncounterDialog extends StatefulWidget {
  final void Function(RollResult) onRoll;
  final WildernessState? wildernessState;

  const _MonsterEncounterDialog({required this.onRoll, this.wildernessState});

  @override
  State<_MonsterEncounterDialog> createState() => _MonsterEncounterDialogState();
}

class _MonsterEncounterDialogState extends State<_MonsterEncounterDialog> {
  int _selectedEnvironment = 6; // Default to Forest (1-indexed)

  @override
  void initState() {
    super.initState();
    // Use the wilderness state if available
    if (widget.wildernessState != null) {
      _selectedEnvironment = widget.wildernessState!.environmentRow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWildernessState = widget.wildernessState != null;
    final envName = MonsterEncounter.environmentNames[(_selectedEnvironment - 1).clamp(0, 9)];
    final envFormula = MonsterEncounter.getEnvironmentFormula(_selectedEnvironment);
    
    return AlertDialog(
      title: const Text('Monster Encounter'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 350,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Environment-based encounter section
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
                    Row(
                      children: [
                        const Icon(Icons.forest, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Environment: $envName ($envFormula)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    if (hasWildernessState) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From wilderness: ${widget.wildernessState!.fullDescription}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Environment selector
                    DropdownButtonFormField<int>(
                      value: _selectedEnvironment,
                      decoration: const InputDecoration(
                        labelText: 'Select Environment',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: List.generate(10, (i) {
                        final name = MonsterEncounter.environmentNames[i];
                        final formula = MonsterEncounter.getEnvironmentFormula(i + 1);
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}. $name ($formula)'),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedEnvironment = v ?? 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _DialogOption(
                title: 'Full Encounter (By Environment)',
                subtitle: 'Row ($envFormula) + Difficulty (2d10) + Counts (1d6-1@)',
                onTap: () {
                  widget.onRoll(MonsterEncounter.generateFullEncounter(_selectedEnvironment));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              const Text('Quick Rolls', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                MonsterEncounter.deadlyExplanation,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            const Divider(),
            _DialogOption(
              title: 'Roll Encounter',
              subtitle: '2d10 for row + difficulty, doubles = boss',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollEncounter());
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Roll Tracks',
              subtitle: '1d6-1@ with disadvantage',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollTracks());
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('By Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: 'Easy (1-4)',
              subtitle: 'Lower CR monsters',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.easy));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Medium (5-8)',
              subtitle: 'Standard CR monsters',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.medium));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Hard (9-0)',
              subtitle: 'Higher CR monsters',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.hard));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: 'Boss',
              subtitle: 'Legendary or unique monster',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.boss));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Special Rows', style: TextStyle(fontWeight: FontWeight.bold)),
            _DialogOption(
              title: '* (Nature/Plants)',
              subtitle: 'Blights, hags, plant creatures',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollSpecialRow(humanoid: false));
                Navigator.pop(context);
              },
            ),
            _DialogOption(
              title: '** (Humanoids)',
              subtitle: 'Bandits, scouts, veterans',
              onTap: () {
                widget.onRoll(MonsterEncounter.rollSpecialRow(humanoid: true));
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

/// Dialog for Random Tables options.
/// Provides Modifier, Idea, Event, Person, Object tables as described in the Juice instructions.
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
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 350,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explanation from the instructions
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '"Discover Meaning" provides abstract concepts. These tables provide '
                  'something more concrete for nouns.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
              const Divider(),
              // Simple Mode section
              const Text(
                'Simple Mode / Alter Scene',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Modifier + Idea replaces Random Event table in "Simple" mode. '
                'Also used when Next Scene is "Altered".',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Modifier + Idea',
                subtitle: '2d10 - Stop Food, Strange Resource, etc.',
                onTap: () {
                  onRoll(randomEvent.rollModifierPlusIdea());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Individual Tables section
              const Text(
                'Individual Tables (d10)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Modifier',
                subtitle: 'Change, Continue, Decrease, Extra, Increase...',
                onTap: () {
                  onRoll(randomEvent.rollModifier());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Idea',
                subtitle: 'Attention, Communication, Danger, Element...',
                onTap: () {
                  onRoll(randomEvent.rollIdea());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Event',
                subtitle: 'Ambush, Anomaly, Blessing, Caravan... (when something happens)',
                onTap: () {
                  onRoll(randomEvent.rollEvent());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Person',
                subtitle: 'Criminal, Entertainer, Expert, Mage... (NPC identity)',
                onTap: () {
                  onRoll(randomEvent.rollPerson());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Object',
                subtitle: 'Arrow, Candle, Cauldron, Chain... (evocative items)',
                onTap: () {
                  onRoll(randomEvent.rollObject());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Combined with Modifier
              const Text(
                'Modifier + Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Modifier + Random',
                subtitle: '1-3: Idea, 4-6: Event, 7-8: Person, 9-0: Object',
                onTap: () {
                  onRoll(randomEvent.generateIdea());
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Modifier + Event',
                subtitle: 'Trigger for scene changes',
                onTap: () {
                  onRoll(randomEvent.generateIdea(category: IdeaCategory.event));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Modifier + Person',
                subtitle: 'Generate NPC with modifier',
                onTap: () {
                  onRoll(randomEvent.generateIdea(category: IdeaCategory.person));
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Modifier + Object',
                subtitle: 'For objects in Simple mode',
                onTap: () {
                  onRoll(randomEvent.generateIdea(category: IdeaCategory.object));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Random Event Focus section (for Fate Check triggers)
              const Text(
                'Random Event Focus',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'For double blanks on Fate Check (primary die left). Triggers things easy to forget.',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
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
              const Divider(),
              // Reference section
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Focus Reference:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    SizedBox(height: 4),
                    Text('1. Advance Time   6. Keyed Event', style: TextStyle(fontSize: 9, fontFamily: 'monospace')),
                    Text('2. Close Thread   7. New Character', style: TextStyle(fontSize: 9, fontFamily: 'monospace')),
                    Text('3. Converge       8. NPC Action', style: TextStyle(fontSize: 9, fontFamily: 'monospace')),
                    Text('4. Diverge        9. Plot Armor', style: TextStyle(fontSize: 9, fontFamily: 'monospace')),
                    Text('5. Immersion      0. Remote Event', style: TextStyle(fontSize: 9, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tip: Use Color + Object for naming Establishments!',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
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

/// Dialog for the NPC Dialog Grid mini-game.
/// A 5x5 grid where you maintain position and navigate via 2d10 rolls.
class _DialogGeneratorDialog extends StatefulWidget {
  final DialogGenerator dialogGenerator;
  final void Function(RollResult) onRoll;

  const _DialogGeneratorDialog({
    required this.dialogGenerator,
    required this.onRoll,
  });

  @override
  State<_DialogGeneratorDialog> createState() => _DialogGeneratorDialogState();
}

class _DialogGeneratorDialogState extends State<_DialogGeneratorDialog> {
  DialogResult? _lastResult;
  
  @override
  void initState() {
    super.initState();
    // If no conversation active, we're at Fact (center)
    if (!widget.dialogGenerator.isConversationActive) {
      widget.dialogGenerator.startConversation();
    }
  }

  void _rollDialog() {
    final result = widget.dialogGenerator.generate();
    setState(() {
      _lastResult = result;
    });
    widget.onRoll(result);
    
    // Show snackbar for special events
    if (result.isDoubles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DOUBLES! Conversation has ended.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _startNewConversation() {
    widget.dialogGenerator.startConversation();
    setState(() {
      _lastResult = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New conversation started at "Fact"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _setPosition(int row, int col) {
    widget.dialogGenerator.setPosition(row, col);
    setState(() {
      _lastResult = null;
    });
    final fragment = DialogGenerator.grid[row][col];
    final isPast = row <= 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting position set to "$fragment" ${isPast ? "(Past)" : "(Present)"}'),
        backgroundColor: Colors.cyan,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildGridCell(int row, int col) {
    final fragment = DialogGenerator.grid[row][col];
    final isCurrentPos = row == widget.dialogGenerator.currentRow && 
                        col == widget.dialogGenerator.currentCol;
    final isPastRow = row <= 1;
    
    return GestureDetector(
      onTap: () => _setPosition(row, col),
      child: Container(
        width: 52,
        height: 40,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isCurrentPos 
              ? Colors.cyan.withValues(alpha: 0.4)
              : isPastRow 
                  ? Colors.grey.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.05),
          border: Border.all(
            color: isCurrentPos ? Colors.cyan : Colors.grey.withValues(alpha: 0.3),
            width: isCurrentPos ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            fragment,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrentPos ? FontWeight.bold : FontWeight.normal,
              fontStyle: isPastRow ? FontStyle.italic : FontStyle.normal,
              color: isCurrentPos ? Colors.cyan : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        // Row labels for Past/Present
        const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Top 2 rows = ', style: TextStyle(fontSize: 9)),
              Text('Past', style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic)),
              Text(' / Bottom 3 = Present', style: TextStyle(fontSize: 9)),
            ],
          ),
        ),
        // The 5x5 grid
        for (int row = 0; row < 5; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 5; col++)
                _buildGridCell(row, col),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.dialogGenerator.isConversationActive;
    final currentFragment = widget.dialogGenerator.currentPositionLabel;
    final isPast = widget.dialogGenerator.isCurrentPast;
    
    return AlertDialog(
      title: const Text('NPC Dialog Grid'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions header
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A mini-game to generate NPC conversations.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Tap any cell to set your starting position\n'
                      '• Roll 2d10: 1st = Direction + Tone, 2nd = Subject\n'
                      '• Doubles = Conversation ends\n'
                      '• Edges wrap around',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // The grid
              _buildGrid(),
              const SizedBox(height: 8),
              
              // Current state
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
                          size: 16,
                          color: isActive ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Conversation Active' : 'Conversation Ended',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current: $currentFragment ${isPast ? "(Past)" : "(Present)"}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (DialogGenerator.fragmentDescriptions[currentFragment] != null)
                      Text(
                        DialogGenerator.fragmentDescriptions[currentFragment]!,
                        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
              
              // Last result display
              if (_lastResult != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Roll: ${_lastResult!.directionRoll}, ${_lastResult!.subjectRoll}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _lastResult!.isDoubles 
                            ? 'DOUBLES - Conversation Ended'
                            : _lastResult!.movementDescription,
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        '${_lastResult!.tone} tone about ${_lastResult!.subject}',
                        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              
              // Direction legend
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1st Die (Direction + Tone):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    Text('1-2: ↑ Up (Neutral)  3-5: ← Left (Defensive)', style: TextStyle(fontSize: 9)),
                    Text('6-8: → Right (Aggressive)  9-0: ↓ Down (Helpful)', style: TextStyle(fontSize: 9)),
                    SizedBox(height: 4),
                    Text('2nd Die (Subject):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    Text('1-2: Them  3-5: Me  6-8: You  9-0: Us', style: TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _rollDialog,
                      icon: const Icon(Icons.casino),
                      label: Text(isActive ? 'Roll 2d10' : 'Roll (New)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _startNewConversation,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Start New Conversation',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                ],
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

/// Dialog for Extended NPC Conversation tables.
/// An alternative to the Dialog Grid mini-game for NPC conversations.
class _ExtendedNpcConversationDialog extends StatefulWidget {
  final ExtendedNpcConversation extendedNpcConversation;
  final void Function(RollResult) onRoll;

  const _ExtendedNpcConversationDialog({
    required this.extendedNpcConversation,
    required this.onRoll,
  });

  @override
  State<_ExtendedNpcConversationDialog> createState() => _ExtendedNpcConversationDialogState();
}

class _ExtendedNpcConversationDialogState extends State<_ExtendedNpcConversationDialog> {
  // Companion Response skew settings
  SkewType _companionSkew = SkewType.none;

  String _getCompanionSkewLabel() {
    switch (_companionSkew) {
      case SkewType.advantage:
        return '@+ In Favor';
      case SkewType.disadvantage:
        return '@- Opposed';
      case SkewType.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('Extended NPC Conversation'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.6,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plot Knowledge / Companion Responses / Dialog Topics',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Alternative to the Dialog Grid mini-game. '
                      'NPCs make the world feel alive!',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // Information Section
              const Text('Information (2d100)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Roll 2d100 to determine what an NPC is talking about. '
                  'Could be a response to asking for info, or something overheard.',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Roll Information',
                subtitle: 'Type of Information + Topic (2d100)',
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollInformation());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Companion Response Section
              const Text('Companion Response (1d100)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Responses to "the plan". Ordered such that bigger numbers '
                      'are more in favor, smaller numbers are more opposed.',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@+ = More likely to agree (Advantage)\n'
                      '@- = More likely to oppose (Disadvantage)',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('None'),
                    selected: _companionSkew == SkewType.none,
                    onSelected: (s) => setState(() => _companionSkew = SkewType.none),
                    visualDensity: VisualDensity.compact,
                  ),
                  ChoiceChip(
                    label: const Text('@- Opposed'),
                    selected: _companionSkew == SkewType.disadvantage,
                    onSelected: (s) => setState(() => _companionSkew = SkewType.disadvantage),
                    visualDensity: VisualDensity.compact,
                  ),
                  ChoiceChip(
                    label: const Text('@+ In Favor'),
                    selected: _companionSkew == SkewType.advantage,
                    onSelected: (s) => setState(() => _companionSkew = SkewType.advantage),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Roll Companion Response',
                subtitle: '1d100${_companionSkew != SkewType.none ? ' ${_getCompanionSkewLabel()}' : ''}',
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollCompanionResponse(skew: _companionSkew));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Dialog Topic Section
              const Text('Dialog Topic (1d100)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'What are NPCs talking about? More topics than the standard table. '
                  'Also usable for News, letters, books, writing on walls, etc.',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 4),
              _DialogOption(
                title: 'Roll Dialog Topic',
                subtitle: 'What NPCs are discussing (1d100)',
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollDialogTopic());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              
              // Reference section
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Response Favor Levels:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    SizedBox(height: 4),
                    Text(
                      '1-20: Strongly Opposed\n'
                      '21-40: Hesitant\n'
                      '41-60: Neutral/Questioning\n'
                      '61-80: Cautious Support\n'
                      '81-100: Strongly In Favor',
                      style: TextStyle(fontSize: 9, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tip: Use the Dialog Grid (Dialog button) for a more interactive '
                  'mini-game experience with position tracking.',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
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

/// Dialog for Abstract Icons.
/// Based on Juice Oracle Right Extension - Roll 1d10 + 1d6 to pick an icon.
class _AbstractIconsDialog extends StatelessWidget {
  final AbstractIcons abstractIcons;
  final void Function(RollResult) onRoll;

  const _AbstractIconsDialog({
    required this.abstractIcons,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Abstract Icons'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header explanation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.lime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Roll 1d10 + 1d6 to pick an icon. These abstract images can be '
              'used for inspiration instead of words. Inspired by Rory\'s Story Cubes.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 12),
          // Usage hints
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uses:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                SizedBox(height: 4),
                Text(
                  '• Alternative to word-based meaning tables\n'
                  '• Visual inspiration for scenes or encounters\n'
                  '• Interpret the symbol in your current context\n'
                  '• Use multiple icons for complex situations',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Roll button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final result = abstractIcons.generate();
                onRoll(result);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.image),
              label: const Text('Roll 1d10 + 1d6'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lime,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Grid reference
          const Text(
            'Grid: 10 rows (1-9, 0) × 6 columns (1-6)',
            style: TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
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

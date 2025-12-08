import 'package:flutter/material.dart';
import '../models/session.dart';
import 'home_state.dart';
import 'theme/juice_theme.dart';
import 'widgets/roll_button.dart';
import 'widgets/roll_history.dart';
import 'widgets/dice_roll_dialog.dart';
import 'widgets/fate_check_dialog.dart';
import 'widgets/next_scene_dialog.dart';
import 'dialogs/dialogs.dart';

/// Home screen with roll buttons and history.
/// 
/// This widget is now focused purely on UI concerns.
/// All business logic is delegated to [HomeStateNotifier].
class HomeScreen extends StatefulWidget {
  /// Optional state notifier for testing.
  /// If not provided, a new one will be created.
  final HomeStateNotifier? stateNotifier;

  const HomeScreen({
    super.key,
    this.stateNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeStateNotifier _notifier;
  late final bool _ownsNotifier;

  @override
  void initState() {
    super.initState();
    
    // Use provided notifier or create a new one
    if (widget.stateNotifier != null) {
      _notifier = widget.stateNotifier!;
      _ownsNotifier = false;
    } else {
      _notifier = HomeStateNotifier();
      _ownsNotifier = true;
      _notifier.init();
    }
    
    // Listen for state changes
    _notifier.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChange);
    if (_ownsNotifier) {
      _notifier.dispose();
    }
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  // ========== Session Dialogs ==========

  void _showSessionSelector() {
    final state = _notifier.state;
    showModalBottomSheet(
      context: context,
      builder: (context) => SessionSelectorSheet(
        sessions: state.sessions,
        currentSession: state.currentSession,
        onSelectSession: (session) {
          _notifier.switchSession(session);
        },
        onNewSession: () {
          _showNewSessionDialog();
        },
        onShowDetails: (session) {
          _showSessionDetailsDialog(session);
        },
        onShowSettings: (session) {
          _showSessionSettingsDialog(session);
        },
        onDeleteSession: (session) async {
          await _notifier.deleteSession(session);
          
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('Deleted session: ${session.name}')),
            );
          }
        },
        onImportSession: () async {
          await _importSession();
        },
      ),
    );
  }

  void _showNewSessionDialog() {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Session Name',
                hintText: 'e.g., Dungeon Crawl',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g., Level 3 fighter',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              
              Navigator.pop(context);
              
              await _notifier.createSession(
                name,
                notes: notesController.text.trim().isEmpty 
                    ? null 
                    : notesController.text.trim(),
              );
              
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Created session: $name')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSessionDetailsDialog(Session session) async {
    final fullSession = await _notifier.getSession(session.id);
    if (fullSession == null || !mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => SessionDetailsDialog(
        session: fullSession,
        isCurrentSession: _notifier.state.currentSession?.id == session.id,
        onDelete: () async {
          await _notifier.deleteSession(session);
          
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('Deleted session: ${session.name}')),
            );
          }
        },
        onExport: () async {
          await fullSession.copyToClipboard();
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('Session copied to clipboard! Paste it somewhere safe to back up.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        onUpdate: (updatedSession) async {
          await _notifier.updateSession(
            session.id,
            name: updatedSession.name,
            notes: updatedSession.notes,
          );
        },
        onShowSettings: () {
          _showSessionSettingsDialog(session);
        },
      ),
    );
  }

  Future<void> _showSessionSettingsDialog(Session session) async {
    final fullSession = await _notifier.getSession(session.id);
    if (fullSession == null || !mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => SessionSettingsDialog(
        session: fullSession,
        onUpdate: (updatedSession) async {
          await _notifier.updateSessionSettings(
            session.id,
            maxRollsPerSession: updatedSession.maxRollsPerSession,
            clearMaxRollsPerSession: updatedSession.maxRollsPerSession == null,
          );
        },
      ),
    );
  }

  Future<void> _importSession() async {
    final session = await _notifier.importSession();
    
    if (!mounted) return;
    
    final messenger = ScaffoldMessenger.of(context);
    
    if (session != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Imported session: ${session.name}'),
          action: SnackBarAction(
            label: 'Switch',
            onPressed: () => _notifier.switchSession(session),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No valid session data found in clipboard'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ========== About Dialog ==========

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => const AboutJuiceDialog(),
    );
  }

  // ========== Oracle Dialogs ==========

  void _showDiceRollDialog() {
    final state = _notifier.state;
    showDialog(
      context: context,
      builder: (context) => DiceRollDialog(
        rollEngine: _notifier.rollEngine,
        onRoll: _notifier.addToHistory,
        initialDiceMode: state.diceDialogMode,
        initialIronswornRollType: state.diceDialogIronswornRollType,
        initialOracleDieType: state.diceDialogOracleDieType,
        onStateChanged: _notifier.updateDiceDialogState,
      ),
    );
  }

  void _showFateCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => FateCheckDialog(
        fateCheck: _notifier.fateCheck,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showNextSceneDialog() {
    showDialog(
      context: context,
      builder: (context) => NextSceneDialog(
        nextScene: _notifier.nextScene,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showRandomTablesDialog() {
    showDialog(
      context: context,
      builder: (context) => RandomTablesDialog(
        randomEvent: _notifier.randomEvent,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showNpcActionDialog() {
    showDialog(
      context: context,
      builder: (context) => NpcActionDialog(
        npcAction: _notifier.npcAction,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showSettlementDialog() {
    showDialog(
      context: context,
      builder: (context) => SettlementDialog(
        settlement: _notifier.settlement,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showTreasureDialog() {
    showDialog(
      context: context,
      builder: (context) => TreasureDialog(
        treasure: _notifier.objectTreasure,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => ChallengeDialog(
        challenge: _notifier.challenge,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showPayThePriceDialog() {
    showDialog(
      context: context,
      builder: (context) => PayThePriceDialog(
        payThePrice: _notifier.payThePrice,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => DetailsDialog(
        details: _notifier.details,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showImmersionDialog() {
    showDialog(
      context: context,
      builder: (context) => ImmersionDialog(
        immersion: _notifier.immersion,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showExpectationCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpectationCheckDialog(
        expectationCheck: _notifier.expectationCheck,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showDialogGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => DialogGeneratorDialog(
        dialogGenerator: _notifier.dialogGenerator,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showNameGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => NameGeneratorDialog(
        nameGenerator: _notifier.nameGenerator,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showDungeonDialog() {
    final state = _notifier.state;
    showDialog(
      context: context,
      builder: (context) => DungeonDialog(
        dungeonGenerator: _notifier.dungeonGenerator,
        onRoll: _notifier.addToHistory,
        isEntering: state.isDungeonEntering,
        onPhaseChange: _notifier.setDungeonPhase,
        isTwoPassMode: state.isDungeonTwoPassMode,
        onTwoPassModeChange: _notifier.setDungeonTwoPassMode,
        twoPassHasFirstDoubles: state.twoPassHasFirstDoubles,
        onTwoPassFirstDoublesChange: _notifier.setTwoPassFirstDoubles,
      ),
    );
  }

  void _showWildernessDialog() {
    showDialog(
      context: context,
      builder: (context) => WildernessDialog(
        wilderness: _notifier.wilderness,
        wildernessState: _notifier.wildernessState,
        onRoll: _notifier.addToHistory,
        onStateChange: _notifier.updateWildernessState,
        dungeonGenerator: _notifier.dungeonGenerator,
        challenge: _notifier.challenge,
      ),
    );
  }

  void _showMonsterDialog() {
    showDialog(
      context: context,
      builder: (context) => MonsterEncounterDialog(
        onRoll: _notifier.addToHistory,
        wildernessState: _notifier.wildernessState,
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => LocationDialog(
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showExtendedNpcDialog() {
    showDialog(
      context: context,
      builder: (context) => ExtendedNpcConversationDialog(
        extendedNpcConversation: _notifier.extendedNpcConversation,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  void _showAbstractIconsDialog() {
    showDialog(
      context: context,
      builder: (context) => AbstractIconsDialog(
        abstractIcons: _notifier.abstractIcons,
        onRoll: _notifier.addToHistory,
      ),
    );
  }

  // ========== Build Methods ==========

  @override
  Widget build(BuildContext context) {
    final state = _notifier.state;
    
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('JuiceRoll'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading session...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 36,
        leading: GestureDetector(
          onTap: _showAboutDialog,
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_drink,
                  color: JuiceTheme.juiceOrange,
                  size: 18,
                ),
                const SizedBox(width: 2),
                const Text(
                  'Juice',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: JuiceTheme.juiceOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 74,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: _showSessionSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  state.currentSession?.name ?? 'JuiceRoll',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          if (state.history.isNotEmpty)
            Semantics(
              label: 'Clear roll history',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, size: 18),
                tooltip: 'Clear History',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History?'),
                      content: const Text('This will remove all roll history for this session.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _notifier.clearHistory();
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
          const SizedBox(width: 8),
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
                    RollButton(
                      label: 'Details',
                      icon: Icons.palette,
                      onPressed: _showDetailsDialog,
                      color: JuiceTheme.parchmentDark,
                    ),
                    RollButton(
                      label: 'Immerse',
                      icon: Icons.visibility,
                      onPressed: _showImmersionDialog,
                      color: JuiceTheme.juiceOrange,
                    ),
                    RollButton(
                      label: 'Fate',
                      icon: Icons.help_outline,
                      onPressed: _showFateCheckDialog,
                      color: JuiceTheme.mystic,
                    ),
                    RollButton(
                      label: 'Scene',
                      icon: Icons.theaters,
                      onPressed: _showNextSceneDialog,
                      color: JuiceTheme.info,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Row 2: Left Page (Expect, Scale, Interrupt) + Right Page (Meaning)
                  _buildButtonRow([
                    RollButton(
                      label: 'Expect',
                      icon: Icons.psychology,
                      onPressed: _showExpectationCheckDialog,
                      color: JuiceTheme.mystic,
                    ),
                    RollButton(
                      label: 'Scale',
                      icon: Icons.swap_vert,
                      onPressed: _notifier.rollScale,
                      color: JuiceTheme.categoryCharacter,
                    ),
                    RollButton(
                      label: 'Interrupt',
                      icon: Icons.bolt,
                      onPressed: _notifier.rollInterruptPlotPoint,
                      color: JuiceTheme.juiceOrange,
                    ),
                    RollButton(
                      label: 'Meaning',
                      icon: Icons.lightbulb_outline,
                      onPressed: _notifier.rollDiscoverMeaning,
                      color: JuiceTheme.gold,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Row 3: Second Inside Folded (Name, Random) + Back Page (Quest, Challenge)
                  _buildButtonRow([
                    RollButton(
                      label: 'Name',
                      icon: Icons.badge,
                      onPressed: _showNameGeneratorDialog,
                      color: JuiceTheme.categoryCharacter,
                    ),
                    RollButton(
                      label: 'Random',
                      icon: Icons.casino,
                      onPressed: _showRandomTablesDialog,
                      color: JuiceTheme.gold,
                    ),
                    RollButton(
                      label: 'Quest',
                      icon: Icons.map,
                      onPressed: _notifier.rollQuest,
                      color: JuiceTheme.rust,
                    ),
                    RollButton(
                      label: 'Challenge',
                      icon: Icons.fitness_center,
                      onPressed: _showChallengeDialog,
                      color: JuiceTheme.categoryCombat,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Row 4: Back Page (Price) + First Inside Unfolded (Wilderness, Monster) + Second Inside Unfolded (NPC)
                  _buildButtonRow([
                    RollButton(
                      label: 'Price',
                      icon: Icons.warning,
                      onPressed: _showPayThePriceDialog,
                      color: JuiceTheme.danger,
                    ),
                    RollButton(
                      label: 'Wilderness',
                      icon: Icons.forest,
                      onPressed: _showWildernessDialog,
                      color: JuiceTheme.categoryExplore,
                    ),
                    RollButton(
                      label: 'Monster',
                      icon: Icons.pest_control,
                      onPressed: _showMonsterDialog,
                      color: JuiceTheme.danger,
                    ),
                    RollButton(
                      label: 'NPC',
                      icon: Icons.person,
                      onPressed: _showNpcActionDialog,
                      color: JuiceTheme.categoryCharacter,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Row 5: Second Inside Unfolded (Dialog, Settlement) + Third Inside Unfolded (Treasure) + Fourth Inside Unfolded (Dungeon)
                  _buildButtonRow([
                    RollButton(
                      label: 'Dialog',
                      icon: Icons.chat,
                      onPressed: _showDialogGeneratorDialog,
                      color: JuiceTheme.categoryCharacter,
                    ),
                    RollButton(
                      label: 'Settlement',
                      icon: Icons.location_city,
                      onPressed: _showSettlementDialog,
                      color: JuiceTheme.categoryWorld,
                    ),
                    RollButton(
                      label: 'Treasure',
                      icon: Icons.diamond,
                      onPressed: _showTreasureDialog,
                      color: JuiceTheme.gold,
                    ),
                    RollButton(
                      label: 'Dungeon',
                      icon: Icons.castle,
                      onPressed: _showDungeonDialog,
                      color: JuiceTheme.categoryUtility,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Row 6: Fourth Inside Unfolded (Location) + Left Extension (NPC Talk) + Right Extension (Abstract) + Dice Utility
                  _buildButtonRow([
                    RollButton(
                      label: 'Location',
                      icon: Icons.grid_on,
                      onPressed: _showLocationDialog,
                      color: JuiceTheme.rust,
                    ),
                    RollButton(
                      label: 'NPC Talk',
                      icon: Icons.record_voice_over,
                      onPressed: _showExtendedNpcDialog,
                      color: JuiceTheme.mystic,
                    ),
                    RollButton(
                      label: 'Abstract',
                      icon: Icons.image,
                      onPressed: _showAbstractIconsDialog,
                      color: JuiceTheme.success,
                    ),
                    RollButton(
                      label: 'Dice',
                      icon: Icons.casino,
                      onPressed: _showDiceRollDialog,
                      color: JuiceTheme.categoryUtility,
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Compact History Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            decoration: BoxDecoration(
              color: JuiceTheme.ink.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: JuiceTheme.parchmentDark.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 12,
                  color: JuiceTheme.parchmentDark.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Roll History',
                  style: TextStyle(
                    fontSize: 11,
                    color: JuiceTheme.parchmentDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // History Section
          Expanded(
            flex: 1,
            child: state.history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 48,
                          color: JuiceTheme.parchmentDark.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No rolls yet',
                          style: TextStyle(
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: JuiceTheme.parchmentDark.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap an oracle button to begin',
                          style: TextStyle(
                            color: JuiceTheme.parchmentDark.withOpacity(0.35),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : RollHistory(
                    history: state.history,
                    onSetWildernessPosition: _notifier.setWildernessPosition,
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
              aspectRatio: 1.03,
              child: btn,
            ),
          ),
        );
      }).toList(),
    );
  }
}

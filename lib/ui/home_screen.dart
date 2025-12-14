import 'package:flutter/material.dart';
import '../models/session.dart';
import 'home_state.dart';
import 'home_screen_components.dart';
import 'theme/juice_theme.dart';
import 'widgets/dice_roll_dialog.dart';
import 'widgets/fate_check_dialog.dart';
import 'widgets/next_scene_dialog.dart';
import 'dialogs/dialogs.dart';

/// Home screen with roll buttons and history.
/// 
/// ## Performance Architecture
/// 
/// This widget uses **targeted rebuilds** to avoid unnecessary work:
/// 
/// - **OracleButtonGrid**: Static, never rebuilds (24 buttons)
/// - **SessionAppBarTitle**: Only rebuilds when session name changes
/// - **ClearHistoryButton**: Only rebuilds when history empty state changes
/// - **HistorySection**: Only rebuilds when history changes (most frequent)
/// 
/// See [home_screen_components.dart] for the extracted widgets and
/// documentation on how to add new stateful components.
/// 
/// ## Why Not Just setState?
/// 
/// Before: `setState(() {})` rebuilt ALL widgets on ANY state change.
/// After: Each component uses `ListenableBuilder` to rebuild only itself.
/// 
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
  
  /// Cached callbacks for the button grid - created once, never changes.
  /// This prevents recreating callback objects on every build.
  late final OracleButtonCallbacks _buttonCallbacks;

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
    
    // Create button callbacks once - these never change
    _buttonCallbacks = OracleButtonCallbacks(
      showDetailsDialog: _showDetailsDialog,
      showImmersionDialog: _showImmersionDialog,
      showFateCheckDialog: _showFateCheckDialog,
      showNextSceneDialog: _showNextSceneDialog,
      showExpectationCheckDialog: _showExpectationCheckDialog,
      showNameGeneratorDialog: _showNameGeneratorDialog,
      showRandomTablesDialog: _showRandomTablesDialog,
      showChallengeDialog: _showChallengeDialog,
      showPayThePriceDialog: _showPayThePriceDialog,
      showWildernessDialog: _showWildernessDialog,
      showMonsterDialog: _showMonsterDialog,
      showNpcActionDialog: _showNpcActionDialog,
      showDialogGeneratorDialog: _showDialogGeneratorDialog,
      showSettlementDialog: _showSettlementDialog,
      showTreasureDialog: _showTreasureDialog,
      showDungeonDialog: _showDungeonDialog,
      showLocationDialog: _showLocationDialog,
      showExtendedNpcDialog: _showExtendedNpcDialog,
      showAbstractIconsDialog: _showAbstractIconsDialog,
      showDiceRollDialog: _showDiceRollDialog,
      rollScale: _notifier.rollScale,
      rollInterruptPlotPoint: _notifier.rollInterruptPlotPoint,
      rollDiscoverMeaning: _notifier.rollDiscoverMeaning,
      rollQuest: _notifier.rollQuest,
    );
    
    // NOTE: We no longer call _notifier.addListener(_onStateChange) here!
    // Each component now uses ListenableBuilder for targeted rebuilds.
    // The only exception is the loading state, which we handle specially.
  }

  @override
  void dispose() {
    if (_ownsNotifier) {
      _notifier.dispose();
    }
    super.dispose();
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
    // PERFORMANCE: Only the loading state check uses direct state access.
    // All other state-dependent UI uses ListenableBuilder for targeted rebuilds.
    // See home_screen_components.dart for details.
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        if (_notifier.state.isLoading) {
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
        
        // Once loaded, return the main UI which uses targeted rebuilds
        return _buildMainScreen();
      },
    );
  }
  
  /// Builds the main screen layout.
  /// 
  /// This method builds ONCE after loading completes. Individual components
  /// handle their own rebuilds via ListenableBuilder:
  /// 
  /// - [SessionAppBarTitle] - rebuilds on session name change
  /// - [ClearHistoryButton] - rebuilds on history empty state change
  /// - [OracleButtonGrid] - NEVER rebuilds (static)
  /// - [HistorySection] - rebuilds on history change
  Widget _buildMainScreen() {
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
        // TARGETED REBUILD: Only rebuilds when session name changes
        title: SessionAppBarTitle(
          notifier: _notifier,
          onTap: _showSessionSelector,
        ),
        centerTitle: true,
        actions: [
          // TARGETED REBUILD: Only rebuilds when history empty state changes
          ClearHistoryButton(
            notifier: _notifier,
            onPressed: _showClearHistoryDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // STATIC: Oracle button grid - never rebuilds (24 buttons)
          Expanded(
            flex: 2,
            child: OracleButtonGrid(callbacks: _buttonCallbacks),
          ),

          // STATIC: History section header - never rebuilds
          const HistorySectionHeader(),

          // TARGETED REBUILD: History section - rebuilds when history changes
          Expanded(
            flex: 1,
            child: HistorySection(notifier: _notifier),
          ),
        ],
      ),
    );
  }
  
  /// Shows the clear history confirmation dialog.
  void _showClearHistoryDialog() {
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
  }
}

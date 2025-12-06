import 'package:flutter/material.dart';
import '../models/roll_result.dart';
import '../models/roll_result_factory.dart';
import '../models/session.dart';
import '../services/session_service.dart';
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
import '../presets/extended_npc_conversation.dart';
import '../presets/abstract_icons.dart';
import 'theme/juice_theme.dart';
import 'widgets/roll_button.dart';
import 'widgets/roll_history.dart';
import 'widgets/dice_roll_dialog.dart';
import 'widgets/fate_check_dialog.dart';
import 'widgets/next_scene_dialog.dart';
import 'dialogs/dialogs.dart';

/// Home screen with roll buttons and history.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RollResult> _history = [];
  final RollEngine _rollEngine = RollEngine();
  final SessionService _sessionService = SessionService();
  
  // Session state
  Session? _currentSession;
  List<Session> _sessions = [];
  bool _isLoading = true;
  
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
  // Dungeon map generation mode: false = One-Pass, true = Two-Pass
  bool _isDungeonTwoPassMode = false;
  // Two-Pass map generation state (persists across dialog opens)
  bool _twoPassHasFirstDoubles = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    
    try {
      await _sessionService.init();
      final session = await _sessionService.loadActiveSession();
      final sessions = await _sessionService.getSessions();
      
      setState(() {
        _currentSession = session;
        _sessions = sessions;
        _isLoading = false;
        
        // Load history from session
        _history.clear();
        for (final json in session.history) {
          _history.add(RollResultFactory.fromJson(json));
        }
        
        // Restore stateful preset states
        _isDungeonEntering = session.dungeonIsEntering;
        _isDungeonTwoPassMode = session.dungeonIsTwoPassMode;
        _twoPassHasFirstDoubles = session.twoPassHasFirstDoubles;
        
        // Restore wilderness state if available
        if (session.wildernessEnvironmentRow != null) {
          _wilderness.initializeAt(
            session.wildernessEnvironmentRow!,
            typeRow: session.wildernessTypeRow,
            isLost: session.wildernessIsLost,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _switchSession(Session session) async {
    final fullSession = await _sessionService.getSession(session.id);
    if (fullSession == null) return;
    
    await _sessionService.setActiveSessionId(session.id);
    
    setState(() {
      _currentSession = fullSession;
      _history.clear();
      for (final json in fullSession.history) {
        _history.add(RollResultFactory.fromJson(json));
      }
      
      // Restore stateful preset states
      _isDungeonEntering = fullSession.dungeonIsEntering;
      _isDungeonTwoPassMode = fullSession.dungeonIsTwoPassMode;
      _twoPassHasFirstDoubles = fullSession.twoPassHasFirstDoubles;
      
      // Restore wilderness state
      if (fullSession.wildernessEnvironmentRow != null) {
        _wilderness.initializeAt(
          fullSession.wildernessEnvironmentRow!,
          typeRow: fullSession.wildernessTypeRow,
          isLost: fullSession.wildernessIsLost,
        );
      }
    });
    
    // Refresh session list
    final sessions = await _sessionService.getSessions();
    setState(() => _sessions = sessions);
  }

  void _setDungeonPhase(bool isEntering) {
    setState(() => _isDungeonEntering = isEntering);
    _saveSessionState();
  }

  void _setDungeonTwoPassMode(bool isTwoPassMode) {
    setState(() => _isDungeonTwoPassMode = isTwoPassMode);
    _saveSessionState();
  }

  void _setTwoPassFirstDoubles(bool hasFirstDoubles) {
    setState(() => _twoPassHasFirstDoubles = hasFirstDoubles);
    _saveSessionState();
  }

  Future<void> _saveSessionState() async {
    if (_currentSession == null) return;
    
    _currentSession!.dungeonIsEntering = _isDungeonEntering;
    _currentSession!.dungeonIsTwoPassMode = _isDungeonTwoPassMode;
    _currentSession!.twoPassHasFirstDoubles = _twoPassHasFirstDoubles;
    
    // Save wilderness state
    final wildernessState = _wilderness.state;
    if (wildernessState != null) {
      _currentSession!.wildernessEnvironmentRow = wildernessState.environmentRow;
      _currentSession!.wildernessTypeRow = wildernessState.typeRow;
      _currentSession!.wildernessIsLost = wildernessState.isLost;
    }
    
    await _sessionService.saveSession(_currentSession!);
  }

  void _addToHistory(RollResult result) {
    setState(() {
      _history.insert(0, result);
      // Keep only last 100 results in memory
      if (_history.length > 100) {
        _history.removeLast();
      }
    });
    
    // Save to session
    if (_currentSession != null) {
      _currentSession!.history.insert(0, result.toJson());
      if (_currentSession!.history.length > 200) {
        _currentSession!.history.removeLast();
      }
      _sessionService.saveSession(_currentSession!);
    }
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    
    if (_currentSession != null) {
      _currentSession!.history.clear();
      _sessionService.saveSession(_currentSession!);
    }
  }

  void _showSessionSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SessionSelectorSheet(
        sessions: _sessions,
        currentSession: _currentSession,
        onSelectSession: (session) {
          _switchSession(session);
        },
        onNewSession: () {
          _showNewSessionDialog();
        },
        onShowDetails: (session) {
          _showSessionDetailsDialog(session);
        },
        onDeleteSession: (session) async {
          await _sessionService.deleteSession(session.id);
          
          // If we deleted the current session, load another
          if (_currentSession?.id == session.id) {
            await _loadSession();
          } else {
            final sessions = await _sessionService.getSessions();
            setState(() => _sessions = sessions);
          }
          
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
              
              final session = await _sessionService.createSession(
                name,
                notes: notesController.text.trim().isEmpty 
                    ? null 
                    : notesController.text.trim(),
              );
              
              // Refresh session list immediately after creation
              final sessions = await _sessionService.getSessions();
              if (mounted) {
                setState(() => _sessions = sessions);
              }
              
              await _switchSession(session);
              
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

  void _showSessionDetailsDialog(Session session) async {
    // Load full session data
    final fullSession = await _sessionService.getSession(session.id);
    if (fullSession == null || !mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => SessionDetailsDialog(
        session: fullSession,
        isCurrentSession: _currentSession?.id == session.id,
        onDelete: () async {
          await _sessionService.deleteSession(session.id);
          
          // If we deleted the current session, load another
          if (_currentSession?.id == session.id) {
            await _loadSession();
          } else {
            final sessions = await _sessionService.getSessions();
            setState(() => _sessions = sessions);
          }
          
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
          await _sessionService.updateSession(
            session.id,
            name: updatedSession.name,
            notes: updatedSession.notes,
          );
          final sessions = await _sessionService.getSessions();
          setState(() => _sessions = sessions);
          if (_currentSession?.id == session.id) {
            _currentSession!.name = updatedSession.name;
            _currentSession!.notes = updatedSession.notes;
          }
        },
      ),
    );
  }

  Future<void> _importSession() async {
    final session = await _sessionService.importSession();
    
    if (!mounted) return;
    
    final messenger = ScaffoldMessenger.of(context);
    
    if (session != null) {
      final sessions = await _sessionService.getSessions();
      setState(() => _sessions = sessions);
      
      messenger.showSnackBar(
        SnackBar(
          content: Text('Imported session: ${session.name}'),
          action: SnackBarAction(
            label: 'Switch',
            onPressed: () => _switchSession(session),
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
      builder: (context) => RandomTablesDialog(
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
      builder: (context) => NpcActionDialog(
        npcAction: _npcAction,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showSettlementDialog() {
    showDialog(
      context: context,
      builder: (context) => SettlementDialog(
        settlement: _settlement,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showTreasureDialog() {
    showDialog(
      context: context,
      builder: (context) => TreasureDialog(
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
      builder: (context) => ChallengeDialog(
        challenge: _challenge,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showPayThePriceDialog() {
    showDialog(
      context: context,
      builder: (context) => PayThePriceDialog(
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
      builder: (context) => DetailsDialog(
        details: _details,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showImmersionDialog() {
    showDialog(
      context: context,
      builder: (context) => ImmersionDialog(
        immersion: _immersion,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showExpectationCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpectationCheckDialog(
        expectationCheck: _expectationCheck,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showDialogGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => DialogGeneratorDialog(
        dialogGenerator: _dialogGenerator,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showNameGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => NameGeneratorDialog(
        nameGenerator: _nameGenerator,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showDungeonDialog() {
    showDialog(
      context: context,
      builder: (context) => DungeonDialog(
        dungeonGenerator: _dungeonGenerator,
        onRoll: _addToHistory,
        isEntering: _isDungeonEntering,
        onPhaseChange: _setDungeonPhase,
        isTwoPassMode: _isDungeonTwoPassMode,
        onTwoPassModeChange: _setDungeonTwoPassMode,
        twoPassHasFirstDoubles: _twoPassHasFirstDoubles,
        onTwoPassFirstDoublesChange: _setTwoPassFirstDoubles,
      ),
    );
  }

  void _showWildernessDialog() {
    showDialog(
      context: context,
      builder: (context) => WildernessDialog(
        wilderness: _wilderness,
        onRoll: _addToHistory,
        dungeonGenerator: _dungeonGenerator,
        challenge: _challenge,
      ),
    );
  }

  void _showMonsterDialog() {
    showDialog(
      context: context,
      builder: (context) => MonsterEncounterDialog(
        onRoll: _addToHistory,
        wildernessState: _wilderness.state,
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => LocationDialog(
        onRoll: _addToHistory,
      ),
    );
  }

  void _showExtendedNpcDialog() {
    showDialog(
      context: context,
      builder: (context) => ExtendedNpcConversationDialog(
        extendedNpcConversation: _extendedNpcConversation,
        onRoll: _addToHistory,
      ),
    );
  }

  void _showAbstractIconsDialog() {
    showDialog(
      context: context,
      builder: (context) => AbstractIconsDialog(
        abstractIcons: _abstractIcons,
        onRoll: _addToHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 4.0),
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
        leadingWidth: 64,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: _showSessionSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _currentSession?.name ?? 'JuiceRoll',
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
          if (_history.isNotEmpty)
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
                      onPressed: _rollScale,
                      color: JuiceTheme.categoryCharacter,
                    ),
                    RollButton(
                      label: 'Interrupt',
                      icon: Icons.bolt,
                      onPressed: _rollInterruptPlotPoint,
                      color: JuiceTheme.juiceOrange,
                    ),
                    RollButton(
                      label: 'Meaning',
                      icon: Icons.lightbulb_outline,
                      onPressed: _rollDiscoverMeaning,
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
                      onPressed: _rollQuest,
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
              color: JuiceTheme.ink.withValues(alpha: 0.3),
              border: Border(
                top: BorderSide(
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 12,
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Roll History',
                  style: TextStyle(
                    fontSize: 11,
                    color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                if (_history.isNotEmpty)
                  Text(
                    '${_history.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: JuiceTheme.parchmentDark.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),

          // History Section
          Expanded(
            flex: 1,
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 48,
                          color: JuiceTheme.parchmentDark.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No rolls yet',
                          style: TextStyle(
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: JuiceTheme.parchmentDark.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap an oracle button to begin',
                          style: TextStyle(
                            color: JuiceTheme.parchmentDark.withValues(alpha: 0.35),
                            fontSize: 12,
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
              aspectRatio: 1.03,
              child: btn,
            ),
          ),
        );
      }).toList(),
    );
  }
}

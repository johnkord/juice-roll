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
import '../presets/monster_encounter.dart';
import '../presets/location.dart';
import '../presets/extended_npc_conversation.dart';
import '../presets/abstract_icons.dart';
import 'theme/juice_theme.dart';
import 'widgets/roll_button.dart';
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
      builder: (context) => _SessionSelectorSheet(
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
      builder: (context) => _SessionDetailsDialog(
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
      builder: (context) => _WildernessDialog(
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
        child: _ScrollableDialogContent(
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
            const _SectionHeader(title: 'NPC Creation', icon: Icons.person_add),
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
            // Complex NPC Section - moved up since it's the most complete option
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
              ),
              child: const Text(
                'Complex NPCs (sidekicks, important characters):\n'
                'Name + 2 Personalities + Need + Motive + Color + 2 Properties.\n'
                'Use @+ for people, @- for monsters.',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 4),
            _DialogOption(
              title: '⭐ Complex NPC (Person)',
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
              title: '⭐ Complex NPC (Monster)',
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
              title: 'Profile Only (No Name)',
              subtitle: '2 Personalities + Need${_getNeedSkewLabel()} + Motive + Color + Properties',
              onTap: () {
                widget.onRoll(widget.npcAction.generateProfile(needSkew: _needSkew));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            
            // Individual Rolls Section
            const _SectionHeader(title: 'Individual Rolls', icon: Icons.casino),
            const SizedBox(height: 4),
            _DialogOption(
              title: 'Personality',
              subtitle: 'd10 - Roll 2 for primary/secondary traits',
              onTap: () {
                widget.onRoll(widget.npcAction.rollPersonality());
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
              subtitle: 'd10 - Auto-rolls History/Focus tables',
              onTap: () {
                widget.onRoll(widget.npcAction.rollMotiveWithFollowUp());
                Navigator.pop(context);
              },
            ),
            const Divider(),
              
            // Action Table Section
            const _SectionHeader(title: 'Action Table', icon: Icons.directions_run),
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
            const _SectionHeader(title: 'Combat Table', icon: Icons.sports_kabaddi),
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

  // Establishment type chips with their d6/d10 ranges
  Widget _buildEstablishmentChip(String name, String range, {bool cityOnly = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      decoration: BoxDecoration(
        color: cityOnly 
            ? JuiceTheme.gold.withValues(alpha: 0.15)
            : JuiceTheme.categoryWorld.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: cityOnly 
              ? JuiceTheme.gold.withValues(alpha: 0.4)
              : JuiceTheme.categoryWorld.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 9,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: cityOnly ? JuiceTheme.gold : JuiceTheme.categoryWorld,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            range,
            style: TextStyle(
              fontSize: 8,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: (cityOnly ? JuiceTheme.gold : JuiceTheme.categoryWorld).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  // News type chip
  Widget _buildNewsChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      margin: const EdgeInsets.only(right: 3, bottom: 3),
      decoration: BoxDecoration(
        color: JuiceTheme.juiceOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 8,
          color: JuiceTheme.juiceOrange.withValues(alpha: 0.9),
        ),
      ),
    );
  }
  
  // Settlement type card (Village/City)
  Widget _buildSettlementTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String mechanics,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mechanics,
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.casino, size: 11, color: color),
                        const SizedBox(width: 3),
                        Text(
                          'Roll',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settlementColor = JuiceTheme.categoryWorld;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.location_city, color: settlementColor, size: 24),
          const SizedBox(width: 8),
          const Text('Settlement'),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 340,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: settlementColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: settlementColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates, size: 14, color: settlementColor),
                        const SizedBox(width: 4),
                        Text(
                          'Settlements are places to rest, stock up on supplies,',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: settlementColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'collect quests, or chat with NPCs.',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: settlementColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Generate Settlement section - prominent
              Row(
                children: [
                  Icon(Icons.add_location_alt, size: 16, color: settlementColor),
                  const SizedBox(width: 6),
                  Text(
                    'Generate Settlement',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: settlementColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Village and City as prominent cards
              Row(
                children: [
                  Expanded(
                    child: _buildSettlementTypeCard(
                      context,
                      icon: Icons.house,
                      title: 'Village',
                      subtitle: 'Smaller, rural',
                      mechanics: '1d6@- count\nd6 establishments',
                      color: JuiceTheme.sepia,
                      onTap: () {
                        onRoll(settlement.generateVillage());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSettlementTypeCard(
                      context,
                      icon: Icons.location_city,
                      title: 'City',
                      subtitle: 'Larger, urban',
                      mechanics: '1d6@+ count\nd10 establishments',
                      color: JuiceTheme.gold,
                      onTap: () {
                        onRoll(settlement.generateCity());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              Divider(color: settlementColor.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              
              // Individual Rolls section
              Row(
                children: [
                  Icon(Icons.casino, size: 16, color: settlementColor),
                  const SizedBox(width: 6),
                  Text(
                    'Individual Rolls',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: settlementColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
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
              
              const SizedBox(height: 12),
              Divider(color: settlementColor.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              
              // Naming & Description section
              Row(
                children: [
                  Icon(Icons.edit_note, size: 16, color: JuiceTheme.mystic),
                  const SizedBox(width: 6),
                  Text(
                    'Naming & Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.mystic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Tip box for naming
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.palette, size: 12, color: JuiceTheme.mystic.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Use Color + Object for establishment names (e.g., "The Crimson Hourglass"). '
                        'The color helps mark on maps, the object is their emblem.',
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
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
              
              const SizedBox(height: 12),
              Divider(color: settlementColor.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              
              // News section
              Row(
                children: [
                  Icon(Icons.campaign, size: 16, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 6),
                  Text(
                    'News',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.juiceOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // News tip box
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.juiceOrange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.juiceOrange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 12, color: JuiceTheme.juiceOrange.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Roll when entering a settlement or on "Advance Time" random event. '
                        'With a Courier, ask for news from other settlements.',
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
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
              
              const SizedBox(height: 8),
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

  // Skew chip builder
  Widget _buildSkewChip(String label, SkewType type, Color color) {
    final isSelected = _skew == type;
    return GestureDetector(
      onTap: () => setState(() => _skew = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 14, color: color),
            if (isSelected)
              const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category card for treasure types
  Widget _buildCategoryCard({
    required String number,
    required String title,
    required String properties,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: JuiceTheme.fontFamilySerif,
                        color: color,
                      ),
                    ),
                    Text(
                      properties,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treasureColor = JuiceTheme.gold;
    final skewLabel = _skew == SkewType.advantage ? ' @+' : _skew == SkewType.disadvantage ? ' @-' : '';
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.diamond, color: treasureColor, size: 24),
          const SizedBox(width: 8),
          const Text('Treasure'),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 340,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Creation Procedure - prominent header
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: treasureColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: treasureColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: treasureColor),
                        const SizedBox(width: 6),
                        Text(
                          'Item Creation Procedure:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: treasureColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1. Roll 4d6 on Object/Treasure table\n'
                      '2. Roll two properties (1d10+1d6 each)\n'
                      '3. Optionally roll color for appearance/elemental',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Color toggle - styled
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _includeColor,
                        onChanged: (v) => setState(() => _includeColor = v ?? false),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: JuiceTheme.mystic.withValues(alpha: 0.6)),
                        activeColor: JuiceTheme.mystic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.palette, size: 14, color: JuiceTheme.mystic.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Include Color (appearance/elemental)',
                        style: TextStyle(
                          fontSize: 10,
                          color: _includeColor ? JuiceTheme.mystic : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Create Full Item - prominent button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onRoll(widget.treasure.generateFullItem(
                      skew: _skew,
                      includeColor: _includeColor,
                    ));
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          treasureColor.withValues(alpha: 0.2),
                          treasureColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: treasureColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18, color: treasureColor),
                        const SizedBox(width: 8),
                        Text(
                          'Create Full Item',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: treasureColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Center(
                  child: Text(
                    '4d6 + 2 Properties${_includeColor ? ' + Color' : ''}$skewLabel',
                    style: TextStyle(
                      fontSize: 9,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              
              // Skew selection
              Row(
                children: [
                  Icon(Icons.tune, size: 14, color: JuiceTheme.info),
                  const SizedBox(width: 6),
                  Text(
                    'Skew:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.info,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '@+ = Better, @- = Worse',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSkewChip('None', SkewType.none, JuiceTheme.info),
                  const SizedBox(width: 8),
                  _buildSkewChip('@- Worse', SkewType.disadvantage, JuiceTheme.rust),
                  const SizedBox(width: 8),
                  _buildSkewChip('@+ Better', SkewType.advantage, JuiceTheme.success),
                ],
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              
              // Roll 4d6 section
              Row(
                children: [
                  Icon(Icons.casino, size: 16, color: treasureColor),
                  const SizedBox(width: 6),
                  Text(
                    'Roll 4d6',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: treasureColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _DialogOption(
                title: 'Random Treasure (4d6)',
                subtitle: 'Category + Properties$skewLabel',
                onTap: () {
                  widget.onRoll(widget.treasure.generate(skew: _skew));
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              
              // By Category section
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: JuiceTheme.categoryWorld),
                  const SizedBox(width: 6),
                  Text(
                    'By Category (3d6)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.categoryWorld,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a specific category and roll 3d6 for properties:',
                style: TextStyle(
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Category grid - 2 columns
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      number: '1',
                      title: 'Trinket',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.sepia,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateTrinket(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCategoryCard(
                      number: '2',
                      title: 'Treasure',
                      properties: 'Quality + Container + Contents',
                      color: JuiceTheme.gold,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateTreasure(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      number: '3',
                      title: 'Document',
                      properties: 'Type + Content + Subject',
                      color: JuiceTheme.parchmentDark,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateDocument(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCategoryCard(
                      number: '4',
                      title: 'Accessory',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.mystic,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateAccessory(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      number: '5',
                      title: 'Weapon',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.danger,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateWeapon(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCategoryCard(
                      number: '6',
                      title: 'Armor',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.info,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateArmor(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              
              // Examples section
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 6),
                  Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.juiceOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic 4d6:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2,5,4,2: New satchel full of art.\n'
                      '6,1,5,3: Broken Mithral gloves.\n'
                      '4,4,1,1: Fine wooden headpiece (crown).',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Full Item Creation:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '4,3,4,5 → "Accessory: Simple Silver Necklace"\n'
                      '  Property: 9,5 → Major Value\n'
                      '  Property: 5,4 → Moderate Power\n'
                      '(A normal-looking necklace that grants power!)',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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

/// Dialog for Challenge options.
class _ChallengeDialog extends StatelessWidget {
  final Challenge challenge;
  final void Function(RollResult) onRoll;

  const _ChallengeDialog({required this.challenge, required this.onRoll});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Challenge',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge Procedure explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.categoryCombat.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.categoryCombat.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center, size: 14, color: JuiceTheme.categoryCombat),
                        const SizedBox(width: 6),
                        Text(
                          'Challenge Procedure',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: JuiceTheme.parchment,
                            fontFamily: JuiceTheme.fontFamilySerif,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1. Roll Physical + Mental challenge with DCs\n'
                      '2. Create a situation where both make sense\n'
                      '3. Choose ONE path - only need to pass one!\n'
                      '4. Fail = Pay The Price (may lock out other option)',
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchment.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Full Challenge section - primary action
              _ChallengeSectionHeader(
                icon: Icons.fitness_center,
                title: 'Full Challenge',
              ),
              const SizedBox(height: 4),
              Text(
                'Rolls 1 Physical + 1 Mental with separate DCs for each:',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
              const SizedBox(height: 6),
              // 3 difficulty options as chips
              Row(
                children: [
                  Expanded(
                    child: _ChallengeDifficultyChip(
                      label: 'Random DCs',
                      hint: '1d10 each',
                      color: JuiceTheme.parchmentDark,
                      onTap: () {
                        onRoll(challenge.rollFullChallenge());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ChallengeDifficultyChip(
                      label: 'Easy DCs',
                      hint: 'advantage',
                      color: JuiceTheme.success,
                      onTap: () {
                        onRoll(challenge.rollFullChallenge(dcSkew: DcSkew.advantage));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ChallengeDifficultyChip(
                      label: 'Hard DCs',
                      hint: 'disadvantage',
                      color: JuiceTheme.danger,
                      onTap: () {
                        onRoll(challenge.rollFullChallenge(dcSkew: DcSkew.disadvantage));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // DC Methods section
              _ChallengeSectionHeader(
                icon: Icons.gavel,
                title: 'DC Methods',
              ),
              const SizedBox(height: 4),
              Text(
                '5 ways to generate a DC:',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
              const SizedBox(height: 6),
              // 2x3 grid for DC methods
              Row(
                children: [
                  Expanded(
                    child: _ChallengeDcOption(
                      title: 'Quick DC',
                      subtitle: '2d6+6',
                      range: '8-18',
                      color: JuiceTheme.gold,
                      onTap: () {
                        onRoll(challenge.rollQuickDc());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ChallengeDcOption(
                      title: 'Random DC',
                      subtitle: '1d10',
                      range: '8-17',
                      color: JuiceTheme.parchmentDark,
                      onTap: () {
                        onRoll(challenge.rollDc());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _ChallengeDcOption(
                      title: 'Balanced DC',
                      subtitle: '1d100 bell',
                      range: 'middle DCs',
                      color: JuiceTheme.info,
                      onTap: () {
                        onRoll(challenge.rollBalancedDc());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ChallengeDcOption(
                      title: 'Easy DC',
                      subtitle: '1d10@+',
                      range: 'lower DC',
                      color: JuiceTheme.success,
                      onTap: () {
                        onRoll(challenge.rollDc(skew: DcSkew.advantage));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ChallengeDcOption(
                      title: 'Hard DC',
                      subtitle: '1d10@−',
                      range: 'higher DC',
                      color: JuiceTheme.danger,
                      onTap: () {
                        onRoll(challenge.rollDc(skew: DcSkew.disadvantage));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Individual Skills section
              _ChallengeSectionHeader(
                icon: Icons.sports_martial_arts,
                title: 'Individual Skills',
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _ChallengeSkillButton(
                      title: 'Physical',
                      color: JuiceTheme.rust,
                      skills: 'Medicine, Survival, Athletics...',
                      onTap: () {
                        onRoll(challenge.rollPhysicalChallenge());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ChallengeSkillButton(
                      title: 'Mental',
                      color: JuiceTheme.mystic,
                      skills: 'Nature, Arcana, Insight...',
                      onTap: () {
                        onRoll(challenge.rollMentalChallenge());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Examples section (compact)
              _ChallengeSectionHeader(
                icon: Icons.lightbulb_outline,
                title: 'Examples',
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChallengeExample(
                      rolls: '8,2',
                      physical: 'Stealth',
                      mental: 'Nature',
                      scenario: 'Capture an elusive creature',
                    ),
                    const SizedBox(height: 4),
                    _ChallengeExample(
                      rolls: '7,6',
                      physical: 'Sleight of Hand',
                      mental: 'Language',
                      scenario: 'Communicate with natives',
                    ),
                    const SizedBox(height: 4),
                    _ChallengeExample(
                      rolls: '9,7',
                      physical: 'Acrobatics',
                      mental: 'Religion',
                      scenario: 'Display martial arts/tai chi',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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

// ========== Challenge Dialog Helper Widgets ==========

class _ChallengeSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ChallengeSectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: JuiceTheme.categoryCombat),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: JuiceTheme.parchment,
            fontFamily: JuiceTheme.fontFamilySerif,
          ),
        ),
      ],
    );
  }
}

class _ChallengeDifficultyChip extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _ChallengeDifficultyChip({
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 8,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeDcOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String range;
  final Color color;
  final VoidCallback onTap;

  const _ChallengeDcOption({
    required this.title,
    required this.subtitle,
    required this.range,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
              Text(
                range,
                style: TextStyle(
                  fontSize: 7,
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeSkillButton extends StatelessWidget {
  final String title;
  final Color color;
  final String skills;
  final VoidCallback onTap;

  const _ChallengeSkillButton({
    required this.title,
    required this.color,
    required this.skills,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    title == 'Physical' ? Icons.directions_run : Icons.psychology,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                skills,
                style: TextStyle(
                  fontSize: 8,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeExample extends StatelessWidget {
  final String rolls;
  final String physical;
  final String mental;
  final String scenario;

  const _ChallengeExample({
    required this.rolls,
    required this.physical,
    required this.mental,
    required this.scenario,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: JuiceTheme.categoryCombat.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            rolls,
            style: TextStyle(
              fontSize: 8,
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: FontWeight.bold,
              color: JuiceTheme.categoryCombat,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 9, color: JuiceTheme.parchment),
              children: [
                TextSpan(
                  text: physical,
                  style: TextStyle(color: JuiceTheme.rust, fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' or '),
                TextSpan(
                  text: mental,
                  style: TextStyle(color: JuiceTheme.mystic, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' - $scenario',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
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
      title: Text(
        'Pay the Price',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: JuiceTheme.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'So you failed a challenge. Time to Pay The Price! '
                        'Use this to determine the effect of your failure.',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.parchment,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Pay The Price button - primary action
              _PayThePriceButton(
                title: 'Pay The Price',
                subtitle: 'Standard consequence (1d10)',
                icon: Icons.casino,
                color: JuiceTheme.rust,
                onTap: () {
                  onRoll(payThePrice.rollConsequence());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),

              // Standard consequences table
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible Outcomes:',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _PriceOutcomeChip('Unintended Effect'),
                        _PriceOutcomeChip('Situation Worsens'),
                        _PriceOutcomeChip('Delayed'),
                        _PriceOutcomeChip('Act Against Intentions'),
                        _PriceOutcomeChip('New Danger'),
                        _PriceOutcomeChip('Community in Danger'),
                        _PriceOutcomeChip('Separated'),
                        _PriceOutcomeChip('Value Lost'),
                        _PriceOutcomeChip('Complication'),
                        _PriceOutcomeChip('Betrayal'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Major Plot Twist section
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, size: 14, color: JuiceTheme.danger),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'For "Miss with a Match" or Critical Fail, use the Major Plot Twist:',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.parchment,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Major Plot Twist button
              _PayThePriceButton(
                title: 'Major Plot Twist',
                subtitle: 'Critical failure consequence (1d10)',
                icon: Icons.bolt,
                color: JuiceTheme.danger,
                onTap: () {
                  onRoll(payThePrice.rollMajorTwist());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),

              // Major twists table
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.danger.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible Twists:',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.danger.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _PriceTwistChip('Benefits Enemy'),
                        _PriceTwistChip('Assumption False'),
                        _PriceTwistChip('Dark Secret'),
                        _PriceTwistChip('Enemy Allies'),
                        _PriceTwistChip('Common Goal'),
                        _PriceTwistChip('Diversion'),
                        _PriceTwistChip('Secret Alliance'),
                        _PriceTwistChip('Someone Returns'),
                        _PriceTwistChip('Connected'),
                        _PriceTwistChip('Too Late'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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

// ========== Pay The Price Dialog Helper Widgets ==========

class _PayThePriceButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PayThePriceButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: JuiceTheme.fontFamilySerif,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceOutcomeChip extends StatelessWidget {
  final String label;

  const _PriceOutcomeChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: JuiceTheme.rust.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }
}

class _PriceTwistChip extends StatelessWidget {
  final String label;

  const _PriceTwistChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: JuiceTheme.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: JuiceTheme.parchment,
        ),
      ),
    );
  }
}

/// Dialog for Details options.
class _DetailsDialog extends StatelessWidget {
  final Details details;
  final void Function(RollResult) onRoll;

  const _DetailsDialog({required this.details, required this.onRoll});

  // Section theme colors
  static const Color _colorSectionColor = Color(0xFF6B8EAE); // Blue-ish
  static const Color _propertySectionColor = JuiceTheme.gold;
  static const Color _detailSectionColor = JuiceTheme.mystic;
  static const Color _historySectionColor = JuiceTheme.rust;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JuiceTheme.gold.withValues(alpha: 0.3),
                  JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_fix_high, color: JuiceTheme.gold, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Front Page',
                style: TextStyle(
                  fontSize: 11,
                  color: JuiceTheme.parchmentDark,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JuiceTheme.parchmentDark.withValues(alpha: 0.12),
                      JuiceTheme.gold.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: JuiceTheme.parchmentDark.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, 
                      color: JuiceTheme.gold.withValues(alpha: 0.7), 
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Add flavor to NPCs, items, settlements, or interpret oracle results.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // ═══════════════════════════════════════════════════════════════
              // COLOR SECTION
              // ═══════════════════════════════════════════════════════════════
              _DetailsSectionCard(
                icon: Icons.palette,
                title: 'Color',
                color: _colorSectionColor,
                description: 'Eye/hair color, armor accents, banners, dragon species...',
                child: Column(
                  children: [
                    // Color swatches preview
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: JuiceTheme.inkDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _colorSwatch(Colors.black87, '⬛'),
                          _colorSwatch(Colors.brown, '🟫'),
                          _colorSwatch(Colors.yellow.shade700, '🟨'),
                          _colorSwatch(Colors.green.shade700, '🟩'),
                          _colorSwatch(Colors.blue.shade700, '🟦'),
                          _colorSwatch(Colors.red.shade700, '🟥'),
                          _colorSwatch(Colors.purple.shade400, '🟪'),
                          _colorSwatch(Colors.grey.shade400, '⬜'),
                          _colorSwatch(Colors.amber, '🟡'),
                          _colorSwatch(Colors.white70, '⬜'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailsRollButton(
                      label: 'Roll Color',
                      subtitle: 'd10',
                      icon: Icons.colorize,
                      color: _colorSectionColor,
                      onTap: () {
                        onRoll(details.rollColor());
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // PROPERTY SECTION - ESSENTIAL
              // ═══════════════════════════════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _propertySectionColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _propertySectionColor.withValues(alpha: 0.12),
                      _propertySectionColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Essential badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _propertySectionColor.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: _propertySectionColor),
                          const SizedBox(width: 6),
                          Text(
                            'Property',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _propertySectionColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _propertySectionColor.withValues(alpha: 0.4),
                                  _propertySectionColor.withValues(alpha: 0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 10, color: _propertySectionColor),
                                const SizedBox(width: 3),
                                Text(
                                  'ESSENTIAL',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _propertySectionColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quote
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: JuiceTheme.inkDark.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border(
                                left: BorderSide(
                                  color: _propertySectionColor.withValues(alpha: 0.6),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: const Text(
                              '"If you only take one table from this whole thing, take this one."',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: JuiceTheme.parchment,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Property & Intensity reference
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: JuiceTheme.rust.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: const Text('d10', 
                                              style: TextStyle(
                                                fontSize: 9, 
                                                fontFamily: JuiceTheme.fontFamilyMono,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('Property', 
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Age • Size • Value • Style • Power • Quality...',
                                        style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: JuiceTheme.info.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: const Text('d6', 
                                              style: TextStyle(
                                                fontSize: 9, 
                                                fontFamily: JuiceTheme.fontFamilyMono,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('Intensity', 
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Minimal → Minor → Mundane → Major → Max',
                                        style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Roll buttons
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _DetailsRollButton(
                                  label: 'Property ×2',
                                  subtitle: 'Recommended',
                                  icon: Icons.content_copy,
                                  color: _propertySectionColor,
                                  isPrimary: true,
                                  onTap: () {
                                    onRoll(details.rollTwoProperties());
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _DetailsRollButton(
                                  label: '×1',
                                  subtitle: 'Single',
                                  icon: Icons.looks_one,
                                  color: _propertySectionColor,
                                  onTap: () {
                                    onRoll(details.rollProperty());
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // DETAIL SECTION
              // ═══════════════════════════════════════════════════════════════
              _DetailsSectionCard(
                icon: Icons.help_outline,
                title: 'Detail',
                color: _detailSectionColor,
                description: 'Oracle threw a curveball? Ground meaning to a thread, character, or emotion.',
                child: Column(
                  children: [
                    _DetailsRollButton(
                      label: 'Roll Detail',
                      subtitle: 'Emotion / Favors / Disfavors (PC, Thread, NPC)',
                      icon: Icons.casino,
                      color: _detailSectionColor,
                      onTap: () {
                        onRoll(details.rollDetailWithFollowUp());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Positive',
                            subtitle: 'Favorable',
                            icon: Icons.thumb_up_outlined,
                            color: JuiceTheme.success,
                            onTap: () {
                              onRoll(details.rollDetailWithFollowUp(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Negative',
                            subtitle: 'Unfavorable',
                            icon: Icons.thumb_down_outlined,
                            color: JuiceTheme.danger,
                            onTap: () {
                              onRoll(details.rollDetailWithFollowUp(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // HISTORY SECTION
              // ═══════════════════════════════════════════════════════════════
              _DetailsSectionCard(
                icon: Icons.history,
                title: 'History',
                color: _historySectionColor,
                description: 'Tie elements to the past: backstory, past scenes, previous actions, or threads.',
                child: Column(
                  children: [
                    _DetailsRollButton(
                      label: 'Roll History',
                      subtitle: 'Backstory → Past Thread → Current Action...',
                      icon: Icons.auto_stories,
                      color: _historySectionColor,
                      onTap: () {
                        onRoll(details.rollHistory());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Recent',
                            subtitle: 'Present',
                            icon: Icons.update,
                            color: JuiceTheme.info,
                            onTap: () {
                              onRoll(details.rollHistory(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailsSkewButton(
                            label: 'Distant',
                            subtitle: 'Past',
                            icon: Icons.hourglass_empty,
                            color: JuiceTheme.sepia,
                            onTap: () {
                              onRoll(details.rollHistory(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _colorSwatch(Color color, String emoji) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: JuiceTheme.parchmentDark.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
    );
  }
}

/// Section card for Details dialog
class _DetailsSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String description;
  final Widget child;

  const _DetailsSectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.06),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Roll button for Details dialog
class _DetailsRollButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _DetailsRollButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isPrimary ? null : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: isPrimary ? 0.5 : 0.3),
              width: isPrimary ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skew button (Positive/Negative, Recent/Distant)
class _DetailsSkewButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DetailsSkewButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact dialog option for side-by-side layouts (e.g., advantage/disadvantage).
class _CompactDialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CompactDialogOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: iconColor.withValues(alpha: 0.08),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: iconColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 9,
                          color: iconColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for Immersion options.
class _ImmersionDialog extends StatelessWidget {
  final Immersion immersion;
  final void Function(RollResult) onRoll;

  const _ImmersionDialog({required this.immersion, required this.onRoll});

  // Section theme colors
  static const Color _fullImmersionColor = JuiceTheme.gold;
  static const Color _sensoryColor = JuiceTheme.info;
  static const Color _emotionalColor = JuiceTheme.mystic;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  JuiceTheme.juiceOrange.withValues(alpha: 0.3),
                  JuiceTheme.mystic.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.self_improvement, color: JuiceTheme.juiceOrange, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Immersion',
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Be your character',
                style: TextStyle(
                  fontSize: 11,
                  color: JuiceTheme.parchmentDark,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JuiceTheme.juiceOrange.withValues(alpha: 0.12),
                      JuiceTheme.mystic.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: JuiceTheme.juiceOrange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, 
                      color: JuiceTheme.juiceOrange.withValues(alpha: 0.7), 
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'See what they see, feel what they feel. Perfect when you\'re "stuck" — provides hints about the environment.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // ═══════════════════════════════════════════════════════════════
              // FULL IMMERSION - COMPLETE EXPERIENCE
              // ═══════════════════════════════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fullImmersionColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _fullImmersionColor.withValues(alpha: 0.12),
                      _fullImmersionColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Complete badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _fullImmersionColor.withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: _fullImmersionColor),
                          const SizedBox(width: 6),
                          Text(
                            'Full Immersion',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _fullImmersionColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _fullImmersionColor.withValues(alpha: 0.4),
                                  _fullImmersionColor.withValues(alpha: 0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 10, color: _fullImmersionColor),
                                const SizedBox(width: 3),
                                Text(
                                  'COMPLETE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _fullImmersionColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Output format quote
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: JuiceTheme.inkDark.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border(
                                left: BorderSide(
                                  color: _fullImmersionColor.withValues(alpha: 0.6),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: const Text(
                              '"You [sense] something [detail] [where], and it causes [emotion] because [cause]"',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: JuiceTheme.parchment,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Roll button
                          _ImmersionRollButton(
                            label: 'Full Immersion',
                            subtitle: '5d10 + 1dF → Complete sensory experience',
                            icon: Icons.auto_awesome,
                            color: _fullImmersionColor,
                            isPrimary: true,
                            onTap: () {
                              onRoll(immersion.generateFullImmersion());
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // ═══════════════════════════════════════════════════════════════
              // SENSORY DETAIL SECTION
              // ═══════════════════════════════════════════════════════════════
              _ImmersionSectionCard(
                icon: Icons.visibility,
                title: 'Sensory Detail',
                color: _sensoryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference info
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDiceReference('d10', 'Sense', 'See (1-3), Hear (4-6), Smell (7-8), Feel (9-0)', _sensoryColor),
                          const SizedBox(height: 3),
                          _buildDiceReference('d10', 'Detail', 'Based on sense (Broken, Colorful, Shiny...)', _sensoryColor),
                          const SizedBox(height: 3),
                          _buildDiceReference('d10', 'Where', 'Above, Behind, In The Distance, Next To You...', _sensoryColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ImmersionRollButton(
                      label: 'Sensory Detail',
                      subtitle: '3d10 → "You [sense] something [detail] [where]"',
                      icon: Icons.visibility,
                      color: _sensoryColor,
                      onTap: () {
                        onRoll(immersion.generateSensoryDetail());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Closer',
                            subtitle: 'Near you',
                            icon: Icons.near_me,
                            color: JuiceTheme.success,
                            onTap: () {
                              onRoll(immersion.generateSensoryDetail(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Further',
                            subtitle: 'Far away',
                            icon: Icons.explore,
                            color: JuiceTheme.info,
                            onTap: () {
                              onRoll(immersion.generateSensoryDetail(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ImmersionRollButton(
                      label: 'Distant Senses Only',
                      subtitle: 'd6 → See or Hear only (exploration/scouting)',
                      icon: Icons.remove_red_eye_outlined,
                      color: _sensoryColor.withValues(alpha: 0.7),
                      onTap: () {
                        onRoll(immersion.generateSensoryDetail(senseDie: 6));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // EMOTIONAL ATMOSPHERE SECTION
              // ═══════════════════════════════════════════════════════════════
              _ImmersionSectionCard(
                icon: Icons.mood,
                title: 'Emotional Atmosphere',
                color: _emotionalColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference info
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: JuiceTheme.inkDark.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildSmallDieBadge('1dF', _emotionalColor),
                              const SizedBox(width: 6),
                              Text(
                                'polarity: (−/blank) negative, (+) positive',
                                style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Emotions paired as opposites: Despair↔Hope, Fear↔Courage, Anger↔Calm...',
                            style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Basic 6: Joy, Sadness, Fear, Anger, Disgust, Surprise',
                            style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: JuiceTheme.parchment),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ImmersionRollButton(
                      label: 'Emotional Atmosphere',
                      subtitle: '2d10 + 1dF → "It causes [emotion] because [cause]"',
                      icon: Icons.mood,
                      color: _emotionalColor,
                      onTap: () {
                        onRoll(immersion.generateEmotionalAtmosphere());
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Positive',
                            subtitle: 'Hopeful',
                            icon: Icons.sentiment_satisfied_alt,
                            color: JuiceTheme.success,
                            onTap: () {
                              onRoll(immersion.generateEmotionalAtmosphere(skew: SkewType.advantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ImmersionSkewButton(
                            label: 'Negative',
                            subtitle: 'Darker',
                            icon: Icons.sentiment_dissatisfied,
                            color: JuiceTheme.danger,
                            onTap: () {
                              onRoll(immersion.generateEmotionalAtmosphere(skew: SkewType.disadvantage));
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ImmersionRollButton(
                      label: 'Basic Emotions Only',
                      subtitle: 'd6 → Joy, Sadness, Fear, Anger, Disgust, Surprise',
                      icon: Icons.emoji_emotions_outlined,
                      color: _emotionalColor.withValues(alpha: 0.7),
                      onTap: () {
                        onRoll(immersion.generateEmotionalAtmosphere(emotionDie: 6));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Example
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JuiceTheme.parchmentDark.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote, size: 14, color: JuiceTheme.parchmentDark),
                        const SizedBox(width: 4),
                        Text(
                          'Example:',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: JuiceTheme.parchmentDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '"You see something discarded behind you, and it causes joy because you were warned about it"',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildDiceReference(String die, String label, String values, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallDieBadge(die, color),
        const SizedBox(width: 6),
        Text(
          '$label → ',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            values,
            style: TextStyle(fontSize: 9, color: JuiceTheme.parchmentDark),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallDieBadge(String die, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        die,
        style: TextStyle(
          fontSize: 9,
          fontFamily: JuiceTheme.fontFamilyMono,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// Section card for Immersion dialog
class _ImmersionSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _ImmersionSectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.06),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Roll button for Immersion dialog
class _ImmersionRollButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ImmersionRollButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isPrimary ? null : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: isPrimary ? 0.5 : 0.3),
              width: isPrimary ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skew button for Immersion dialog (Closer/Further, Positive/Negative)
class _ImmersionSkewButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ImmersionSkewButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      title: Text(
        'Expectation Check',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuiceTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Instead of asking "Is X true?", you assume X is true and test '
                'whether your expectation holds.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 10),
            
            // Use cases row
            Row(
              children: [
                Expanded(
                  child: _ExpectUseCaseBox(
                    icon: Icons.psychology,
                    title: 'Story Events',
                    example: '"The tavern is busy..."',
                    color: JuiceTheme.mystic,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ExpectUseCaseBox(
                    icon: Icons.person,
                    title: 'NPC Behavior',
                    example: '"Guard will let me pass..."',
                    color: JuiceTheme.categoryCharacter,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Outcome reference grid
            _buildOutcomeGrid(),
            
            const SizedBox(height: 12),
            
            // Roll button
            _ExpectDialogOption(
              title: 'Roll 2dF',
              subtitle: 'Test your expectation',
              icon: Icons.casino,
              iconColor: JuiceTheme.gold,
              highlighted: true,
              onTap: () {
                onRoll(expectationCheck.check());
                Navigator.pop(context);
              },
            ),
            
            const SizedBox(height: 8),
            
            // Tip
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates, size: 12, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tip: Think of your most-likely AND next-most-likely outcomes before rolling!',
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }

  Widget _buildOutcomeGrid() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: JuiceTheme.gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.casino, size: 12, color: JuiceTheme.gold),
              const SizedBox(width: 4),
              Text(
                '2dF Outcomes',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: JuiceTheme.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Expected outcomes (positive zone)
          Row(
            children: [
              _ExpectOutcomeChip(dice: '++', label: 'Expected!', color: JuiceTheme.success, isIntense: true),
              const SizedBox(width: 4),
              _ExpectOutcomeChip(dice: '+○', label: 'Expected', color: JuiceTheme.success),
            ],
          ),
          const SizedBox(height: 4),
          // Middle outcomes
          Row(
            children: [
              _ExpectOutcomeChip(dice: '+−', label: 'Next Most', color: JuiceTheme.gold),
              const SizedBox(width: 4),
              _ExpectOutcomeChip(dice: '−+', label: 'Next Most', color: JuiceTheme.gold),
            ],
          ),
          const SizedBox(height: 4),
          // Modifier outcomes (neutral zone)
          Row(
            children: [
              _ExpectOutcomeChip(dice: '○+', label: 'Favorable', color: JuiceTheme.info),
              const SizedBox(width: 4),
              _ExpectOutcomeChip(dice: '○−', label: 'Unfavorable', color: JuiceTheme.categoryWorld),
            ],
          ),
          const SizedBox(height: 4),
          // Special & Opposite
          Row(
            children: [
              _ExpectOutcomeChip(dice: '○○', label: 'Mod+Idea', color: JuiceTheme.juiceOrange, isSpecial: true),
              const SizedBox(width: 4),
              _ExpectOutcomeChip(dice: '−○', label: 'Opposite', color: JuiceTheme.danger),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _ExpectOutcomeChip(dice: '−−', label: 'Opposite!', color: JuiceTheme.danger, isIntense: true),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

/// Use case box for Expectation Check dialog.
class _ExpectUseCaseBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String example;
  final Color color;

  const _ExpectUseCaseBox({
    required this.icon,
    required this.title,
    required this.example,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            example,
            style: TextStyle(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outcome chip for Expectation Check grid.
class _ExpectOutcomeChip extends StatelessWidget {
  final String dice;
  final String label;
  final Color color;
  final bool isIntense;
  final bool isSpecial;

  const _ExpectOutcomeChip({
    required this.dice,
    required this.label,
    required this.color,
    this.isIntense = false,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isIntense || isSpecial ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(4),
          border: isIntense || isSpecial
              ? Border.all(color: color.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                dice,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isIntense ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isIntense)
              Icon(Icons.whatshot, size: 10, color: color),
            if (isSpecial)
              Icon(Icons.auto_awesome, size: 10, color: color),
          ],
        ),
      ),
    );
  }
}

/// Dialog option for Expectation Check.
class _ExpectDialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool highlighted;
  final VoidCallback onTap;

  const _ExpectDialogOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.highlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: highlighted
                  ? iconColor.withValues(alpha: 0.5)
                  : JuiceTheme.gold.withValues(alpha: 0.3),
              width: highlighted ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: highlighted
                ? iconColor.withValues(alpha: 0.1)
                : JuiceTheme.gold.withValues(alpha: 0.08),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: JuiceTheme.parchmentDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: iconColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
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
      title: Text(
        'Name Generator',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple Method section
            _NameSectionHeader(
              icon: Icons.casino,
              title: 'Simple Method',
              subtitle: 'Quick random names using 3d20',
            ),
            const SizedBox(height: 6),
            _NameDialogOption(
              title: '3d20 (Columns 1,2,3)',
              subtitle: 'Roll on all three columns',
              icon: Icons.grid_3x3,
              iconColor: JuiceTheme.gold,
              onTap: () {
                onRoll(nameGenerator.generate());
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 4),
            _NameDialogOption(
              title: '3d20 (Column 1 Only)',
              subtitle: 'Roll on column 1 three times',
              icon: Icons.view_column,
              iconColor: JuiceTheme.juiceOrange,
              onTap: () {
                onRoll(nameGenerator.generateColumn1Only());
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            
            // Pattern Method section
            _NameSectionHeader(
              icon: Icons.pattern,
              title: 'Pattern Method',
              subtitle: 'Use pattern column for structured names',
            ),
            const SizedBox(height: 6),
            _NameDialogOption(
              title: 'Neutral',
              subtitle: 'Roll 1d20 for pattern',
              icon: Icons.balance,
              iconColor: JuiceTheme.parchmentDark,
              onTap: () {
                onRoll(nameGenerator.generatePatternNeutral());
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 4),
            // Masculine/Feminine row
            Row(
              children: [
                Expanded(
                  child: _NameGenderOption(
                    title: 'Masculine',
                    subtitle: '@- (disadvantage)',
                    icon: Icons.arrow_downward,
                    color: JuiceTheme.info,
                    onTap: () {
                      onRoll(nameGenerator.generateMasculine());
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NameGenderOption(
                    title: 'Feminine',
                    subtitle: '@+ (advantage)',
                    icon: Icons.arrow_upward,
                    color: JuiceTheme.categoryCharacter,
                    onTap: () {
                      onRoll(nameGenerator.generateFeminine());
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Info box
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: JuiceTheme.parchmentDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 12, color: JuiceTheme.gold),
                      const SizedBox(width: 4),
                      Text(
                        'Examples',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Simple: Tolimaea, Mayosid, Nenetar\n'
                    '• Masculine: Osuma, Likel, Risan\n'
                    '• Feminine: Nedeli, Eyosi, Kisora',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: JuiceTheme.parchmentDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }
}

/// Section header for Name Generator dialog.
class _NameSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NameSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: JuiceTheme.gold),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: JuiceTheme.parchment,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: JuiceTheme.parchmentDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Dialog option for Name Generator.
class _NameDialogOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NameDialogOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
            color: JuiceTheme.gold.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: JuiceTheme.gold.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gender option for Name Generator (compact side-by-side).
class _NameGenderOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NameGenderOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
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
  final bool isTwoPassMode;
  final void Function(bool) onTwoPassModeChange;
  final bool twoPassHasFirstDoubles;
  final void Function(bool) onTwoPassFirstDoublesChange;

  const _DungeonDialog({
    required this.dungeonGenerator,
    required this.onRoll,
    required this.isEntering,
    required this.onPhaseChange,
    required this.isTwoPassMode,
    required this.onTwoPassModeChange,
    required this.twoPassHasFirstDoubles,
    required this.onTwoPassFirstDoublesChange,
  });

  @override
  State<_DungeonDialog> createState() => _DungeonDialogState();
}

class _DungeonDialogState extends State<_DungeonDialog> {
  // Theme colors for dungeon - forest brown-green for exploration
  static const Color _dungeonColor = JuiceTheme.categoryExplore;
  static const Color _phaseEnteringColor = JuiceTheme.rust;  // @- worse/smaller
  static const Color _phaseExploringColor = JuiceTheme.success;  // @+ better/larger
  static const Color _encounterColor = JuiceTheme.danger;  // Red for danger
  static const Color _trapColor = JuiceTheme.juiceOrange;  // Orange for traps

  late bool _isEntering;
  // Local state for Two-Pass mode (synced with parent on change)
  late bool _isTwoPassMode;
  // Local state for first doubles in Two-Pass mode
  late bool _twoPassHasFirstDoubles;
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

  // Scroll controller to track scroll position for indicators
  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _isEntering = widget.isEntering;
    _isTwoPassMode = widget.isTwoPassMode;
    _twoPassHasFirstDoubles = widget.twoPassHasFirstDoubles;
    _scrollController.addListener(_updateScrollIndicators);
    // Check initial scroll state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    setState(() {
      _canScrollUp = position.pixels > 0;
      _canScrollDown = position.pixels < position.maxScrollExtent;
    });
  }

  void _setPhase(bool isEntering) {
    setState(() => _isEntering = isEntering);
    widget.onPhaseChange(isEntering);
  }

  void _resetMap() {
    if (_isTwoPassMode) {
      // Two-Pass: reset to @+ (before first doubles)
      setState(() => _twoPassHasFirstDoubles = false);
      widget.onTwoPassFirstDoublesChange(false);
    } else {
      // One-Pass: reset to Entering (@-)
      _setPhase(true);
    }
  }

  void _setTwoPassMode(bool isTwoPassMode) {
    setState(() => _isTwoPassMode = isTwoPassMode);
    widget.onTwoPassModeChange(isTwoPassMode);
  }

  void _setTwoPassFirstDoubles(bool hasFirstDoubles) {
    setState(() => _twoPassHasFirstDoubles = hasFirstDoubles);
    widget.onTwoPassFirstDoublesChange(hasFirstDoubles);
  }

  // Build a themed mode chip (One-Pass / Two-Pass)
  Widget _buildModeChip(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () => _setTwoPassMode(label == 'Two-Pass'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'One-Pass' ? Icons.route : Icons.layers,
              size: 14,
              color: isSelected ? color : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a themed die size chip (d6/d10)
  Widget _buildDieChip(String label, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: isSelected ? color : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  // Build a themed skew chip (@-/@+)
  Widget _buildSkewChip(String label, AdvantageType type, AdvantageType current, Color color, Function(AdvantageType) onTap) {
    final isSelected = current == type;
    return GestureDetector(
      onTap: () => onTap(isSelected ? AdvantageType.none : type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 12, color: color),
            if (isSelected)
              const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: isSelected ? color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a section header with icon
  Widget _buildDungeonSectionHeader(String title, IconData icon, {Color? color}) {
    final c = color ?? _dungeonColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  // Build an info/tip box
  Widget _buildInfoBox(String content, {Color? color, bool isCompact = false}) {
    final c = color ?? _dungeonColor;
    return Container(
      padding: EdgeInsets.all(isCompact ? 6 : 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: isCompact ? 9 : 10,
          fontStyle: FontStyle.italic,
          color: JuiceTheme.parchment.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  // Get the current advantage state based on mode
  bool get _useAdvantage {
    if (_isTwoPassMode) {
      // Two-Pass: @+ before first doubles, @- after
      return !_twoPassHasFirstDoubles;
    } else {
      // One-Pass: @- while entering, @+ while exploring
      return !_isEntering;
    }
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Determine current status text based on mode
    final String statusText;
    final Color statusColor;
    if (_isTwoPassMode) {
      if (_twoPassHasFirstDoubles) {
        statusText = '1d10@- (after 1st doubles)';
        statusColor = _phaseEnteringColor;
      } else {
        statusText = '1d10@+ (until 1st doubles)';
        statusColor = _phaseExploringColor;
      }
    } else {
      if (_isEntering) {
        statusText = '1d10@- Entering (until doubles)';
        statusColor = _phaseEnteringColor;
      } else {
        statusText = '1d10@+ Exploring (after doubles)';
        statusColor = _phaseExploringColor;
      }
    }

    // Build the sticky phase indicator
    Widget buildStickyPhaseIndicator() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.explore, size: 14, color: statusColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: statusColor,
                ),
              ),
            ),
            // Phase toggle chips (One-Pass only) - use Flexible to prevent overflow
            if (!_isTwoPassMode) ...[
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactPhaseChip('(@-)', _isEntering, _phaseEnteringColor, () => _setPhase(true)),
                    const SizedBox(width: 4),
                    _buildCompactPhaseChip('(@+)', !_isEntering, _phaseExploringColor, () => _setPhase(false)),
                  ],
                ),
              ),
            ],
            // Two-Pass doubles indicators
            if (_isTwoPassMode) ...[
              _buildCompactDoublesIndicator('1st', _twoPassHasFirstDoubles, _phaseEnteringColor),
              const SizedBox(width: 4),
              _buildCompactDoublesIndicator('2nd', false, _encounterColor),
            ],
            const SizedBox(width: 4),
            InkWell(
              onTap: _resetMap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.refresh, size: 16, color: statusColor.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.door_front_door, size: 22, color: _dungeonColor),
          const SizedBox(width: 10),
          Text(
            'Dungeon Generator',
            style: TextStyle(
              fontFamily: JuiceTheme.fontFamilySerif,
              color: _dungeonColor,
            ),
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.65,
        child: Column(
          children: [
            // Sticky phase indicator at top
            buildStickyPhaseIndicator(),
            const SizedBox(height: 8),
            // Scroll indicator - top fade
            if (_canScrollUp)
              Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      JuiceTheme.surface,
                      JuiceTheme.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.keyboard_arrow_up, size: 12, color: JuiceTheme.parchmentDark.withValues(alpha: 0.6)),
                ),
              ),
            // Main scrollable content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dungeon Name Section
                        _buildDungeonSectionHeader('Dungeon Name', Icons.castle),
                        _DialogOption(
                          title: 'Generate Name (3d10)',
                          subtitle: '[Dungeon] of the [Description] [Subject]',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.generateName());
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(),
                        
                        // ============ UNIFIED MAP GENERATION SECTION ============
                        _buildDungeonSectionHeader('Map Generation', Icons.map),
                        const SizedBox(height: 8),
                        
                        // Mode Toggle: One-Pass vs Two-Pass
                        Row(
                          children: [
                            Expanded(child: _buildModeChip('One-Pass', !_isTwoPassMode, _dungeonColor)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildModeChip('Two-Pass', _isTwoPassMode, JuiceTheme.mystic)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Mode-specific explanation
                        _buildInfoBox(
                          _isTwoPassMode
                            ? 'Two-Pass: Pre-generate map, then explore\n'
                              '• Start 1d10@+ → 1st doubles → 1d10@-\n'
                              '• 2nd doubles → STOP (remaining = dead ends)\n'
                              '• Roll encounters during exploration phase'
                            : 'One-Pass: Explore as you generate\n'
                              '• Start 1d10@- → doubles → switch to 1d10@+\n'
                              '• Roll encounters as you enter each room\n'
                              '• Mimics "Skyrim" style: long way in, shortcut out',
                          color: _isTwoPassMode ? JuiceTheme.mystic : _dungeonColor,
                        ),
                        const SizedBox(height: 8),
              
              // Map Generation Buttons
              _DialogOption(
                title: 'Next Area',
                subtitle: _isTwoPassMode
                    ? 'Layout only (${_useAdvantage ? "1d10@+" : "1d10@-"})'
                    : 'Area + Passage if applicable',
                onTap: () {
                  if (_isTwoPassMode) {
                    // Two-Pass mode: use generateTwoPassArea
                    final result = widget.dungeonGenerator.generateTwoPassArea(
                      hasFirstDoubles: _twoPassHasFirstDoubles,
                      useD6ForPassage: _useD6ForPassage,
                      passageSkew: _passageConditionSkew,
                    );
                    widget.onRoll(result);
                    
                    // Handle doubles transitions
                    if (result.isSecondDoubles) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎲 2nd DOUBLES! STOP MAP GENERATION\nAll remaining paths → Small Chamber: 1 Door'),
                          backgroundColor: Color(0xFF8B3A3A),  // Dark danger
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } else if (result.isDoubles && !_twoPassHasFirstDoubles) {
                      _setTwoPassFirstDoubles(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎲 1st DOUBLES! Switching to @- for remaining areas'),
                          backgroundColor: Color(0xFF8B5513),  // Dark rust
                        ),
                      );
                    }
                  } else {
                    // One-Pass mode: use generateNextArea
                    final result = widget.dungeonGenerator.generateNextArea(
                      isEntering: _isEntering,
                      includePassage: true,
                      useD6ForPassage: _useD6ForPassage,
                      passageSkew: _passageConditionSkew,
                    );
                    widget.onRoll(result);
                    
                    // Auto-switch phase if doubles while entering
                    if (result.isDoubles && _isEntering) {
                      _setPhase(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎲 DOUBLES! Switched to Exploring phase (@+)'),
                          backgroundColor: Color(0xFF4A6B4A),  // Dark success
                        ),
                      );
                    }
                  }
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Full Area + Condition',
                subtitle: _isTwoPassMode
                    ? 'Area + Condition (no encounters)'
                    : 'Area + Condition + Passage',
                onTap: () {
                  if (_isTwoPassMode) {
                    // Two-Pass mode: use generateTwoPassArea (already includes condition)
                    final result = widget.dungeonGenerator.generateTwoPassArea(
                      hasFirstDoubles: _twoPassHasFirstDoubles,
                      useD6ForPassage: _useD6ForPassage,
                      passageSkew: _passageConditionSkew,
                    );
                    widget.onRoll(result);
                    
                    // Handle doubles transitions
                    if (result.isSecondDoubles) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎲 2nd DOUBLES! STOP MAP GENERATION\nAll remaining paths → Small Chamber: 1 Door'),
                          backgroundColor: Color(0xFF8B3A3A),  // Dark danger
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } else if (result.isDoubles && !_twoPassHasFirstDoubles) {
                      _setTwoPassFirstDoubles(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎲 1st DOUBLES! Switching to @- for remaining areas'),
                          backgroundColor: Color(0xFF8B5513),  // Dark rust
                        ),
                      );
                    }
                  } else {
                    // One-Pass mode: use generateFullArea
                    final result = widget.dungeonGenerator.generateFullArea(
                      isEntering: _isEntering,
                      isOccupied: !_useD6ForPassage,
                      conditionSkew: _passageConditionSkew,
                      includePassage: true,
                      useD6ForPassage: _useD6ForPassage,
                      passageSkew: _passageConditionSkew,
                    );
                    widget.onRoll(result);
                    
                    // Auto-switch phase if doubles while entering
                    if (result.area.isDoubles && _isEntering) {
                      _setPhase(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎲 DOUBLES! Switched to Exploring phase (@+)'),
                          backgroundColor: Color(0xFF4A6B4A),  // Dark success
                        ),
                      );
                    }
                  }
                  Navigator.pop(context);
                },
              ),
              _DialogOption(
                title: 'Passage',
                subtitle: 'Manual passage roll (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
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
              const SizedBox(height: 4),
              
              // Passage & Condition Settings (collapsed)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 14, color: JuiceTheme.mystic),
                        const SizedBox(width: 6),
                        Text(
                          'Passage/Condition Settings',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: JuiceTheme.mystic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'd6 = Linear/Unoccupied  •  d10 = Branching/Occupied\n'
                      '@- = Smaller/Worse  •  @+ = Larger/Better',
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildDieChip('d6', _useD6ForPassage, JuiceTheme.info, () => setState(() => _useD6ForPassage = true)),
                        _buildDieChip('d10', !_useD6ForPassage, JuiceTheme.info, () => setState(() => _useD6ForPassage = false)),
                        const SizedBox(width: 8),
                        _buildSkewChip('@-', AdvantageType.disadvantage, _passageConditionSkew, _phaseEnteringColor, 
                          (v) => setState(() => _passageConditionSkew = v)),
                        _buildSkewChip('@+', AdvantageType.advantage, _passageConditionSkew, _phaseExploringColor,
                          (v) => setState(() => _passageConditionSkew = v)),
                      ],
                    ),
                  ],
                ),
              ),
              
                        const Divider(),
                        // Encounter Settings
                        _buildDungeonSectionHeader('Dungeon Encounter', Icons.warning_amber_rounded, color: _encounterColor),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: _encounterColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _encounterColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '10m 1d6 (NH: d6); Trap: 10m AP@+ A/L, PP L/T',
                      style: TextStyle(fontSize: 10, fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: _encounterColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'd6 = Lingering 10+ min in unsafe area\n'
                      'd10 = Entering area first time\n'
                      '@+ = Better Encounters, @- = Worse',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildDieChip('d6 Linger', _isLingering, _encounterColor, () => setState(() => _isLingering = true)),
                        _buildDieChip('d10 Entry', !_isLingering, _encounterColor, () => setState(() => _isLingering = false)),
                        const SizedBox(width: 8),
                        _buildSkewChip('@-', AdvantageType.disadvantage, _encounterSkew, _phaseEnteringColor,
                          (v) => setState(() => _encounterSkew = v)),
                        _buildSkewChip('@+', AdvantageType.advantage, _encounterSkew, _phaseExploringColor,
                          (v) => setState(() => _encounterSkew = v)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
                        _buildDungeonSectionHeader('Encounter Details', Icons.pest_control, color: _trapColor),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _trapColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _trapColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.motion_photos_paused, size: 14, color: _trapColor),
                        const SizedBox(width: 6),
                        Text(
                          'Trap Procedure',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _trapColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchment.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Reference for encounter types
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JuiceTheme.sepia.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, size: 14, color: JuiceTheme.sepia),
                        const SizedBox(width: 6),
                        Text(
                          'Encounter Reference',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: JuiceTheme.sepia),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1: Monster    6: Known\n'
                      '2: Nat Hazard 7: Trap\n'
                      '3: Challenge  8: Feature\n'
                      '4: Immersion  9: Key\n'
                      '5: Safety     0: Treasure',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: JuiceTheme.parchment.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
                        const SizedBox(height: 8), // Extra padding at bottom for scroll
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scroll indicator - bottom fade
            if (_canScrollDown)
              Container(
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      JuiceTheme.surface,
                      JuiceTheme.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.keyboard_arrow_down, size: 14, color: JuiceTheme.parchmentDark.withValues(alpha: 0.6)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: _dungeonColor)),
        ),
      ],
    );
  }

  // Compact phase chip for sticky header
  Widget _buildCompactPhaseChip(String label, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: isSelected ? color : color.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  // Compact doubles indicator for sticky header
  Widget _buildCompactDoublesIndicator(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 10,
            color: isActive ? color : Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? color : Colors.grey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable content wrapper with scroll indicators for dialogs.
/// Shows up/down arrows when content can be scrolled.
class _ScrollableDialogContent extends StatefulWidget {
  final Widget? child;
  final List<Widget>? children;

  const _ScrollableDialogContent({
    this.child,
    this.children,
  }) : assert(child != null || children != null, 'Either child or children must be provided');

  @override
  State<_ScrollableDialogContent> createState() => _ScrollableDialogContentState();
}

class _ScrollableDialogContentState extends State<_ScrollableDialogContent> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    setState(() {
      _canScrollUp = position.pixels > 0;
      _canScrollDown = position.pixels < position.maxScrollExtent - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scroll up indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _canScrollUp ? 16 : 0,
          child: _canScrollUp
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        JuiceTheme.surface,
                        JuiceTheme.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 14,
                      color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Main scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: widget.child ?? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children!,
            ),
          ),
        ),
        // Scroll down indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _canScrollDown ? 16 : 0,
          child: _canScrollDown
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        JuiceTheme.surface,
                        JuiceTheme.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Helper widget for section headers with icons.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: JuiceTheme.gold),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: JuiceTheme.gold.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: JuiceTheme.gold.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: JuiceTheme.gold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: JuiceTheme.parchmentDark,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: JuiceTheme.gold.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for Wilderness exploration options.
class _WildernessDialog extends StatefulWidget {
  final Wilderness wilderness;
  final void Function(RollResult) onRoll;
  final DungeonGenerator dungeonGenerator;
  final Challenge challenge;

  const _WildernessDialog({
    required this.wilderness,
    required this.onRoll,
    required this.dungeonGenerator,
    required this.challenge,
  });

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
      title: Text(
        'Wilderness',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show current state if initialized
              if (isInitialized) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _WildernessStateCard(state: state)),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Reset Wilderness?'),
                            content: const Text('This will clear the current wilderness state. You will need to initialize a new starting area.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.wilderness.reset();
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Wilderness state reset')),
                                  );
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: JuiceTheme.sepia.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: JuiceTheme.sepia.withValues(alpha: 0.3)),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 18,
                          color: JuiceTheme.sepia.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ========== Environment Section ==========
              _WildernessSectionHeader(
                icon: Icons.terrain,
                title: 'Environment',
              ),
              const SizedBox(height: 6),
              
              if (!isInitialized) ...[
                _WildernessActionButton(
                  title: 'Initialize Random Area',
                  subtitle: 'Start in a random environment (1d10 + 1dF)',
                  icon: Icons.shuffle,
                  color: JuiceTheme.categoryExplore,
                  onTap: () {
                    widget.onRoll(widget.wilderness.initializeRandom());
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 6),
                _WildernessActionButton(
                  title: _showEnvironmentPicker ? 'Hide Picker' : 'Set Known Position...',
                  subtitle: 'Start from an existing location',
                  icon: _showEnvironmentPicker ? Icons.expand_less : Icons.expand_more,
                  color: JuiceTheme.sepia,
                  onTap: () => setState(() => _showEnvironmentPicker = !_showEnvironmentPicker),
                ),
              ] else ...[
                _WildernessActionButton(
                  title: 'Transition to Next Area',
                  subtitle: 'Move to adjacent area (2dF env + 1dF type)',
                  icon: Icons.arrow_forward,
                  color: JuiceTheme.categoryExplore,
                  onTap: () {
                    widget.onRoll(widget.wilderness.transition());
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 6),
                _WildernessActionButton(
                  title: _showEnvironmentPicker ? 'Hide Picker' : 'Change Position...',
                  subtitle: 'Set to a different location',
                  icon: _showEnvironmentPicker ? Icons.expand_less : Icons.expand_more,
                  color: JuiceTheme.sepia,
                  onTap: () => setState(() => _showEnvironmentPicker = !_showEnvironmentPicker),
                ),
              ],

              // Environment picker
              if (_showEnvironmentPicker) ...[
                const SizedBox(height: 8),
                _WildernessEnvironmentPicker(
                  selectedEnvironment: _selectedEnvironment,
                  selectedType: _selectedType,
                  onEnvironmentChanged: (v) => setState(() => _selectedEnvironment = v),
                  onTypeChanged: (v) => setState(() => _selectedType = v),
                  onConfirm: () {
                    final result = widget.wilderness.initializeAt(_selectedEnvironment, typeRow: _selectedType);
                    widget.onRoll(result);
                    Navigator.pop(context);
                  },
                ),
              ],
              const SizedBox(height: 14),

              // ========== Encounters Section ==========
              _WildernessSectionHeader(
                icon: Icons.explore,
                title: 'Encounters',
              ),
              const SizedBox(height: 6),

              // Skew toggles as compact chips
              Row(
                children: [
                  _WildernessModifierChip(
                    label: 'Dangerous',
                    subtitle: 'Disadvantage',
                    isSelected: _hasDangerousTerrain,
                    color: JuiceTheme.danger,
                    onTap: () => setState(() => _hasDangerousTerrain = !_hasDangerousTerrain),
                  ),
                  const SizedBox(width: 8),
                  _WildernessModifierChip(
                    label: 'Map/Guide',
                    subtitle: 'Advantage',
                    isSelected: _hasMapOrGuide,
                    color: JuiceTheme.success,
                    onTap: () => setState(() => _hasMapOrGuide = !_hasMapOrGuide),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _WildernessActionButton(
                title: 'Roll Encounter',
                subtitle: isInitialized 
                    ? 'What happens? (d${state.isLost ? 6 : 10}${_getSkewLabel()})'
                    : 'What happens? (d10)',
                icon: Icons.casino,
                color: JuiceTheme.gold,
                onTap: () {
                  _rollEncounterWithFollowUp();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 6),

              if (isInitialized && state.isLost) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: JuiceTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 14, color: JuiceTheme.danger),
                      const SizedBox(width: 6),
                      Text(
                        'LOST - using d6 for encounters',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.danger,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          widget.wilderness.setLost(false);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No longer lost - using d10')),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mark Found',
                          style: TextStyle(fontSize: 10, color: JuiceTheme.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Secondary encounter options in a compact row
              Row(
                children: [
                  Expanded(
                    child: _WildernessCompactButton(
                      title: 'Weather',
                      icon: Icons.cloud,
                      color: JuiceTheme.info,
                      onTap: () {
                        widget.onRoll(widget.wilderness.rollWeather());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _WildernessCompactButton(
                      title: 'Hazard',
                      icon: Icons.warning,
                      color: JuiceTheme.rust,
                      onTap: () {
                        widget.onRoll(widget.wilderness.rollNaturalHazard());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _WildernessCompactButton(
                      title: 'Feature',
                      icon: Icons.place,
                      color: JuiceTheme.mystic,
                      onTap: () {
                        widget.onRoll(widget.wilderness.rollFeature());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ========== Monster Level Section ==========
              _WildernessSectionHeader(
                icon: Icons.pets,
                title: 'Monster Level',
              ),
              const SizedBox(height: 6),

              _WildernessActionButton(
                title: 'Roll Monster Level',
                subtitle: isInitialized
                    ? 'Based on ${state.environment} (${_getMonsterFormula(state.environmentRow)})'
                    : '1d6+modifier with advantage/disadvantage',
                icon: Icons.catching_pokemon,
                color: JuiceTheme.danger,
                onTap: () {
                  widget.onRoll(widget.wilderness.rollMonsterLevel());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
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

  String _getMonsterFormula(int environmentRow) {
    // Monster formulas from the wilderness table
    const formulas = [
      '@-',      // 1 Arctic
      '+1@-',    // 2 Mountains
      '+1@-',    // 3 Cavern
      '+2',      // 4 Hills
      '+2@+',    // 5 Grassland
      '+3',      // 6 Forest
      '+3@+',    // 7 Swamp
      '+4',      // 8 Water
      '+4@+',    // 9 Coast
      '+4@+',    // 10 Desert
    ];
    final index = (environmentRow - 1).clamp(0, 9);
    return '1d6${formulas[index]}';
  }

  /// Roll an encounter and automatically roll any required follow-up
  void _rollEncounterWithFollowUp() {
    var encounterResult = widget.wilderness.rollEncounter(
      hasDangerousTerrain: _hasDangerousTerrain,
      hasMapOrGuide: _hasMapOrGuide,
    );
    
    // If follow-up is required, roll it and embed the result
    if (encounterResult.requiresFollowUp) {
      final encounter = encounterResult.encounter;
      final environmentRow = widget.wilderness.state?.environmentRow ?? 5;
      
      if (encounter == 'Natural Hazard') {
        final hazard = widget.wilderness.rollNaturalHazard();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: hazard.roll,
          followUpResult: hazard.result,
        );
      } else if (encounter == 'Monster') {
        final monster = MonsterEncounter.generateFullEncounter(environmentRow);
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: monster.row + 1,
          followUpResult: monster.encounterSummary,
          followUpData: {
            'difficulty': monster.difficulty.name,
            'hasBoss': monster.hasBoss,
            'bossMonster': monster.bossMonster,
            'environmentFormula': monster.environmentFormula,
          },
        );
      } else if (encounter == 'Weather') {
        final weather = widget.wilderness.rollWeather();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: weather.weatherRow,
          followUpResult: weather.weather,
          followUpData: {
            'baseRoll': weather.baseRoll,
            'formula': weather.formula,
          },
        );
      } else if (encounter == 'Challenge') {
        final challenge = widget.challenge.rollFullChallenge();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: challenge.physicalRoll,
          followUpResult: '${challenge.physicalSkill} DC${challenge.physicalDc} / ${challenge.mentalSkill} DC${challenge.mentalDc}',
          followUpData: {
            'physicalSkill': challenge.physicalSkill,
            'physicalDc': challenge.physicalDc,
            'mentalSkill': challenge.mentalSkill,
            'mentalDc': challenge.mentalDc,
          },
        );
      } else if (encounter == 'Dungeon') {
        final dungeon = widget.dungeonGenerator.generateName();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: dungeon.typeRoll,
          followUpResult: dungeon.name,
          followUpData: {
            'type': dungeon.dungeonType,
            'description': dungeon.descriptionWord,
            'subject': dungeon.subject,
          },
        );
      } else if (encounter == 'Feature') {
        final feature = widget.wilderness.rollFeature();
        encounterResult = encounterResult.withFollowUp(
          followUpRoll: feature.roll,
          followUpResult: feature.result,
        );
      }
    }
    
    // Add the single encounter result (with embedded follow-up if any)
    widget.onRoll(encounterResult);
  }

  String _getSkewLabel() {
    if (_hasDangerousTerrain && _hasMapOrGuide) return ''; // Cancel out
    if (_hasDangerousTerrain) return '@-';
    if (_hasMapOrGuide) return '@+';
    return '';
  }
}

// ========== Wilderness Dialog Helper Widgets ==========

class _WildernessSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _WildernessSectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: JuiceTheme.categoryExplore),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: JuiceTheme.parchment,
            fontFamily: JuiceTheme.fontFamilySerif,
          ),
        ),
      ],
    );
  }
}

class _WildernessStateCard extends StatelessWidget {
  final WildernessState state;

  const _WildernessStateCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: JuiceTheme.categoryExplore.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.categoryExplore.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: JuiceTheme.categoryExplore),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.fullDescription,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: JuiceTheme.parchment,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _StateInfoChip(
                icon: Icons.cloud,
                label: 'Weather',
                value: '1d6@${state.environmentSkew}+${state.typeModifier}',
              ),
              const SizedBox(width: 8),
              if (state.isLost)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: JuiceTheme.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: JuiceTheme.danger.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 10, color: JuiceTheme.danger),
                      const SizedBox(width: 3),
                      Text(
                        'LOST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.danger,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StateInfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: JuiceTheme.sepia.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: JuiceTheme.parchmentDark),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 9,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: JuiceTheme.parchmentDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _WildernessActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WildernessActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WildernessCompactButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WildernessCompactButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WildernessModifierChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _WildernessModifierChip({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? color.withValues(alpha: 0.2) : JuiceTheme.sepia.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? color.withValues(alpha: 0.5) : JuiceTheme.sepia.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 14,
                  color: isSelected ? color : JuiceTheme.parchmentDark,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : JuiceTheme.parchment,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WildernessEnvironmentPicker extends StatelessWidget {
  final int selectedEnvironment;
  final int selectedType;
  final ValueChanged<int> onEnvironmentChanged;
  final ValueChanged<int> onTypeChanged;
  final VoidCallback onConfirm;

  const _WildernessEnvironmentPicker({
    required this.selectedEnvironment,
    required this.selectedType,
    required this.onEnvironmentChanged,
    required this.onTypeChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: JuiceTheme.sepia.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JuiceTheme.sepia.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Environment dropdown
          DropdownButtonFormField<int>(
            value: selectedEnvironment,
            decoration: InputDecoration(
              labelText: 'Environment',
              labelStyle: TextStyle(color: JuiceTheme.parchmentDark),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia.withValues(alpha: 0.3)),
              ),
            ),
            dropdownColor: JuiceTheme.surface,
            iconEnabledColor: JuiceTheme.parchment,
            style: TextStyle(color: JuiceTheme.parchment, fontSize: 12),
            selectedItemBuilder: (context) {
              return List.generate(10, (i) {
                final env = Wilderness.environments[i];
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${i + 1}. $env',
                    style: TextStyle(fontSize: 12, color: JuiceTheme.parchment),
                  ),
                );
              });
            },
            items: List.generate(10, (i) {
              final env = Wilderness.environments[i];
              // Parse the environment string to separate name and formula
              final match = RegExp(r'(.+?)\s*(\([^)]+\))').firstMatch(env);
              final name = match?.group(1) ?? env;
              final formula = match?.group(2) ?? '';
              return DropdownMenuItem(
                value: i + 1,
                child: Row(
                  children: [
                    Text(
                      '${i + 1}. ',
                      style: TextStyle(fontSize: 13, color: JuiceTheme.sepia, fontFamily: JuiceTheme.fontFamilyMono),
                    ),
                    Expanded(
                      child: Text(
                        name.trim(),
                        style: TextStyle(fontSize: 13, color: JuiceTheme.parchment, fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (formula.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: JuiceTheme.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          formula,
                          style: TextStyle(
                            fontSize: 11,
                            color: JuiceTheme.gold,
                            fontFamily: JuiceTheme.fontFamilyMono,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            onChanged: (v) => onEnvironmentChanged(v ?? 6),
          ),
          const SizedBox(height: 8),
          // Type dropdown
          DropdownButtonFormField<int>(
            value: selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              labelStyle: TextStyle(color: JuiceTheme.parchmentDark),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: JuiceTheme.sepia.withValues(alpha: 0.3)),
              ),
            ),
            dropdownColor: JuiceTheme.surface,
            iconEnabledColor: JuiceTheme.parchment,
            style: TextStyle(color: JuiceTheme.parchment, fontSize: 12),
            selectedItemBuilder: (context) {
              return List.generate(10, (i) {
                final type = Wilderness.types[i]['name'] as String;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${i + 1}. $type',
                    style: TextStyle(fontSize: 12, color: JuiceTheme.parchment),
                  ),
                );
              });
            },
            items: List.generate(10, (i) {
              final type = Wilderness.types[i]['name'] as String;
              return DropdownMenuItem(
                value: i + 1,
                child: Row(
                  children: [
                    Text(
                      '${i + 1}. ',
                      style: TextStyle(fontSize: 13, color: JuiceTheme.sepia, fontFamily: JuiceTheme.fontFamilyMono),
                    ),
                    Expanded(
                      child: Text(
                        type,
                        style: TextStyle(fontSize: 13, color: JuiceTheme.parchment, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
            onChanged: (v) => onTypeChanged(v ?? 6),
          ),
          const SizedBox(height: 10),
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: JuiceTheme.categoryExplore.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.categoryExplore.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 14, color: JuiceTheme.categoryExplore),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${Wilderness.types[selectedType - 1]['name']} ${Wilderness.environments[selectedEnvironment - 1]}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.parchment,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Set Position'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JuiceTheme.categoryExplore,
                foregroundColor: JuiceTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
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
    final combatColor = JuiceTheme.categoryCombat;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.pest_control, size: 22, color: combatColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monster Encounter',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: JuiceTheme.parchment,
                    fontSize: 18,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        combatColor,
                        combatColor.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Environment-based encounter section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.categoryExplore.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JuiceTheme.categoryExplore.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.landscape, size: 16, color: JuiceTheme.categoryExplore),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Environment: $envName ($envFormula)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: JuiceTheme.categoryExplore,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasWildernessState) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: JuiceTheme.categoryExplore.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 10, color: JuiceTheme.categoryExplore),
                            const SizedBox(width: 4),
                            Text(
                              'From wilderness: ${widget.wildernessState!.fullDescription}',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: JuiceTheme.categoryExplore,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Environment selector
                    DropdownButtonFormField<int>(
                      value: _selectedEnvironment,
                      decoration: InputDecoration(
                        labelText: 'Select Environment',
                        labelStyle: TextStyle(color: JuiceTheme.parchmentDark, fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: JuiceTheme.categoryExplore.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: JuiceTheme.categoryExplore.withValues(alpha: 0.3)),
                        ),
                      ),
                      dropdownColor: JuiceTheme.surface,
                      iconEnabledColor: JuiceTheme.parchment,
                      style: TextStyle(color: JuiceTheme.parchment, fontSize: 12),
                      selectedItemBuilder: (context) {
                        return List.generate(10, (i) {
                          final name = MonsterEncounter.environmentNames[i];
                          final formula = MonsterEncounter.getEnvironmentFormula(i + 1);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${i + 1}. $name ($formula)',
                              style: TextStyle(fontSize: 12, color: JuiceTheme.parchment),
                            ),
                          );
                        });
                      },
                      items: List.generate(10, (i) {
                        final name = MonsterEncounter.environmentNames[i];
                        final formula = MonsterEncounter.getEnvironmentFormula(i + 1);
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}. ',
                                style: TextStyle(fontSize: 13, color: JuiceTheme.sepia, fontFamily: JuiceTheme.fontFamilyMono),
                              ),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(fontSize: 13, color: JuiceTheme.parchment, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: JuiceTheme.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  formula,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: JuiceTheme.gold,
                                    fontFamily: JuiceTheme.fontFamilyMono,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedEnvironment = v ?? 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Full Encounter button - primary action
              _MonsterPrimaryButton(
                title: 'Full Encounter (By Environment)',
                subtitle: 'Row ($envFormula) + Difficulty (2d10) + Counts (1d6-1@)',
                icon: Icons.groups,
                onTap: () {
                  widget.onRoll(MonsterEncounter.generateFullEncounter(_selectedEnvironment));
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 12),
              
              // Quick Rolls section
              _MonsterSectionHeader(icon: Icons.flash_on, title: 'Quick Rolls'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 11, color: JuiceTheme.sepia),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        MonsterEncounter.deadlyExplanation,
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.sepia,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MonsterQuickButton(
                      title: 'Roll Encounter',
                      subtitle: '2d10 for row + difficulty\ndoubles = boss',
                      icon: Icons.casino,
                      color: combatColor,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MonsterQuickButton(
                      title: 'Roll Tracks',
                      subtitle: '1d6-1@ with disadvantage',
                      icon: Icons.pets,
                      color: JuiceTheme.sepia,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollTracks());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // By Difficulty section
              _MonsterSectionHeader(icon: Icons.trending_up, title: 'By Difficulty'),
              const SizedBox(height: 6),
              // 2x2 grid for difficulties
              Row(
                children: [
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Easy (1-4)',
                      subtitle: 'Lower CR monsters',
                      color: JuiceTheme.success,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.easy));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Medium (5-8)',
                      subtitle: 'Standard CR',
                      color: JuiceTheme.juiceOrange,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.medium));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Hard (9-0)',
                      subtitle: 'Higher CR monsters',
                      color: JuiceTheme.danger,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.hard));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MonsterDifficultyChip(
                      label: 'Boss',
                      subtitle: 'Legendary monster',
                      color: JuiceTheme.mystic,
                      icon: Icons.star,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollEncounter(forcedDifficulty: MonsterDifficulty.boss));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Special Rows section
              _MonsterSectionHeader(icon: Icons.star_border, title: 'Special Rows'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _MonsterSpecialRowButton(
                      label: '* (Nature/Plants)',
                      subtitle: 'Blights, hags, plant creatures',
                      icon: Icons.eco,
                      color: JuiceTheme.categoryExplore,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollSpecialRow(humanoid: false));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MonsterSpecialRowButton(
                      label: '** (Humanoids)',
                      subtitle: 'Bandits, scouts, veterans',
                      icon: Icons.person,
                      color: JuiceTheme.rust,
                      onTap: () {
                        widget.onRoll(MonsterEncounter.rollSpecialRow(humanoid: true));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }
}

/// Section header for Monster Encounter dialog
class _MonsterSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  
  const _MonsterSectionHeader({required this.icon, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: JuiceTheme.categoryCombat),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: JuiceTheme.categoryCombat,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: JuiceTheme.categoryCombat.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

/// Primary action button for Monster dialog
class _MonsterPrimaryButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  
  const _MonsterPrimaryButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final combatColor = JuiceTheme.categoryCombat;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: combatColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: combatColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: combatColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: combatColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: combatColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: combatColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick roll button for Monster dialog
class _MonsterQuickButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _MonsterQuickButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: JuiceTheme.parchmentDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Difficulty chip for Monster dialog
class _MonsterDifficultyChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;
  
  const _MonsterDifficultyChip({
    required this.label,
    required this.subtitle,
    required this.color,
    this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 14, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Special row button for Monster dialog
class _MonsterSpecialRowButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _MonsterSpecialRowButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 12, color: color.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8,
                  color: JuiceTheme.parchmentDark,
                ),
              ),
            ],
          ),
        ),
      ),
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
      title: Text(
        'Random Tables',
        style: TextStyle(
          fontFamily: JuiceTheme.fontFamilySerif,
          color: JuiceTheme.parchment,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro explanation
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: JuiceTheme.gold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '"Discover Meaning" provides abstract concepts. These tables provide something more concrete for nouns.',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.parchment,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Simple Mode / Alter Scene - primary action
              _RandomSectionHeader(
                icon: Icons.tune,
                title: 'Simple Mode / Alter Scene',
              ),
              const SizedBox(height: 4),
              _RandomPrimaryOption(
                title: 'Modifier + Idea',
                subtitle: 'Replaces Random Event table • 2d10',
                examples: 'Stop Food, Strange Resource, Increase Attention',
                onTap: () {
                  onRoll(randomEvent.rollModifierPlusIdea());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),

              // Individual Tables section
              _RandomSectionHeader(
                icon: Icons.view_list,
                title: 'Individual Tables (d10)',
              ),
              const SizedBox(height: 6),
              _RandomIndividualTable(
                label: 'Modifier',
                examples: 'Change, Continue, Decrease, Extra, Increase, Stop, Strange...',
                color: JuiceTheme.rust,
                onTap: () {
                  onRoll(randomEvent.rollModifier());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Idea',
                examples: 'Attention, Communication, Danger, Element, Food, Home...',
                color: JuiceTheme.mystic,
                onTap: () {
                  onRoll(randomEvent.rollIdea());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Event',
                examples: 'Ambush, Anomaly, Blessing, Caravan, Curse, Discovery...',
                color: JuiceTheme.danger,
                onTap: () {
                  onRoll(randomEvent.rollEvent());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Person',
                examples: 'Criminal, Entertainer, Expert, Mage, Mercenary, Noble...',
                color: JuiceTheme.info,
                onTap: () {
                  onRoll(randomEvent.rollPerson());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 4),
              _RandomIndividualTable(
                label: 'Object',
                examples: 'Arrow, Candle, Cauldron, Chain, Claw, Hook, Quill, Skull...',
                color: JuiceTheme.success,
                onTap: () {
                  onRoll(randomEvent.rollObject());
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),

              // Modifier + Category section (combined options)
              _RandomSectionHeader(
                icon: Icons.merge_type,
                title: 'Modifier + Category',
              ),
              const SizedBox(height: 6),
              // 2x2 grid for modifier combinations
              Row(
                children: [
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Random',
                      hint: '1-3: Idea, 4-6: Event\n7-8: Person, 9-0: Object',
                      color: JuiceTheme.parchmentDark,
                      onTap: () {
                        onRoll(randomEvent.generateIdea());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Event',
                      hint: 'Scene triggers',
                      color: JuiceTheme.danger,
                      onTap: () {
                        onRoll(randomEvent.generateIdea(category: IdeaCategory.event));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Person',
                      hint: 'NPC generation',
                      color: JuiceTheme.info,
                      onTap: () {
                        onRoll(randomEvent.generateIdea(category: IdeaCategory.person));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _RandomModifierCombo(
                      label: 'Object',
                      hint: 'Items & things',
                      color: JuiceTheme.success,
                      onTap: () {
                        onRoll(randomEvent.generateIdea(category: IdeaCategory.object));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Random Event Focus section
              _RandomSectionHeader(
                icon: Icons.shuffle,
                title: 'Random Event Focus',
              ),
              const SizedBox(height: 4),
              Text(
                'For double blanks on Fate Check (primary die left)',
                style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: JuiceTheme.parchmentDark),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _RandomFocusButton(
                      title: 'Focus Only',
                      subtitle: '1d10',
                      onTap: () {
                        onRoll(randomEvent.generateFocus());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RandomFocusButton(
                      title: 'Full Event',
                      subtitle: '3d10',
                      isPrimary: true,
                      onTap: () {
                        onRoll(randomEvent.generate());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Compact Focus Reference
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Focus Reference:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 Advance Time  2 Close Thread  3 Converge  4 Diverge  5 Immersion\n'
                      '6 Keyed Event  7 New Character  8 NPC Action  9 Plot Armor  0 Remote',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: JuiceTheme.parchment,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tip box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 11, color: JuiceTheme.gold),
                    const SizedBox(width: 6),
                    Text(
                      'Tip: Use Color + Object for naming Establishments!',
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.gold,
                      ),
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
          child: Text('Close', style: TextStyle(color: JuiceTheme.parchmentDark)),
        ),
      ],
    );
  }
}

/// Section header for Random Tables dialog.
class _RandomSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _RandomSectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: JuiceTheme.gold),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: JuiceTheme.gold,
          ),
        ),
      ],
    );
  }
}

/// Primary featured option (Modifier + Idea).
class _RandomPrimaryOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String examples;
  final VoidCallback onTap;

  const _RandomPrimaryOption({
    required this.title,
    required this.subtitle,
    required this.examples,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                JuiceTheme.gold.withValues(alpha: 0.15),
                JuiceTheme.juiceOrange.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JuiceTheme.gold.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.casino, size: 24, color: JuiceTheme.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      examples,
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: JuiceTheme.gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual table row option.
class _RandomIndividualTable extends StatelessWidget {
  final String label;
  final String examples;
  final Color color;
  final VoidCallback onTap;

  const _RandomIndividualTable({
    required this.label,
    required this.examples,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  examples,
                  style: TextStyle(
                    fontSize: 9,
                    color: JuiceTheme.parchmentDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 14, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modifier combination button (2x2 grid).
class _RandomModifierCombo extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _RandomModifierCombo({
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Modifier + $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+ $label',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 8,
                    color: JuiceTheme.parchmentDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Focus button for Random Event Focus section.
class _RandomFocusButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RandomFocusButton({
    required this.title,
    required this.subtitle,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? JuiceTheme.categoryOracle : JuiceTheme.parchmentDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isPrimary ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: isPrimary ? 0.5 : 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? color : JuiceTheme.parchment,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// Dialog for Location Grid options.
class _LocationDialog extends StatelessWidget {
  final void Function(RollResult) onRoll;

  const _LocationDialog({required this.onRoll});

  // Theme color for location - rust for exploration/maps
  static const Color _locationColor = JuiceTheme.rust;
  static const Color _compassColor = JuiceTheme.categoryExplore;
  static const Color _zoomColor = JuiceTheme.mystic;

  // Build a method card with icon and description
  Widget _buildMethodCard({
    required String title,
    required IconData icon,
    required String description,
    required String useFor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilySerif,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: JuiceTheme.parchment.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline, size: 12, color: color.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    useFor,
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: color.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the visual grid representation
  Widget _buildGridVisual() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _locationColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // North label
          Text(
            'N',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: _compassColor,
            ),
          ),
          const SizedBox(height: 4),
          // Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // West label
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  'W',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _compassColor,
                  ),
                ),
              ),
              // 5x5 grid
              Column(
                children: List.generate(5, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (col) {
                      // Determine ring: 0=center, 1=close, 2=far
                      final isCenter = row == 2 && col == 2;
                      final isClose = !isCenter && 
                          row >= 1 && row <= 3 && 
                          col >= 1 && col <= 3;
                      
                      Color cellColor;
                      String symbol;
                      if (isCenter) {
                        cellColor = JuiceTheme.gold;
                        symbol = '◉';
                      } else if (isClose) {
                        cellColor = _locationColor;
                        symbol = '○';
                      } else {
                        cellColor = JuiceTheme.parchmentDark;
                        symbol = '·';
                      }
                      
                      return Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cellColor.withValues(alpha: isCenter ? 0.3 : 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: cellColor.withValues(alpha: 0.4),
                            width: isCenter ? 1.5 : 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                              fontSize: 12,
                              color: cellColor,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              // East label
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'E',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: _compassColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // South label
          Text(
            'S',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: _compassColor,
            ),
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('◉', 'Center', JuiceTheme.gold),
              const SizedBox(width: 16),
              _buildLegendItem('○', 'Close', _locationColor),
              const SizedBox(width: 16),
              _buildLegendItem('·', 'Far', JuiceTheme.parchmentDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String symbol, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: JuiceTheme.parchment.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.grid_on, size: 22, color: _locationColor),
          const SizedBox(width: 10),
          Text(
            'Location Grid',
            style: TextStyle(
              fontFamily: JuiceTheme.fontFamilySerif,
              color: _locationColor,
            ),
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _locationColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _locationColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: _locationColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A 5×5 bullseye grid. Roll 1d100 to get both a direction and a distance.',
                        style: TextStyle(
                          fontSize: 11,
                          color: JuiceTheme.parchment.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Compass Method
              _buildMethodCard(
                title: 'Compass Method',
                icon: Icons.explore,
                color: _compassColor,
                description: 'Imagine your PC at the center. Roll to get:\n'
                    '• Direction (N, S, E, W, NE, NW, SE, SW)\n'
                    '• Distance (Close or Far based on ring)',
                useFor: 'Next town, hex population, travel days, roads',
              ),
              
              // Zoom Method
              _buildMethodCard(
                title: 'Zoom Method',
                icon: Icons.zoom_in,
                color: _zoomColor,
                description: 'Use iterative zooming:\n'
                    '1. Grid overlays world map → roll to zoom in\n'
                    '2. Grid overlays region → roll again\n'
                    '3. Grid overlays settlement → roll for building\n'
                    '4. Keep zooming until you have your answer',
                useFor: 'Remote Events, hidden treasure locations',
              ),
              
              const SizedBox(height: 12),
              
              // Visual Grid
              _buildGridVisual(),
              
              const SizedBox(height: 16),
              
              // Roll button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _locationColor,
                      _locationColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _locationColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onRoll(Location.roll());
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Roll 1d100',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: JuiceTheme.fontFamilyMono,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          child: Text('Close', style: TextStyle(color: _locationColor)),
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
  // Color mappings for tones
  static const Map<String, Color> _toneColors = {
    'Neutral': JuiceTheme.info,
    'Defensive': JuiceTheme.rust,
    'Aggressive': JuiceTheme.danger,
    'Helpful': JuiceTheme.success,
  };
  
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
    widget.onRoll(result);
    // Close dialog to show result in roll history
    Navigator.pop(context);
  }

  void _startNewConversation() {
    widget.dialogGenerator.startConversation();
    setState(() {});
  }

  void _setPosition(int row, int col) {
    widget.dialogGenerator.setPosition(row, col);
    setState(() {});
  }

  Widget _buildGridCell(int row, int col) {
    final fragment = DialogGenerator.grid[row][col];
    final isCurrentPos = row == widget.dialogGenerator.currentRow && 
                        col == widget.dialogGenerator.currentCol;
    final isPastRow = row <= 1;
    
    return GestureDetector(
      onTap: () => _setPosition(row, col),
      child: Container(
        width: 54,
        height: 36,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isCurrentPos 
              ? JuiceTheme.mystic.withValues(alpha: 0.35)
              : isPastRow 
                  ? JuiceTheme.sepia.withValues(alpha: 0.15)
                  : JuiceTheme.parchment.withValues(alpha: 0.08),
          border: Border.all(
            color: isCurrentPos 
                ? JuiceTheme.mystic 
                : isPastRow 
                    ? JuiceTheme.sepia.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.3),
            width: isCurrentPos ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            fragment,
            style: TextStyle(
              fontSize: 9,
              fontFamily: JuiceTheme.fontFamilySerif,
              fontWeight: isCurrentPos ? FontWeight.bold : FontWeight.normal,
              fontStyle: isPastRow ? FontStyle.italic : FontStyle.normal,
              color: isCurrentPos 
                  ? JuiceTheme.mystic 
                  : isPastRow 
                      ? JuiceTheme.sepia 
                      : Colors.white70,
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
        // Row labels for Past/Present with sepia styling
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Top 2 rows = ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              Text('Past', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: JuiceTheme.sepia)),
              Text(' / Bottom 3 = ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              const Text('Present', style: TextStyle(fontSize: 10)),
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
  
  Widget _buildToneLegendChip(String tone, String direction, String range, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            direction,
            style: TextStyle(fontSize: 11, color: color),
          ),
          const SizedBox(width: 3),
          Text(
            tone,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            range,
            style: TextStyle(
              fontSize: 8,
              fontFamily: JuiceTheme.fontFamilyMono,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDirectionArrow(String direction) {
    switch (direction) {
      case 'up': return '↑';
      case 'down': return '↓';
      case 'left': return '←';
      case 'right': return '→';
      default: return '·';
    }
  }
  @override
  Widget build(BuildContext context) {
    final isActive = widget.dialogGenerator.isConversationActive;
    final currentFragment = widget.dialogGenerator.currentPositionLabel;
    final isPast = widget.dialogGenerator.isCurrentPast;
    final dialogColor = JuiceTheme.mystic;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.forum, color: dialogColor, size: 24),
          const SizedBox(width: 8),
          const Text('NPC Dialog Grid'),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 340,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions header
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dialogColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dialogColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates, size: 14, color: dialogColor),
                        const SizedBox(width: 4),
                        Text(
                          'A mini-game to generate NPC conversations.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: dialogColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Tap any cell to set your starting position\n'
                      '• Roll 2d10: 1st = Direction + Tone, 2nd = Subject\n'
                      '• Doubles = Conversation ends\n'
                      '• Edges wrap around',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // The grid
              _buildGrid(),
              const SizedBox(height: 10),
              
              // Current state panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive 
                      ? JuiceTheme.success.withValues(alpha: 0.1)
                      : JuiceTheme.juiceOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? JuiceTheme.success : JuiceTheme.juiceOrange,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.record_voice_over : Icons.voice_over_off,
                          size: 16,
                          color: isActive ? JuiceTheme.success : JuiceTheme.juiceOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Conversation Active' : 'Conversation Ended',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? JuiceTheme.success : JuiceTheme.juiceOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Current: ',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: dialogColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentFragment,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: JuiceTheme.fontFamilySerif,
                              fontStyle: isPast ? FontStyle.italic : FontStyle.normal,
                              color: dialogColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPast 
                                ? JuiceTheme.sepia.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPast ? 'Past' : 'Present',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: isPast ? FontStyle.italic : FontStyle.normal,
                              color: isPast ? JuiceTheme.sepia : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (DialogGenerator.fragmentDescriptions[currentFragment] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DialogGenerator.fragmentDescriptions[currentFragment]!,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Direction/Tone legend - compact 2x2 grid
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1st Die (Direction + Tone):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildToneLegendChip('Neutral', '↑', '1-2', JuiceTheme.info),
                        _buildToneLegendChip('Defensive', '←', '3-5', JuiceTheme.rust),
                        _buildToneLegendChip('Aggressive', '→', '6-8', JuiceTheme.danger),
                        _buildToneLegendChip('Helpful', '↓', '9-0', JuiceTheme.success),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2nd Die (Subject):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1-2: Them  •  3-5: Me  •  6-8: You  •  9-0: Us',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: Colors.grey.shade500,
                      ),
                    ),
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
                      icon: const Icon(Icons.casino, size: 18),
                      label: Text(isActive ? 'Roll 2d10' : 'Roll (New)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dialogColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _startNewConversation,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset to Fact (center)',
                    style: IconButton.styleFrom(
                      backgroundColor: JuiceTheme.success.withValues(alpha: 0.2),
                      foregroundColor: JuiceTheme.success,
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
  // Theme colors for NPC conversation - character/social interactions
  static const Color _npcColor = JuiceTheme.categoryCharacter;
  static const Color _infoColor = JuiceTheme.info;  // Blue for information
  static const Color _companionColor = JuiceTheme.success;  // Green for companion responses
  static const Color _topicColor = JuiceTheme.juiceOrange;  // Orange for dialog topics
  static const Color _opposedColor = JuiceTheme.danger;  // Red for opposed
  static const Color _favorColor = JuiceTheme.success;  // Green for in favor

  // Companion Response skew settings
  SkewType _companionSkew = SkewType.none;

  // Build a themed section header with icon
  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    final c = color ?? _npcColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: c),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  // Build an info/tip box
  Widget _buildInfoBox(String content, {Color? color}) {
    final c = color ?? _npcColor;
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: JuiceTheme.parchment.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  // Build a themed skew chip
  Widget _buildSkewChip(String label, SkewType type, IconData icon, Color color) {
    final isSelected = _companionSkew == type;
    return GestureDetector(
      onTap: () => setState(() => _companionSkew = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 12, color: color),
            if (isSelected)
              const SizedBox(width: 4),
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a themed roll button
  Widget _buildRollButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.parchmentDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  // Build a favor level row
  Widget _buildFavorLevelRow(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              range,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: JuiceTheme.parchment.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _getSkewLabel() {
    switch (_companionSkew) {
      case SkewType.advantage:
        return ' @+ In Favor';
      case SkewType.disadvantage:
        return ' @- Opposed';
      case SkewType.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _npcColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.record_voice_over, size: 20, color: _npcColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Extended NPC Conversation',
              style: TextStyle(
                fontFamily: JuiceTheme.fontFamilySerif,
                fontSize: 17,
                color: _npcColor,
              ),
            ),
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _npcColor.withValues(alpha: 0.12),
                      _npcColor.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _npcColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat, size: 14, color: _npcColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Plot Knowledge • Companion Responses • Dialog Topics',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _npcColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Alternative to the Dialog Grid mini-game. NPCs make the world feel alive!',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // INFORMATION SECTION (2d100)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Information', Icons.info_outline, color: _infoColor),
              _buildInfoBox(
                'Roll 2d100 to determine what an NPC is talking about. '
                'Could be a response to asking for info, or something overheard.',
                color: _infoColor,
              ),
              const SizedBox(height: 8),
              _buildRollButton(
                title: 'Roll Information',
                subtitle: 'Type + Topic (2d100)',
                icon: Icons.library_books,
                color: _infoColor,
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollInformation());
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // ═══════════════════════════════════════════════════════════════
              // COMPANION RESPONSE SECTION (1d100)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Companion Response', Icons.groups, color: _companionColor),
              _buildInfoBox(
                'Responses to "the plan". Ordered such that bigger numbers '
                'are more in favor, smaller numbers are more opposed.',
                color: _companionColor,
              ),
              const SizedBox(height: 8),
              // Skew selection
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 12, color: JuiceTheme.parchmentDark),
                        const SizedBox(width: 4),
                        Text(
                          'Attitude Bias',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: JuiceTheme.parchmentDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildSkewChip('None', SkewType.none, Icons.horizontal_rule, JuiceTheme.parchmentDark),
                        _buildSkewChip('@- Opposed', SkewType.disadvantage, Icons.thumb_down_outlined, _opposedColor),
                        _buildSkewChip('@+ In Favor', SkewType.advantage, Icons.thumb_up_outlined, _favorColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildRollButton(
                title: 'Roll Companion Response',
                subtitle: '1d100${_getSkewLabel()}',
                icon: Icons.question_answer,
                color: _companionColor,
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollCompanionResponse(skew: _companionSkew));
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // ═══════════════════════════════════════════════════════════════
              // DIALOG TOPIC SECTION (1d100)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Dialog Topic', Icons.topic, color: _topicColor),
              _buildInfoBox(
                'What are NPCs talking about? More topics than the standard table. '
                'Also usable for News, letters, books, writing on walls, etc.',
                color: _topicColor,
              ),
              const SizedBox(height: 8),
              _buildRollButton(
                title: 'Roll Dialog Topic',
                subtitle: 'What NPCs are discussing (1d100)',
                icon: Icons.forum,
                color: _topicColor,
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollDialogTopic());
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // ═══════════════════════════════════════════════════════════════
              // REFERENCE: RESPONSE FAVOR LEVELS
              // ═══════════════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _companionColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sentiment_satisfied_alt, size: 14, color: _companionColor),
                        const SizedBox(width: 6),
                        Text(
                          'Response Favor Levels',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: _companionColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFavorLevelRow('1-20', 'Strongly Opposed', JuiceTheme.danger),
                    _buildFavorLevelRow('21-40', 'Hesitant', JuiceTheme.juiceOrange),
                    _buildFavorLevelRow('41-60', 'Neutral / Questioning', JuiceTheme.parchmentDark),
                    _buildFavorLevelRow('61-80', 'Cautious Support', JuiceTheme.info),
                    _buildFavorLevelRow('81-100', 'Strongly In Favor', JuiceTheme.success),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // TIP: DIALOG GRID
              // ═══════════════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: JuiceTheme.mystic.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: JuiceTheme.mystic),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Use the Dialog Grid (Dialog button) for a more interactive '
                        'mini-game experience with position tracking.',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.parchment.withValues(alpha: 0.85),
                        ),
                      ),
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
          child: Text(
            'Close',
            style: TextStyle(color: _npcColor),
          ),
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

  // Theme colors - success green for abstract/visual creativity
  static const Color _iconColor = JuiceTheme.success;
  static const Color _gridColor = JuiceTheme.mystic;

  const _AbstractIconsDialog({
    required this.abstractIcons,
    required this.onRoll,
  });

  // Build a use case item
  Widget _buildUseCase(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _iconColor.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchment.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a grid cell preview
  Widget _buildGridCell(int row, int col, {bool isHighlighted = false}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isHighlighted 
            ? _iconColor.withValues(alpha: 0.4)
            : JuiceTheme.inkDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isHighlighted 
              ? _iconColor 
              : JuiceTheme.parchmentDark.withValues(alpha: 0.3),
          width: isHighlighted ? 1.5 : 0.5,
        ),
      ),
      child: isHighlighted
          ? Icon(Icons.image, size: 12, color: _iconColor)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome, size: 20, color: _iconColor),
          ),
          const SizedBox(width: 10),
          Text(
            'Abstract Icons',
            style: TextStyle(
              fontFamily: JuiceTheme.fontFamilySerif,
              color: _iconColor,
            ),
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _iconColor.withValues(alpha: 0.12),
                      _iconColor.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _iconColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette, size: 14, color: _iconColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Visual Inspiration • Symbol Interpretation',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Roll 1d10 + 1d6 to pick an icon. These abstract images can be '
                      'used for inspiration instead of words. Inspired by Rory\'s Story Cubes.',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Mini grid visualization
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _gridColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Grid header
                    Row(
                      children: [
                        Icon(Icons.grid_view, size: 14, color: _gridColor),
                        const SizedBox(width: 6),
                        Text(
                          'Icon Grid',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _gridColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _gridColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '10 × 6 = 60 icons',
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: JuiceTheme.fontFamilyMono,
                              color: _gridColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mini grid preview (showing 4x4 sample)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Row labels
                        Column(
                          children: [
                            const SizedBox(height: 22),  // Offset for column labels
                            for (int r = 1; r <= 4; r++)
                              Container(
                                width: 16,
                                height: 20,
                                margin: const EdgeInsets.only(bottom: 2),
                                alignment: Alignment.center,
                                child: Text(
                                  '$r',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontFamily: JuiceTheme.fontFamilyMono,
                                    color: JuiceTheme.parchmentDark,
                                  ),
                                ),
                              ),
                            Container(
                              width: 16,
                              height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                '⋮',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        // Grid cells
                        Column(
                          children: [
                            // Column labels
                            Row(
                              children: [
                                for (int c = 1; c <= 4; c++)
                                  Container(
                                    width: 20,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$c',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontFamily: JuiceTheme.fontFamilyMono,
                                        color: JuiceTheme.parchmentDark,
                                      ),
                                    ),
                                  ),
                                Container(
                                  width: 20,
                                  height: 16,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '⋯',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: JuiceTheme.parchmentDark.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Grid rows
                            for (int r = 1; r <= 4; r++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  children: [
                                    for (int c = 1; c <= 4; c++)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 2),
                                        child: _buildGridCell(r, c, isHighlighted: r == 2 && c == 3),
                                      ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '⋯',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: JuiceTheme.parchmentDark.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Ellipsis row
                            Row(
                              children: [
                                for (int c = 1; c <= 5; c++)
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(right: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '⋮',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: JuiceTheme.parchmentDark.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dice indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: JuiceTheme.rust.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: JuiceTheme.rust.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.casino, size: 12, color: JuiceTheme.rust),
                              const SizedBox(width: 4),
                              Text(
                                '1d10 → Row',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: JuiceTheme.fontFamilyMono,
                                  fontWeight: FontWeight.bold,
                                  color: JuiceTheme.rust,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: JuiceTheme.info.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: JuiceTheme.info.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.casino, size: 12, color: JuiceTheme.info),
                              const SizedBox(width: 4),
                              Text(
                                '1d6 → Col',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: JuiceTheme.fontFamilyMono,
                                  fontWeight: FontWeight.bold,
                                  color: JuiceTheme.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Usage hints section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 14, color: JuiceTheme.gold),
                        const SizedBox(width: 6),
                        Text(
                          'Uses',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: JuiceTheme.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildUseCase(Icons.swap_horiz, 'Alternative to word-based meaning tables'),
                    _buildUseCase(Icons.visibility, 'Visual inspiration for scenes or encounters'),
                    _buildUseCase(Icons.psychology, 'Interpret the symbol in your current context'),
                    _buildUseCase(Icons.layers, 'Use multiple icons for complex situations'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              
              // Roll button
              InkWell(
                onTap: () {
                  final result = abstractIcons.generate();
                  onRoll(result);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _iconColor,
                        _iconColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _iconColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20, color: JuiceTheme.inkDark),
                      const SizedBox(width: 10),
                      Text(
                        'Roll 1d10 + 1d6',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: JuiceTheme.fontFamilyMono,
                          color: JuiceTheme.inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Grid reference footer
              Center(
                child: Text(
                  'Rows: 1-9, 0  •  Columns: 1-6',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: JuiceTheme.fontFamilyMono,
                    color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
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
          child: Text(
            'Close',
            style: TextStyle(color: _iconColor),
          ),
        ),
      ],
    );
  }
}

/// A bottom sheet for selecting or managing sessions.
class _SessionSelectorSheet extends StatelessWidget {
  final List<Session> sessions;
  final Session? currentSession;
  final void Function(Session) onSelectSession;
  final void Function(Session) onShowDetails;
  final void Function(Session) onDeleteSession;
  final VoidCallback onNewSession;
  final VoidCallback onImportSession;

  const _SessionSelectorSheet({
    required this.sessions,
    required this.currentSession,
    required this.onSelectSession,
    required this.onShowDetails,
    required this.onDeleteSession,
    required this.onNewSession,
    required this.onImportSession,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onImportSession,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Import'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // New Session button
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.add, color: Colors.white),
            ),
            title: const Text('New Session'),
            subtitle: const Text('Start a fresh adventure'),
            onTap: () {
              Navigator.pop(context);
              onNewSession();
            },
          ),
          const Divider(height: 1),
          // Session list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isSelected = session.id == currentSession?.id;
                
                return Dismissible(
                  key: Key(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Session?'),
                        content: Text(
                          isSelected
                              ? 'This is your current session. Deleting it will create a new empty session. '
                                'Are you sure you want to delete "${session.name}" with ${session.history.length} rolls?'
                              : 'Are you sure you want to delete "${session.name}"? '
                                'This will permanently remove all ${session.history.length} rolls.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    onDeleteSession(session);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey[700],
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              session.name.isNotEmpty
                                  ? session.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                    title: Text(
                      session.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${session.history.length} rolls • ${_formatDate(session.lastAccessedAt)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        Navigator.pop(context);
                        onShowDetails(session);
                      },
                    ),
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        onSelectSession(session);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          // Footer with session count
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${sessions.length} session${sessions.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for viewing and managing session details.
class _SessionDetailsDialog extends StatefulWidget {
  final Session session;
  final bool isCurrentSession;
  final Future<void> Function(Session) onUpdate;
  final Future<void> Function() onDelete;
  final VoidCallback onExport;

  const _SessionDetailsDialog({
    required this.session,
    required this.isCurrentSession,
    required this.onUpdate,
    required this.onDelete,
    required this.onExport,
  });

  @override
  State<_SessionDetailsDialog> createState() => _SessionDetailsDialogState();
}

class _SessionDetailsDialogState extends State<_SessionDetailsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  bool _isEditing = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.name);
    _notesController = TextEditingController(text: widget.session.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatFullDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  Future<void> _saveChanges() async {
    final updatedSession = widget.session.copyWith(
      name: _nameController.text.trim().isEmpty 
          ? widget.session.name 
          : _nameController.text.trim(),
      notes: _notesController.text.trim(),
    );
    await widget.onUpdate(updatedSession);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session updated')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: Text(
          widget.isCurrentSession
              ? 'This is your current session. Deleting it will create a new empty session. '
                'Are you sure you want to delete "${widget.session.name}" with ${widget.session.history.length} rolls?'
              : 'Are you sure you want to delete "${widget.session.name}"? '
                'This will permanently remove all ${widget.session.history.length} rolls.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      await widget.onDelete();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Session Name',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  )
                : Text(widget.session.name),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 350,
        ),
        child: _ScrollableDialogContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats
              const _SectionHeader(icon: Icons.analytics, title: 'Session Stats'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.casino,
                      label: 'Rolls',
                      value: '${widget.session.history.length}',
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _formatFullDate(widget.session.createdAt),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                    icon: Icons.access_time,
                    label: 'Last Played',
                    value: _formatFullDate(widget.session.lastAccessedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Notes
            const _SectionHeader(icon: Icons.notes, title: 'Notes'),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add notes about this session...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Text(
                  (widget.session.notes ?? '').isEmpty
                      ? 'No notes yet'
                      : widget.session.notes!,
                  style: TextStyle(
                    color: (widget.session.notes ?? '').isEmpty
                        ? Colors.grey[500]
                        : Colors.white,
                    fontStyle: (widget.session.notes ?? '').isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Export button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onExport,
                icon: const Icon(Icons.copy),
                label: const Text('Copy to Clipboard'),
              ),
            ),
            if (widget.isCurrentSession)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This is your current session',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        ),
      ),
      actions: [
        if (!_isDeleting)
          TextButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        if (_isDeleting)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        const Spacer(),
        if (_isEditing) ...[
          TextButton(
            onPressed: () {
              _nameController.text = widget.session.name;
              _notesController.text = widget.session.notes ?? '';
              setState(() => _isEditing = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text('Save'),
          ),
        ] else
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
      ],
    );
  }
}

/// A helper widget for displaying detail rows.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

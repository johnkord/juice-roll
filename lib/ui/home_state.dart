import 'package:flutter/foundation.dart';
import '../models/roll_result.dart';
import '../models/roll_result_factory.dart';
import '../models/session.dart';
import '../services/session_service.dart';
import '../core/preset_registry.dart';
import '../core/roll_engine.dart';
import '../presets/abstract_icons.dart';
import '../presets/challenge.dart';
import '../presets/details.dart';
import '../presets/dialog_generator.dart';
import '../presets/discover_meaning.dart';
import '../presets/dungeon_generator.dart';
import '../presets/expectation_check.dart';
import '../presets/extended_npc_conversation.dart';
import '../presets/fate_check.dart';
import '../presets/immersion.dart';
import '../presets/interrupt_plot_point.dart';
import '../presets/name_generator.dart';
import '../presets/next_scene.dart';
import '../presets/npc_action.dart';
import '../presets/object_treasure.dart';
import '../presets/pay_the_price.dart';
import '../presets/quest.dart';
import '../presets/random_event.dart';
import '../presets/scale.dart';
import '../presets/settlement.dart';
import '../presets/wilderness.dart';

/// Immutable state snapshot for the HomeScreen.
/// 
/// This class holds all the state that was previously scattered
/// across multiple fields in _HomeScreenState.
class HomeState {
  /// Roll history (most recent first)
  final List<RollResult> history;
  
  /// Current active session
  final Session? currentSession;
  
  /// All available sessions (for session selector)
  final List<Session> sessions;
  
  /// Whether the app is currently loading session data
  final bool isLoading;
  
  /// Dungeon exploration phase: true = Entering, false = Exploring
  final bool isDungeonEntering;
  
  /// Dungeon map generation mode: false = One-Pass, true = Two-Pass
  final bool isDungeonTwoPassMode;
  
  /// Two-Pass map generation state: whether first doubles have been rolled
  final bool twoPassHasFirstDoubles;
  
  /// Wilderness exploration state
  final WildernessState? wildernessState;
  
  /// Dice dialog mode: 0 = Standard, 1 = Fate, 2 = Ironsworn
  final int diceDialogMode;
  
  /// Ironsworn roll type: 'action', 'progress', 'oracle', 'yesno', 'cursed'
  final String diceDialogIronswornRollType;
  
  /// Oracle die type: 6, 20, or 100
  final int diceDialogOracleDieType;

  const HomeState({
    this.history = const [],
    this.currentSession,
    this.sessions = const [],
    this.isLoading = true,
    this.isDungeonEntering = true,
    this.isDungeonTwoPassMode = false,
    this.twoPassHasFirstDoubles = false,
    this.wildernessState,
    this.diceDialogMode = 0,
    this.diceDialogIronswornRollType = 'action',
    this.diceDialogOracleDieType = 100,
  });

  /// Create a copy with updated fields
  HomeState copyWith({
    List<RollResult>? history,
    Session? currentSession,
    bool clearCurrentSession = false,
    List<Session>? sessions,
    bool? isLoading,
    bool? isDungeonEntering,
    bool? isDungeonTwoPassMode,
    bool? twoPassHasFirstDoubles,
    WildernessState? wildernessState,
    bool clearWildernessState = false,
    int? diceDialogMode,
    String? diceDialogIronswornRollType,
    int? diceDialogOracleDieType,
  }) {
    return HomeState(
      history: history ?? this.history,
      currentSession: clearCurrentSession ? null : (currentSession ?? this.currentSession),
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      isDungeonEntering: isDungeonEntering ?? this.isDungeonEntering,
      isDungeonTwoPassMode: isDungeonTwoPassMode ?? this.isDungeonTwoPassMode,
      twoPassHasFirstDoubles: twoPassHasFirstDoubles ?? this.twoPassHasFirstDoubles,
      wildernessState: clearWildernessState ? null : (wildernessState ?? this.wildernessState),
      diceDialogMode: diceDialogMode ?? this.diceDialogMode,
      diceDialogIronswornRollType: diceDialogIronswornRollType ?? this.diceDialogIronswornRollType,
      diceDialogOracleDieType: diceDialogOracleDieType ?? this.diceDialogOracleDieType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeState &&
        listEquals(other.history, history) &&
        other.currentSession?.id == currentSession?.id &&
        listEquals(other.sessions, sessions) &&
        other.isLoading == isLoading &&
        other.isDungeonEntering == isDungeonEntering &&
        other.isDungeonTwoPassMode == isDungeonTwoPassMode &&
        other.twoPassHasFirstDoubles == twoPassHasFirstDoubles &&
        other.wildernessState == wildernessState &&
        other.diceDialogMode == diceDialogMode &&
        other.diceDialogIronswornRollType == diceDialogIronswornRollType &&
        other.diceDialogOracleDieType == diceDialogOracleDieType;
  }

  @override
  int get hashCode {
    return Object.hash(
      history.length,
      currentSession?.id,
      sessions.length,
      isLoading,
      isDungeonEntering,
      isDungeonTwoPassMode,
      twoPassHasFirstDoubles,
      wildernessState,
      diceDialogMode,
      diceDialogIronswornRollType,
      diceDialogOracleDieType,
    );
  }
}

/// Manages application state for the HomeScreen.
/// 
/// This separates business logic from UI, making it:
/// - **Testable**: Unit test state transitions without widget tests
/// - **Maintainable**: Clear separation of concerns
/// - **Extensible**: Easy to add features like undo/redo
class HomeStateNotifier extends ChangeNotifier {
  final SessionService _sessionService;
  
  /// Registry containing all oracle presets.
  /// Presets are lazily initialized when first accessed.
  final PresetRegistry presets;

  HomeState _state = const HomeState();
  
  /// Current state snapshot
  HomeState get state => _state;

  /// Creates a HomeStateNotifier with consolidated dependencies.
  /// 
  /// All oracle presets are now managed through [PresetRegistry],
  /// reducing the constructor from 22+ parameters to just 2.
  HomeStateNotifier({
    SessionService? sessionService,
    PresetRegistry? presets,
  })  : _sessionService = sessionService ?? SessionService(),
        presets = presets ?? PresetRegistry();

  // ========== Convenience Accessors ==========
  // These provide backwards compatibility and cleaner access patterns
  
  RollEngine get rollEngine => presets.rollEngine;
  
  // Forward all preset accessors to the registry for API compatibility
  FateCheck get fateCheck => presets.fateCheck;
  ExpectationCheck get expectationCheck => presets.expectationCheck;
  NextScene get nextScene => presets.nextScene;
  RandomEvent get randomEvent => presets.randomEvent;
  DiscoverMeaning get discoverMeaning => presets.discoverMeaning;
  InterruptPlotPoint get interruptPlotPoint => presets.interruptPlotPoint;
  NpcAction get npcAction => presets.npcAction;
  DialogGenerator get dialogGenerator => presets.dialogGenerator;
  NameGenerator get nameGenerator => presets.nameGenerator;
  Settlement get settlement => presets.settlement;
  ObjectTreasure get objectTreasure => presets.objectTreasure;
  Quest get quest => presets.quest;
  DungeonGenerator get dungeonGenerator => presets.dungeonGenerator;
  Wilderness get wilderness => presets.wilderness;
  ExtendedNpcConversation get extendedNpcConversation => presets.extendedNpcConversation;
  Challenge get challenge => presets.challenge;
  PayThePrice get payThePrice => presets.payThePrice;
  Scale get scale => presets.scale;
  Details get details => presets.details;
  Immersion get immersion => presets.immersion;
  AbstractIcons get abstractIcons => presets.abstractIcons;

  /// Initialize by loading the active session
  Future<void> init() async {
    _updateState(_state.copyWith(isLoading: true));
    
    try {
      await _sessionService.init();
      final session = await _sessionService.loadActiveSession();
      final sessions = await _sessionService.getSessions();
      
      // Load history from session
      final history = <RollResult>[];
      for (final json in session.history) {
        history.add(RollResultFactory.fromJson(json));
      }
      
      // Restore wilderness state if available
      WildernessState? wildernessState;
      if (session.wildernessEnvironmentRow != null) {
        wildernessState = WildernessState(
          environmentRow: session.wildernessEnvironmentRow!,
          typeRow: session.wildernessTypeRow ?? session.wildernessEnvironmentRow!,
          isLost: session.wildernessIsLost,
        );
      }
      
      _updateState(HomeState(
        history: history,
        currentSession: session,
        sessions: sessions,
        isLoading: false,
        isDungeonEntering: session.dungeonIsEntering,
        isDungeonTwoPassMode: session.dungeonIsTwoPassMode,
        twoPassHasFirstDoubles: session.twoPassHasFirstDoubles,
        wildernessState: wildernessState,
        diceDialogMode: session.diceDialogMode,
        diceDialogIronswornRollType: session.diceDialogIronswornRollType,
        diceDialogOracleDieType: session.diceDialogOracleDieType,
      ));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  /// Switch to a different session
  Future<void> switchSession(Session session) async {
    final fullSession = await _sessionService.getSession(session.id);
    if (fullSession == null) return;
    
    await _sessionService.setActiveSessionId(session.id);
    
    // Load history from session
    final history = <RollResult>[];
    for (final json in fullSession.history) {
      history.add(RollResultFactory.fromJson(json));
    }
    
    // Restore wilderness state
    WildernessState? wildernessState;
    if (fullSession.wildernessEnvironmentRow != null) {
      wildernessState = WildernessState(
        environmentRow: fullSession.wildernessEnvironmentRow!,
        typeRow: fullSession.wildernessTypeRow ?? fullSession.wildernessEnvironmentRow!,
        isLost: fullSession.wildernessIsLost,
      );
    }
    
    // Refresh session list
    final sessions = await _sessionService.getSessions();
    
    _updateState(HomeState(
      history: history,
      currentSession: fullSession,
      sessions: sessions,
      isLoading: false,
      isDungeonEntering: fullSession.dungeonIsEntering,
      isDungeonTwoPassMode: fullSession.dungeonIsTwoPassMode,
      twoPassHasFirstDoubles: fullSession.twoPassHasFirstDoubles,
      wildernessState: wildernessState,
      diceDialogMode: fullSession.diceDialogMode,
      diceDialogIronswornRollType: fullSession.diceDialogIronswornRollType,
      diceDialogOracleDieType: fullSession.diceDialogOracleDieType,
    ));
  }

  /// Create a new session
  Future<Session> createSession(String name, {String? notes}) async {
    final session = await _sessionService.createSession(name, notes: notes);
    
    // Refresh session list
    final sessions = await _sessionService.getSessions();
    _updateState(_state.copyWith(sessions: sessions));
    
    // Switch to the new session
    await switchSession(session);
    
    return session;
  }

  /// Delete a session
  Future<void> deleteSession(Session session) async {
    await _sessionService.deleteSession(session.id);
    
    // If we deleted the current session, reload
    if (_state.currentSession?.id == session.id) {
      await init();
    } else {
      final sessions = await _sessionService.getSessions();
      _updateState(_state.copyWith(sessions: sessions));
    }
  }

  /// Update session name and notes
  Future<void> updateSession(String id, {String? name, String? notes}) async {
    await _sessionService.updateSession(id, name: name, notes: notes);
    
    final sessions = await _sessionService.getSessions();
    
    // Update current session if it was modified
    if (_state.currentSession?.id == id) {
      final updatedCurrent = _state.currentSession!;
      if (name != null) updatedCurrent.name = name;
      if (notes != null) updatedCurrent.notes = notes;
      _updateState(_state.copyWith(
        currentSession: updatedCurrent,
        sessions: sessions,
      ));
    } else {
      _updateState(_state.copyWith(sessions: sessions));
    }
  }

  /// Update session settings (like max rolls per session)
  Future<void> updateSessionSettings(
    String id, {
    int? maxRollsPerSession,
    bool clearMaxRollsPerSession = false,
  }) async {
    await _sessionService.updateSessionSettings(
      id,
      maxRollsPerSession: maxRollsPerSession,
      clearMaxRollsPerSession: clearMaxRollsPerSession,
    );
    
    final sessions = await _sessionService.getSessions();
    
    // Update current session if it was modified
    if (_state.currentSession?.id == id) {
      final updatedCurrent = _state.currentSession!;
      if (clearMaxRollsPerSession) {
        updatedCurrent.maxRollsPerSession = null;
      } else if (maxRollsPerSession != null) {
        updatedCurrent.maxRollsPerSession = maxRollsPerSession;
      }
      _updateState(_state.copyWith(
        currentSession: updatedCurrent,
        sessions: sessions,
      ));
    } else {
      _updateState(_state.copyWith(sessions: sessions));
    }
  }

  /// Import a session from clipboard
  Future<Session?> importSession() async {
    final session = await _sessionService.importSession();
    
    if (session != null) {
      final sessions = await _sessionService.getSessions();
      _updateState(_state.copyWith(sessions: sessions));
    }
    
    return session;
  }

  /// Get a full session by ID (for details dialog)
  Future<Session?> getSession(String id) async {
    return await _sessionService.getSession(id);
  }

  // ========== History Management ==========

  /// Add a result to the history
  void addToHistory(RollResult result) {
    final newHistory = [result, ..._state.history];
    
    // Get the max rolls limit from session settings (null = unlimited)
    final maxRolls = _state.currentSession?.maxRollsPerSession;
    
    _updateState(_state.copyWith(history: newHistory));
    
    // Save to session
    if (_state.currentSession != null) {
      _state.currentSession!.history.insert(0, result.toJson());
      // Only trim if a limit is set
      if (maxRolls != null && _state.currentSession!.history.length > maxRolls) {
        _state.currentSession!.history.removeLast();
      }
      _sessionService.saveSession(_state.currentSession!);
    }
  }

  /// Clear all history
  void clearHistory() {
    _updateState(_state.copyWith(history: []));
    
    if (_state.currentSession != null) {
      _state.currentSession!.history.clear();
      _sessionService.saveSession(_state.currentSession!);
    }
  }

  // ========== Dungeon State Management ==========

  /// Set the dungeon exploration phase
  void setDungeonPhase(bool isEntering) {
    _updateState(_state.copyWith(isDungeonEntering: isEntering));
    _saveSessionState();
  }

  /// Set the dungeon map generation mode
  void setDungeonTwoPassMode(bool isTwoPassMode) {
    _updateState(_state.copyWith(isDungeonTwoPassMode: isTwoPassMode));
    _saveSessionState();
  }

  /// Set whether first doubles have been rolled in two-pass mode
  void setTwoPassFirstDoubles(bool hasFirstDoubles) {
    _updateState(_state.copyWith(twoPassHasFirstDoubles: hasFirstDoubles));
    _saveSessionState();
  }

  // ========== Wilderness State Management ==========

  /// Get the current wilderness state
  WildernessState? get wildernessState => _state.wildernessState;

  /// Update wilderness state from a result
  void updateWildernessState(WildernessState? newState) {
    _updateState(_state.copyWith(wildernessState: newState));
    _saveSessionState();
  }

  /// Reset wilderness state
  void resetWildernessState() {
    _updateState(_state.copyWith(clearWildernessState: true));
    _saveSessionState();
  }

  /// Set wilderness position manually (from history item)
  void setWildernessPosition(int envRow, int? typeRow) {
    final result = wilderness.initializeAt(envRow, typeRow: typeRow);
    if (result.newState != null) {
      _updateState(_state.copyWith(wildernessState: result.newState));
    }
    addToHistory(result);
    _saveSessionState();
  }

  /// Set lost/found status
  void setWildernessLost(bool isLost) {
    final currentState = _state.wildernessState;
    if (currentState != null) {
      _updateState(_state.copyWith(
        wildernessState: currentState.copyWith(isLost: isLost),
      ));
      _saveSessionState();
    }
  }

  // ========== Quick Roll Methods ==========
  
  /// Roll Discover Meaning
  void rollDiscoverMeaning() {
    final result = discoverMeaning.generate();
    addToHistory(result);
  }

  /// Roll Interrupt Plot Point
  void rollInterruptPlotPoint() {
    final result = interruptPlotPoint.generate();
    addToHistory(result);
  }

  /// Roll Quest
  void rollQuest() {
    final result = quest.generate();
    addToHistory(result);
  }

  /// Roll Scale
  void rollScale() {
    final result = scale.roll();
    addToHistory(result);
  }

  // ========== Dice Dialog State Management ==========

  /// Update dice dialog state (mode, roll type, die type)
  void updateDiceDialogState({
    int? mode,
    String? ironswornRollType,
    int? oracleDieType,
  }) {
    _updateState(_state.copyWith(
      diceDialogMode: mode,
      diceDialogIronswornRollType: ironswornRollType,
      diceDialogOracleDieType: oracleDieType,
    ));
    _saveSessionState();
  }

  // ========== Private Helpers ==========

  void _updateState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _saveSessionState() async {
    if (_state.currentSession == null) return;
    
    _state.currentSession!.dungeonIsEntering = _state.isDungeonEntering;
    _state.currentSession!.dungeonIsTwoPassMode = _state.isDungeonTwoPassMode;
    _state.currentSession!.twoPassHasFirstDoubles = _state.twoPassHasFirstDoubles;
    
    // Save wilderness state from HomeState
    final wildernessState = _state.wildernessState;
    if (wildernessState != null) {
      _state.currentSession!.wildernessEnvironmentRow = wildernessState.environmentRow;
      _state.currentSession!.wildernessTypeRow = wildernessState.typeRow;
      _state.currentSession!.wildernessIsLost = wildernessState.isLost;
    } else {
      // Clear wilderness state in session
      _state.currentSession!.wildernessEnvironmentRow = null;
      _state.currentSession!.wildernessTypeRow = null;
      _state.currentSession!.wildernessIsLost = false;
    }
    
    // Save dice dialog state
    _state.currentSession!.diceDialogMode = _state.diceDialogMode;
    _state.currentSession!.diceDialogIronswornRollType = _state.diceDialogIronswornRollType;
    _state.currentSession!.diceDialogOracleDieType = _state.diceDialogOracleDieType;
    
    await _sessionService.saveSession(_state.currentSession!);
  }
}

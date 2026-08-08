import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/ui/home_state.dart';
import 'package:juice_roll/models/roll_result.dart';
import 'package:juice_roll/models/session.dart';
import 'package:juice_roll/services/session_service.dart';

void main() {
  group('HomeState', () {
    test('default state has expected initial values', () {
      const state = HomeState();

      expect(state.history, isEmpty);
      expect(state.currentSession, isNull);
      expect(state.sessions, isEmpty);
      expect(state.isLoading, isTrue);
      expect(state.persistenceError, isNull);
      expect(state.isDungeonEntering, isTrue);
      expect(state.isDungeonTwoPassMode, isFalse);
      expect(state.twoPassHasFirstDoubles, isFalse);
    });

    test('copyWith creates new state with updated fields', () {
      const state = HomeState();

      final newState = state.copyWith(
        isLoading: false,
        isDungeonEntering: false,
        isDungeonTwoPassMode: true,
      );

      expect(newState.isLoading, isFalse);
      expect(newState.isDungeonEntering, isFalse);
      expect(newState.isDungeonTwoPassMode, isTrue);
      // Unchanged fields should remain
      expect(newState.twoPassHasFirstDoubles, isFalse);
    });

    test('copyWith with history creates independent list', () {
      const state = HomeState();
      final history = [
        RollResult(
          type: RollType.fateCheck,
          description: 'Test',
          diceResults: [1],
          total: 1,
        ),
      ];

      final newState = state.copyWith(history: history);

      expect(newState.history.length, 1);
      expect(newState.history.first.description, 'Test');
    });

    test('equality works correctly', () {
      const state1 = HomeState(isLoading: false);
      const state2 = HomeState(isLoading: false);
      const state3 = HomeState(isLoading: true);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('HomeStateNotifier', () {
    test('creates with default presets', () {
      final notifier = HomeStateNotifier();

      expect(notifier.rollEngine, isNotNull);
      expect(notifier.fateCheck, isNotNull);
      expect(notifier.discoverMeaning, isNotNull);
      expect(notifier.wilderness, isNotNull);
      expect(notifier.dungeonGenerator, isNotNull);

      notifier.dispose();
    });

    test('initial state is loading', () {
      final notifier = HomeStateNotifier();

      expect(notifier.state.isLoading, isTrue);
      expect(notifier.state.history, isEmpty);

      notifier.dispose();
    });

    test('addToHistory adds result to beginning', () {
      final notifier = HomeStateNotifier();

      final result1 = RollResult(
        type: RollType.fateCheck,
        description: 'First',
        diceResults: [1],
        total: 1,
      );
      final result2 = RollResult(
        type: RollType.fateCheck,
        description: 'Second',
        diceResults: [2],
        total: 2,
      );

      notifier.addToHistory(result1);
      notifier.addToHistory(result2);

      expect(notifier.state.history.length, 2);
      expect(notifier.state.history[0].description, 'Second');
      expect(notifier.state.history[1].description, 'First');

      notifier.dispose();
    });

    test('clearHistory removes all results', () {
      final notifier = HomeStateNotifier();

      notifier.addToHistory(RollResult(
        type: RollType.fateCheck,
        description: 'Test',
        diceResults: [1],
        total: 1,
      ));

      expect(notifier.state.history.length, 1);

      notifier.clearHistory();

      expect(notifier.state.history, isEmpty);

      notifier.dispose();
    });

    test('setDungeonPhase updates state', () {
      final notifier = HomeStateNotifier();

      expect(notifier.state.isDungeonEntering, isTrue);

      notifier.setDungeonPhase(false);

      expect(notifier.state.isDungeonEntering, isFalse);

      notifier.dispose();
    });

    test('setDungeonTwoPassMode updates state', () {
      final notifier = HomeStateNotifier();

      expect(notifier.state.isDungeonTwoPassMode, isFalse);

      notifier.setDungeonTwoPassMode(true);

      expect(notifier.state.isDungeonTwoPassMode, isTrue);

      notifier.dispose();
    });

    test('setTwoPassFirstDoubles updates state', () {
      final notifier = HomeStateNotifier();

      expect(notifier.state.twoPassHasFirstDoubles, isFalse);

      notifier.setTwoPassFirstDoubles(true);

      expect(notifier.state.twoPassHasFirstDoubles, isTrue);

      notifier.dispose();
    });

    test('notifies listeners on state change', () {
      final notifier = HomeStateNotifier();
      var notificationCount = 0;

      notifier.addListener(() {
        notificationCount++;
      });

      notifier.setDungeonPhase(false);
      expect(notificationCount, 1);

      notifier.addToHistory(RollResult(
        type: RollType.fateCheck,
        description: 'Test',
        diceResults: [1],
        total: 1,
      ));
      expect(notificationCount, 2);

      notifier.clearHistory();
      expect(notificationCount, 3);

      notifier.dispose();
    });

    test('rollDiscoverMeaning adds result to history', () {
      final notifier = HomeStateNotifier();

      expect(notifier.state.history, isEmpty);

      notifier.rollDiscoverMeaning();

      expect(notifier.state.history.length, 1);
      expect(notifier.state.history.first.type, RollType.discoverMeaning);

      notifier.dispose();
    });

    test('rollInterruptPlotPoint adds result to history', () {
      final notifier = HomeStateNotifier();

      notifier.rollInterruptPlotPoint();

      expect(notifier.state.history.length, 1);
      expect(notifier.state.history.first.type, RollType.interruptPlotPoint);

      notifier.dispose();
    });

    test('rollQuest adds result to history', () {
      final notifier = HomeStateNotifier();

      notifier.rollQuest();

      expect(notifier.state.history.length, 1);
      expect(notifier.state.history.first.type, RollType.quest);

      notifier.dispose();
    });

    test('rollScale adds result to history', () {
      final notifier = HomeStateNotifier();

      notifier.rollScale();

      expect(notifier.state.history.length, 1);
      expect(notifier.state.history.first.type, RollType.scale);

      notifier.dispose();
    });

    test('history is unlimited by default', () {
      final notifier = HomeStateNotifier();

      // Add 105 items
      for (var i = 0; i < 105; i++) {
        notifier.addToHistory(RollResult(
          type: RollType.fateCheck,
          description: 'Item $i',
          diceResults: [i],
          total: i,
        ));
      }

      expect(notifier.state.history.length, 105);
      // Most recent should be first
      expect(notifier.state.history.first.description, 'Item 104');

      notifier.dispose();
    });

    test('initialization failures remain visible and retryable', () async {
      final notifier = HomeStateNotifier(
        sessionService: _FailingInitSessionService(),
      );

      await notifier.init();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.currentSession, isNull);
      expect(notifier.state.persistenceError, isNotNull);

      notifier.dispose();
    });

    test('failed background saves can be retried', () async {
      final service = _ControlledSessionService();
      final notifier = HomeStateNotifier(sessionService: service);
      await notifier.init();
      service.failSaves = true;

      notifier.addToHistory(_result('Unsaved'));
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.persistenceError, isNotNull);

      service.failSaves = false;
      await notifier.retryPersistence();

      expect(notifier.state.persistenceError, isNull);
      expect(service.storedSession.history, hasLength(1));

      notifier.dispose();
    });

    test('custom history limits keep memory and storage in sync', () async {
      final service = _ControlledSessionService(maxRollsPerSession: 2);
      final notifier = HomeStateNotifier(sessionService: service);
      await notifier.init();

      notifier.addToHistory(_result('First'));
      notifier.addToHistory(_result('Second'));
      notifier.addToHistory(_result('Third'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        notifier.state.history.map((result) => result.description),
        ['Third', 'Second'],
      );
      expect(notifier.state.currentSession!.history, hasLength(2));
      expect(service.storedSession.history, hasLength(2));

      notifier.dispose();
    });

    test('session summaries update immediately when history changes', () async {
      final service = _ControlledSessionService();
      final notifier = HomeStateNotifier(sessionService: service);
      await notifier.init();

      notifier.addToHistory(_result('Counted'));

      expect(notifier.state.sessions.single.rollCount, 1);

      notifier.clearHistory();

      expect(notifier.state.sessions.single.rollCount, 0);

      notifier.dispose();
    });

    test('session management failures are reported without changing state',
        () async {
      final service = _ControlledSessionService();
      final notifier = HomeStateNotifier(sessionService: service);
      await notifier.init();
      final originalSession = notifier.state.currentSession!;

      service.failReads = true;
      expect(await notifier.switchSession(originalSession), isFalse);
      expect(notifier.state.currentSession?.id, originalSession.id);
      expect(notifier.state.persistenceError, isNotNull);

      service
        ..failReads = false
        ..failDeletes = true;
      expect(await notifier.deleteSession(originalSession), isFalse);
      expect(notifier.state.currentSession?.id, originalSession.id);

      service
        ..failDeletes = false
        ..failUpdates = true;
      expect(
        await notifier.updateSession(originalSession.id, name: 'Not Saved'),
        isFalse,
      );
      expect(notifier.state.currentSession?.name, isNot('Not Saved'));

      notifier.dispose();
    });

    test('setWildernessPosition adds result to history', () {
      final notifier = HomeStateNotifier();

      notifier.setWildernessPosition(5, 5);

      expect(notifier.state.history.length, 1);
      expect(
          notifier.state.history.first.description, 'Set Wilderness Position');

      // Verify wilderness state is updated in HomeState
      expect(notifier.wildernessState, isNotNull);
      expect(notifier.wildernessState!.environmentRow, 5);

      notifier.dispose();
    });
  });
}

RollResult _result(String description) => RollResult(
      type: RollType.fateCheck,
      description: description,
      diceResults: const [1],
      total: 1,
    );

class _FailingInitSessionService extends SessionService {
  @override
  Future<void> init() async {
    throw SessionStorageException(
      'Initialize session storage',
      StateError('Unavailable'),
    );
  }
}

class _ControlledSessionService extends SessionService {
  _ControlledSessionService({int? maxRollsPerSession})
      : storedSession = Session.create('Test Session')
          ..maxRollsPerSession = maxRollsPerSession;

  Session storedSession;
  bool failSaves = false;
  bool failReads = false;
  bool failDeletes = false;
  bool failUpdates = false;

  @override
  Future<void> init() async {}

  @override
  Future<Session> loadActiveSession() async => _copy(storedSession);

  @override
  Future<List<Session>> getSessions() async => [
        Session.fromMetadataJson(storedSession.toMetadataJson()),
      ];

  @override
  Future<Session?> getSession(String id) async {
    if (failReads) {
      throw SessionStorageException(
        'Load session',
        StateError('Unavailable'),
      );
    }
    return _copy(storedSession);
  }

  @override
  Future<void> setActiveSessionId(String? id) async {}

  @override
  Future<void> deleteSession(String id) async {
    if (failDeletes) {
      throw SessionStorageException(
        'Delete session',
        StateError('Unavailable'),
      );
    }
  }

  @override
  Future<void> updateSession(String id, {String? name, String? notes}) async {
    if (failUpdates) {
      throw SessionStorageException(
        'Update session',
        StateError('Unavailable'),
      );
    }
    if (name != null) storedSession.name = name;
    if (notes != null) storedSession.notes = notes;
  }

  @override
  Future<void> saveSession(Session session) async {
    if (failSaves) {
      throw SessionStorageException(
        'Save session',
        StateError('Unavailable'),
      );
    }
    storedSession = _copy(session);
  }

  Session _copy(Session session) => Session.fromJson(session.toJson());
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/models/roll_result.dart';
import 'package:juice_roll/models/session.dart';
import 'package:juice_roll/services/session_service.dart';
import 'package:juice_roll/ui/home_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = SessionService();
  });

  group('history retention', () {
    test('new sessions keep unlimited history by default', () async {
      final session = Session.create('Unlimited')
        ..history = List.generate(
          250,
          (index) => {'sequence': index},
        );

      await service.saveSession(session);

      final stored = await service.getSession(session.id);
      expect(stored, isNotNull);
      expect(stored!.maxRollsPerSession, isNull);
      expect(stored.history, hasLength(250));
    });

    test('custom limits retain the newest rolls', () async {
      final session = Session.create('Limited')
        ..history = [
          {'sequence': 'newest'},
          {'sequence': 'newer'},
          {'sequence': 'new'},
          {'sequence': 'old'},
          {'sequence': 'oldest'},
        ];

      await service.saveSession(session);
      await service.updateSessionSettings(
        session.id,
        maxRollsPerSession: 3,
      );

      final stored = await service.getSession(session.id);
      expect(stored, isNotNull);
      expect(
        stored!.history.map((roll) => roll['sequence']),
        ['newest', 'newer', 'new'],
      );
    });
  });

  test('session metadata reports the stored roll count', () async {
    final session = Session.create('Counted')
      ..history = List.generate(
        7,
        (index) => {'sequence': index},
      );

    await service.saveSession(session);

    final sessions = await service.getSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.rollCount, 7);
  });

  test('concurrent roll writes are preserved in order', () async {
    final session = Session.create('Rapid rolls');
    await service.saveSession(session);

    await Future.wait(
      List.generate(
        25,
        (index) => service.addRoll(
          session.id,
          RollResult(
            type: RollType.fateCheck,
            description: 'Roll $index',
            diceResults: [index],
            total: index,
          ),
        ),
      ),
    );

    final stored = await service.getSession(session.id);
    expect(stored, isNotNull);
    expect(stored!.history, hasLength(25));
    expect(
      stored.history.map((roll) => roll['description']),
      List.generate(25, (index) => 'Roll ${24 - index}'),
    );
  });

  test('queued saves snapshot each requested session state', () async {
    final session = Session.create('Queued snapshots');
    final saves = <Future<void>>[];

    for (var index = 0; index < 25; index++) {
      session.history.insert(0, {'sequence': index});
      saves.add(service.saveSession(session));
    }
    await Future.wait(saves);

    final stored = await service.getSession(session.id);
    expect(stored, isNotNull);
    expect(stored!.history, hasLength(25));
    expect(
      stored.history.map((roll) => roll['sequence']),
      List.generate(25, (index) => 24 - index),
    );
  });

  test('corrupt session storage is reported instead of shown as empty',
      () async {
    SharedPreferences.setMockInitialValues({
      'juice_roll_sessions': '{not valid json',
    });
    service = SessionService();

    expect(
      service.getSessions,
      throwsA(isA<SessionStorageException>()),
    );
  });

  group('legacy v1 compatibility', () {
    test('loads and resaves the original schema without data loss', () async {
      final fixture = _legacySessionFixture();
      SharedPreferences.setMockInitialValues({
        'juice_roll_sessions': jsonEncode([_legacyMetadataFixture()]),
        'juice_roll_session_legacy-session': jsonEncode(fixture),
        'juice_roll_active_session': 'legacy-session',
      });
      service = SessionService();

      final loaded = await service.loadActiveSession();

      expect(loaded.id, fixture['id']);
      expect(loaded.name, fixture['name']);
      expect(loaded.notes, fixture['notes']);
      expect(loaded.wildernessEnvironmentRow, 2);
      expect(loaded.wildernessTypeRow, 4);
      expect(loaded.wildernessIsLost, isTrue);
      expect(loaded.dungeonIsEntering, isFalse);
      expect(loaded.dungeonIsTwoPassMode, isTrue);
      expect(loaded.twoPassHasFirstDoubles, isTrue);
      expect(loaded.maxRollsPerSession, isNull);
      expect(loaded.history, fixture['history']);

      // Fields introduced after the original schema use non-destructive defaults.
      expect(loaded.diceDialogMode, 0);
      expect(loaded.diceDialogIronswornRollType, 'action');
      expect(loaded.diceDialogOracleDieType, 100);

      await service.saveSession(loaded);
      final reloaded = await service.getSession(loaded.id);

      expect(reloaded, isNotNull);
      expect(reloaded!.name, fixture['name']);
      expect(reloaded.notes, fixture['notes']);
      expect(reloaded.wildernessEnvironmentRow, 2);
      expect(reloaded.wildernessTypeRow, 4);
      expect(reloaded.wildernessIsLost, isTrue);
      expect(reloaded.dungeonIsEntering, isFalse);
      expect(reloaded.dungeonIsTwoPassMode, isTrue);
      expect(reloaded.twoPassHasFirstDoubles, isTrue);
      expect(reloaded.maxRollsPerSession, isNull);
      expect(reloaded.history, fixture['history']);
      expect((await service.getSessions()).single.rollCount, 2);
    });

    test('preserves an existing custom cap and history within that cap',
        () async {
      final fixture = _legacySessionFixture()..['maxRollsPerSession'] = 5;
      SharedPreferences.setMockInitialValues({
        'juice_roll_sessions': jsonEncode([_legacyMetadataFixture()]),
        'juice_roll_session_legacy-session': jsonEncode(fixture),
        'juice_roll_active_session': 'legacy-session',
      });
      service = SessionService();

      final loaded = await service.loadActiveSession();
      await service.saveSession(loaded);
      final reloaded = await service.getSession(loaded.id);

      expect(reloaded, isNotNull);
      expect(reloaded!.maxRollsPerSession, 5);
      expect(reloaded.history, fixture['history']);
    });

    test('does not trim an over-limit legacy session on an unrelated save',
        () async {
      final fixture = _legacySessionFixture()..['maxRollsPerSession'] = 1;
      SharedPreferences.setMockInitialValues({
        'juice_roll_sessions': jsonEncode([_legacyMetadataFixture()]),
        'juice_roll_session_legacy-session': jsonEncode(fixture),
        'juice_roll_active_session': 'legacy-session',
      });
      service = SessionService();

      final loaded = await service.loadActiveSession();
      loaded.notes = 'Updated without changing retention';
      await service.saveSession(loaded);
      final reloaded = await service.getSession(loaded.id);

      expect(reloaded, isNotNull);
      expect(reloaded!.maxRollsPerSession, 1);
      expect(reloaded.history, fixture['history']);
      expect(reloaded.notes, 'Updated without changing retention');
    });

    test('repairs legacy metadata missing a roll count on the next save',
        () async {
      final metadata = _legacyMetadataFixture()..remove('rollCount');
      final fixture = _legacySessionFixture();
      SharedPreferences.setMockInitialValues({
        'juice_roll_sessions': jsonEncode([metadata]),
        'juice_roll_session_legacy-session': jsonEncode(fixture),
        'juice_roll_active_session': 'legacy-session',
      });
      service = SessionService();

      final loaded = await service.loadActiveSession();
      expect(loaded.history, hasLength(2));

      await service.saveSession(loaded);

      expect((await service.getSessions()).single.rollCount, 2);
      expect(
          (await service.getSession(loaded.id))!.history, fixture['history']);
    });

    test('initializes the app state from original v1 history', () async {
      final fixture = _legacySessionFixture();
      SharedPreferences.setMockInitialValues({
        'juice_roll_sessions': jsonEncode([_legacyMetadataFixture()]),
        'juice_roll_session_legacy-session': jsonEncode(fixture),
        'juice_roll_active_session': 'legacy-session',
      });
      service = SessionService();
      final notifier = HomeStateNotifier(sessionService: service);

      await notifier.init();

      expect(notifier.state.persistenceError, isNull);
      expect(notifier.state.currentSession?.id, 'legacy-session');
      expect(
        notifier.state.history.map((roll) => roll.description),
        ['Legacy newest roll', 'Legacy older roll'],
      );

      notifier.dispose();
    });

    test('imports original v1 individual and bulk clipboard exports', () async {
      String? clipboardText;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        switch (call.method) {
          case 'Clipboard.setData':
            clipboardText =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
            return null;
          case 'Clipboard.getData':
            return {'text': clipboardText};
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await Clipboard.setData(ClipboardData(
        text: jsonEncode({
          'version': '1.0',
          'exportedAt': '2025-02-03T04:05:06.000Z',
          'type': 'session',
          'session': _legacySessionFixture(),
        }),
      ));

      final imported = await Session.importFromClipboard();

      expect(imported, isNotNull);
      expect(imported!.name, 'Legacy Adventure (imported)');
      expect(imported.notes, 'Original v1 session');
      expect(imported.history, _legacySessionFixture()['history']);
      expect(imported.diceDialogMode, 0);
      expect(imported.diceDialogIronswornRollType, 'action');
      expect(imported.diceDialogOracleDieType, 100);

      await Clipboard.setData(ClipboardData(
        text: jsonEncode({
          'version': '1.0',
          'exportedAt': '2025-02-03T04:05:06.000Z',
          'type': 'all_sessions',
          'sessions': [_legacySessionFixture()],
        }),
      ));

      final importedBackup = await SessionExport.importAllFromClipboard();

      expect(importedBackup, isNotNull);
      expect(importedBackup, hasLength(1));
      expect(importedBackup!.single.name, 'Legacy Adventure (imported)');
      expect(
        importedBackup.single.history,
        _legacySessionFixture()['history'],
      );
    });
  });
}

Map<String, dynamic> _legacyMetadataFixture() => {
      'id': 'legacy-session',
      'name': 'Legacy Adventure',
      'createdAt': '2025-01-02T03:04:05.000Z',
      'lastAccessedAt': '2025-02-03T04:05:06.000Z',
      'notes': 'Original v1 session',
      'rollCount': 2,
    };

Map<String, dynamic> _legacySessionFixture() => {
      'id': 'legacy-session',
      'name': 'Legacy Adventure',
      'createdAt': '2025-01-02T03:04:05.000Z',
      'lastAccessedAt': '2025-02-03T04:05:06.000Z',
      'notes': 'Original v1 session',
      'wildernessEnvironmentRow': 2,
      'wildernessTypeRow': 4,
      'wildernessIsLost': true,
      'dungeonIsEntering': false,
      'dungeonIsTwoPassMode': true,
      'twoPassHasFirstDoubles': true,
      'maxRollsPerSession': null,
      'history': [
        {
          'className': 'RollResult',
          'type': 'fateCheck',
          'description': 'Legacy newest roll',
          'diceResults': [1, 0],
          'total': 1,
          'interpretation': 'Yes',
          'timestamp': '2025-02-03T04:05:06.000Z',
          'metadata': {'source': 'legacy'},
          'imagePath': null,
        },
        {
          'className': 'RollResult',
          'type': 'discoverMeaning',
          'description': 'Legacy older roll',
          'diceResults': [4, 12],
          'total': 16,
          'interpretation': 'Hidden Community',
          'timestamp': '2025-02-01T02:03:04.000Z',
          'metadata': null,
          'imagePath': null,
        },
      ],
    };

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/roll_result.dart';

class SessionStorageException implements Exception {
  final String operation;
  final Object cause;

  const SessionStorageException(this.operation, this.cause);

  @override
  String toString() => 'SessionStorageException: $operation failed ($cause)';
}

/// Service for managing session persistence using local storage.
/// All data is stored locally on the device - no servers involved.
class SessionService {
  static const String _sessionsKey = 'juice_roll_sessions';
  static const String _sessionPrefix = 'juice_roll_session_';
  static const String _activeSessionKey = 'juice_roll_active_session';

  static const int maxSessions = 50;

  /// Default limit when history limiting is enabled (null = unlimited)
  static const int defaultMaxRollsPerSession = 200;

  SharedPreferences? _prefs;
  Future<void> _writeQueue = Future<void>.value();

  /// Initialize the service (must be called before use)
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('SessionService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  Future<void> _setString(String key, String value, String operation) async {
    final succeeded = await _preferences.setString(key, value);
    if (!succeeded) {
      throw SessionStorageException(
        operation,
        StateError('Local storage rejected the write'),
      );
    }
  }

  Future<void> _remove(String key, String operation) async {
    final succeeded = await _preferences.remove(key);
    if (!succeeded) {
      throw SessionStorageException(
        operation,
        StateError('Local storage rejected the removal'),
      );
    }
  }

  Future<T> _enqueueWrite<T>(Future<T> Function() operation) {
    final completer = Completer<T>();

    Future<void> run() async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }

    _writeQueue = _writeQueue.then((_) => run());
    return completer.future;
  }

  /// Get list of all session metadata (without full history)
  Future<List<Session>> getSessions() async {
    await init();
    await _writeQueue;
    return _getSessionsNow();
  }

  Future<List<Session>> _getSessionsNow() async {
    final json = _preferences.getString(_sessionsKey);
    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) =>
              Session.fromMetadataJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));
    } catch (error) {
      throw SessionStorageException('Load session index', error);
    }
  }

  /// Get full session with history
  Future<Session?> getSession(String id) async {
    await init();
    await _writeQueue;
    return _getSessionNow(id);
  }

  Future<Session?> _getSessionNow(String id) async {
    final json = _preferences.getString('$_sessionPrefix$id');
    if (json == null) return null;

    try {
      return Session.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (error) {
      throw SessionStorageException('Load session $id', error);
    }
  }

  /// Get the currently active session ID
  Future<String?> getActiveSessionId() async {
    await init();
    return _preferences.getString(_activeSessionKey);
  }

  /// Set the active session ID
  Future<void> setActiveSessionId(String? id) async {
    await init();
    if (id == null) {
      await _remove(_activeSessionKey, 'Clear active session');
    } else {
      await _setString(_activeSessionKey, id, 'Set active session');
    }
  }

  /// Load the active session (or create default if none exists)
  Future<Session> loadActiveSession() async {
    await init();

    final activeId = await getActiveSessionId();
    if (activeId != null) {
      final session = await getSession(activeId);
      if (session != null) {
        return session;
      }
    }

    // No active session - check if any sessions exist
    final sessions = await getSessions();
    if (sessions.isNotEmpty) {
      // Load the most recent session
      final session = await getSession(sessions.first.id);
      if (session != null) {
        await setActiveSessionId(session.id);
        return session;
      }
    }

    // Create default session
    final defaultSession = Session.create('Default Session');
    await saveSession(defaultSession);
    await setActiveSessionId(defaultSession.id);
    return defaultSession;
  }

  /// Save a session (creates or updates)
  Future<void> saveSession(Session session) {
    session.lastAccessedAt = DateTime.now();
    final snapshot = Session.fromJson(
      jsonDecode(jsonEncode(session.toJson())) as Map<String, dynamic>,
    );

    return _enqueueWrite(() async {
      await init();
      await _saveSessionNow(snapshot);
    });
  }

  Future<void> _saveSessionNow(
    Session session, {
    bool enforceHistoryLimit = false,
  }) async {
    session.lastAccessedAt = DateTime.now();
    if (enforceHistoryLimit) {
      _applyHistoryLimit(session);
    }

    // Save full session
    await _setString(
      '$_sessionPrefix${session.id}',
      jsonEncode(session.toJson()),
      'Save session ${session.id}',
    );

    // Update session list
    await _updateSessionListNow(session);
  }

  void _applyHistoryLimit(Session session) {
    final maxRolls = session.maxRollsPerSession;
    if (maxRolls != null && session.history.length > maxRolls) {
      session.history = session.history.sublist(0, maxRolls);
    }
  }

  /// Add a roll to the current session
  Future<void> addRoll(String sessionId, RollResult roll) {
    return _enqueueWrite(() async {
      await init();
      final session = await _getSessionNow(sessionId);
      if (session == null) return;

      session.history.insert(0, roll.toJson());
      await _saveSessionNow(session, enforceHistoryLimit: true);
    });
  }

  /// Update session metadata in the sessions list
  Future<void> _updateSessionListNow(Session session) async {
    final sessions = await _getSessionsNow();

    // Remove existing entry if present
    sessions.removeWhere((s) => s.id == session.id);

    // Add updated entry at the beginning
    sessions.insert(0, session);

    // Enforce max sessions limit
    while (sessions.length > maxSessions) {
      final removed = sessions.removeLast();
      await _remove(
        '$_sessionPrefix${removed.id}',
        'Remove session ${removed.id}',
      );
    }

    // Save updated list
    await _setString(
      _sessionsKey,
      jsonEncode(sessions.map((s) => s.toMetadataJson()).toList()),
      'Save session index',
    );
  }

  /// Create a new session
  Future<Session> createSession(String name, {String? notes}) async {
    final session = Session.create(name, notes: notes);
    await saveSession(session);
    await setActiveSessionId(session.id);
    return session;
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    return _enqueueWrite(() async {
      await init();

      // Remove session data
      await _remove('$_sessionPrefix$id', 'Delete session $id');

      // Update session list
      final sessions = await _getSessionsNow();
      sessions.removeWhere((s) => s.id == id);
      await _setString(
        _sessionsKey,
        jsonEncode(sessions.map((s) => s.toMetadataJson()).toList()),
        'Save session index',
      );

      // If this was the active session, clear it
      final activeId = await getActiveSessionId();
      if (activeId == id) {
        if (sessions.isNotEmpty) {
          await setActiveSessionId(sessions.first.id);
        } else {
          await setActiveSessionId(null);
        }
      }
    });
  }

  /// Clear history for a session
  Future<void> clearSessionHistory(String sessionId) {
    return _enqueueWrite(() async {
      await init();
      final session = await _getSessionNow(sessionId);
      if (session == null) return;

      session.history.clear();
      await _saveSessionNow(session, enforceHistoryLimit: true);
    });
  }

  /// Update session name and notes
  Future<void> updateSession(String id, {String? name, String? notes}) {
    return _enqueueWrite(() async {
      await init();
      final session = await _getSessionNow(id);
      if (session == null) return;

      if (name != null) session.name = name;
      if (notes != null) session.notes = notes;

      await _saveSessionNow(session);
    });
  }

  /// Update session settings
  Future<void> updateSessionSettings(
    String id, {
    int? maxRollsPerSession,
    bool clearMaxRollsPerSession = false,
  }) {
    return _enqueueWrite(() async {
      await init();
      final session = await _getSessionNow(id);
      if (session == null) return;

      if (clearMaxRollsPerSession) {
        session.maxRollsPerSession = null;
      } else if (maxRollsPerSession != null) {
        session.maxRollsPerSession = maxRollsPerSession;
      }

      await _saveSessionNow(session, enforceHistoryLimit: true);
    });
  }

  /// Update wilderness state for a session
  Future<void> updateWildernessState(
    String sessionId, {
    int? environmentRow,
    int? typeRow,
    bool? isLost,
  }) {
    return _enqueueWrite(() async {
      await init();
      final session = await _getSessionNow(sessionId);
      if (session == null) return;

      if (environmentRow != null) {
        session.wildernessEnvironmentRow = environmentRow;
      }
      if (typeRow != null) session.wildernessTypeRow = typeRow;
      if (isLost != null) session.wildernessIsLost = isLost;

      await _saveSessionNow(session);
    });
  }

  /// Update dungeon state for a session
  Future<void> updateDungeonState(
    String sessionId, {
    bool? isEntering,
    bool? twoPassHasFirstDoubles,
  }) {
    return _enqueueWrite(() async {
      await init();
      final session = await _getSessionNow(sessionId);
      if (session == null) return;

      if (isEntering != null) session.dungeonIsEntering = isEntering;
      if (twoPassHasFirstDoubles != null) {
        session.twoPassHasFirstDoubles = twoPassHasFirstDoubles;
      }

      await _saveSessionNow(session);
    });
  }

  /// Import a session from clipboard
  Future<Session?> importSession() async {
    final session = await Session.importFromClipboard();
    if (session == null) return null;

    await saveSession(session);
    return session;
  }

  /// Import all sessions from clipboard
  Future<List<Session>?> importAllSessions() async {
    final sessions = await SessionExport.importAllFromClipboard();
    if (sessions == null) return null;

    for (final session in sessions) {
      await saveSession(session);
    }
    return sessions;
  }

  /// Export all sessions to clipboard
  Future<void> exportAllSessions() async {
    final sessionMetas = await getSessions();
    final fullSessions = <Session>[];

    for (final meta in sessionMetas) {
      final full = await getSession(meta.id);
      if (full != null) {
        fullSessions.add(full);
      }
    }

    await SessionExport.exportAllToClipboard(fullSessions);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/roll_result.dart';

/// Service for managing session persistence using local storage.
/// All data is stored locally on the device - no servers involved.
class SessionService {
  static const String _sessionsKey = 'juice_roll_sessions';
  static const String _sessionPrefix = 'juice_roll_session_';
  static const String _activeSessionKey = 'juice_roll_active_session';
  
  static const int maxSessions = 50;
  static const int maxRollsPerSession = 200;

  SharedPreferences? _prefs;

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

  /// Get list of all session metadata (without full history)
  Future<List<Session>> getSessions() async {
    await init();
    final json = _preferences.getString(_sessionsKey);
    if (json == null) return [];
    
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => Session.fromMetadataJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));
    } catch (e) {
      return [];
    }
  }

  /// Get full session with history
  Future<Session?> getSession(String id) async {
    await init();
    final json = _preferences.getString('$_sessionPrefix$id');
    if (json == null) return null;
    
    try {
      return Session.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return null;
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
      await _preferences.remove(_activeSessionKey);
    } else {
      await _preferences.setString(_activeSessionKey, id);
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
  Future<void> saveSession(Session session) async {
    await init();
    
    // Update last accessed time
    session.lastAccessedAt = DateTime.now();
    
    // Trim history if too long
    if (session.history.length > maxRollsPerSession) {
      session.history = session.history.sublist(
        session.history.length - maxRollsPerSession
      );
    }
    
    // Save full session
    await _preferences.setString(
      '$_sessionPrefix${session.id}',
      jsonEncode(session.toJson()),
    );
    
    // Update session list
    await _updateSessionList(session);
  }

  /// Add a roll to the current session
  Future<void> addRoll(String sessionId, RollResult roll) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    
    session.history.insert(0, roll.toJson());
    await saveSession(session);
  }

  /// Update session metadata in the sessions list
  Future<void> _updateSessionList(Session session) async {
    final sessions = await getSessions();
    
    // Remove existing entry if present
    sessions.removeWhere((s) => s.id == session.id);
    
    // Add updated entry at the beginning
    sessions.insert(0, session);
    
    // Enforce max sessions limit
    while (sessions.length > maxSessions) {
      final removed = sessions.removeLast();
      await _preferences.remove('$_sessionPrefix${removed.id}');
    }
    
    // Save updated list
    await _preferences.setString(
      _sessionsKey,
      jsonEncode(sessions.map((s) => s.toMetadataJson()).toList()),
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
    await init();
    
    // Remove session data
    await _preferences.remove('$_sessionPrefix$id');
    
    // Update session list
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _preferences.setString(
      _sessionsKey,
      jsonEncode(sessions.map((s) => s.toMetadataJson()).toList()),
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
  }

  /// Clear history for a session
  Future<void> clearSessionHistory(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    
    session.history.clear();
    await saveSession(session);
  }

  /// Update session name and notes
  Future<void> updateSession(String id, {String? name, String? notes}) async {
    final session = await getSession(id);
    if (session == null) return;
    
    if (name != null) session.name = name;
    if (notes != null) session.notes = notes;
    
    await saveSession(session);
  }

  /// Update wilderness state for a session
  Future<void> updateWildernessState(
    String sessionId, {
    int? environmentRow,
    int? typeRow,
    bool? isLost,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    
    if (environmentRow != null) session.wildernessEnvironmentRow = environmentRow;
    if (typeRow != null) session.wildernessTypeRow = typeRow;
    if (isLost != null) session.wildernessIsLost = isLost;
    
    await saveSession(session);
  }

  /// Update dungeon state for a session
  Future<void> updateDungeonState(
    String sessionId, {
    bool? isEntering,
    bool? twoPassHasFirstDoubles,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) return;
    
    if (isEntering != null) session.dungeonIsEntering = isEntering;
    if (twoPassHasFirstDoubles != null) session.twoPassHasFirstDoubles = twoPassHasFirstDoubles;
    
    await saveSession(session);
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

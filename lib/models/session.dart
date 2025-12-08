import 'dart:convert';
import 'package:flutter/services.dart';

/// Represents a play session with roll history and state.
class Session {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime lastAccessedAt;
  String? notes;
  
  // Stateful presets
  int? wildernessEnvironmentRow;
  int? wildernessTypeRow;
  bool wildernessIsLost;
  bool dungeonIsEntering;
  bool dungeonIsTwoPassMode;
  bool twoPassHasFirstDoubles;
  
  // Dice dialog state
  int diceDialogMode; // 0 = Standard, 1 = Fate, 2 = Ironsworn
  String diceDialogIronswornRollType; // 'action', 'progress', 'oracle', 'yesno', 'cursed'
  int diceDialogOracleDieType; // 6, 20, or 100
  
  // Session settings
  int? maxRollsPerSession; // null = unlimited history
  
  // Roll history
  List<Map<String, dynamic>> history;

  Session({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastAccessedAt,
    this.notes,
    this.wildernessEnvironmentRow,
    this.wildernessTypeRow,
    this.wildernessIsLost = false,
    this.dungeonIsEntering = true,
    this.dungeonIsTwoPassMode = false,
    this.twoPassHasFirstDoubles = false,
    this.diceDialogMode = 0,
    this.diceDialogIronswornRollType = 'action',
    this.diceDialogOracleDieType = 100,
    this.maxRollsPerSession,
    List<Map<String, dynamic>>? history,
  }) : history = history ?? [];

  /// Create a new session with generated ID
  factory Session.create(String name, {String? notes}) {
    final now = DateTime.now();
    return Session(
      id: '${now.millisecondsSinceEpoch}_${name.hashCode.abs()}',
      name: name,
      createdAt: now,
      lastAccessedAt: now,
      notes: notes,
    );
  }

  int get rollCount => history.length;

  /// Create a copy with updated fields
  Session copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    String? notes,
    int? wildernessEnvironmentRow,
    int? wildernessTypeRow,
    bool? wildernessIsLost,
    bool? dungeonIsEntering,
    bool? dungeonIsTwoPassMode,
    bool? twoPassHasFirstDoubles,
    int? diceDialogMode,
    String? diceDialogIronswornRollType,
    int? diceDialogOracleDieType,
    int? maxRollsPerSession,
    bool clearMaxRollsPerSession = false,
    List<Map<String, dynamic>>? history,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      notes: notes ?? this.notes,
      wildernessEnvironmentRow: wildernessEnvironmentRow ?? this.wildernessEnvironmentRow,
      wildernessTypeRow: wildernessTypeRow ?? this.wildernessTypeRow,
      wildernessIsLost: wildernessIsLost ?? this.wildernessIsLost,
      dungeonIsEntering: dungeonIsEntering ?? this.dungeonIsEntering,
      dungeonIsTwoPassMode: dungeonIsTwoPassMode ?? this.dungeonIsTwoPassMode,
      twoPassHasFirstDoubles: twoPassHasFirstDoubles ?? this.twoPassHasFirstDoubles,
      diceDialogMode: diceDialogMode ?? this.diceDialogMode,
      diceDialogIronswornRollType: diceDialogIronswornRollType ?? this.diceDialogIronswornRollType,
      diceDialogOracleDieType: diceDialogOracleDieType ?? this.diceDialogOracleDieType,
      maxRollsPerSession: clearMaxRollsPerSession ? null : (maxRollsPerSession ?? this.maxRollsPerSession),
      history: history ?? List<Map<String, dynamic>>.from(this.history),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'lastAccessedAt': lastAccessedAt.toIso8601String(),
    'notes': notes,
    'wildernessEnvironmentRow': wildernessEnvironmentRow,
    'wildernessTypeRow': wildernessTypeRow,
    'wildernessIsLost': wildernessIsLost,
    'dungeonIsEntering': dungeonIsEntering,
    'dungeonIsTwoPassMode': dungeonIsTwoPassMode,
    'twoPassHasFirstDoubles': twoPassHasFirstDoubles,
    'diceDialogMode': diceDialogMode,
    'diceDialogIronswornRollType': diceDialogIronswornRollType,
    'diceDialogOracleDieType': diceDialogOracleDieType,
    'maxRollsPerSession': maxRollsPerSession,
    'history': history,
  };

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      notes: json['notes'] as String?,
      wildernessEnvironmentRow: json['wildernessEnvironmentRow'] as int?,
      wildernessTypeRow: json['wildernessTypeRow'] as int?,
      wildernessIsLost: json['wildernessIsLost'] as bool? ?? false,
      dungeonIsEntering: json['dungeonIsEntering'] as bool? ?? true,
      dungeonIsTwoPassMode: json['dungeonIsTwoPassMode'] as bool? ?? false,
      twoPassHasFirstDoubles: json['twoPassHasFirstDoubles'] as bool? ?? false,
      diceDialogMode: json['diceDialogMode'] as int? ?? 0,
      diceDialogIronswornRollType: json['diceDialogIronswornRollType'] as String? ?? 'action',
      diceDialogOracleDieType: json['diceDialogOracleDieType'] as int? ?? 100,
      maxRollsPerSession: json['maxRollsPerSession'] as int?,
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ?? [],
    );
  }

  /// Metadata-only JSON for session list (without full history)
  Map<String, dynamic> toMetadataJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'lastAccessedAt': lastAccessedAt.toIso8601String(),
    'notes': notes,
    'rollCount': rollCount,
  };

  factory Session.fromMetadataJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      notes: json['notes'] as String?,
      // These will be loaded when full session is loaded
    );
  }

  /// Export session to clipboard as JSON
  Future<void> copyToClipboard() async {
    final exportData = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'session',
      'session': toJson(),
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(exportData)));
  }

  /// Import session from clipboard JSON
  static Future<Session?> importFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == null || data!.text!.isEmpty) return null;
      
      final json = jsonDecode(data.text!) as Map<String, dynamic>;
      
      // Validate version
      final version = json['version'] as String?;
      if (version != '1.0') return null;
      
      final type = json['type'] as String?;
      if (type != 'session') return null;
      
      final sessionJson = json['session'] as Map<String, dynamic>?;
      if (sessionJson == null) return null;
      
      // Generate new ID to avoid conflicts
      final imported = Session.fromJson(sessionJson);
      final now = DateTime.now();
      return Session(
        id: '${now.millisecondsSinceEpoch}_imported_${imported.name.hashCode.abs()}',
        name: '${imported.name} (imported)',
        createdAt: now,
        lastAccessedAt: now,
        notes: imported.notes,
        wildernessEnvironmentRow: imported.wildernessEnvironmentRow,
        wildernessTypeRow: imported.wildernessTypeRow,
        wildernessIsLost: imported.wildernessIsLost,
        dungeonIsEntering: imported.dungeonIsEntering,
        dungeonIsTwoPassMode: imported.dungeonIsTwoPassMode,
        twoPassHasFirstDoubles: imported.twoPassHasFirstDoubles,
        diceDialogMode: imported.diceDialogMode,
        diceDialogIronswornRollType: imported.diceDialogIronswornRollType,
        diceDialogOracleDieType: imported.diceDialogOracleDieType,
        maxRollsPerSession: imported.maxRollsPerSession,
        history: imported.history,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => 'Session($name, $rollCount rolls)';
}

/// Export wrapper for all sessions
class SessionExport {
  static Future<void> exportAllToClipboard(List<Session> sessions) async {
    final exportData = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'type': 'all_sessions',
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
    await Clipboard.setData(ClipboardData(text: jsonEncode(exportData)));
  }

  static Future<List<Session>?> importAllFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == null || data!.text!.isEmpty) return null;
      
      final json = jsonDecode(data.text!) as Map<String, dynamic>;
      
      final version = json['version'] as String?;
      if (version != '1.0') return null;
      
      final type = json['type'] as String?;
      if (type != 'all_sessions') return null;
      
      final sessionsJson = json['sessions'] as List<dynamic>?;
      if (sessionsJson == null) return null;
      
      final now = DateTime.now();
      return sessionsJson.asMap().entries.map((entry) {
        final sessionJson = Map<String, dynamic>.from(entry.value as Map);
        final imported = Session.fromJson(sessionJson);
        return Session(
          id: '${now.millisecondsSinceEpoch}_imported_${entry.key}_${imported.name.hashCode.abs()}',
          name: '${imported.name} (imported)',
          createdAt: now,
          lastAccessedAt: now,
          notes: imported.notes,
          wildernessEnvironmentRow: imported.wildernessEnvironmentRow,
          wildernessTypeRow: imported.wildernessTypeRow,
          wildernessIsLost: imported.wildernessIsLost,
          dungeonIsEntering: imported.dungeonIsEntering,
          dungeonIsTwoPassMode: imported.dungeonIsTwoPassMode,
          twoPassHasFirstDoubles: imported.twoPassHasFirstDoubles,
          diceDialogMode: imported.diceDialogMode,
          diceDialogIronswornRollType: imported.diceDialogIronswornRollType,
          diceDialogOracleDieType: imported.diceDialogOracleDieType,
          maxRollsPerSession: imported.maxRollsPerSession,
          history: imported.history,
        );
      }).toList();
    } catch (e) {
      return null;
    }
  }
}

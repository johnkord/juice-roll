# Session & Roll History Persistence Proposal

## Overview

This document proposes solutions for persisting roll history across browser/app sessions in the JuiceRoll application. The goal is to allow users to:

1. **Maintain roll history** within a single "play session" (adventure/scenario)
2. **Resume sessions** after closing the app/browser
3. **Review past sessions** and their roll logs
4. **Manage multiple sessions** (different characters, campaigns, or scenarios)

---

## Current State

### How History Works Now

The current implementation stores roll history **in-memory only**:

```dart
// lib/ui/home_screen.dart
class _HomeScreenState extends State<HomeScreen> {
  final List<RollResult> _history = [];
  // ... history is lost on app close/refresh
}
```

**Current limitations:**
- History is lost when the browser tab closes or app terminates
- No concept of "sessions" - just a single rolling list
- Maximum 100 results kept in memory
- Wilderness state (`_wilderness.state`) is also ephemeral

### Tech Stack Context

- **Flutter Web/iOS** - Cross-platform with web as primary deployment
- **No external dependencies** for storage currently
- `shared_preferences` mentioned in design doc but not yet added

---

## Proposed Solutions

### Option A: Local Storage with `shared_preferences` (Recommended for MVP)

**Description:** Use Flutter's `shared_preferences` package for simple key-value persistence. Best for quick implementation with reasonable functionality.

**Implementation:**

```yaml
# pubspec.yaml additions
dependencies:
  shared_preferences: ^2.2.2
```

**Architecture:**

```
lib/
├── services/
│   └── session_service.dart      # Session CRUD operations
├── models/
│   ├── roll_result.dart          # Add toJson/fromJson
│   └── session.dart              # New session model
```

**Session Model:**

```dart
class Session {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final List<RollResult> history;
  final WildernessState? wildernessState;
  final Map<String, dynamic> metadata; // character name, campaign, notes
}
```

**Pros:**
- ✅ Simple implementation (~2-3 hours)
- ✅ Works on Web, iOS, Android, Desktop
- ✅ No additional backend needed
- ✅ Familiar Flutter pattern
- ✅ Already mentioned in design doc

**Cons:**
- ❌ Limited storage (~5-10MB depending on platform)
- ❌ All data as JSON strings (slower for large histories)
- ❌ No query capability
- ❌ Web localStorage can be cleared by user

**Best for:** MVP, users with moderate session counts (<20 sessions, <500 rolls each)

---

### Option B: IndexedDB via `idb_shim` + Hive (Recommended for Full Feature)

**Description:** Use IndexedDB (web) and Hive (native) for structured, queryable local storage with better performance for larger datasets.

**Implementation:**

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  idb_shim: ^2.4.0  # For web IndexedDB support
```

**Architecture:**

```dart
// Abstract storage interface for platform-specific implementations
abstract class SessionStorage {
  Future<List<Session>> getSessions();
  Future<Session?> getSession(String id);
  Future<void> saveSession(Session session);
  Future<void> deleteSession(String id);
  Future<void> appendRoll(String sessionId, RollResult roll);
}

// Platform-specific implementations
class HiveSessionStorage implements SessionStorage { ... }  // Native
class IdbSessionStorage implements SessionStorage { ... }   // Web
```

**Pros:**
- ✅ Better performance for large datasets
- ✅ Structured data with indexes
- ✅ Append-only operations (efficient for roll logging)
- ✅ Can query/filter by date, type, etc.
- ✅ Larger storage limits (50MB+ for IndexedDB)

**Cons:**
- ❌ More complex setup
- ❌ Requires code generation for Hive adapters
- ❌ Two implementations to maintain (web vs native)

**Best for:** Users with many sessions, long campaigns, or desire to search/filter history

---

### Option C: SQLite via `sqflite` + `sqflite_common_ffi_web`

**Description:** Full relational database for maximum flexibility and query power.

**Implementation:**

```yaml
dependencies:
  sqflite: ^2.3.0
  sqflite_common_ffi_web: ^0.4.0  # Web support
  path: ^1.8.3
```

**Schema:**

```sql
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  last_accessed_at INTEGER NOT NULL,
  metadata TEXT -- JSON blob
);

CREATE TABLE rolls (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  dice_results TEXT NOT NULL, -- JSON array
  total INTEGER NOT NULL,
  interpretation TEXT,
  metadata TEXT, -- JSON blob for type-specific data
  timestamp INTEGER NOT NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id)
);

CREATE INDEX idx_rolls_session ON rolls(session_id);
CREATE INDEX idx_rolls_timestamp ON rolls(timestamp);
CREATE INDEX idx_rolls_type ON rolls(type);
```

**Pros:**
- ✅ Full SQL query capability
- ✅ Best performance for large datasets
- ✅ Can export/import sessions easily
- ✅ Future-proof for advanced features (statistics, filtering)

**Cons:**
- ❌ Most complex implementation
- ❌ Web SQLite support still maturing
- ❌ Larger bundle size
- ❌ Overkill for most users

**Best for:** Power users, future analytics features, campaign management tools

---

### ~~Option D: Cloud Sync~~ (Not Recommended)

**Intentionally excluded.** All data stays on the user's device - no servers, no accounts, no tracking. Users own their data completely.

**For backup/sharing:** Users can export sessions to clipboard as JSON and paste into their own storage (notes app, text file, email to self, etc.).

---

## Design Principles

1. **100% Local Storage** - All data stored on device only. No network calls, no external servers.
2. **User Data Ownership** - Users can export everything via clipboard at any time.
3. **Privacy First** - No analytics, no telemetry, no accounts required.
4. **Offline Forever** - App works identically with or without internet.

---

## Recommendation

### Phase 1: MVP with `shared_preferences` (Option A)

Start with the simplest viable solution:

1. Add `shared_preferences` dependency
2. Create `Session` model with JSON serialization
3. Create `SessionService` for CRUD operations
4. Add session selector UI in app bar
5. Auto-save on each roll

**Estimated effort:** 4-6 hours

### Phase 2: Enhanced Storage (Option B)

If users report performance issues or request features:

1. Migrate to Hive/IndexedDB
2. Add session search/filter
3. Add roll statistics

**Estimated effort:** 8-12 hours

---

## Session Management UX

### Session Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                     APP LAUNCH                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────────┐
              │  Load last active session   │
              │  (or show session picker)   │
              └─────────────────────────────┘
                            │
           ┌────────────────┼────────────────┐
           ▼                ▼                ▼
    ┌───────────┐    ┌───────────┐    ┌───────────┐
    │  Resume   │    │   New     │    │  Select   │
    │  Session  │    │  Session  │    │  Other    │
    └───────────┘    └───────────┘    └───────────┘
           │                │                │
           └────────────────┼────────────────┘
                            ▼
              ┌─────────────────────────────┐
              │     Active Session          │
              │  - Auto-save on each roll   │
              │  - Update last_accessed_at  │
              └─────────────────────────────┘
```

### UI Mockups

#### Session Selector in App Bar

```
┌─────────────────────────────────────────┐
│ JuiceRoll        [📋 Dungeon Crawl ▼]  🗑 │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ + New Session                       │ │
│ ├─────────────────────────────────────┤ │
│ │ 📋 Dungeon Crawl          (active)  │ │
│ │    12 rolls • 2 hours ago           │ │
│ ├─────────────────────────────────────┤ │
│ │ 📋 Solo Hexcrawl                    │ │
│ │    47 rolls • 3 days ago            │ │
│ ├─────────────────────────────────────┤ │
│ │ 📋 Test Session                     │ │
│ │    5 rolls • 1 week ago             │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### New Session Dialog

```
┌─────────────────────────────────────────┐
│           Create New Session            │
├─────────────────────────────────────────┤
│                                         │
│ Session Name:                           │
│ ┌─────────────────────────────────────┐ │
│ │ Forest of Doom                      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Notes (optional):                       │
│ ┌─────────────────────────────────────┐ │
│ │ Playing Ironsworn, ranger class     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [ ] Copy wilderness state from current │
│                                         │
│         [Cancel]        [Create]        │
└─────────────────────────────────────────┘
```

#### Session Info/Edit

```
┌─────────────────────────────────────────┐
│           Session Details               │
├─────────────────────────────────────────┤
│                                         │
│ Name: Dungeon Crawl                     │
│ Created: Dec 1, 2025 at 3:42 PM         │
│ Last Played: Dec 4, 2025 at 10:15 AM    │
│ Total Rolls: 47                         │
│                                         │
│ Notes:                                  │
│ ┌─────────────────────────────────────┐ │
│ │ Level 3 fighter exploring the      │ │
│ │ Caverns of Chaos                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Wilderness State: Tropical Forest       │
│ Lost Status: Oriented                   │
│                                         │
│ [Export JSON]  [Delete]       [Done]    │
└─────────────────────────────────────────┘
```

---

## Data Model Details

### RollResult Serialization

Add JSON serialization to existing `RollResult` class:

```dart
class RollResult {
  // ... existing fields ...
  
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'description': description,
    'diceResults': diceResults,
    'total': total,
    'interpretation': interpretation,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
    'imagePath': imagePath,
  };
  
  factory RollResult.fromJson(Map<String, dynamic> json) {
    return RollResult(
      type: RollType.values.byName(json['type']),
      description: json['description'],
      diceResults: List<int>.from(json['diceResults']),
      total: json['total'],
      interpretation: json['interpretation'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
      imagePath: json['imagePath'],
    );
  }
}
```

**Challenge:** Subclass serialization (e.g., `FateCheckResult`, `QuestResult`)

**Solution:** Use a factory with type discriminator:

```dart
static RollResult fromJson(Map<String, dynamic> json) {
  final type = RollType.values.byName(json['type']);
  switch (type) {
    case RollType.fateCheck:
      return FateCheckResult.fromJson(json);
    case RollType.quest:
      return QuestResult.fromJson(json);
    // ... etc
    default:
      return RollResult._fromJson(json);
  }
}
```

### Session Model

```dart
class Session {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime lastAccessedAt;
  String? notes;
  
  // Stateful presets
  int? wildernessEnvironmentRow;
  int? wildernessTypeRow;
  bool? wildernessIsLost;
  bool? dungeonIsEntering;
  bool? twoPassHasFirstDoubles;
  
  // History (loaded lazily for list view)
  List<RollResult>? _history;
  int rollCount; // Cached count for display
  
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
    'twoPassHasFirstDoubles': twoPassHasFirstDoubles,
    'rollCount': rollCount,
  };
}
```

---

## Storage Keys / Structure

### shared_preferences Keys

```
juice_roll_sessions        → JSON array of session metadata (without history)
juice_roll_session_{id}    → JSON object with full session including history
juice_roll_active_session  → String session ID
juice_roll_settings        → JSON object with app settings
```

### Example Data

```json
// juice_roll_sessions
[
  {"id": "abc123", "name": "Dungeon Crawl", "createdAt": "2025-12-01T15:42:00Z", "rollCount": 47},
  {"id": "def456", "name": "Hexcrawl", "createdAt": "2025-11-28T10:00:00Z", "rollCount": 12}
]

// juice_roll_session_abc123
{
  "id": "abc123",
  "name": "Dungeon Crawl",
  "createdAt": "2025-12-01T15:42:00Z",
  "lastAccessedAt": "2025-12-04T10:15:00Z",
  "notes": "Level 3 fighter in Caverns of Chaos",
  "wildernessEnvironmentRow": 6,
  "wildernessTypeRow": 7,
  "wildernessIsLost": false,
  "history": [
    {"type": "fateCheck", "description": "Fate Check", ...},
    {"type": "quest", "description": "Quest", ...}
  ]
}
```

---

## Storage Limits & Considerations

### Platform Limits

| Platform | Storage Mechanism | Typical Limit | Notes |
|----------|------------------|---------------|-------|
| **Web** | localStorage | 5-10MB | Can be cleared by user |
| **iOS** | NSUserDefaults | ~4MB recommended | Larger via documents |
| **Android** | SharedPreferences | ~4MB recommended | Larger via files |

### Estimated Data Sizes

| Item | Approximate Size |
|------|-----------------|
| Simple roll | 200-400 bytes |
| Complex roll (Quest, NPC) | 500-1000 bytes |
| 100 rolls | ~50-100 KB |
| 1000 rolls | ~500 KB - 1 MB |

**Recommendation:** Limit to 50 sessions with 200 rolls each = ~10MB max

---

## Migration Path

### From Current (In-Memory) to Sessions

1. **First launch after update:**
   - Check for existing in-memory history (won't exist on fresh start)
   - Create "Default Session" if no sessions exist
   - Show migration notice: "Your rolls are now saved!"

2. **Subsequent launches:**
   - Load last active session
   - Resume where user left off

---

## Export/Import via Clipboard

Users can backup and transfer their data using the system clipboard - no servers involved.

### Export to Clipboard

**Single Session:**
```
Session Details → [Copy to Clipboard] → Paste anywhere (notes, file, email)
```

**All Sessions:**
```
Settings → Export All → [Copy to Clipboard] → Paste to backup location
```

### Import from Clipboard

```
Settings → Import → [Paste from Clipboard] → Validate → Confirm Import
```

### Clipboard Data Format

```json
{
  "version": "1.0",
  "exportedAt": "2025-12-04T12:00:00Z",
  "type": "session",  // or "all_sessions"
  "session": { ... }  // or "sessions": [...]
}
```

### UI for Export/Import

#### Export Session (in Session Details)

```
┌─────────────────────────────────────────┐
│           Session Details               │
├─────────────────────────────────────────┤
│ Name: Dungeon Crawl                     │
│ Created: Dec 1, 2025                    │
│ Rolls: 47                               │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📋 Copy to Clipboard                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ "Copied! Paste into a text file or     │
│  notes app to save your backup."       │
│                                         │
│              [Delete]        [Done]     │
└─────────────────────────────────────────┘
```

#### Import Session (in Settings/App Menu)

```
┌─────────────────────────────────────────┐
│           Import Session                │
├─────────────────────────────────────────┤
│                                         │
│ Paste your exported session data:       │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📋 Paste from Clipboard             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ✓ Valid session found!                  │
│   "Dungeon Crawl" - 47 rolls            │
│   Exported: Dec 4, 2025                 │
│                                         │
│         [Cancel]        [Import]        │
└─────────────────────────────────────────┘
```

### Implementation Notes

```dart
// Export to clipboard
import 'package:flutter/services.dart';

Future<void> exportToClipboard(Session session) async {
  final json = jsonEncode({
    'version': '1.0',
    'exportedAt': DateTime.now().toIso8601String(),
    'type': 'session',
    'session': session.toJson(),
  });
  await Clipboard.setData(ClipboardData(text: json));
}

// Import from clipboard
Future<Session?> importFromClipboard() async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  if (data?.text == null) return null;
  
  try {
    final json = jsonDecode(data!.text!);
    if (json['version'] != '1.0') throw FormatException('Unknown version');
    return Session.fromJson(json['session']);
  } catch (e) {
    return null; // Invalid format
  }
}
```

---

## Implementation Checklist

### Phase 1 (MVP)

- [ ] Add `shared_preferences` dependency
- [ ] Create `Session` model with JSON serialization
- [ ] Add `toJson`/`fromJson` to all `RollResult` subclasses
- [ ] Create `SessionService` with CRUD operations
- [ ] Add session selector dropdown in app bar
- [ ] Create new session dialog
- [ ] Auto-save on each roll
- [ ] Load last session on app start
- [ ] Persist wilderness state per session
- [ ] Add clear history confirmation (per session)

### Phase 2 (Enhanced)

- [ ] Session rename/edit
- [ ] Session notes field
- [ ] Session delete with confirmation
- [ ] Copy session to clipboard (JSON export)
- [ ] Import session from clipboard
- [ ] Copy all sessions to clipboard
- [ ] Roll count display in session list
- [ ] Session last accessed time

### Phase 3 (Advanced)

- [ ] Migrate to Hive/IndexedDB for better performance
- [ ] Add roll filtering/search
- [ ] Add roll statistics per session
- [ ] Session templates (pre-configured states)

---

## Conclusion

For the JuiceRoll app, **Option A (shared_preferences)** provides the best balance of:

- Quick implementation time
- Cross-platform compatibility  
- Sufficient storage for typical use cases
- Alignment with existing design doc plans
- **100% local storage - no servers, no accounts, no tracking**

Users maintain complete ownership of their data:
- All data stored locally on their device
- Export anytime via clipboard to backup wherever they want
- Import from clipboard to restore or transfer between devices
- No internet connection ever required

The modular architecture proposed allows easy migration to more robust local storage (Options B/C) if user needs grow beyond the MVP capabilities.

**Next steps:**
1. Review and approve this proposal
2. Implement Phase 1 checklist items
3. Gather user feedback on session management UX
4. Iterate based on real-world usage patterns

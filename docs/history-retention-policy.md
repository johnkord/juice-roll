# History Retention Policy

**Status:** Accepted
**Decision date:** 2026-08-08

## Decision

- Session history is unlimited by default.
- A user may enable a positive, session-specific maximum.
- The suggested value when enabling a limit is 200; it is not a default cap.
- History is stored newest-first. When a cap is exceeded or lowered, retain the
  newest entries and remove the oldest entries.
- Existing and imported sessions with no explicit cap remain unlimited.
- Existing and imported positive caps are preserved.
- In-memory history, full stored sessions, metadata counts, and exported data
  must represent the same retained entries.

## User Safety

Reducing a limit is destructive for entries beyond the new maximum. Settings
copy must state this before Save. Users should export important sessions before
reducing a limit.

Generic session saves and imports do not enforce a stored cap. This preserves
an existing or imported session exactly, including the unusual case where its
history already exceeds its custom cap. A cap is enforced only when the user
adds a new roll or explicitly changes the limit.

Corrupt storage or a rejected write must be reported as an error. It must not be
presented as an empty session or successful save.

## Backward Compatibility

The original v1.0 local-storage keys and required session fields are unchanged.
Fields added later for Dice-dialog preferences default safely when absent.
Original v1.0 individual-session and all-session clipboard exports remain
importable.

Compatibility fixtures verify that original v1.0 sessions:

- initialize through the current app state;
- preserve notes, Wilderness state, Dungeon state, custom caps, and raw history;
- survive load, save, and reload without history loss;
- repair missing metadata roll counts on the next save; and
- retain over-limit history during unrelated saves.

## Verification

Tests cover:

- more than 100 entries with no cap;
- a custom cap retaining newest-first entries;
- metadata roll counts;
- concurrent roll writes; and
- queued snapshots from rapid UI saves.

This policy is implemented without changing Juice Oracle mechanics or the
normal home UI.
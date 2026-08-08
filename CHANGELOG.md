# Changelog

## 1.1.0 - 2026-08-08

### Added

- Bulk session backup and non-destructive backup import.
- Retryable storage error reporting.
- Keyboard and screen-reader support for home oracle actions and key controls.
- Required Dart analysis and Flutter test gates before deployment.

### Fixed

- Session-selector roll counts now match stored history.
- Rapid session writes are serialized to prevent lost or reordered rolls.
- Custom history limits retain the newest rolls.
- Generic saves and imports preserve existing history, including legacy
  over-limit sessions.

### Compatibility

- Original v1.0 local sessions and individual/full clipboard exports remain
  supported.
- Juice Oracle mechanics, canonical action order, and the existing home layout
  are unchanged.
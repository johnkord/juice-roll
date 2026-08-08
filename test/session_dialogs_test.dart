import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/models/session.dart';
import 'package:juice_roll/ui/dialogs/session_dialogs.dart';

void main() {
  testWidgets('session selector shows metadata roll counts', (tester) async {
    final session = Session.fromMetadataJson({
      'id': 'session-1',
      'name': 'Seven Rolls',
      'createdAt': DateTime(2026).toIso8601String(),
      'lastAccessedAt': DateTime(2026).toIso8601String(),
      'rollCount': 7,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionSelectorSheet(
            sessions: [session],
            currentSession: session,
            onSelectSession: (_) async {},
            onShowDetails: (_) async {},
            onShowSettings: (_) async {},
            onDeleteSession: (_) async {},
            onNewSession: () {},
            onImportSession: () async {},
            onBackupAll: () async {},
            onImportBackup: () async {},
          ),
        ),
      ),
    );

    expect(find.textContaining('7 rolls'), findsOneWidget);
  });
}

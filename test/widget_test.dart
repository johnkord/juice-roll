// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:juice_roll/main.dart';
import 'package:juice_roll/services/session_service.dart';
import 'package:juice_roll/ui/home_screen.dart';
import 'package:juice_roll/ui/home_state.dart';
import 'package:juice_roll/ui/widgets/roll_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JuiceRollApp());

    // Verify that the app title is present.
    expect(find.text('JuiceRoll'), findsOneWidget);
  });

  testWidgets('Session load failures show a retry action', (tester) async {
    final notifier = HomeStateNotifier(
      sessionService: _FailingSessionService(),
    );
    await notifier.init();

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(stateNotifier: notifier)),
    );

    expect(find.text('Session data is unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    notifier.dispose();
  });

  testWidgets('Home actions and header controls expose semantics',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const JuiceRollApp());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('About Juice Roll'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Select session:')),
      findsOneWidget,
    );
    expect(find.byType(RollButton), findsNWidgets(24));

    semantics.dispose();
  });
}

class _FailingSessionService extends SessionService {
  @override
  Future<void> init() async {
    throw SessionStorageException(
      'Initialize session storage',
      StateError('Unavailable'),
    );
  }
}

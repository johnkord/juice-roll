import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/ui/widgets/roll_button.dart';

void main() {
  testWidgets('roll buttons expose semantics and keyboard activation',
      (tester) async {
    var activationCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 100,
              child: RollButton(
                label: 'Details',
                icon: Icons.palette,
                color: Colors.orange,
                onPressed: () => activationCount++,
              ),
            ),
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(RollButton));
    expect(semantics.label, 'Details');
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activationCount, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(activationCount, 2);
  });
}

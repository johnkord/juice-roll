import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juice_roll/core/roll_engine.dart';
import 'package:juice_roll/presets/dungeon_generator.dart';
import 'package:juice_roll/ui/dialogs/dungeon_dialog.dart';
import 'package:juice_roll/ui/theme/juice_theme.dart';
import 'package:juice_roll/ui/widgets/dice_roll_dialog.dart';

void main() {
  testWidgets('dice modes and steppers expose accessible controls',
      (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: JuiceTheme.themeData,
        home: Scaffold(
          body: DiceRollDialog(
            rollEngine: RollEngine(),
            onRoll: (_) {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Standard dice mode'), findsOneWidget);
    expect(find.bySemanticsLabel('Fate dice mode'), findsOneWidget);
    expect(find.bySemanticsLabel('Ironsworn dice mode'), findsOneWidget);

    for (final label in ['Decrease modifier', 'Increase modifier']) {
      final control = find.bySemanticsLabel(label);
      expect(control, findsOneWidget);
      final size = tester.getSize(control);
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }

    semantics.dispose();
  });

  testWidgets('dungeon reset is named and at least 44 pixels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: JuiceTheme.themeData,
        home: Scaffold(
          body: DungeonDialog(
            dungeonGenerator: DungeonGenerator(RollEngine()),
            onRoll: (_) {},
            isEntering: true,
            onPhaseChange: (_) {},
            isTwoPassMode: false,
            onTwoPassModeChange: (_) {},
            twoPassHasFirstDoubles: false,
            onTwoPassFirstDoublesChange: (_) {},
          ),
        ),
      ),
    );

    final reset = find.byTooltip('Reset dungeon map');
    expect(reset, findsOneWidget);
    final size = tester.getSize(reset);
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });
}

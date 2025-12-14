/// Home Screen Components - Extracted widgets with targeted rebuilds.
///
/// ## Why This File Exists
///
/// The HomeScreen was rebuilding ALL widgets (including 24 static buttons)
/// whenever ANY state changed. This file extracts components that need
/// targeted rebuilds, using `ListenableBuilder` to only rebuild when necessary.
///
/// ## How Targeted Rebuilds Work
///
/// Instead of calling `setState(() {})` which rebuilds the entire widget tree,
/// we use `ListenableBuilder` which only rebuilds its child when the
/// `HomeStateNotifier` fires `notifyListeners()`.
///
/// ## Adding New Stateful Components
///
/// If you need to add a new component that depends on HomeState:
///
/// 1. Create a new widget class in this file
/// 2. Pass the `HomeStateNotifier` to it
/// 3. Wrap the state-dependent part in `ListenableBuilder`
/// 4. Access state via `notifier.state` inside the builder
///
/// Example:
/// ```dart
/// class _MyNewComponent extends StatelessWidget {
///   final HomeStateNotifier notifier;
///   const _MyNewComponent({required this.notifier});
///
///   @override
///   Widget build(BuildContext context) {
///     return ListenableBuilder(
///       listenable: notifier,
///       builder: (context, _) {
///         final state = notifier.state;
///         // Use state.someField here
///         return MyWidget(data: state.someField);
///       },
///     );
///   }
/// }
/// ```
///
/// ## Performance Notes
///
/// - Static widgets (like the oracle button grid) should NOT use ListenableBuilder
/// - Only wrap the minimal subtree that actually needs the state
/// - The button grid is intentionally NOT in a ListenableBuilder since it never changes
library;

import 'package:flutter/material.dart';
import 'home_state.dart';
import 'theme/juice_theme.dart';
import 'widgets/roll_button.dart';
import 'widgets/roll_history.dart';

// =============================================================================
// ORACLE BUTTON GRID
// =============================================================================

/// Static grid of oracle buttons that NEVER rebuilds after initial build.
///
/// This is intentionally NOT wrapped in ListenableBuilder because the buttons
/// themselves don't change - only their callbacks matter, and those are
/// captured at build time.
///
/// Performance: This widget builds 24 RollButtons. By keeping it static,
/// we avoid rebuilding all of them on every state change.
class OracleButtonGrid extends StatelessWidget {
  /// Callbacks for each button - these open dialogs or trigger rolls.
  /// Grouped by category for maintainability.
  final OracleButtonCallbacks callbacks;

  const OracleButtonGrid({
    super.key,
    required this.callbacks,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Front Page (Details, Immersion) + Left Page (Fate, Scene)
          _ButtonRow(children: [
            RollButton(
              label: 'Details',
              icon: Icons.palette,
              onPressed: callbacks.showDetailsDialog,
              color: JuiceTheme.parchmentDark,
            ),
            RollButton(
              label: 'Immerse',
              icon: Icons.visibility,
              onPressed: callbacks.showImmersionDialog,
              color: JuiceTheme.juiceOrange,
            ),
            RollButton(
              label: 'Fate',
              icon: Icons.help_outline,
              onPressed: callbacks.showFateCheckDialog,
              color: JuiceTheme.mystic,
            ),
            RollButton(
              label: 'Scene',
              icon: Icons.theaters,
              onPressed: callbacks.showNextSceneDialog,
              color: JuiceTheme.info,
            ),
          ]),
          const SizedBox(height: 4),
          // Row 2: Left Page (Expect, Scale, Interrupt) + Right Page (Meaning)
          _ButtonRow(children: [
            RollButton(
              label: 'Expect',
              icon: Icons.psychology,
              onPressed: callbacks.showExpectationCheckDialog,
              color: JuiceTheme.mystic,
            ),
            RollButton(
              label: 'Scale',
              icon: Icons.swap_vert,
              onPressed: callbacks.rollScale,
              color: JuiceTheme.categoryCharacter,
            ),
            RollButton(
              label: 'Interrupt',
              icon: Icons.bolt,
              onPressed: callbacks.rollInterruptPlotPoint,
              color: JuiceTheme.juiceOrange,
            ),
            RollButton(
              label: 'Meaning',
              icon: Icons.lightbulb_outline,
              onPressed: callbacks.rollDiscoverMeaning,
              color: JuiceTheme.gold,
            ),
          ]),
          const SizedBox(height: 4),
          // Row 3: Second Inside Folded (Name, Random) + Back Page (Quest, Challenge)
          _ButtonRow(children: [
            RollButton(
              label: 'Name',
              icon: Icons.badge,
              onPressed: callbacks.showNameGeneratorDialog,
              color: JuiceTheme.categoryCharacter,
            ),
            RollButton(
              label: 'Random',
              icon: Icons.casino,
              onPressed: callbacks.showRandomTablesDialog,
              color: JuiceTheme.gold,
            ),
            RollButton(
              label: 'Quest',
              icon: Icons.map,
              onPressed: callbacks.rollQuest,
              color: JuiceTheme.rust,
            ),
            RollButton(
              label: 'Challenge',
              icon: Icons.fitness_center,
              onPressed: callbacks.showChallengeDialog,
              color: JuiceTheme.categoryCombat,
            ),
          ]),
          const SizedBox(height: 4),
          // Row 4: Back Page (Price) + First Inside Unfolded (Wilderness, Monster) + Second Inside Unfolded (NPC)
          _ButtonRow(children: [
            RollButton(
              label: 'Price',
              icon: Icons.warning,
              onPressed: callbacks.showPayThePriceDialog,
              color: JuiceTheme.danger,
            ),
            RollButton(
              label: 'Wilderness',
              icon: Icons.forest,
              onPressed: callbacks.showWildernessDialog,
              color: JuiceTheme.categoryExplore,
            ),
            RollButton(
              label: 'Monster',
              icon: Icons.pest_control,
              onPressed: callbacks.showMonsterDialog,
              color: JuiceTheme.danger,
            ),
            RollButton(
              label: 'NPC',
              icon: Icons.person,
              onPressed: callbacks.showNpcActionDialog,
              color: JuiceTheme.categoryCharacter,
            ),
          ]),
          const SizedBox(height: 4),
          // Row 5: Second Inside Unfolded (Dialog, Settlement) + Third Inside Unfolded (Treasure) + Fourth Inside Unfolded (Dungeon)
          _ButtonRow(children: [
            RollButton(
              label: 'Dialog',
              icon: Icons.chat,
              onPressed: callbacks.showDialogGeneratorDialog,
              color: JuiceTheme.categoryCharacter,
            ),
            RollButton(
              label: 'Settlement',
              icon: Icons.location_city,
              onPressed: callbacks.showSettlementDialog,
              color: JuiceTheme.categoryWorld,
            ),
            RollButton(
              label: 'Treasure',
              icon: Icons.diamond,
              onPressed: callbacks.showTreasureDialog,
              color: JuiceTheme.gold,
            ),
            RollButton(
              label: 'Dungeon',
              icon: Icons.castle,
              onPressed: callbacks.showDungeonDialog,
              color: JuiceTheme.categoryUtility,
            ),
          ]),
          const SizedBox(height: 4),
          // Row 6: Fourth Inside Unfolded (Location) + Left Extension (NPC Talk) + Right Extension (Abstract) + Dice Utility
          _ButtonRow(children: [
            RollButton(
              label: 'Location',
              icon: Icons.grid_on,
              onPressed: callbacks.showLocationDialog,
              color: JuiceTheme.rust,
            ),
            RollButton(
              label: 'NPC Talk',
              icon: Icons.record_voice_over,
              onPressed: callbacks.showExtendedNpcDialog,
              color: JuiceTheme.mystic,
            ),
            RollButton(
              label: 'Abstract',
              icon: Icons.image,
              onPressed: callbacks.showAbstractIconsDialog,
              color: JuiceTheme.success,
            ),
            RollButton(
              label: 'Dice',
              icon: Icons.casino,
              onPressed: callbacks.showDiceRollDialog,
              color: JuiceTheme.categoryUtility,
            ),
          ]),
        ],
      ),
    );
  }
}

/// Helper widget for building a row of buttons with consistent spacing.
class _ButtonRow extends StatelessWidget {
  final List<Widget> children;
  
  const _ButtonRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.map((btn) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AspectRatio(
              aspectRatio: 1.03,
              child: btn,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Callbacks for oracle buttons, grouped for easy maintenance.
///
/// When adding a new oracle button:
/// 1. Add the callback here
/// 2. Implement it in _HomeScreenState
/// 3. Pass it when creating OracleButtonCallbacks
class OracleButtonCallbacks {
  // Dialog openers
  final VoidCallback showDetailsDialog;
  final VoidCallback showImmersionDialog;
  final VoidCallback showFateCheckDialog;
  final VoidCallback showNextSceneDialog;
  final VoidCallback showExpectationCheckDialog;
  final VoidCallback showNameGeneratorDialog;
  final VoidCallback showRandomTablesDialog;
  final VoidCallback showChallengeDialog;
  final VoidCallback showPayThePriceDialog;
  final VoidCallback showWildernessDialog;
  final VoidCallback showMonsterDialog;
  final VoidCallback showNpcActionDialog;
  final VoidCallback showDialogGeneratorDialog;
  final VoidCallback showSettlementDialog;
  final VoidCallback showTreasureDialog;
  final VoidCallback showDungeonDialog;
  final VoidCallback showLocationDialog;
  final VoidCallback showExtendedNpcDialog;
  final VoidCallback showAbstractIconsDialog;
  final VoidCallback showDiceRollDialog;
  
  // Quick roll actions (no dialog)
  final VoidCallback rollScale;
  final VoidCallback rollInterruptPlotPoint;
  final VoidCallback rollDiscoverMeaning;
  final VoidCallback rollQuest;

  const OracleButtonCallbacks({
    required this.showDetailsDialog,
    required this.showImmersionDialog,
    required this.showFateCheckDialog,
    required this.showNextSceneDialog,
    required this.showExpectationCheckDialog,
    required this.showNameGeneratorDialog,
    required this.showRandomTablesDialog,
    required this.showChallengeDialog,
    required this.showPayThePriceDialog,
    required this.showWildernessDialog,
    required this.showMonsterDialog,
    required this.showNpcActionDialog,
    required this.showDialogGeneratorDialog,
    required this.showSettlementDialog,
    required this.showTreasureDialog,
    required this.showDungeonDialog,
    required this.showLocationDialog,
    required this.showExtendedNpcDialog,
    required this.showAbstractIconsDialog,
    required this.showDiceRollDialog,
    required this.rollScale,
    required this.rollInterruptPlotPoint,
    required this.rollDiscoverMeaning,
    required this.rollQuest,
  });
}

// =============================================================================
// SESSION APP BAR TITLE
// =============================================================================

/// App bar title that shows current session name with targeted rebuilds.
///
/// DEPENDS ON: `state.currentSession?.name`
///
/// This rebuilds when the session changes (name update, session switch).
/// Uses ListenableBuilder to avoid rebuilding the entire app bar.
class SessionAppBarTitle extends StatelessWidget {
  final HomeStateNotifier notifier;
  final VoidCallback onTap;

  const SessionAppBarTitle({
    super.key,
    required this.notifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final sessionName = notifier.state.currentSession?.name ?? 'JuiceRoll';
        return GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  sessionName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// CLEAR HISTORY BUTTON
// =============================================================================

/// Clear history button that only shows when history is not empty.
///
/// DEPENDS ON: `state.history.isNotEmpty`
///
/// This rebuilds when history changes to show/hide the button.
class ClearHistoryButton extends StatelessWidget {
  final HomeStateNotifier notifier;
  final VoidCallback onPressed;

  const ClearHistoryButton({
    super.key,
    required this.notifier,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final hasHistory = notifier.state.history.isNotEmpty;
        if (!hasHistory) {
          return const SizedBox.shrink();
        }
        return Semantics(
          label: 'Clear roll history',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.delete_sweep, size: 18),
            tooltip: 'Clear History',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: onPressed,
          ),
        );
      },
    );
  }
}

// =============================================================================
// HISTORY SECTION
// =============================================================================

/// Roll history section with targeted rebuilds.
///
/// DEPENDS ON: `state.history`
///
/// This is the most frequently updated section - rebuilds on every roll.
/// Isolated to prevent the button grid from rebuilding.
class HistorySection extends StatelessWidget {
  final HomeStateNotifier notifier;

  const HistorySection({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final history = notifier.state.history;
        
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 48,
                  color: JuiceTheme.parchmentDark30,
                ),
                const SizedBox(height: 12),
                Text(
                  'No rolls yet',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    color: JuiceTheme.parchmentDark50,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap an oracle button to begin',
                  style: TextStyle(
                    color: JuiceTheme.parchmentDark35,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }
        
        return RollHistory(
          history: history,
          onSetWildernessPosition: notifier.setWildernessPosition,
        );
      },
    );
  }
}

// =============================================================================
// HISTORY SECTION HEADER
// =============================================================================

/// Static header for the history section - never rebuilds.
///
/// This is a const widget since the header text never changes.
class HistorySectionHeader extends StatelessWidget {
  const HistorySectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: BoxDecoration(
        color: JuiceTheme.ink30,
        border: Border(
          top: BorderSide(
            color: JuiceTheme.parchmentDark20,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 12,
            color: JuiceTheme.parchmentDark60,
          ),
          const SizedBox(width: 6),
          Text(
            'Roll History',
            style: TextStyle(
              fontSize: 11,
              color: JuiceTheme.parchmentDark60,
            ),
          ),
        ],
      ),
    );
  }
}

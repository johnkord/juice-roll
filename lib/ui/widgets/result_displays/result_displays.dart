/// Result Display Builders - Modular display widgets for roll results.
/// 
/// This module provides the registry-based display system that replaces
/// the monolithic if/else chain in result_display_builder.dart.
/// 
/// ## Architecture
/// 
/// - **ResultDisplayRegistry** - Maps result types to display builder functions
/// - **Display modules** - Each category of results has its own display file
/// - **base_display_helpers.dart** - Shared helper widgets used across displays
/// 
/// ## Usage
/// 
/// 1. Call [registerAllDisplayBuilders] during app initialization:
/// ```dart
/// void main() {
///   registerAllDisplayBuilders();     // For UI display
///   runApp(const JuiceRollApp());
/// }
/// ```
/// 
/// 2. Build displays using the ResultDisplayBuilder:
/// ```dart
/// final widget = ResultDisplayBuilder(theme).buildDisplay(result);
/// ```
/// 
/// ## Adding New Result Types
/// 
/// 1. Create the result class (extends RollResult)
/// 2. Register in RollResultFactory (for JSON serialization)
/// 3. Add display function to appropriate display module
/// 4. Register in that module's register function
/// 
/// Example:
/// ```dart
/// // In the appropriate display module (e.g., oracle_displays.dart)
/// void registerOracleDisplays() {
///   // ... existing registrations
///   ResultDisplayRegistry.register<MyNewResult>(buildMyNewDisplay);
/// }
/// 
/// Widget buildMyNewDisplay(MyNewResult result, ThemeData theme) {
///   return Column(
///     children: [
///       // Your display widgets
///     ],
///   );
/// }
/// ```
library;

// Registry
export '../result_display_registry.dart';

// Shared helpers
export 'base_display_helpers.dart';

// Display modules - add more as they're migrated
export 'ironsworn_displays.dart';
export 'oracle_displays.dart';
export 'npc_displays.dart';
export 'settlement_displays.dart';
export 'challenge_displays.dart';
export 'immersion_displays.dart';
export 'details_displays.dart';
export 'wilderness_displays.dart';
export 'dungeon_displays.dart';
export 'misc_displays.dart';

import 'ironsworn_displays.dart';
import 'oracle_displays.dart';
import 'npc_displays.dart';
import 'settlement_displays.dart';
import 'challenge_displays.dart';
import 'immersion_displays.dart';
import 'details_displays.dart';
import 'wilderness_displays.dart';
import 'dungeon_displays.dart';
import 'misc_displays.dart';

import '../result_display_registry.dart';

/// Register all display builders with the registry.
/// 
/// Call this once during app initialization.
/// 
/// ```dart
/// void main() {
///   registerAllDisplayBuilders();
///   runApp(const JuiceRollApp());
/// }
/// ```
void registerAllDisplayBuilders() {
  if (ResultDisplayRegistry.isInitialized) return;
  
  // Register each category
  registerIronswornDisplays();
  registerOracleDisplays();
  registerNpcDisplays();
  registerSettlementDisplays();
  registerChallengeDisplays();
  registerImmersionDisplays();
  registerDetailsDisplays();
  registerWildernessDisplays();
  registerDungeonDisplays();
  registerMiscDisplays();
  
  ResultDisplayRegistry.markInitialized();
}

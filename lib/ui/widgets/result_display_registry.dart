import 'package:flutter/material.dart';
import '../../models/roll_result.dart';

/// Function type for building a display widget from a result.
typedef DisplayBuilder<T extends RollResult> = Widget Function(T result, ThemeData theme);

/// Registry for result type display builders.
/// 
/// This replaces the massive if/else chain in ResultDisplayBuilder with a
/// type-safe, extensible registry pattern.
/// 
/// ## Usage
/// 
/// Register during app initialization or in module files:
/// ```dart
/// ResultDisplayRegistry.register<FateCheckResult>(
///   (result, theme) => FateCheckDisplay(result: result, theme: theme),
/// );
/// ```
/// 
/// Build display:
/// ```dart
/// final widget = ResultDisplayRegistry.build(result, theme);
/// ```
/// 
/// ## Architecture
/// 
/// This registry works alongside RollResultFactory (for JSON deserialization):
/// - `RollResultFactory` - Maps className strings → factory functions for JSON
/// - `ResultDisplayRegistry` - Maps Type → display builder functions for UI
/// 
/// Both registries should be initialized at app startup.
class ResultDisplayRegistry {
  static final Map<Type, DisplayBuilder<RollResult>> _builders = {};
  
  static bool _initialized = false;
  
  /// Register a display builder for a specific result type.
  /// 
  /// The builder function receives the typed result and theme,
  /// and should return a Widget to display the result.
  /// 
  /// Example:
  /// ```dart
  /// ResultDisplayRegistry.register<FateCheckResult>(
  ///   (result, theme) => Column(
  ///     children: [
  ///       Text(result.outcome.displayName),
  ///       // ...
  ///     ],
  ///   ),
  /// );
  /// ```
  static void register<T extends RollResult>(DisplayBuilder<T> builder) {
    _builders[T] = (result, theme) => builder(result as T, theme);
  }
  
  /// Check if a type has a registered display builder.
  static bool hasBuilder(Type type) => _builders.containsKey(type);
  
  /// Build the display widget for a result.
  /// 
  /// Returns null if no builder is registered for the type,
  /// allowing callers to fall back to a default display.
  static Widget? build(RollResult result, ThemeData theme) {
    final builder = _builders[result.runtimeType];
    return builder?.call(result, theme);
  }
  
  /// Get all registered types (for debugging/testing).
  static List<Type> get registeredTypes => _builders.keys.toList();
  
  /// Get the count of registered builders.
  static int get count => _builders.length;
  
  /// Check if the registry has been initialized.
  static bool get isInitialized => _initialized;
  
  /// Mark the registry as initialized.
  /// 
  /// Called after all display builders have been registered.
  /// Prevents double-initialization.
  static void markInitialized() {
    _initialized = true;
  }
  
  /// Clear all registrations (for testing).
  static void clear() {
    _builders.clear();
    _initialized = false;
  }
}

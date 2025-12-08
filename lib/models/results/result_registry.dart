import '../roll_result.dart';
import 'table_lookup_result.dart';
import 'ironsworn_result.dart';

// Import oracle result types from preset files
import '../../presets/fate_check.dart' show FateCheckResult;
import '../../presets/expectation_check.dart' show ExpectationCheckResult;
import '../../presets/random_event.dart' 
    show RandomEventResult, RandomEventFocusResult, IdeaResult, SingleTableResult;
import '../../presets/next_scene.dart' 
    show NextSceneResult, NextSceneWithFollowUpResult, FocusResult;
import '../../presets/discover_meaning.dart' show DiscoverMeaningResult;
import '../../presets/interrupt_plot_point.dart' show InterruptPlotPointResult;

/// Central registry for RollResult types.
/// 
/// This replaces the manual map in RollResultFactory with a 
/// more maintainable registration system.
/// 
/// Usage:
/// ```dart
/// // During app initialization
/// ResultRegistry.initialize();
/// 
/// // To deserialize
/// final result = ResultRegistry.fromJson(json);
/// ```
class ResultRegistry {
  static final Map<String, RollResult Function(Map<String, dynamic>)> _registry = {};
  
  /// Alias mapping for backward compatibility with deprecated class names.
  /// Maps old class names to their replacement class names.
  static final Map<String, String> _aliases = {};
  
  static bool _initialized = false;

  /// Register a result type factory.
  static void register(
    String className, 
    RollResult Function(Map<String, dynamic>) factory,
  ) {
    _registry[className] = factory;
  }

  /// Register an alias for backward compatibility.
  /// When loading JSON with [oldName], it will use the factory for [newName].
  static void registerAlias(String oldName, String newName) {
    _aliases[oldName] = newName;
  }

  /// Initialize the registry with all known result types.
  /// This should be called once during app startup.
  static void initialize() {
    if (_initialized) return;
    
    // =========================================================================
    // BASE TYPES
    // =========================================================================
    register('RollResult', RollResult.fromJson);
    register('FateRollResult', FateRollResult.fromJson);
    
    // =========================================================================
    // CONSOLIDATED TYPES - TABLE LOOKUP
    // =========================================================================
    register('TableLookupResult', TableLookupResult.fromJson);
    
    // Backward compatibility aliases for simple table results
    registerAlias('DetailResult', 'TableLookupResult');
    registerAlias('SettlementDetailResult', 'TableLookupResult');
    registerAlias('DungeonDetailResult', 'TableLookupResult');
    registerAlias('WildernessDetailResult', 'TableLookupResult');
    registerAlias('ColorResult', 'TableLookupResult');
    registerAlias('SizeResult', 'TableLookupResult');
    registerAlias('ShapeResult', 'TableLookupResult');
    registerAlias('ConditionResult', 'TableLookupResult');
    registerAlias('HistoryResult', 'TableLookupResult');
    
    // =========================================================================
    // ORACLE RESULTS - From preset files
    // =========================================================================
    register('FateCheckResult', FateCheckResult.fromJson);
    register('ExpectationCheckResult', ExpectationCheckResult.fromJson);
    register('RandomEventResult', RandomEventResult.fromJson);
    register('RandomEventFocusResult', RandomEventFocusResult.fromJson);
    register('IdeaResult', IdeaResult.fromJson);
    register('SingleTableResult', SingleTableResult.fromJson);
    register('NextSceneResult', NextSceneResult.fromJson);
    register('NextSceneWithFollowUpResult', NextSceneWithFollowUpResult.fromJson);
    register('FocusResult', FocusResult.fromJson);
    register('DiscoverMeaningResult', DiscoverMeaningResult.fromJson);
    register('InterruptPlotPointResult', InterruptPlotPointResult.fromJson);
    
    // =========================================================================
    // IRONSWORN/STARFORGED RESULTS
    // =========================================================================
    register('IronswornActionResult', IronswornActionResult.fromJson);
    register('IronswornProgressResult', IronswornProgressResult.fromJson);
    register('IronswornOracleResult', IronswornOracleResult.fromJson);
    register('IronswornYesNoResult', IronswornYesNoResult.fromJson);
    register('IronswornCursedOracleResult', IronswornCursedOracleResult.fromJson);
    register('IronswornMomentumBurnResult', IronswornMomentumBurnResult.fromJson);
    
    // Note: Additional result types can be registered as needed.
    // For comprehensive coverage, see RollResultFactory which registers all types.
    
    _initialized = true;
  }

  /// Deserialize a RollResult from JSON.
  /// 
  /// Handles:
  /// 1. New registered types
  /// 2. Aliased (deprecated) type names
  /// 3. Fallback to base RollResult for unknown types
  static RollResult fromJson(Map<String, dynamic> json) {
    var className = json['className'] as String? ?? 'RollResult';
    
    // Check for aliased (deprecated) names
    if (_aliases.containsKey(className)) {
      className = _aliases[className]!;
    }
    
    final factory = _registry[className];
    if (factory != null) {
      try {
        return factory(json);
      } catch (e) {
        // If the specific factory fails, fall back to base
        return RollResult.fromJson(json);
      }
    }
    
    // Unknown type - return base RollResult
    return RollResult.fromJson(json);
  }

  /// Check if a type is registered
  static bool isRegistered(String className) {
    return _registry.containsKey(className) || _aliases.containsKey(className);
  }

  /// Get list of all registered type names (for debugging)
  static List<String> get registeredTypes => _registry.keys.toList();
}

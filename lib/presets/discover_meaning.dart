import '../core/roll_engine.dart';
import '../data/meaning_data.dart' as data;

// Re-export result class for backward compatibility
export '../models/results/discover_meaning_result.dart';

import '../models/results/discover_meaning_result.dart';

/// Discover Meaning preset for the Juice Oracle.
/// Generates two-word prompts for open interpretation.
/// Uses the Meaning Tables from meaning-name-generator.md.
class DiscoverMeaning {
  final RollEngine _rollEngine;

  // ========== Static Accessors (delegate to data file) ==========

  /// Adjective words (column 1) - d20
  static List<String> get adjectives => data.adjectives;

  /// Noun words (column 2) - d20
  static List<String> get nouns => data.nouns;

  DiscoverMeaning([RollEngine? rollEngine])
      : _rollEngine = rollEngine ?? RollEngine();

  /// Generate a meaning phrase (Adjective + Noun).
  DiscoverMeaningResult generate() {
    final adjRoll = _rollEngine.rollDie(20);
    final nounRoll = _rollEngine.rollDie(20);

    final adjective = adjectives[adjRoll - 1];
    final noun = nouns[nounRoll - 1];

    return DiscoverMeaningResult(
      adjectiveRoll: adjRoll,
      adjective: adjective,
      nounRoll: nounRoll,
      noun: noun,
    );
  }
}

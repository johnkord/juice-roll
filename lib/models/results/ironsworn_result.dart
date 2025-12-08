import '../roll_result.dart';
import 'result_types.dart';
import 'display_sections.dart';

/// Possible outcomes for Ironsworn action and progress rolls.
enum IronswornOutcome {
  /// Action score beats both challenge dice
  strongHit,
  
  /// Action score beats one challenge die
  weakHit,
  
  /// Action score beats neither challenge die
  miss,
}

extension IronswornOutcomeDisplay on IronswornOutcome {
  String get displayText {
    switch (this) {
      case IronswornOutcome.strongHit:
        return 'Strong Hit';
      case IronswornOutcome.weakHit:
        return 'Weak Hit';
      case IronswornOutcome.miss:
        return 'Miss';
    }
  }

  String get description {
    switch (this) {
      case IronswornOutcome.strongHit:
        return 'Your action score beats both challenge dice. You succeed!';
      case IronswornOutcome.weakHit:
        return 'Your action score beats one challenge die. Success with a cost or complication.';
      case IronswornOutcome.miss:
        return 'Your action score beats neither die. You fail or face a serious setback.';
    }
  }

  bool get isSuccess => this == IronswornOutcome.strongHit || this == IronswornOutcome.weakHit;
}

/// Result of an Ironsworn/Starforged action roll.
/// 
/// Action Roll: 1d6 (action die) + stat + adds vs 2d10 (challenge dice)
/// Compare action score to each challenge die:
/// - Strong Hit: beats both
/// - Weak Hit: beats one  
/// - Miss: beats neither
/// 
/// Match: both challenge dice show the same value (notable opportunity or complication)
class IronswornActionResult extends RollResult {
  /// The action die result (1d6)
  final int actionDie;
  
  /// The two challenge dice results (2d10)
  final List<int> challengeDice;
  
  /// Stat bonus added to action die
  final int statBonus;
  
  /// Additional modifiers (from assets, etc.)
  final int adds;
  
  /// The calculated action score (actionDie + statBonus + adds)
  final int actionScore;
  
  /// The determined outcome
  final IronswornOutcome outcome;
  
  /// Whether the challenge dice matched (both same value)
  final bool isMatch;

  IronswornActionResult({
    required this.actionDie,
    required this.challengeDice,
    this.statBonus = 0,
    this.adds = 0,
    DateTime? timestamp,
  }) : actionScore = actionDie + statBonus + adds,
       outcome = _calculateOutcome(actionDie + statBonus + adds, challengeDice),
       isMatch = challengeDice[0] == challengeDice[1],
       super(
         type: RollType.ironswornAction,
         description: _buildDescription(statBonus, adds),
         diceResults: [actionDie, ...challengeDice],
         total: actionDie + statBonus + adds,
         interpretation: _buildInterpretation(
           actionDie + statBonus + adds, 
           challengeDice,
           challengeDice[0] == challengeDice[1],
         ),
         timestamp: timestamp,
         metadata: {
           'actionDie': actionDie,
           'challengeDice': challengeDice,
           'statBonus': statBonus,
           'adds': adds,
           'actionScore': actionDie + statBonus + adds,
           'outcome': _calculateOutcome(actionDie + statBonus + adds, challengeDice).name,
           'isMatch': challengeDice[0] == challengeDice[1],
         },
         displayType: ResultDisplayType.ironsworn,
       );

  @override
  String get className => 'IronswornActionResult';

  static IronswornOutcome _calculateOutcome(int actionScore, List<int> challengeDice) {
    final beatsFirst = actionScore > challengeDice[0];
    final beatsSecond = actionScore > challengeDice[1];
    
    if (beatsFirst && beatsSecond) {
      return IronswornOutcome.strongHit;
    } else if (beatsFirst || beatsSecond) {
      return IronswornOutcome.weakHit;
    } else {
      return IronswornOutcome.miss;
    }
  }

  static String _buildDescription(int statBonus, int adds) {
    final parts = <String>['Action Roll'];
    if (statBonus != 0 || adds != 0) {
      final total = statBonus + adds;
      parts.add(total >= 0 ? '+$total' : '$total');
    }
    return parts.join(' ');
  }

  static String _buildInterpretation(int actionScore, List<int> challengeDice, bool isMatch) {
    final outcome = _calculateOutcome(actionScore, challengeDice);
    final matchText = isMatch ? ' with a Match!' : '';
    return '${outcome.displayText}$matchText';
  }

  /// UI display sections for generic rendering.
  @override
  List<ResultSection> get sections {
    final result = <ResultSection>[];
    
    // Action die section
    result.add(DisplaySections.labeledValue(
      label: '1d6',
      value: '$actionDie',
      sublabel: statBonus != 0 || adds != 0 
          ? 'Action Die' 
          : null,
    ));
    
    // Stat/adds if present
    if (statBonus != 0 || adds != 0) {
      result.add(DisplaySections.labeledValue(
        label: 'Bonus',
        value: '+${statBonus + adds}',
        sublabel: 'Stat + Adds',
      ));
    }
    
    // Action score
    result.add(DisplaySections.labeledValue(
      label: 'Action Score',
      value: '$actionScore',
      sublabel: 'vs Challenge',
    ));
    
    // Challenge dice section
    result.add(DisplaySections.labeledValue(
      label: '2d10',
      value: '${challengeDice[0]}, ${challengeDice[1]}',
      sublabel: isMatch ? 'Match!' : 'Challenge Dice',
    ));
    
    // Outcome section
    result.add(DisplaySections.outcome(
      value: outcome.displayText,
      isPositive: outcome.isSuccess,
    ));
    
    // Match indicator if applicable
    if (isMatch) {
      result.add(DisplaySections.trigger(
        value: 'Match!',
        colorValue: outcome.isSuccess ? 0xFF4CAF50 : 0xFFFF5722, // Green or orange
      ));
    }
    
    return result;
  }

  factory IronswornActionResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IronswornActionResult(
      actionDie: meta['actionDie'] as int,
      challengeDice: (meta['challengeDice'] as List<dynamic>).cast<int>(),
      statBonus: meta['statBonus'] as int? ?? 0,
      adds: meta['adds'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Ironsworn Action Roll:');
    buffer.writeln('  Action Die: $actionDie + $statBonus (stat) + $adds (adds) = $actionScore');
    buffer.writeln('  Challenge: ${challengeDice[0]}, ${challengeDice[1]}${isMatch ? ' (Match!)' : ''}');
    buffer.write('  Result: ${outcome.displayText}');
    return buffer.toString();
  }
}

/// Result of an Ironsworn/Starforged progress roll.
/// 
/// Progress Roll: Progress score (0-10, no dice) vs 2d10 challenge dice
/// Used for completing vows, journeys, combat, etc.
class IronswornProgressResult extends RollResult {
  /// The progress score (0-10 based on progress track boxes)
  final int progressScore;
  
  /// The two challenge dice results (2d10)
  final List<int> challengeDice;
  
  /// The determined outcome
  final IronswornOutcome outcome;
  
  /// Whether the challenge dice matched
  final bool isMatch;

  IronswornProgressResult({
    required this.progressScore,
    required this.challengeDice,
    DateTime? timestamp,
  }) : outcome = _calculateOutcome(progressScore, challengeDice),
       isMatch = challengeDice[0] == challengeDice[1],
       super(
         type: RollType.ironswornProgress,
         description: 'Progress Roll',
         diceResults: challengeDice,
         total: progressScore,
         interpretation: _buildInterpretation(progressScore, challengeDice),
         timestamp: timestamp,
         metadata: {
           'progressScore': progressScore,
           'challengeDice': challengeDice,
           'outcome': _calculateOutcome(progressScore, challengeDice).name,
           'isMatch': challengeDice[0] == challengeDice[1],
         },
         displayType: ResultDisplayType.ironsworn,
       );

  @override
  String get className => 'IronswornProgressResult';

  static IronswornOutcome _calculateOutcome(int progressScore, List<int> challengeDice) {
    final beatsFirst = progressScore > challengeDice[0];
    final beatsSecond = progressScore > challengeDice[1];
    
    if (beatsFirst && beatsSecond) {
      return IronswornOutcome.strongHit;
    } else if (beatsFirst || beatsSecond) {
      return IronswornOutcome.weakHit;
    } else {
      return IronswornOutcome.miss;
    }
  }

  static String _buildInterpretation(int progressScore, List<int> challengeDice) {
    final outcome = _calculateOutcome(progressScore, challengeDice);
    final isMatch = challengeDice[0] == challengeDice[1];
    final matchText = isMatch ? ' with a Match!' : '';
    return '${outcome.displayText}$matchText';
  }

  @override
  List<ResultSection> get sections {
    final result = <ResultSection>[];
    
    // Progress score section
    result.add(DisplaySections.labeledValue(
      label: 'Progress',
      value: '$progressScore',
      sublabel: 'vs Challenge',
    ));
    
    // Challenge dice section
    result.add(DisplaySections.labeledValue(
      label: '2d10',
      value: '${challengeDice[0]}, ${challengeDice[1]}',
      sublabel: isMatch ? 'Match!' : 'Challenge Dice',
    ));
    
    // Outcome section
    result.add(DisplaySections.outcome(
      value: outcome.displayText,
      isPositive: outcome.isSuccess,
    ));
    
    if (isMatch) {
      result.add(DisplaySections.trigger(
        value: 'Match!',
        colorValue: outcome.isSuccess ? 0xFF4CAF50 : 0xFFFF5722,
      ));
    }
    
    return result;
  }

  factory IronswornProgressResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IronswornProgressResult(
      progressScore: meta['progressScore'] as int,
      challengeDice: (meta['challengeDice'] as List<dynamic>).cast<int>(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Ironsworn Progress Roll:');
    buffer.writeln('  Progress Score: $progressScore');
    buffer.writeln('  Challenge: ${challengeDice[0]}, ${challengeDice[1]}${isMatch ? ' (Match!)' : ''}');
    buffer.write('  Result: ${outcome.displayText}');
    return buffer.toString();
  }
}

/// Result of an Ironsworn oracle roll (1d100 or other percentile lookups).
class IronswornOracleResult extends RollResult {
  /// The oracle roll (typically 1-100)
  final int oracleRoll;
  
  /// Description of what oracle table was used
  final String? oracleTable;
  
  /// The die type used (6, 20, or 100)
  final int dieType;
  
  /// Whether the oracle dice show a match (doubles on d100)
  final bool isMatch;

  IronswornOracleResult({
    required this.oracleRoll,
    this.oracleTable,
    this.dieType = 100,
    DateTime? timestamp,
  }) : isMatch = dieType == 100 && _isDoubles(oracleRoll),
       super(
         type: RollType.ironswornOracle,
         description: oracleTable != null ? 'Oracle: $oracleTable' : 'Oracle Roll',
         diceResults: [oracleRoll],
         total: oracleRoll,
         interpretation: _buildInterpretation(oracleRoll, dieType),
         timestamp: timestamp,
         metadata: {
           'oracleRoll': oracleRoll,
           'dieType': dieType,
           'isMatch': dieType == 100 && _isDoubles(oracleRoll),
           if (oracleTable != null) 'oracleTable': oracleTable,
         },
       );

  @override
  String get className => 'IronswornOracleResult';
  
  static bool _isDoubles(int roll) {
    // Doubles on d100: 11, 22, 33, 44, 55, 66, 77, 88, 99, and 100 (00)
    if (roll == 100) return true;
    if (roll < 11) return false;
    final tens = roll ~/ 10;
    final ones = roll % 10;
    return tens == ones;
  }
  
  static String _buildInterpretation(int roll, int dieType) {
    if (dieType == 100 && _isDoubles(roll)) {
      return '$roll (Match - Twist!)';
    }
    return '$roll';
  }

  @override
  List<ResultSection> get sections {
    final result = <ResultSection>[
      DisplaySections.labeledValue(
        label: '1d$dieType',
        value: '$oracleRoll',
        sublabel: oracleTable,
      ),
    ];
    
    if (isMatch) {
      result.add(DisplaySections.trigger(
        value: 'Match - Twist!',
        colorValue: 0xFFFFB300, // Amber
      ));
    }
    
    return result;
  }

  factory IronswornOracleResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IronswornOracleResult(
      oracleRoll: meta['oracleRoll'] as int,
      oracleTable: meta['oracleTable'] as String?,
      dieType: meta['dieType'] as int? ?? 100,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Ironsworn Oracle (d$dieType): $oracleRoll${isMatch ? ' (Match!)' : ''}${oracleTable != null ? ' ($oracleTable)' : ''}';
}

/// Odds levels for Ironsworn Yes/No oracle.
enum IronswornOdds {
  almostCertain,
  likely,
  fiftyFifty,
  unlikely,
  smallChance,
}

extension IronswornOddsDisplay on IronswornOdds {
  String get displayText {
    switch (this) {
      case IronswornOdds.almostCertain:
        return 'Almost Certain';
      case IronswornOdds.likely:
        return 'Likely';
      case IronswornOdds.fiftyFifty:
        return '50/50';
      case IronswornOdds.unlikely:
        return 'Unlikely';
      case IronswornOdds.smallChance:
        return 'Small Chance';
    }
  }
  
  /// Threshold: roll this or higher = Yes
  int get yesThreshold {
    switch (this) {
      case IronswornOdds.almostCertain:
        return 11;
      case IronswornOdds.likely:
        return 26;
      case IronswornOdds.fiftyFifty:
        return 51;
      case IronswornOdds.unlikely:
        return 76;
      case IronswornOdds.smallChance:
        return 91;
    }
  }
  
  String get rangeDescription {
    switch (this) {
      case IronswornOdds.almostCertain:
        return 'Yes on 11-100';
      case IronswornOdds.likely:
        return 'Yes on 26-100';
      case IronswornOdds.fiftyFifty:
        return 'Yes on 51-100';
      case IronswornOdds.unlikely:
        return 'Yes on 76-100';
      case IronswornOdds.smallChance:
        return 'Yes on 91-100';
    }
  }
}

/// Result of an Ironsworn Yes/No oracle (Ask the Oracle).
class IronswornYesNoResult extends RollResult {
  /// The d100 roll
  final int roll;
  
  /// The odds level chosen
  final IronswornOdds odds;
  
  /// Whether the answer is Yes
  final bool isYes;
  
  /// Whether the dice show doubles (extreme result / twist)
  final bool isMatch;

  IronswornYesNoResult({
    required this.roll,
    required this.odds,
    DateTime? timestamp,
  }) : isYes = roll >= odds.yesThreshold,
       isMatch = _isDoubles(roll),
       super(
         type: RollType.ironswornOracle,
         description: 'Ask the Oracle (${odds.displayText})',
         diceResults: [roll],
         total: roll,
         interpretation: _buildInterpretation(roll, odds),
         timestamp: timestamp,
         metadata: {
           'roll': roll,
           'odds': odds.name,
           'isYes': roll >= odds.yesThreshold,
           'isMatch': _isDoubles(roll),
         },
         displayType: ResultDisplayType.ironsworn,
       );

  @override
  String get className => 'IronswornYesNoResult';
  
  static bool _isDoubles(int roll) {
    if (roll == 100) return true;
    if (roll < 11) return false;
    final tens = roll ~/ 10;
    final ones = roll % 10;
    return tens == ones;
  }
  
  static String _buildInterpretation(int roll, IronswornOdds odds) {
    final isYes = roll >= odds.yesThreshold;
    final isMatch = _isDoubles(roll);
    
    if (isMatch) {
      return isYes ? 'Yes! (Extreme/Twist)' : 'No! (Extreme/Twist)';
    }
    return isYes ? 'Yes' : 'No';
  }
  
  /// Display text for the answer
  String get answerText {
    if (isMatch) {
      return isYes ? 'Yes! (Extreme)' : 'No! (Extreme)';
    }
    return isYes ? 'Yes' : 'No';
  }

  @override
  List<ResultSection> get sections {
    final result = <ResultSection>[];
    
    result.add(DisplaySections.labeledValue(
      label: '1d100',
      value: '$roll',
      sublabel: odds.rangeDescription,
    ));
    
    result.add(DisplaySections.outcome(
      value: answerText,
      isPositive: isYes,
    ));
    
    if (isMatch) {
      result.add(DisplaySections.trigger(
        value: 'Extreme Result!',
        colorValue: 0xFFFFB300, // Amber
      ));
    }
    
    return result;
  }

  factory IronswornYesNoResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IronswornYesNoResult(
      roll: meta['roll'] as int,
      odds: IronswornOdds.values.byName(meta['odds'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'Ask the Oracle (${odds.displayText}): $roll → $answerText';
}

/// Result of a Sundered Isles cursed oracle roll.
/// Rolls d100 + cursed d10; if cursed die shows 10, also consult cursed table.
class IronswornCursedOracleResult extends RollResult {
  /// The d100 oracle roll
  final int oracleRoll;
  
  /// The cursed d10 roll
  final int cursedDie;
  
  /// Description of what oracle table was used
  final String? oracleTable;
  
  /// Whether the cursed die triggered (rolled 10)
  final bool isCursed;
  
  /// Whether the oracle dice show doubles
  final bool isMatch;

  IronswornCursedOracleResult({
    required this.oracleRoll,
    required this.cursedDie,
    this.oracleTable,
    DateTime? timestamp,
  }) : isCursed = cursedDie == 10,
       isMatch = _isDoubles(oracleRoll),
       super(
         type: RollType.ironswornOracle,
         description: oracleTable != null 
             ? 'Cursed Oracle: $oracleTable' 
             : 'Cursed Oracle Roll',
         diceResults: [oracleRoll, cursedDie],
         total: oracleRoll,
         interpretation: _buildInterpretation(oracleRoll, cursedDie),
         timestamp: timestamp,
         metadata: {
           'oracleRoll': oracleRoll,
           'cursedDie': cursedDie,
           'isCursed': cursedDie == 10,
           'isMatch': _isDoubles(oracleRoll),
           if (oracleTable != null) 'oracleTable': oracleTable,
         },
         displayType: ResultDisplayType.ironsworn,
       );

  @override
  String get className => 'IronswornCursedOracleResult';
  
  static bool _isDoubles(int roll) {
    if (roll == 100) return true;
    if (roll < 11) return false;
    final tens = roll ~/ 10;
    final ones = roll % 10;
    return tens == ones;
  }
  
  static String _buildInterpretation(int oracleRoll, int cursedDie) {
    final parts = <String>['$oracleRoll'];
    if (_isDoubles(oracleRoll)) {
      parts.add('Match');
    }
    if (cursedDie == 10) {
      parts.add('CURSED!');
    }
    return parts.join(' + ');
  }

  @override
  List<ResultSection> get sections {
    final result = <ResultSection>[];
    
    result.add(DisplaySections.labeledValue(
      label: '1d100',
      value: '$oracleRoll',
      sublabel: oracleTable ?? 'Oracle',
    ));
    
    result.add(DisplaySections.labeledValue(
      label: 'Cursed d10',
      value: '$cursedDie',
      sublabel: isCursed ? 'Cursed!' : null,
    ));
    
    if (isCursed) {
      result.add(DisplaySections.trigger(
        value: 'CURSED! Consult cursed table',
        colorValue: 0xFF7B1FA2, // Purple for supernatural
      ));
    }
    
    if (isMatch) {
      result.add(DisplaySections.trigger(
        value: 'Match - Twist!',
        colorValue: 0xFFFFB300, // Amber
      ));
    }
    
    return result;
  }

  factory IronswornCursedOracleResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IronswornCursedOracleResult(
      oracleRoll: meta['oracleRoll'] as int,
      cursedDie: meta['cursedDie'] as int,
      oracleTable: meta['oracleTable'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('Sundered Isles Cursed Oracle: $oracleRoll');
    if (isMatch) buffer.write(' (Match)');
    buffer.write(' + Cursed: $cursedDie');
    if (isCursed) buffer.write(' (CURSED!)');
    if (oracleTable != null) buffer.write(' ($oracleTable)');
    return buffer.toString();
  }
}

/// Result of an Ironsworn action roll with momentum burn.
class IronswornMomentumBurnResult extends RollResult {
  /// The original action die result (1d6)
  final int actionDie;
  
  /// The two challenge dice results (2d10)
  final List<int> challengeDice;
  
  /// Stat bonus added to action die
  final int statBonus;
  
  /// Additional modifiers
  final int adds;
  
  /// The original action score (actionDie + statBonus + adds)
  final int originalActionScore;
  
  /// The momentum value used to replace the action score
  final int momentumValue;
  
  /// The original outcome (before burning momentum)
  final IronswornOutcome originalOutcome;
  
  /// The outcome after burning momentum
  final IronswornOutcome burnedOutcome;
  
  /// Whether the challenge dice matched
  final bool isMatch;
  
  /// Whether burning momentum improved the result
  final bool wasUpgraded;

  IronswornMomentumBurnResult({
    required this.actionDie,
    required this.challengeDice,
    required this.momentumValue,
    this.statBonus = 0,
    this.adds = 0,
    DateTime? timestamp,
  }) : originalActionScore = actionDie + statBonus + adds,
       originalOutcome = _calculateOutcome(actionDie + statBonus + adds, challengeDice),
       burnedOutcome = _calculateOutcome(momentumValue, challengeDice),
       isMatch = challengeDice[0] == challengeDice[1],
       wasUpgraded = _wasUpgraded(
         _calculateOutcome(actionDie + statBonus + adds, challengeDice),
         _calculateOutcome(momentumValue, challengeDice),
       ),
       super(
         type: RollType.ironswornAction,
         description: 'Action Roll (Momentum Burn)',
         diceResults: [actionDie, ...challengeDice],
         total: momentumValue,
         interpretation: _buildInterpretation(
           actionDie + statBonus + adds,
           momentumValue,
           challengeDice,
         ),
         timestamp: timestamp,
         metadata: {
           'actionDie': actionDie,
           'challengeDice': challengeDice,
           'statBonus': statBonus,
           'adds': adds,
           'originalActionScore': actionDie + statBonus + adds,
           'momentumValue': momentumValue,
           'originalOutcome': _calculateOutcome(actionDie + statBonus + adds, challengeDice).name,
           'burnedOutcome': _calculateOutcome(momentumValue, challengeDice).name,
           'isMatch': challengeDice[0] == challengeDice[1],
           'momentumBurned': true,
         },
         displayType: ResultDisplayType.ironsworn,
       );

  @override
  String get className => 'IronswornMomentumBurnResult';

  static IronswornOutcome _calculateOutcome(int score, List<int> challengeDice) {
    final beatsFirst = score > challengeDice[0];
    final beatsSecond = score > challengeDice[1];
    
    if (beatsFirst && beatsSecond) {
      return IronswornOutcome.strongHit;
    } else if (beatsFirst || beatsSecond) {
      return IronswornOutcome.weakHit;
    } else {
      return IronswornOutcome.miss;
    }
  }
  
  static bool _wasUpgraded(IronswornOutcome original, IronswornOutcome burned) {
    final originalRank = original == IronswornOutcome.strongHit ? 2 
        : original == IronswornOutcome.weakHit ? 1 : 0;
    final burnedRank = burned == IronswornOutcome.strongHit ? 2 
        : burned == IronswornOutcome.weakHit ? 1 : 0;
    return burnedRank > originalRank;
  }

  static String _buildInterpretation(int originalScore, int momentum, List<int> challengeDice) {
    final originalOutcome = _calculateOutcome(originalScore, challengeDice);
    final burnedOutcome = _calculateOutcome(momentum, challengeDice);
    final isMatch = challengeDice[0] == challengeDice[1];
    final matchText = isMatch ? ' with a Match!' : '';
    
    if (_wasUpgraded(originalOutcome, burnedOutcome)) {
      return '${originalOutcome.displayText} → ${burnedOutcome.displayText} (Momentum Burned!)$matchText';
    }
    return '${burnedOutcome.displayText} (Momentum: $momentum)$matchText';
  }

  @override
  List<ResultSection> get sections {
    final result = <ResultSection>[];
    
    // Original roll info
    result.add(DisplaySections.labeledValue(
      label: '1d6',
      value: '$actionDie',
      sublabel: 'Original: $originalActionScore',
    ));
    
    // Momentum burn
    result.add(DisplaySections.labeledValue(
      label: 'Momentum',
      value: '$momentumValue',
      sublabel: 'Burned!',
    ));
    
    // Challenge dice
    result.add(DisplaySections.labeledValue(
      label: '2d10',
      value: '${challengeDice[0]}, ${challengeDice[1]}',
      sublabel: isMatch ? 'Match!' : 'Challenge Dice',
    ));
    
    // Show upgrade if applicable
    if (wasUpgraded) {
      result.add(DisplaySections.trigger(
        value: '${originalOutcome.displayText} → ${burnedOutcome.displayText}',
        colorValue: 0xFF4CAF50, // Green for upgrade
      ));
    }
    
    // Final outcome
    result.add(DisplaySections.outcome(
      value: burnedOutcome.displayText,
      isPositive: burnedOutcome.isSuccess,
    ));
    
    if (isMatch) {
      result.add(DisplaySections.trigger(
        value: 'Match!',
        colorValue: burnedOutcome.isSuccess ? 0xFF4CAF50 : 0xFFFF5722,
      ));
    }
    
    return result;
  }

  factory IronswornMomentumBurnResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return IronswornMomentumBurnResult(
      actionDie: meta['actionDie'] as int,
      challengeDice: (meta['challengeDice'] as List<dynamic>).cast<int>(),
      momentumValue: meta['momentumValue'] as int,
      statBonus: meta['statBonus'] as int? ?? 0,
      adds: meta['adds'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Ironsworn Action Roll (Momentum Burn):');
    buffer.writeln('  Original: $actionDie + $statBonus + $adds = $originalActionScore → ${originalOutcome.displayText}');
    buffer.writeln('  Momentum: $momentumValue → ${burnedOutcome.displayText}');
    buffer.writeln('  Challenge: ${challengeDice[0]}, ${challengeDice[1]}${isMatch ? ' (Match!)' : ''}');
    if (wasUpgraded) {
      buffer.write('  UPGRADED: ${originalOutcome.displayText} → ${burnedOutcome.displayText}');
    }
    return buffer.toString();
  }
}

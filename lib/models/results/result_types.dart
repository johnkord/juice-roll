/// Display type hints for UI rendering.
/// 
/// These help the UI determine how to render a result without
/// needing to check the concrete class type.
enum ResultDisplayType {
  /// Simple dice + interpretation (default)
  standard,
  
  /// Fate dice symbols + outcome chip (FateCheck, NextScene, Expectation)
  fateCheck,
  
  /// Side-by-side values (e.g., challenge physical OR mental)
  twoColumn,
  
  /// Nested/follow-up results with sub-sections
  hierarchical,
  
  /// Multi-part generated content (Quest, NPC Profile)
  generated,
  
  /// Includes state changes (Wilderness transitions)
  stateful,
  
  /// Has image/icon display (Abstract Icons)
  visual,
  
  /// Ironsworn-style action/progress roll (1d6 action vs 2d10 challenge)
  ironsworn,
}

/// A displayable section within a result.
/// 
/// Provides a structured way to represent result data for
/// generic UI rendering without type-specific code.
class ResultSection {
  /// Optional label for this section (e.g., "Intensity", "Focus")
  final String? label;
  
  /// The main value to display
  final String value;
  
  /// Optional sublabel or additional context
  final String? sublabel;
  
  /// Optional color hint for styling
  final int? colorValue;
  
  /// Optional icon name (from Material Icons)
  final String? iconName;
  
  /// Dice rolls associated with this section
  final List<int>? relatedDice;
  
  /// Whether this section represents an emphasized/highlighted value
  final bool isEmphasized;

  const ResultSection({
    this.label,
    required this.value,
    this.sublabel,
    this.colorValue,
    this.iconName,
    this.relatedDice,
    this.isEmphasized = false,
  });

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    'value': value,
    if (sublabel != null) 'sublabel': sublabel,
    if (colorValue != null) 'colorValue': colorValue,
    if (iconName != null) 'iconName': iconName,
    if (relatedDice != null) 'relatedDice': relatedDice,
    if (isEmphasized) 'isEmphasized': isEmphasized,
  };

  /// Create from JSON
  factory ResultSection.fromJson(Map<String, dynamic> json) => ResultSection(
    label: json['label'] as String?,
    value: json['value'] as String,
    sublabel: json['sublabel'] as String?,
    colorValue: json['colorValue'] as int?,
    iconName: json['iconName'] as String?,
    relatedDice: (json['relatedDice'] as List?)?.cast<int>(),
    isEmphasized: json['isEmphasized'] as bool? ?? false,
  );

  @override
  String toString() => label != null ? '$label: $value' : value;
}

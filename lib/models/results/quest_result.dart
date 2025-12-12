import '../roll_result.dart';

/// Result of a Quest generation.
/// Generates full quest descriptions with objective, description, focus,
/// preposition, and location components. Some components can be expanded
/// with sub-table references.
class QuestResult extends RollResult {
  final int objectiveRoll;
  final String objective;
  final int descriptionRoll;
  @override
  // ignore: overridden_fields
  final String description;
  final int? descriptionSubRoll;
  final String? descriptionExpanded;
  final int focusRoll;
  final String focus;
  final int? focusSubRoll;
  final String? focusExpanded;
  final int prepositionRoll;
  final String preposition;
  final int locationRoll;
  final String location;
  final int? locationSubRoll;
  final String? locationExpanded;

  QuestResult({
    required this.objectiveRoll,
    required this.objective,
    required this.descriptionRoll,
    required this.description,
    this.descriptionSubRoll,
    this.descriptionExpanded,
    required this.focusRoll,
    required this.focus,
    this.focusSubRoll,
    this.focusExpanded,
    required this.prepositionRoll,
    required this.preposition,
    required this.locationRoll,
    required this.location,
    this.locationSubRoll,
    this.locationExpanded,
    DateTime? timestamp,
  }) : super(
          type: RollType.quest,
          description: 'Quest',
          diceResults: [
            objectiveRoll,
            descriptionRoll,
            if (descriptionSubRoll != null) descriptionSubRoll,
            focusRoll,
            if (focusSubRoll != null) focusSubRoll,
            prepositionRoll,
            locationRoll,
            if (locationSubRoll != null) locationSubRoll,
          ],
          total: objectiveRoll +
              descriptionRoll +
              (descriptionSubRoll ?? 0) +
              focusRoll +
              (focusSubRoll ?? 0) +
              prepositionRoll +
              locationRoll +
              (locationSubRoll ?? 0),
          interpretation: _buildInterpretation(
            objective,
            description,
            descriptionExpanded,
            focus,
            focusExpanded,
            preposition,
            location,
            locationExpanded,
          ),
          timestamp: timestamp,
          metadata: {
            'objective': objective,
            'objectiveRoll': objectiveRoll,
            'description': description,
            'descriptionRoll': descriptionRoll,
            if (descriptionExpanded != null)
              'descriptionExpanded': descriptionExpanded,
            if (descriptionSubRoll != null)
              'descriptionSubRoll': descriptionSubRoll,
            'focus': focus,
            'focusRoll': focusRoll,
            if (focusExpanded != null) 'focusExpanded': focusExpanded,
            if (focusSubRoll != null) 'focusSubRoll': focusSubRoll,
            'preposition': preposition,
            'prepositionRoll': prepositionRoll,
            'location': location,
            'locationRoll': locationRoll,
            if (locationExpanded != null) 'locationExpanded': locationExpanded,
            if (locationSubRoll != null) 'locationSubRoll': locationSubRoll,
          },
        );

  @override
  String get className => 'QuestResult';

  factory QuestResult.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>;
    return QuestResult(
      objectiveRoll: meta['objectiveRoll'] as int? ?? 1,
      objective: meta['objective'] as String,
      descriptionRoll: meta['descriptionRoll'] as int? ?? 1,
      description: meta['description'] as String,
      descriptionSubRoll: meta['descriptionSubRoll'] as int?,
      descriptionExpanded: meta['descriptionExpanded'] as String?,
      focusRoll: meta['focusRoll'] as int? ?? 1,
      focus: meta['focus'] as String,
      focusSubRoll: meta['focusSubRoll'] as int?,
      focusExpanded: meta['focusExpanded'] as String?,
      prepositionRoll: meta['prepositionRoll'] as int? ?? 1,
      preposition: meta['preposition'] as String,
      locationRoll: meta['locationRoll'] as int? ?? 1,
      location: meta['location'] as String,
      locationSubRoll: meta['locationSubRoll'] as int?,
      locationExpanded: meta['locationExpanded'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static String _buildInterpretation(
    String objective,
    String description,
    String? descriptionExpanded,
    String focus,
    String? focusExpanded,
    String preposition,
    String location,
    String? locationExpanded,
  ) {
    final descText = descriptionExpanded != null
        ? '$descriptionExpanded ($description)'
        : description;
    final focusText = focusExpanded != null ? '$focusExpanded ($focus)' : focus;
    final locationText =
        locationExpanded != null ? '$locationExpanded ($location)' : location;
    return '$objective the $descText $focusText $preposition the $locationText';
  }

  /// Get the display text for the description (with expansion if available).
  String get descriptionDisplay => descriptionExpanded != null
      ? '$descriptionExpanded ($description)'
      : description;

  /// Get the display text for the focus (with expansion if available).
  String get focusDisplay =>
      focusExpanded != null ? '$focusExpanded ($focus)' : focus;

  /// Get the display text for the location (with expansion if available).
  String get locationDisplay =>
      locationExpanded != null ? '$locationExpanded ($location)' : location;

  /// Get the full quest sentence.
  String get questSentence =>
      '$objective the $descriptionDisplay $focusDisplay $preposition the $locationDisplay';

  /// Check if the description was expanded from a sub-table.
  bool get hasDescriptionExpansion => descriptionExpanded != null;

  /// Check if the focus was expanded from a sub-table.
  bool get hasFocusExpansion => focusExpanded != null;

  /// Check if the location was expanded from a sub-table.
  bool get hasLocationExpansion => locationExpanded != null;

  @override
  String toString() => 'Quest: $questSentence';
}

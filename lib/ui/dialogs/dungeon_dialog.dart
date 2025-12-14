import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/shared.dart';
import '../../presets/dungeon_generator.dart';
import '../../models/roll_result.dart';

/// Dialog for Dungeon Generator options.
/// Includes One-Pass and Two-Pass modes, encounters, traps, and more.
class DungeonDialog extends StatefulWidget {
  final DungeonGenerator dungeonGenerator;
  final void Function(RollResult) onRoll;
  final bool isEntering;
  final void Function(bool) onPhaseChange;
  final bool isTwoPassMode;
  final void Function(bool) onTwoPassModeChange;
  final bool twoPassHasFirstDoubles;
  final void Function(bool) onTwoPassFirstDoublesChange;

  const DungeonDialog({
    super.key,
    required this.dungeonGenerator,
    required this.onRoll,
    required this.isEntering,
    required this.onPhaseChange,
    required this.isTwoPassMode,
    required this.onTwoPassModeChange,
    required this.twoPassHasFirstDoubles,
    required this.onTwoPassFirstDoublesChange,
  });

  @override
  State<DungeonDialog> createState() => _DungeonDialogState();
}

class _DungeonDialogState extends State<DungeonDialog> {
  // Theme colors for dungeon - forest brown-green for exploration
  static const Color _dungeonColor = JuiceTheme.categoryExplore;
  static const Color _phaseEnteringColor = JuiceTheme.rust;  // @- worse/smaller
  static const Color _phaseExploringColor = JuiceTheme.success;  // @+ better/larger
  static const Color _encounterColor = JuiceTheme.danger;  // Red for danger
  static const Color _trapColor = JuiceTheme.juiceOrange;  // Orange for traps

  late bool _isEntering;
  // Local state for Two-Pass mode (synced with parent on change)
  late bool _isTwoPassMode;
  // Local state for first doubles in Two-Pass mode
  late bool _twoPassHasFirstDoubles;
  // Passage/Condition table die size
  // d6 = Linear/Unoccupied, d10 = Branching/Occupied
  bool _useD6ForPassage = false;
  // Passage/Condition skew
  // Disadvantage = Smaller/Worse, Advantage = Larger/Better
  AdvantageType _passageConditionSkew = AdvantageType.none;
  
  // Encounter table settings
  // d6 = Lingering (10+ min in unsafe area), d10 = First entry
  bool _isLingering = false;
  // Advantage = Better Encounters, Disadvantage = Worse Encounters
  AdvantageType _encounterSkew = AdvantageType.none;

  // Scroll controller to track scroll position for indicators
  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _isEntering = widget.isEntering;
    _isTwoPassMode = widget.isTwoPassMode;
    _twoPassHasFirstDoubles = widget.twoPassHasFirstDoubles;
    _scrollController.addListener(_updateScrollIndicators);
    // Check initial scroll state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    setState(() {
      _canScrollUp = position.pixels > 0;
      _canScrollDown = position.pixels < position.maxScrollExtent;
    });
  }

  void _setPhase(bool isEntering) {
    setState(() => _isEntering = isEntering);
    widget.onPhaseChange(isEntering);
  }

  void _resetMap() {
    if (_isTwoPassMode) {
      // Two-Pass: reset to @+ (before first doubles)
      setState(() => _twoPassHasFirstDoubles = false);
      widget.onTwoPassFirstDoublesChange(false);
    } else {
      // One-Pass: reset to Entering (@-)
      _setPhase(true);
    }
  }

  void _setTwoPassMode(bool isTwoPassMode) {
    setState(() => _isTwoPassMode = isTwoPassMode);
    widget.onTwoPassModeChange(isTwoPassMode);
  }

  void _setTwoPassFirstDoubles(bool hasFirstDoubles) {
    setState(() => _twoPassHasFirstDoubles = hasFirstDoubles);
    widget.onTwoPassFirstDoublesChange(hasFirstDoubles);
  }

  // Build a themed mode chip (One-Pass / Two-Pass)
  Widget _buildModeChip(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () => _setTwoPassMode(label == 'Two-Pass'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'One-Pass' ? Icons.route : Icons.layers,
              size: 14,
              color: isSelected ? color : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a themed die size chip (d6/d10)
  Widget _buildDieChip(String label, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: isSelected ? color : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  // Build a themed skew chip (@-/@+)
  Widget _buildSkewChip(String label, AdvantageType type, AdvantageType current, Color color, Function(AdvantageType) onTap) {
    final isSelected = current == type;
    return GestureDetector(
      onTap: () => onTap(isSelected ? AdvantageType.none : type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 12, color: color),
            if (isSelected)
              const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: isSelected ? color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build an info/tip box
  Widget _buildInfoBox(String content, {Color? color, bool isCompact = false}) {
    final c = color ?? _dungeonColor;
    return Container(
      padding: EdgeInsets.all(isCompact ? 6 : 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: isCompact ? 9 : 10,
          fontStyle: FontStyle.italic,
          color: JuiceTheme.parchment85,
        ),
      ),
    );
  }

  // Get the current advantage state based on mode
  bool get _useAdvantage {
    if (_isTwoPassMode) {
      // Two-Pass: @+ before first doubles, @- after
      return !_twoPassHasFirstDoubles;
    } else {
      // One-Pass: @- while entering, @+ while exploring
      return !_isEntering;
    }
  }

  String _getPassageDieLabel() => _useD6ForPassage ? 'd6' : 'd10';
  String _getPassageSkewLabel() {
    switch (_passageConditionSkew) {
      case AdvantageType.advantage: return '@+';
      case AdvantageType.disadvantage: return '@-';
      case AdvantageType.none: return '';
    }
  }
  
  String _getEncounterDieLabel() => _isLingering ? 'd6' : 'd10';
  String _getEncounterSkewLabel() {
    switch (_encounterSkew) {
      case AdvantageType.advantage: return '@+';
      case AdvantageType.disadvantage: return '@-';
      case AdvantageType.none: return '';
    }
  }

  // Compact phase chip for sticky header
  Widget _buildCompactPhaseChip(String label, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: JuiceTheme.fontFamilyMono,
            color: isSelected ? color : color.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // Compact doubles indicator for sticky header
  Widget _buildCompactDoublesIndicator(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? color : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 10,
            color: isActive ? color : Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? color : Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Determine current status text based on mode
    final String statusText;
    final Color statusColor;
    if (_isTwoPassMode) {
      if (_twoPassHasFirstDoubles) {
        statusText = '1d10@- (after 1st doubles)';
        statusColor = _phaseEnteringColor;
      } else {
        statusText = '1d10@+ (until 1st doubles)';
        statusColor = _phaseExploringColor;
      }
    } else {
      if (_isEntering) {
        statusText = '1d10@- Entering (until doubles)';
        statusColor = _phaseEnteringColor;
      } else {
        statusText = '1d10@+ Exploring (after doubles)';
        statusColor = _phaseExploringColor;
      }
    }

    // Build the sticky phase indicator
    Widget buildStickyPhaseIndicator() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.explore, size: 14, color: statusColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: statusColor,
                ),
              ),
            ),
            // Phase toggle chips (One-Pass only) - use Flexible to prevent overflow
            if (!_isTwoPassMode) ...[
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactPhaseChip('(@-)', _isEntering, _phaseEnteringColor, () => _setPhase(true)),
                    const SizedBox(width: 4),
                    _buildCompactPhaseChip('(@+)', !_isEntering, _phaseExploringColor, () => _setPhase(false)),
                  ],
                ),
              ),
            ],
            // Two-Pass doubles indicators
            if (_isTwoPassMode) ...[
              _buildCompactDoublesIndicator('1st', _twoPassHasFirstDoubles, _phaseEnteringColor),
              const SizedBox(width: 4),
              _buildCompactDoublesIndicator('2nd', false, _encounterColor),
            ],
            const SizedBox(width: 4),
            InkWell(
              onTap: _resetMap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.refresh, size: 16, color: statusColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.door_front_door, size: 22, color: _dungeonColor),
          const SizedBox(width: 10),
          Text(
            'Dungeon Generator',
            style: TextStyle(
              fontFamily: JuiceTheme.fontFamilySerif,
              color: _dungeonColor,
            ),
          ),
        ],
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.65,
        child: Column(
          children: [
            // Sticky phase indicator at top
            buildStickyPhaseIndicator(),
            const SizedBox(height: 8),
            // Scroll indicator - top fade
            if (_canScrollUp)
              Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      JuiceTheme.surface,
                      JuiceTheme.surface00,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.keyboard_arrow_up, size: 12, color: JuiceTheme.parchmentDark60),
                ),
              ),
            // Main scrollable content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dungeon Name Section
                        SectionHeader(title: 'Dungeon Name', icon: Icons.castle, color: _dungeonColor, fontSize: 13),
                        DialogOption(
                          title: 'Generate Name (3d10)',
                          subtitle: '[Dungeon] of the [Description] [Subject]',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.generateName());
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(),
                        
                        // ============ UNIFIED MAP GENERATION SECTION ============
                        SectionHeader(title: 'Map Generation', icon: Icons.map, color: _dungeonColor, fontSize: 13),
                        const SizedBox(height: 8),
                        
                        // Mode Toggle: One-Pass vs Two-Pass
                        Row(
                          children: [
                            Expanded(child: _buildModeChip('One-Pass', !_isTwoPassMode, _dungeonColor)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildModeChip('Two-Pass', _isTwoPassMode, JuiceTheme.mystic)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Mode-specific explanation
                        _buildInfoBox(
                          _isTwoPassMode
                            ? 'Two-Pass: Pre-generate map, then explore\n'
                              '• Start 1d10@+ → 1st doubles → 1d10@-\n'
                              '• 2nd doubles → STOP (remaining = dead ends)\n'
                              '• Roll encounters during exploration phase'
                            : 'One-Pass: Explore as you generate\n'
                              '• Start 1d10@- → doubles → switch to 1d10@+\n'
                              '• Roll encounters as you enter each room\n'
                              '• Mimics "Skyrim" style: long way in, shortcut out',
                          color: _isTwoPassMode ? JuiceTheme.mystic : _dungeonColor,
                        ),
                        const SizedBox(height: 8),
              
                        // Map Generation Buttons
                        DialogOption(
                          title: 'Next Area',
                          subtitle: _isTwoPassMode
                              ? 'Layout only (${_useAdvantage ? "1d10@+" : "1d10@-"})'
                              : 'Area + Passage if applicable',
                          onTap: () {
                            if (_isTwoPassMode) {
                              // Two-Pass mode: use generateTwoPassArea
                              final result = widget.dungeonGenerator.generateTwoPassArea(
                                hasFirstDoubles: _twoPassHasFirstDoubles,
                                useD6ForPassage: _useD6ForPassage,
                                passageSkew: _passageConditionSkew,
                              );
                              widget.onRoll(result);
                              
                              // Handle doubles transitions
                              if (result.isSecondDoubles) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎲 2nd DOUBLES! STOP MAP GENERATION\nAll remaining paths → Small Chamber: 1 Door'),
                                    backgroundColor: const Color(0xFF8B3A3A),  // Dark danger
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } else if (result.isDoubles && !_twoPassHasFirstDoubles) {
                                _setTwoPassFirstDoubles(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎲 1st DOUBLES! Switching to @- for remaining areas'),
                                    backgroundColor: const Color(0xFF8B5513),  // Dark rust
                                  ),
                                );
                              }
                            } else {
                              // One-Pass mode: use generateNextArea
                              final result = widget.dungeonGenerator.generateNextArea(
                                isEntering: _isEntering,
                                includePassage: true,
                                useD6ForPassage: _useD6ForPassage,
                                passageSkew: _passageConditionSkew,
                              );
                              widget.onRoll(result);
                              
                              // Auto-switch phase if doubles while entering
                              if (result.isDoubles && _isEntering) {
                                _setPhase(false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎲 DOUBLES! Switched to Exploring phase (@+)'),
                                    backgroundColor: const Color(0xFF4A6B4A),  // Dark success
                                  ),
                                );
                              }
                            }
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Full Area + Condition',
                          subtitle: _isTwoPassMode
                              ? 'Area + Condition (no encounters)'
                              : 'Area + Condition + Passage',
                          onTap: () {
                            if (_isTwoPassMode) {
                              // Two-Pass mode: use generateTwoPassArea (already includes condition)
                              final result = widget.dungeonGenerator.generateTwoPassArea(
                                hasFirstDoubles: _twoPassHasFirstDoubles,
                                useD6ForPassage: _useD6ForPassage,
                                passageSkew: _passageConditionSkew,
                              );
                              widget.onRoll(result);
                              
                              // Handle doubles transitions
                              if (result.isSecondDoubles) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎲 2nd DOUBLES! STOP MAP GENERATION\nAll remaining paths → Small Chamber: 1 Door'),
                                    backgroundColor: const Color(0xFF8B3A3A),  // Dark danger
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } else if (result.isDoubles && !_twoPassHasFirstDoubles) {
                                _setTwoPassFirstDoubles(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎲 1st DOUBLES! Switching to @- for remaining areas'),
                                    backgroundColor: const Color(0xFF8B5513),  // Dark rust
                                  ),
                                );
                              }
                            } else {
                              // One-Pass mode: use generateFullArea
                              final result = widget.dungeonGenerator.generateFullArea(
                                isEntering: _isEntering,
                                isOccupied: !_useD6ForPassage,
                                conditionSkew: _passageConditionSkew,
                                includePassage: true,
                                useD6ForPassage: _useD6ForPassage,
                                passageSkew: _passageConditionSkew,
                              );
                              widget.onRoll(result);
                              
                              // Auto-switch phase if doubles while entering
                              if (result.area.isDoubles && _isEntering) {
                                _setPhase(false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎲 DOUBLES! Switched to Exploring phase (@+)'),
                                    backgroundColor: const Color(0xFF4A6B4A),  // Dark success
                                  ),
                                );
                              }
                            }
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Passage',
                          subtitle: 'Manual passage roll (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.generatePassage(
                              useD6: _useD6ForPassage,
                              skew: _passageConditionSkew,
                            ));
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Condition',
                          subtitle: 'Room state (${_getPassageDieLabel()}${_getPassageSkewLabel()})',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.generateCondition(
                              useD6: _useD6ForPassage,
                              skew: _passageConditionSkew,
                            ));
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 4),
                        
                        // Passage & Condition Settings (collapsed)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: JuiceTheme.mystic08,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: JuiceTheme.mystic25),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.tune, size: 14, color: JuiceTheme.mystic),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Passage/Condition Settings',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: JuiceTheme.mystic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'd6 = Linear/Unoccupied  •  d10 = Branching/Occupied\n'
                                '@- = Smaller/Worse  •  @+ = Larger/Better',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontStyle: FontStyle.italic,
                                  color: JuiceTheme.parchment70,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _buildDieChip('d6', _useD6ForPassage, JuiceTheme.info, () => setState(() => _useD6ForPassage = true)),
                                  _buildDieChip('d10', !_useD6ForPassage, JuiceTheme.info, () => setState(() => _useD6ForPassage = false)),
                                  const SizedBox(width: 8),
                                  _buildSkewChip('@-', AdvantageType.disadvantage, _passageConditionSkew, _phaseEnteringColor, 
                                    (v) => setState(() => _passageConditionSkew = v)),
                                  _buildSkewChip('@+', AdvantageType.advantage, _passageConditionSkew, _phaseExploringColor,
                                    (v) => setState(() => _passageConditionSkew = v)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const Divider(),
                        // Encounter Settings
                        SectionHeader(title: 'Dungeon Encounter', icon: Icons.warning_amber_rounded, color: _encounterColor, fontSize: 13),
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: _encounterColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _encounterColor.withOpacity(0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '10m 1d6 (NH: d6); Trap: 10m AP@+ A/L, PP L/T',
                                style: TextStyle(fontSize: 10, fontFamily: JuiceTheme.fontFamilyMono, fontWeight: FontWeight.bold, color: _encounterColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'd6 = Lingering 10+ min in unsafe area\n'
                                'd10 = Entering area first time\n'
                                '@+ = Better Encounters, @- = Worse',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: JuiceTheme.parchment70,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _buildDieChip('d6 Linger', _isLingering, _encounterColor, () => setState(() => _isLingering = true)),
                                  _buildDieChip('d10 Entry', !_isLingering, _encounterColor, () => setState(() => _isLingering = false)),
                                  const SizedBox(width: 8),
                                  _buildSkewChip('@-', AdvantageType.disadvantage, _encounterSkew, _phaseEnteringColor,
                                    (v) => setState(() => _encounterSkew = v)),
                                  _buildSkewChip('@+', AdvantageType.advantage, _encounterSkew, _phaseExploringColor,
                                    (v) => setState(() => _encounterSkew = v)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DialogOption(
                          title: 'Encounter Type',
                          subtitle: 'What do you find? (${_getEncounterDieLabel()}${_getEncounterSkewLabel()})',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollEncounterType(
                              isLingering: _isLingering,
                              skew: _encounterSkew,
                            ));
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Full Encounter',
                          subtitle: 'Type + Monster/Trap/Feature if applicable',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollFullEncounter(
                              isLingering: _isLingering,
                              skew: _encounterSkew,
                            ));
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(),
                        SectionHeader(title: 'Encounter Details', icon: Icons.pest_control, color: _trapColor, fontSize: 13),
                        DialogOption(
                          title: 'Monster (2d10)',
                          subtitle: 'Descriptor + Ability',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollMonsterDescription());
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Trap (2d10)',
                          subtitle: 'Action + Subject',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollTrap());
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Trap Procedure (Searching)',
                          subtitle: 'Trap + DC (10 min, @+): Pass=Avoid, Fail=Locate',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollTrapProcedure(isSearching: true));
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Trap Procedure (Passive)',
                          subtitle: 'Trap + DC (Passive): Pass=Locate, Fail=Trigger',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollTrapProcedure(isSearching: false));
                            Navigator.pop(context);
                          },
                        ),
                        DialogOption(
                          title: 'Feature (1d10)',
                          subtitle: 'Library, Mural, Mushrooms, Prison...',
                          onTap: () {
                            widget.onRoll(widget.dungeonGenerator.rollFeature());
                            Navigator.pop(context);
                          },
                        ),
                        // Show trap procedure info
                        const Divider(),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _trapColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _trapColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.motion_photos_paused, size: 14, color: _trapColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Trap Procedure',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _trapColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '1. BEFORE encounter: decide to search (10 min) or not\n'
                                '2. If searching: Active Perception @+ vs DC\n'
                                '   • Pass = AVOID (completely bypass)\n'
                                '   • Fail = LOCATE (must disarm/bypass)\n'
                                '3. If NOT searching: Passive Perception vs DC\n'
                                '   • Pass = LOCATE (must disarm/bypass)\n'
                                '   • Fail = TRIGGER (suffer consequences)\n\n'
                                'Note: Lingering >10 min in non-Safety room = roll\n'
                                'another encounter (d6). Only 1 action per room is "free".',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: JuiceTheme.parchment85,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Reference for encounter types
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: JuiceTheme.sepia10,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: JuiceTheme.sepia20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.menu_book, size: 14, color: JuiceTheme.sepia),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Encounter Reference',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: JuiceTheme.sepia),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '1: Monster    6: Known\n'
                                '2: Nat Hazard 7: Trap\n'
                                '3: Challenge  8: Feature\n'
                                '4: Immersion  9: Key\n'
                                '5: Safety     0: Treasure',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontFamily: JuiceTheme.fontFamilyMono,
                                  color: JuiceTheme.parchment85,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8), // Extra padding at bottom for scroll
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scroll indicator - bottom fade
            if (_canScrollDown)
              Container(
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      JuiceTheme.surface,
                      JuiceTheme.surface00,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.keyboard_arrow_down, size: 14, color: JuiceTheme.parchmentDark60),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: _dungeonColor)),
        ),
      ],
    );
  }
}

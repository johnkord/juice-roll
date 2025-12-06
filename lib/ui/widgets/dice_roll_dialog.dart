import 'package:flutter/material.dart';
import '../../core/roll_engine.dart';
import '../../models/roll_result.dart';
import '../theme/juice_theme.dart';

/// Dialog for rolling custom dice (NdX, Fate, advantage/disadvantage, skewed).
/// 
/// Supports dice types commonly used in Juice Oracle:
/// - Fate Dice (2dF for Fate Check)
/// - d100 (table lookups)
/// - d6 with skew (various tables)
/// - d10 (half-tables, Abstract Icons row)
/// - d20 (optional, D&D 5e integration)
class DiceRollDialog extends StatefulWidget {
  final RollEngine rollEngine;
  final void Function(RollResult) onRoll;

  const DiceRollDialog({
    super.key,
    required this.rollEngine,
    required this.onRoll,
  });

  @override
  State<DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<DiceRollDialog> {
  // Theme colors
  static const _primaryColor = JuiceTheme.gold;
  static const _fateColor = JuiceTheme.mystic;
  static const _standardColor = JuiceTheme.rust;
  static const _successColor = JuiceTheme.success;
  static const _dangerColor = JuiceTheme.danger;

  int _diceCount = 2;
  int _diceSides = 6;
  int _modifier = 0;
  int _skew = 0;
  bool _advantage = false;
  bool _disadvantage = false;
  bool _useFateDice = false;

  // Quick preset definitions
  static const List<_DicePreset> _standardPresets = [
    _DicePreset('1d6', 1, 6, 'Oracle, simple checks'),
    _DicePreset('2d6', 2, 6, 'PbtA, reaction rolls'),
    _DicePreset('1d10', 1, 10, 'Half-tables, icons row'),
    _DicePreset('1d100', 1, 100, 'Table lookups'),
    _DicePreset('1d20', 1, 20, 'D&D 5e checks'),
    _DicePreset('3d6', 3, 6, 'Stat generation'),
  ];

  static const List<_DicePreset> _fatePresets = [
    _DicePreset('2dF', 2, 0, 'Fate Check (Juice)'),
    _DicePreset('4dF', 4, 0, 'Fate Core/Accelerated'),
    _DicePreset('1dF', 1, 0, 'Single Fate die'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = _useFateDice ? _fateColor : _standardColor;
    
    return Dialog(
      backgroundColor: JuiceTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: themeColor.withValues(alpha: 0.3), width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400, 
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(themeColor),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dice Type Toggle
                    _buildDiceTypeToggle(themeColor),
                    const SizedBox(height: 16),
                    
                    // Quick Presets
                    _buildSectionHeader(
                      'Quick Roll',
                      Icons.flash_on,
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildQuickPresets(),
                    const SizedBox(height: 16),
                    
                    // Custom Configuration
                    _buildSectionHeader(
                      'Custom Configuration',
                      Icons.tune,
                      color: themeColor,
                    ),
                    const SizedBox(height: 8),
                    _buildCustomConfiguration(themeColor),
                    const SizedBox(height: 16),
                    
                    // Roll Preview
                    _buildRollPreview(themeColor),
                  ],
                ),
              ),
            ),
            
            // Actions
            _buildActions(themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.2),
            themeColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: themeColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _useFateDice ? Icons.auto_awesome : Icons.casino,
              color: themeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roll Dice',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: JuiceTheme.parchment,
                  ),
                ),
                Text(
                  _useFateDice ? 'Fate dice for oracle checks' : 'Standard polyhedral dice',
                  style: TextStyle(
                    fontSize: 12,
                    color: JuiceTheme.parchmentDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: JuiceTheme.parchmentDark),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildDiceTypeToggle(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: JuiceTheme.ink.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              'Standard',
              Icons.casino,
              !_useFateDice,
              _standardColor,
              () => setState(() {
                _useFateDice = false;
                _diceCount = 2;
                _diceSides = 6;
              }),
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              'Fate',
              Icons.auto_awesome,
              _useFateDice,
              _fateColor,
              () => setState(() {
                _useFateDice = true;
                _diceCount = 2; // Default to 2dF for Juice Fate Check
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected 
            ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5)
            : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : JuiceTheme.parchmentDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : JuiceTheme.parchmentDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    final headerColor = color ?? JuiceTheme.parchment;
    return Row(
      children: [
        Icon(icon, size: 16, color: headerColor.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: JuiceTheme.fontFamilySerif,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: headerColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: headerColor.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPresets() {
    final presets = _useFateDice ? _fatePresets : _standardPresets;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) => _buildPresetChip(preset)).toList(),
    );
  }

  Widget _buildPresetChip(_DicePreset preset) {
    final isSelected = _useFateDice 
        ? _diceCount == preset.count
        : (_diceCount == preset.count && _diceSides == preset.sides);
    final color = _useFateDice ? _fateColor : _standardColor;
    
    return Tooltip(
      message: preset.description,
      child: InkWell(
        onTap: () {
          setState(() {
            _diceCount = preset.count;
            if (!_useFateDice) {
              _diceSides = preset.sides;
            }
            _skew = 0;
            _advantage = false;
            _disadvantage = false;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            color: isSelected ? null : JuiceTheme.ink.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : JuiceTheme.parchmentDark.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            preset.label,
            style: TextStyle(
              fontFamily: JuiceTheme.fontFamilyMono,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected ? color : JuiceTheme.parchment,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomConfiguration(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: JuiceTheme.ink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          if (!_useFateDice) ...[
            // Dice Count & Sides Row
            Row(
              children: [
                // Dice count
                Expanded(
                  child: _buildNumberControl(
                    label: 'Count',
                    value: _diceCount,
                    min: 1,
                    max: 20,
                    color: themeColor,
                    onChanged: (v) => setState(() => _diceCount = v),
                  ),
                ),
                const SizedBox(width: 12),
                // Dice sides
                Expanded(
                  child: _buildDiceSidesSelector(themeColor),
                ),
              ],
            ),
            
            // Skew slider (only for d6)
            if (_diceSides == 6) ...[
              const SizedBox(height: 12),
              _buildSkewControl(themeColor),
            ],
            
            // Advantage/Disadvantage
            const SizedBox(height: 12),
            _buildAdvantageControl(),
          ] else ...[
            // Fate Dice Count
            _buildNumberControl(
              label: 'Fate Dice',
              value: _diceCount,
              min: 1,
              max: 10,
              color: _fateColor,
              onChanged: (v) => setState(() => _diceCount = v),
            ),
            const SizedBox(height: 12),
            // Fate dice explanation
            _buildInfoBox(
              'Fate dice have 3 faces: [+] Plus, [ ] Blank, [−] Minus. '
              'Juice uses 2dF for Fate Checks.',
              color: _fateColor,
            ),
          ],
          
          // Modifier (both modes)
          const SizedBox(height: 12),
          _buildModifierControl(themeColor),
        ],
      ),
    );
  }

  Widget _buildNumberControl({
    required String label,
    required int value,
    required int min,
    required int max,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: JuiceTheme.parchmentDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: JuiceTheme.ink.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                Icons.remove,
                value > min ? () => onChanged(value - 1) : null,
                color,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: color,
                    ),
                  ),
                ),
              ),
              _buildControlButton(
                Icons.add,
                value < max ? () => onChanged(value + 1) : null,
                color,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback? onPressed, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? color : JuiceTheme.parchmentDark.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildDiceSidesSelector(Color themeColor) {
    // Dice with their associated colors and labels
    final diceOptions = [
      (4, 'd4', JuiceTheme.info),
      (6, 'd6', _standardColor),
      (8, 'd8', JuiceTheme.success),
      (10, 'd10', _standardColor),
      (12, 'd12', JuiceTheme.mystic),
      (20, 'd20', JuiceTheme.gold),
      (100, 'd%', JuiceTheme.juiceOrange),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Die Type',
          style: TextStyle(
            fontSize: 11,
            color: JuiceTheme.parchmentDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: JuiceTheme.ink.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          ),
          child: DropdownButton<int>(
            value: _diceSides,
            dropdownColor: JuiceTheme.surface,
            underline: const SizedBox(),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: themeColor),
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilyMono,
              fontSize: 18,
            ),
            items: diceOptions.map((option) {
              final (sides, label, color) = option;
              return DropdownMenuItem(
                value: sides,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '$sides',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _diceSides = value;
                  if (value != 6) _skew = 0;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkewControl(Color themeColor) {
    // Skew labels for context
    String skewLabel;
    Color skewColor;
    if (_skew == 0) {
      skewLabel = 'No skew';
      skewColor = JuiceTheme.parchmentDark;
    } else if (_skew > 0) {
      skewLabel = 'High (+$_skew)';
      skewColor = _successColor;
    } else {
      skewLabel = 'Low ($_skew)';
      skewColor = _dangerColor;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_flat, size: 14, color: JuiceTheme.parchmentDark),
            const SizedBox(width: 4),
            Text(
              'Skew',
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchmentDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: skewColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: skewColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                skewLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: skewColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.arrow_downward, size: 14, color: _dangerColor.withValues(alpha: 0.6)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _skew >= 0 ? _successColor : _dangerColor,
                  inactiveTrackColor: JuiceTheme.ink,
                  thumbColor: _skew == 0 ? JuiceTheme.parchmentDark : (_skew > 0 ? _successColor : _dangerColor),
                  overlayColor: (_skew >= 0 ? _successColor : _dangerColor).withValues(alpha: 0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _skew.toDouble(),
                  min: -3,
                  max: 3,
                  divisions: 6,
                  onChanged: (value) {
                    setState(() => _skew = value.round());
                  },
                ),
              ),
            ),
            Icon(Icons.arrow_upward, size: 14, color: _successColor.withValues(alpha: 0.6)),
          ],
        ),
        Text(
          'Skew shifts d6 results toward lower or higher values',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: JuiceTheme.parchmentDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvantageControl() {
    return Row(
      children: [
        Expanded(
          child: _buildAdvantageChip(
            'Advantage',
            Icons.thumb_up_outlined,
            _advantage,
            _successColor,
            () => setState(() {
              _advantage = !_advantage;
              if (_advantage) _disadvantage = false;
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAdvantageChip(
            'Disadvantage',
            Icons.thumb_down_outlined,
            _disadvantage,
            _dangerColor,
            () => setState(() {
              _disadvantage = !_disadvantage;
              if (_disadvantage) _advantage = false;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvantageChip(
    String label,
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : JuiceTheme.ink.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : JuiceTheme.parchmentDark.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : JuiceTheme.parchmentDark,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : JuiceTheme.parchmentDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifierControl(Color themeColor) {
    final modColor = _modifier > 0 ? _successColor : (_modifier < 0 ? _dangerColor : JuiceTheme.parchmentDark);
    
    return Row(
      children: [
        Icon(Icons.add_circle_outline, size: 14, color: JuiceTheme.parchmentDark),
        const SizedBox(width: 4),
        Text(
          'Modifier',
          style: TextStyle(
            fontSize: 11,
            color: JuiceTheme.parchmentDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: JuiceTheme.ink.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: modColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                Icons.remove,
                _modifier > -20 ? () => setState(() => _modifier--) : null,
                modColor,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 48),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Text(
                    _modifier >= 0 ? '+$_modifier' : '$_modifier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: modColor,
                    ),
                  ),
                ),
              ),
              _buildControlButton(
                Icons.add,
                _modifier < 20 ? () => setState(() => _modifier++) : null,
                modColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String content, {Color? color}) {
    final boxColor = color ?? JuiceTheme.info;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: boxColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: boxColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: boxColor.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchment.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRollPreview(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.15),
            themeColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Roll Preview',
            style: TextStyle(
              fontSize: 10,
              color: JuiceTheme.parchmentDark,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _useFateDice ? Icons.auto_awesome : Icons.casino,
                color: themeColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _buildRollDescription(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: themeColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (_advantage || _disadvantage || (_skew != 0 && _diceSides == 6)) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                if (_advantage)
                  _buildPreviewTag('ADV', _successColor),
                if (_disadvantage)
                  _buildPreviewTag('DIS', _dangerColor),
                if (_skew != 0 && _diceSides == 6)
                  _buildPreviewTag(
                    'SKEW ${_skew > 0 ? '+$_skew' : '$_skew'}',
                    _skew > 0 ? _successColor : _dangerColor,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: JuiceTheme.fontFamilyMono,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActions(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JuiceTheme.ink.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: JuiceTheme.parchmentDark),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withValues(alpha: 0.8),
                  themeColor,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _performRoll,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.casino,
                        color: JuiceTheme.ink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Roll!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: JuiceTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildRollDescription() {
    final buffer = StringBuffer();

    if (_useFateDice) {
      buffer.write('${_diceCount}dF');
    } else {
      buffer.write('${_diceCount}d$_diceSides');
    }

    if (_modifier != 0) {
      buffer.write(_modifier >= 0 ? '+$_modifier' : '$_modifier');
    }

    return buffer.toString();
  }

  void _performRoll() {
    RollResult result;

    if (_useFateDice) {
      final dice = widget.rollEngine.rollFateDice(_diceCount);
      final sum = dice.reduce((a, b) => a + b) + _modifier;

      result = FateRollResult(
        description: '${_diceCount}dF${_modifier != 0 ? (_modifier >= 0 ? '+$_modifier' : '$_modifier') : ''}',
        diceResults: dice,
        total: sum,
      );
    } else if (_advantage) {
      final advResult = widget.rollEngine.rollWithAdvantage(_diceCount, _diceSides);
      result = RollResult(
        type: RollType.advantage,
        description: '${_diceCount}d$_diceSides (advantage)',
        diceResults: advResult.chosenRoll,
        total: advResult.chosenSum + _modifier,
        interpretation: 'Chose ${advResult.chosenSum} over ${advResult.discardedSum}',
        metadata: {
          'discarded': advResult.discardedRoll,
          'discardedSum': advResult.discardedSum,
        },
      );
    } else if (_disadvantage) {
      final disResult = widget.rollEngine.rollWithDisadvantage(_diceCount, _diceSides);
      result = RollResult(
        type: RollType.disadvantage,
        description: '${_diceCount}d$_diceSides (disadvantage)',
        diceResults: disResult.chosenRoll,
        total: disResult.chosenSum + _modifier,
        interpretation: 'Chose ${disResult.chosenSum} over ${disResult.discardedSum}',
        metadata: {
          'discarded': disResult.discardedRoll,
          'discardedSum': disResult.discardedSum,
        },
      );
    } else if (_skew != 0 && _diceSides == 6) {
      // Skewed d6 - roll each die with skew
      final dice = List.generate(_diceCount, (_) => widget.rollEngine.rollSkewedD6(_skew));
      final sum = dice.reduce((a, b) => a + b) + _modifier;
      result = RollResult(
        type: RollType.skewed,
        description: '${_diceCount}d6 (skew ${_skew > 0 ? '+$_skew' : '$_skew'})',
        diceResults: dice,
        total: sum,
        metadata: {'skew': _skew},
      );
    } else {
      // Standard roll
      final dice = widget.rollEngine.rollDice(_diceCount, _diceSides);
      final sum = dice.reduce((a, b) => a + b) + _modifier;
      result = RollResult(
        type: RollType.standard,
        description: '${_diceCount}d$_diceSides${_modifier != 0 ? (_modifier >= 0 ? '+$_modifier' : '$_modifier') : ''}',
        diceResults: dice,
        total: sum,
      );
    }

    widget.onRoll(result);
    Navigator.pop(context);
  }
}

/// A quick preset for dice rolling
class _DicePreset {
  final String label;
  final int count;
  final int sides; // 0 for Fate dice
  final String description;

  const _DicePreset(this.label, this.count, this.sides, this.description);
}

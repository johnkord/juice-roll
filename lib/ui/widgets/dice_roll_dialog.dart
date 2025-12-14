import 'package:flutter/material.dart';
import '../../core/roll_engine.dart';
import '../../models/roll_result.dart';
import '../../models/results/ironsworn_result.dart';
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
  
  /// Initial dice mode: 0 = Standard, 1 = Fate, 2 = Ironsworn
  final int initialDiceMode;
  
  /// Initial Ironsworn roll type: 'action', 'progress', 'oracle', 'yesno', 'cursed'
  final String initialIronswornRollType;
  
  /// Initial oracle die type: 6, 20, or 100
  final int initialOracleDieType;
  
  /// Callback when dice mode or roll type changes (for persistence)
  final void Function({int? mode, String? ironswornRollType, int? oracleDieType})? onStateChanged;

  const DiceRollDialog({
    super.key,
    required this.rollEngine,
    required this.onRoll,
    this.initialDiceMode = 0,
    this.initialIronswornRollType = 'action',
    this.initialOracleDieType = 100,
    this.onStateChanged,
  });

  @override
  State<DiceRollDialog> createState() => _DiceRollDialogState();
}

class _DiceRollDialogState extends State<DiceRollDialog> {
  // Theme colors
  static const _primaryColor = JuiceTheme.gold;
  static const _fateColor = JuiceTheme.mystic;
  static const _standardColor = JuiceTheme.rust;
  static const _ironswornColor = Color(0xFF5C6BC0); // Indigo for Ironsworn
  static const _successColor = JuiceTheme.success;
  static const _dangerColor = JuiceTheme.danger;

  int _diceCount = 2;
  int _diceSides = 6;
  int _modifier = 0;
  int _skew = 0;
  bool _advantage = false;
  bool _disadvantage = false;
  
  // Dice mode: 0 = Standard, 1 = Fate, 2 = Ironsworn
  late int _diceMode;
  
  // Ironsworn-specific state
  int _ironswornStat = 0;
  int _ironswornAdds = 0;
  int _ironswornProgress = 5;
  late String _ironswornRollType; // 'action', 'progress', 'oracle', 'yesno', 'cursed'
  
  // Oracle type selection
  late int _oracleDieType; // 6, 20, or 100 for table oracles
  IronswornOdds _yesNoOdds = IronswornOdds.likely;
  
  // Momentum burn for action rolls
  int _momentum = 0;
  bool _useMomentumBurn = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize from widget properties (persisted state)
    _diceMode = widget.initialDiceMode;
    _ironswornRollType = widget.initialIronswornRollType;
    _oracleDieType = widget.initialOracleDieType;
  }
  
  /// Notify parent of state changes for persistence
  void _notifyStateChanged() {
    widget.onStateChanged?.call(
      mode: _diceMode,
      ironswornRollType: _ironswornRollType,
      oracleDieType: _oracleDieType,
    );
  }

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

  // Helper to check current mode
  bool get _useFateDice => _diceMode == 1;
  bool get _useIronsworn => _diceMode == 2;

  @override
  Widget build(BuildContext context) {
    final themeColor = _useIronsworn 
        ? _ironswornColor 
        : (_useFateDice ? _fateColor : _standardColor);
    
    return Dialog(
      backgroundColor: JuiceTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: themeColor.withOpacity(0.3), width: 1),
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
            themeColor.withOpacity(0.2),
            themeColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: themeColor.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _useIronsworn 
                  ? Icons.shield_outlined 
                  : (_useFateDice ? Icons.auto_awesome : Icons.casino),
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
                  _useIronsworn 
                      ? 'Ironsworn/Starforged dice' 
                      : (_useFateDice ? 'Fate dice for oracle checks' : 'Standard polyhedral dice'),
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
        color: JuiceTheme.ink30,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              'Standard',
              Icons.casino,
              _diceMode == 0,
              _standardColor,
              () {
                setState(() {
                  _diceMode = 0;
                  _diceCount = 2;
                  _diceSides = 6;
                });
                _notifyStateChanged();
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              'Fate',
              Icons.auto_awesome,
              _diceMode == 1,
              _fateColor,
              () {
                setState(() {
                  _diceMode = 1;
                  _diceCount = 2; // Default to 2dF for Juice Fate Check
                });
                _notifyStateChanged();
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              'Ironsworn',
              Icons.shield_outlined,
              _diceMode == 2,
              _ironswornColor,
              () {
                setState(() {
                  _diceMode = 2;
                });
                _notifyStateChanged();
              },
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
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected 
            ? Border.all(color: color.withOpacity(0.5), width: 1.5)
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
        Icon(icon, size: 16, color: headerColor.withOpacity(0.8)),
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
            color: headerColor.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPresets() {
    // For Ironsworn, we show roll type selection instead of dice presets
    if (_useIronsworn) {
      return _buildIronswornRollTypeSelector();
    }
    
    final presets = _useFateDice ? _fatePresets : _standardPresets;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) => _buildPresetChip(preset)).toList(),
    );
  }

  Widget _buildIronswornRollTypeSelector() {
    final rollTypes = [
      ('action', 'Action', '1d6 + stat vs 2d10'),
      ('progress', 'Progress', 'Progress vs 2d10'),
      ('oracle', 'Oracle', 'd6/d20/d100 lookup'),
      ('yesno', 'Yes/No', 'Ask the Oracle'),
      ('cursed', 'Cursed', 'Sundered Isles d10'),
    ];
    
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: rollTypes.map((type) {
        final (value, label, desc) = type;
        final isSelected = _ironswornRollType == value;
        
        return Tooltip(
          message: desc,
          child: InkWell(
            onTap: () {
              setState(() => _ironswornRollType = value);
              _notifyStateChanged();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          _ironswornColor.withOpacity(0.3),
                          _ironswornColor.withOpacity(0.15),
                        ],
                      )
                    : null,
                color: isSelected ? null : JuiceTheme.ink30,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _ironswornColor : JuiceTheme.parchmentDark30,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _ironswornColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: JuiceTheme.fontFamilyMono,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                  color: isSelected ? _ironswornColor : JuiceTheme.parchment,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
                      color.withOpacity(0.3),
                      color.withOpacity(0.15),
                    ],
                  )
                : null,
            color: isSelected ? null : JuiceTheme.ink30,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : JuiceTheme.parchmentDark30,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
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
        color: JuiceTheme.ink20,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          if (_useIronsworn) ...[
            // Ironsworn configuration
            _buildIronswornConfiguration(themeColor),
          ] else if (!_useFateDice) ...[
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
            
            // Modifier (standard mode)
            const SizedBox(height: 12),
            _buildModifierControl(themeColor),
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
            
            // Modifier (fate mode)
            const SizedBox(height: 12),
            _buildModifierControl(themeColor),
          ],
        ],
      ),
    );
  }

  Widget _buildIronswornConfiguration(Color themeColor) {
    switch (_ironswornRollType) {
      case 'action':
        return _buildIronswornActionConfig(themeColor);
      case 'progress':
        return _buildIronswornProgressConfig(themeColor);
      case 'oracle':
        return _buildIronswornTableOracleConfig(themeColor);
      case 'yesno':
        return _buildIronswornYesNoConfig(themeColor);
      case 'cursed':
        return _buildIronswornCursedConfig(themeColor);
      default:
        return _buildIronswornActionConfig(themeColor);
    }
  }

  Widget _buildIronswornActionConfig(Color themeColor) {
    return Column(
      children: [
        // Stat and Adds row
        Row(
          children: [
            Expanded(
              child: _buildNumberControl(
                label: 'Stat',
                value: _ironswornStat,
                min: 0,
                max: 5,
                color: themeColor,
                onChanged: (v) => setState(() => _ironswornStat = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberControl(
                label: 'Adds',
                value: _ironswornAdds,
                min: 0,
                max: 10,
                color: themeColor,
                onChanged: (v) => setState(() => _ironswornAdds = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Momentum burn option
        _buildMomentumBurnControl(themeColor),
        const SizedBox(height: 12),
        _buildInfoBox(
          'Roll 1d6 + Stat + Adds vs 2d10 challenge dice.\n'
          '• Strong Hit: Beat both dice\n'
          '• Weak Hit: Beat one die\n'
          '• Miss: Beat neither\n'
          '• Match: Both challenge dice show same value',
          color: themeColor,
        ),
      ],
    );
  }

  Widget _buildMomentumBurnControl(Color themeColor) {
    final momentumColor = _useMomentumBurn ? JuiceTheme.gold : JuiceTheme.parchmentDark;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _useMomentumBurn 
            ? JuiceTheme.gold10 
            : JuiceTheme.ink20,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: momentumColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _useMomentumBurn = !_useMomentumBurn),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    Icon(
                      _useMomentumBurn 
                          ? Icons.check_box 
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: momentumColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Momentum Burn',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: momentumColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_useMomentumBurn) ...[
                _buildControlButton(
                  Icons.remove,
                  _momentum > -6 ? () => setState(() => _momentum--) : null,
                  momentumColor,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 36),
                  child: Center(
                    child: Text(
                      '$_momentum',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: momentumColor,
                      ),
                    ),
                  ),
                ),
                _buildControlButton(
                  Icons.add,
                  _momentum < 10 ? () => setState(() => _momentum++) : null,
                  momentumColor,
                ),
              ],
            ],
          ),
          if (_useMomentumBurn) ...[
            const SizedBox(height: 6),
            Text(
              'Burn momentum to replace action score with momentum value.',
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: JuiceTheme.parchmentDark80,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIronswornProgressConfig(Color themeColor) {
    return Column(
      children: [
        _buildNumberControl(
          label: 'Progress Score',
          value: _ironswornProgress,
          min: 0,
          max: 10,
          color: themeColor,
          onChanged: (v) => setState(() => _ironswornProgress = v),
        ),
        const SizedBox(height: 12),
        _buildInfoBox(
          'Compare your progress score (0-10) vs 2d10 challenge dice.\n'
          'Used for Fulfill Your Vow, Reach a Milestone, etc.\n'
          '• Strong Hit: Beat both dice\n'
          '• Weak Hit: Beat one die\n'
          '• Miss: Beat neither',
          color: themeColor,
        ),
      ],
    );
  }

  Widget _buildIronswornTableOracleConfig(Color themeColor) {
    final dieOptions = [
      (6, 'd6', 'Simple oracles'),
      (20, 'd20', 'Character oracles'),
      (100, 'd100', 'Standard oracles'),
    ];
    
    return Column(
      children: [
        // Die type selector
        Row(
          children: [
            Text(
              'Die Type',
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchmentDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dieOptions.map((option) {
            final (sides, label, desc) = option;
            final isSelected = _oracleDieType == sides;
            
            return Tooltip(
              message: desc,
              child: InkWell(
                onTap: () {
                  setState(() => _oracleDieType = sides);
                  _notifyStateChanged();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? themeColor.withOpacity(0.2) 
                        : JuiceTheme.ink30,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? themeColor 
                          : JuiceTheme.parchmentDark30,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: JuiceTheme.fontFamilyMono,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: isSelected ? themeColor : JuiceTheme.parchment,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildInfoBox(
          'Roll for Ironsworn/Starforged oracle tables.\n'
          '• d6: Simple result tables (1-6)\n'
          '• d20: Character/creature oracles\n'
          '• d100: Standard percentile oracles',
          color: themeColor,
        ),
      ],
    );
  }

  Widget _buildIronswornYesNoConfig(Color themeColor) {
    final oddsOptions = [
      (IronswornOdds.almostCertain, 'Almost Certain', '11+', JuiceTheme.success),
      (IronswornOdds.likely, 'Likely', '26+', Color(0xFF8BC34A)),
      (IronswornOdds.fiftyFifty, '50/50', '51+', JuiceTheme.gold),
      (IronswornOdds.unlikely, 'Unlikely', '76+', JuiceTheme.juiceOrange),
      (IronswornOdds.smallChance, 'Small Chance', '91+', JuiceTheme.danger),
    ];
    
    return Column(
      children: [
        Text(
          'Select Odds',
          style: TextStyle(
            fontSize: 11,
            color: JuiceTheme.parchmentDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...oddsOptions.map((option) {
          final (value, label, threshold, color) = option;
          final isSelected = _yesNoOdds == value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => setState(() => _yesNoOdds = value),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withOpacity(0.2) 
                      : JuiceTheme.ink20,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : JuiceTheme.parchmentDark30,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_on : Icons.radio_button_off,
                      size: 18,
                      color: isSelected ? color : JuiceTheme.parchmentDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                          color: isSelected ? color : JuiceTheme.parchment,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Yes on $threshold',
                        style: TextStyle(
                          fontFamily: JuiceTheme.fontFamilyMono,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Ask the Oracle a yes/no question.\n'
          'Roll d100 and compare against the threshold based on odds.',
          color: themeColor,
        ),
      ],
    );
  }

  Widget _buildIronswornCursedConfig(Color themeColor) {
    final cursedColor = const Color(0xFF9C27B0); // Purple for cursed
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cursedColor.withOpacity(0.15),
                cursedColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cursedColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: cursedColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sundered Isles',
                      style: TextStyle(
                        fontFamily: JuiceTheme.fontFamilySerif,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cursedColor,
                      ),
                    ),
                    Text(
                      'Cursed Die adds danger to oracle rolls',
                      style: TextStyle(
                        fontSize: 11,
                        color: JuiceTheme.parchmentDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoBox(
          'Roll d100 for the oracle + d10 cursed die.\n'
          '• 10 on cursed die = Curse triggers!\n'
          '• Draw from your curse deck or consult curse table.\n'
          'Used in Sundered Isles for supernatural peril.',
          color: cursedColor,
        ),
      ],
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
            color: JuiceTheme.ink30,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
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
            color: onPressed != null ? color : JuiceTheme.parchmentDark30,
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
            color: JuiceTheme.ink30,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColor.withOpacity(0.3)),
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
                        color: color.withOpacity(0.2),
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
                color: skewColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: skewColor.withOpacity(0.3)),
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
            Icon(Icons.arrow_downward, size: 14, color: _dangerColor.withOpacity(0.6)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _skew >= 0 ? _successColor : _dangerColor,
                  inactiveTrackColor: JuiceTheme.ink,
                  thumbColor: _skew == 0 ? JuiceTheme.parchmentDark : (_skew > 0 ? _successColor : _dangerColor),
                  overlayColor: (_skew >= 0 ? _successColor : _dangerColor).withOpacity(0.2),
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
            Icon(Icons.arrow_upward, size: 14, color: _successColor.withOpacity(0.6)),
          ],
        ),
        Text(
          'Skew shifts d6 results toward lower or higher values',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: JuiceTheme.parchmentDark70,
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
          color: isSelected ? color.withOpacity(0.2) : JuiceTheme.ink30,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : JuiceTheme.parchmentDark30,
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
            color: JuiceTheme.ink30,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: modColor.withOpacity(0.3)),
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
        color: boxColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: boxColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: boxColor.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 11,
                color: JuiceTheme.parchment90,
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
            themeColor.withOpacity(0.15),
            themeColor.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
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
                _useIronsworn 
                    ? Icons.shield_outlined 
                    : (_useFateDice ? Icons.auto_awesome : Icons.casino),
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
          if (!_useIronsworn && (_advantage || _disadvantage || (_skew != 0 && _diceSides == 6))) ...[
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
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
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
        color: JuiceTheme.ink20,
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
                  themeColor.withOpacity(0.8),
                  themeColor,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.4),
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

    if (_useIronsworn) {
      switch (_ironswornRollType) {
        case 'action':
          buffer.write('1d6');
          final total = _ironswornStat + _ironswornAdds;
          if (total > 0) {
            buffer.write('+$total');
          }
          buffer.write(' vs 2d10');
          if (_useMomentumBurn) {
            buffer.write(' (M:$_momentum)');
          }
          break;
        case 'progress':
          buffer.write('$_ironswornProgress vs 2d10');
          break;
        case 'oracle':
          buffer.write('1d$_oracleDieType');
          break;
        case 'yesno':
          final oddsLabels = {
            IronswornOdds.almostCertain: 'AC',
            IronswornOdds.likely: 'L',
            IronswornOdds.fiftyFifty: '50/50',
            IronswornOdds.unlikely: 'UL',
            IronswornOdds.smallChance: 'SC',
          };
          buffer.write('d100 ${oddsLabels[_yesNoOdds]}');
          break;
        case 'cursed':
          buffer.write('d100 + Cursed d10');
          break;
      }
    } else if (_useFateDice) {
      buffer.write('${_diceCount}dF');
      if (_modifier != 0) {
        buffer.write(_modifier >= 0 ? '+$_modifier' : '$_modifier');
      }
    } else {
      buffer.write('${_diceCount}d$_diceSides');
      if (_modifier != 0) {
        buffer.write(_modifier >= 0 ? '+$_modifier' : '$_modifier');
      }
    }

    return buffer.toString();
  }

  void _performRoll() {
    RollResult result;

    if (_useIronsworn) {
      result = _performIronswornRoll();
    } else if (_useFateDice) {
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

  RollResult _performIronswornRoll() {
    switch (_ironswornRollType) {
      case 'action':
        // Roll 1d6 action die + 2d10 challenge dice
        final actionDie = widget.rollEngine.rollDie(6);
        final challengeDice = widget.rollEngine.rollDice(2, 10);
        
        // Check if momentum burn is being used
        if (_useMomentumBurn) {
          return IronswornMomentumBurnResult(
            actionDie: actionDie,
            challengeDice: challengeDice,
            statBonus: _ironswornStat,
            adds: _ironswornAdds,
            momentumValue: _momentum,
          );
        }
        
        return IronswornActionResult(
          actionDie: actionDie,
          challengeDice: challengeDice,
          statBonus: _ironswornStat,
          adds: _ironswornAdds,
        );
      
      case 'progress':
        // Roll 2d10 challenge dice vs progress score
        final challengeDice = widget.rollEngine.rollDice(2, 10);
        return IronswornProgressResult(
          progressScore: _ironswornProgress,
          challengeDice: challengeDice,
        );
      
      case 'oracle':
        // Roll specified die type for oracle lookup
        final oracleRoll = widget.rollEngine.rollDie(_oracleDieType);
        return IronswornOracleResult(
          oracleRoll: oracleRoll,
          dieType: _oracleDieType,
        );
      
      case 'yesno':
        // Roll d100 for yes/no oracle
        final yesNoRoll = widget.rollEngine.rollDie(100);
        return IronswornYesNoResult(
          roll: yesNoRoll,
          odds: _yesNoOdds,
        );
      
      case 'cursed':
        // Roll d100 + cursed d10 for Sundered Isles
        final oracleRoll = widget.rollEngine.rollDie(100);
        final cursedDie = widget.rollEngine.rollDie(10);
        return IronswornCursedOracleResult(
          oracleRoll: oracleRoll,
          cursedDie: cursedDie,
        );
      
      default:
        // Fallback to action roll
        final actionDie = widget.rollEngine.rollDie(6);
        final challengeDice = widget.rollEngine.rollDice(2, 10);
        return IronswornActionResult(
          actionDie: actionDie,
          challengeDice: challengeDice,
          statBonus: _ironswornStat,
          adds: _ironswornAdds,
        );
    }
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

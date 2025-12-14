import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/object_treasure.dart';
import '../../presets/details.dart' show SkewType;
import '../shared/dialog_components.dart';
import '../shared/oracle_dialog.dart';
import '../theme/juice_theme.dart';

/// Dialog for Treasure options.
class TreasureDialog extends StatefulWidget {
  final ObjectTreasure treasure;
  final void Function(RollResult) onRoll;

  const TreasureDialog({
    super.key,
    required this.treasure,
    required this.onRoll,
  });

  @override
  State<TreasureDialog> createState() => _TreasureDialogState();
}

class _TreasureDialogState extends State<TreasureDialog> {
  SkewType _skew = SkewType.none;
  bool _includeColor = false;

  @override
  Widget build(BuildContext context) {
    final treasureColor = JuiceTheme.gold;
    final skewLabel = _skew == SkewType.advantage ? ' @+' : _skew == SkewType.disadvantage ? ' @-' : '';
    
    return OracleDialog(
      icon: Icons.diamond,
      title: 'Treasure',
      accentColor: treasureColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Item Creation Procedure - prominent header
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: treasureColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: treasureColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: treasureColor),
                        const SizedBox(width: 6),
                        Text(
                          'Item Creation Procedure:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: treasureColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1. Roll 4d6 on Object/Treasure table\n'
                      '2. Roll two properties (1d10+1d6 each)\n'
                      '3. Optionally roll color for appearance/elemental',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Color toggle - styled
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic08,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: JuiceTheme.mystic20),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _includeColor,
                        onChanged: (v) => setState(() => _includeColor = v ?? false),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: JuiceTheme.mystic60),
                        activeColor: JuiceTheme.mystic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.palette, size: 14, color: JuiceTheme.mystic70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Include Color (appearance/elemental)',
                        style: TextStyle(
                          fontSize: 10,
                          color: _includeColor ? JuiceTheme.mystic : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Create Full Item - prominent button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onRoll(widget.treasure.generateFullItem(
                      skew: _skew,
                      includeColor: _includeColor,
                    ));
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          treasureColor.withOpacity(0.2),
                          treasureColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: treasureColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18, color: treasureColor),
                        const SizedBox(width: 8),
                        Text(
                          'Create Full Item',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: treasureColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Center(
                  child: Text(
                    '4d6 + 2 Properties${_includeColor ? ' + Color' : ''}$skewLabel',
                    style: TextStyle(
                      fontSize: 9,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withOpacity(0.3)),
              const SizedBox(height: 10),
              
              // Skew selection
              Row(
                children: [
                  Icon(Icons.tune, size: 14, color: JuiceTheme.info),
                  const SizedBox(width: 6),
                  Text(
                    'Skew:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: JuiceTheme.info,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '@+ = Better, @- = Worse',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TreasureSkewChip(
                    label: 'None',
                    type: SkewType.none,
                    color: JuiceTheme.info,
                    isSelected: _skew == SkewType.none,
                    onTap: () => setState(() => _skew = SkewType.none),
                  ),
                  const SizedBox(width: 8),
                  _TreasureSkewChip(
                    label: '@- Worse',
                    type: SkewType.disadvantage,
                    color: JuiceTheme.rust,
                    isSelected: _skew == SkewType.disadvantage,
                    onTap: () => setState(() => _skew = SkewType.disadvantage),
                  ),
                  const SizedBox(width: 8),
                  _TreasureSkewChip(
                    label: '@+ Better',
                    type: SkewType.advantage,
                    color: JuiceTheme.success,
                    isSelected: _skew == SkewType.advantage,
                    onTap: () => setState(() => _skew = SkewType.advantage),
                  ),
                ],
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withOpacity(0.3)),
              const SizedBox(height: 10),
              
              // Roll 4d6 section
              Row(
                children: [
                  Icon(Icons.casino, size: 16, color: treasureColor),
                  const SizedBox(width: 6),
                  Text(
                    'Roll 4d6',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: treasureColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DialogOption(
                title: 'Random Treasure (4d6)',
                subtitle: 'Category + Properties$skewLabel',
                onTap: () {
                  widget.onRoll(widget.treasure.generate(skew: _skew));
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withOpacity(0.3)),
              const SizedBox(height: 10),
              
              // By Category section
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: JuiceTheme.categoryWorld),
                  const SizedBox(width: 6),
                  Text(
                    'By Category (3d6)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.categoryWorld,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a specific category and roll 3d6 for properties:',
                style: TextStyle(
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Category grid - 2 columns
              Row(
                children: [
                  Expanded(
                    child: _TreasureCategoryCard(
                      number: '1',
                      title: 'Trinket',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.sepia,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateTrinket(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TreasureCategoryCard(
                      number: '2',
                      title: 'Treasure',
                      properties: 'Quality + Container + Contents',
                      color: JuiceTheme.gold,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateTreasure(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _TreasureCategoryCard(
                      number: '3',
                      title: 'Document',
                      properties: 'Type + Content + Subject',
                      color: JuiceTheme.parchmentDark,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateDocument(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TreasureCategoryCard(
                      number: '4',
                      title: 'Accessory',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.mystic,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateAccessory(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _TreasureCategoryCard(
                      number: '5',
                      title: 'Weapon',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.danger,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateWeapon(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TreasureCategoryCard(
                      number: '6',
                      title: 'Armor',
                      properties: 'Quality + Material + Type',
                      color: JuiceTheme.info,
                      onTap: () {
                        widget.onRoll(widget.treasure.generateArmor(skew: _skew));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 14),
              Divider(color: treasureColor.withOpacity(0.3)),
              const SizedBox(height: 10),
              
              // Examples section
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: JuiceTheme.juiceOrange),
                  const SizedBox(width: 6),
                  Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: JuiceTheme.juiceOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic 4d6:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2,5,4,2: New satchel full of art.\n'
                      '6,1,5,3: Broken Mithral gloves.\n'
                      '4,4,1,1: Fine wooden headpiece (crown).',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Full Item Creation:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: JuiceTheme.parchment,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '4,3,4,5 → "Accessory: Simple Silver Necklace"\n'
                      '  Property: 9,5 → Major Value\n'
                      '  Property: 5,4 → Moderate Power\n'
                      '(A normal-looking necklace that grants power!)',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: JuiceTheme.fontFamilyMono,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
  }
}

// =============================================================================
// HELPER WIDGETS (Private to this file)
// =============================================================================

// Skew chip builder
class _TreasureSkewChip extends StatelessWidget {
  final String label;
  final SkewType type;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TreasureSkewChip({
    required this.label,
    required this.type,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 14, color: color),
            if (isSelected)
              const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category card for treasure types
class _TreasureCategoryCard extends StatelessWidget {
  final String number;
  final String title;
  final String properties;
  final Color color;
  final VoidCallback onTap;

  const _TreasureCategoryCard({
    required this.number,
    required this.title,
    required this.properties,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
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
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: JuiceTheme.fontFamilySerif,
                        color: color,
                      ),
                    ),
                    Text(
                      properties,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: color.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

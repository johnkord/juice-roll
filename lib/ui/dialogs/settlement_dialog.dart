import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import '../../presets/settlement.dart';
import '../shared/dialog_components.dart';
import '../shared/oracle_dialog.dart';
import '../theme/juice_theme.dart';

/// Dialog for Settlement options.
class SettlementDialog extends StatelessWidget {
  final Settlement settlement;
  final void Function(RollResult) onRoll;

  const SettlementDialog({
    super.key,
    required this.settlement,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    final settlementColor = JuiceTheme.categoryWorld;
    
    return OracleDialog(
      icon: Icons.location_city,
      accentColor: settlementColor,
      title: 'Settlement',
      closeButtonText: 'Close',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header explanation
          OracleDialogIntro(
            icon: Icons.tips_and_updates,
            iconColor: settlementColor,
            backgroundColor: settlementColor.withOpacity(0.1),
            borderColor: settlementColor.withOpacity(0.3),
            text: 'Settlements are places to rest, stock up on supplies, collect quests, or chat with NPCs.',
          ),
          const SizedBox(height: 12),
          
          // Generate Settlement section - prominent
          OracleDialogSection(
            icon: Icons.add_location_alt,
            title: 'Generate Settlement',
            color: settlementColor,
          ),
          const SizedBox(height: 8),
          
          // Village and City as prominent cards
          Row(
            children: [
              Expanded(
                child: _SettlementTypeCard(
                  icon: Icons.house,
                  title: 'Village',
                  subtitle: 'Smaller, rural',
                  mechanics: '1d6@- count\nd6 establishments',
                  color: JuiceTheme.sepia,
                  onTap: () {
                    onRoll(settlement.generateVillage());
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SettlementTypeCard(
                  icon: Icons.location_city,
                  title: 'City',
                  subtitle: 'Larger, urban',
                  mechanics: '1d6@+ count\nd10 establishments',
                  color: JuiceTheme.gold,
                  onTap: () {
                    onRoll(settlement.generateCity());
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(color: settlementColor.withOpacity(0.3)),
          const SizedBox(height: 8),
          
          // Individual Rolls section
          OracleDialogSection(
            icon: Icons.casino,
            title: 'Individual Rolls',
            color: settlementColor,
          ),
          const SizedBox(height: 8),
          
          DialogOption(
            title: 'Name (2d10)',
            subtitle: 'Also usable for NPC last names',
            onTap: () {
              onRoll(settlement.generateName());
              Navigator.pop(context);
            },
          ),
          DialogOption(
            title: 'Establishment (d6)',
            subtitle: 'Village: Stable, Tavern, Inn, Entertainment, General Store, Artisan',
            onTap: () {
              onRoll(settlement.rollEstablishment(isVillage: true));
              Navigator.pop(context);
            },
          ),
          DialogOption(
            title: 'Establishment (d10)',
            subtitle: 'City: +Courier, Temple, Guild Hall, Magic Shop',
            onTap: () {
              onRoll(settlement.rollEstablishment(isVillage: false));
              Navigator.pop(context);
            },
          ),
          DialogOption(
            title: 'Artisan (d10)',
            subtitle: 'Artist, Baker, Tailor, Tanner, Archer, Blacksmith, Carpenter, Apothecary, Jeweler, Scribe',
            onTap: () {
              onRoll(settlement.rollArtisan());
              Navigator.pop(context);
            },
          ),
          
          const SizedBox(height: 12),
          Divider(color: settlementColor.withOpacity(0.3)),
          const SizedBox(height: 8),
          
          // Naming & Description section
          OracleDialogSection(
            icon: Icons.edit_note,
            title: 'Naming & Description',
            color: JuiceTheme.mystic,
          ),
          const SizedBox(height: 6),
          
          // Tip box for naming
          Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: JuiceTheme.mystic08,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.mystic20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.palette, size: 12, color: JuiceTheme.mystic70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Use Color + Object for establishment names (e.g., "The Crimson Hourglass"). '
                    'The color helps mark on maps, the object is their emblem.',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          DialogOption(
            title: 'Establishment Name',
            subtitle: 'Color + Object → "The [Color] [Object]"',
            onTap: () {
              onRoll(settlement.generateEstablishmentName());
              Navigator.pop(context);
            },
          ),
          DialogOption(
            title: 'Settlement Properties',
            subtitle: 'Two properties with intensity (e.g., "Major Style" + "Minimal Weight")',
            onTap: () {
              onRoll(settlement.generateProperties());
              Navigator.pop(context);
            },
          ),
          DialogOption(
            title: 'Simple NPC',
            subtitle: 'Name + Personality + Need + Motive (for establishment owners)',
            onTap: () {
              onRoll(settlement.generateSimpleNpc());
              Navigator.pop(context);
            },
          ),
          
          const SizedBox(height: 12),
          Divider(color: settlementColor.withOpacity(0.3)),
          const SizedBox(height: 8),
          
          // News section
          OracleDialogSection(
            icon: Icons.campaign,
            title: 'News',
            color: JuiceTheme.juiceOrange,
          ),
          const SizedBox(height: 6),
          
          // News tip box
          Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: JuiceTheme.juiceOrange08,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JuiceTheme.juiceOrange20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 12, color: JuiceTheme.juiceOrange70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Roll when entering a settlement or on "Advance Time" random event. '
                    'With a Courier, ask for news from other settlements.',
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          DialogOption(
            title: 'News (d10)',
            subtitle: 'War, Sickness, Disaster, Crime, Succession, Remote Event, Arrival, Mail, Sale, Celebration',
            onTap: () {
              onRoll(settlement.rollNews());
              Navigator.pop(context);
            },
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

// Settlement type card (Village/City)
class _SettlementTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String mechanics;
  final Color color;
  final VoidCallback onTap;

  const _SettlementTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mechanics,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: JuiceTheme.fontFamilySerif,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: color.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mechanics,
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: JuiceTheme.fontFamilyMono,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.casino, size: 11, color: color),
                        const SizedBox(width: 3),
                        Text(
                          'Roll',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/juice_theme.dart';
import '../shared/oracle_dialog.dart';
import '../../presets/extended_npc_conversation.dart';
import '../../presets/details.dart' show SkewType;
import '../../models/roll_result.dart';

/// Dialog for Extended NPC Conversation tables.
/// An alternative to the Dialog Grid mini-game for NPC conversations.
class ExtendedNpcConversationDialog extends StatefulWidget {
  final ExtendedNpcConversation extendedNpcConversation;
  final void Function(RollResult) onRoll;

  const ExtendedNpcConversationDialog({
    super.key,
    required this.extendedNpcConversation,
    required this.onRoll,
  });

  @override
  State<ExtendedNpcConversationDialog> createState() => _ExtendedNpcConversationDialogState();
}

class _ExtendedNpcConversationDialogState extends State<ExtendedNpcConversationDialog> {
  // Theme colors for NPC conversation - character/social interactions
  static const Color _npcColor = JuiceTheme.categoryCharacter;
  static const Color _infoColor = JuiceTheme.info;  // Blue for information
  static const Color _companionColor = JuiceTheme.success;  // Green for companion responses
  static const Color _topicColor = JuiceTheme.juiceOrange;  // Orange for dialog topics
  static const Color _opposedColor = JuiceTheme.danger;  // Red for opposed
  static const Color _favorColor = JuiceTheme.success;  // Green for in favor

  // Companion Response skew settings
  SkewType _companionSkew = SkewType.none;

  // Build a themed section header with icon
  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    final c = color ?? _npcColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: c),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: JuiceTheme.fontFamilySerif,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  // Build an info/tip box
  Widget _buildInfoBox(String content, {Color? color}) {
    final c = color ?? _npcColor;
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: JuiceTheme.parchment85,
        ),
      ),
    );
  }

  // Build a themed skew chip
  Widget _buildSkewChip(String label, SkewType type, IconData icon, Color color) {
    final isSelected = _companionSkew == type;
    return GestureDetector(
      onTap: () => setState(() => _companionSkew = type),
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
            if (isSelected)
              Icon(Icons.check, size: 12, color: color),
            if (isSelected)
              const SizedBox(width: 4),
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: JuiceTheme.fontFamilyMono,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a themed roll button
  Widget _buildRollButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: JuiceTheme.fontFamilyMono,
                      color: JuiceTheme.parchmentDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  // Build a favor level row
  Widget _buildFavorLevelRow(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              range,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontFamily: JuiceTheme.fontFamilyMono,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: JuiceTheme.parchment90,
            ),
          ),
        ],
      ),
    );
  }

  String _getSkewLabel() {
    switch (_companionSkew) {
      case SkewType.advantage:
        return ' @+ In Favor';
      case SkewType.disadvantage:
        return ' @- Opposed';
      case SkewType.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return OracleDialog(
      icon: Icons.record_voice_over,
      title: 'Extended NPC Conversation',
      accentColor: _npcColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Header explanation
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _npcColor.withOpacity(0.12),
                      _npcColor.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _npcColor.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat, size: 14, color: _npcColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Plot Knowledge • Companion Responses • Dialog Topics',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _npcColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Alternative to the Dialog Grid mini-game. NPCs make the world feel alive!',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: JuiceTheme.parchment80,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // INFORMATION SECTION (2d100)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Information', Icons.info_outline, color: _infoColor),
              _buildInfoBox(
                'Roll 2d100 to determine what an NPC is talking about. '
                'Could be a response to asking for info, or something overheard.',
                color: _infoColor,
              ),
              const SizedBox(height: 8),
              _buildRollButton(
                title: 'Roll Information',
                subtitle: 'Type + Topic (2d100)',
                icon: Icons.library_books,
                color: _infoColor,
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollInformation());
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // ═══════════════════════════════════════════════════════════════
              // COMPANION RESPONSE SECTION (1d100)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Companion Response', Icons.groups, color: _companionColor),
              _buildInfoBox(
                'Responses to "the plan". Ordered such that bigger numbers '
                'are more in favor, smaller numbers are more opposed.',
                color: _companionColor,
              ),
              const SizedBox(height: 8),
              // Skew selection
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 12, color: JuiceTheme.parchmentDark),
                        const SizedBox(width: 4),
                        Text(
                          'Attitude Bias',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: JuiceTheme.parchmentDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildSkewChip('None', SkewType.none, Icons.horizontal_rule, JuiceTheme.parchmentDark),
                        _buildSkewChip('@- Opposed', SkewType.disadvantage, Icons.thumb_down_outlined, _opposedColor),
                        _buildSkewChip('@+ In Favor', SkewType.advantage, Icons.thumb_up_outlined, _favorColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildRollButton(
                title: 'Roll Companion Response',
                subtitle: '1d100${_getSkewLabel()}',
                icon: Icons.question_answer,
                color: _companionColor,
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollCompanionResponse(skew: _companionSkew));
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // ═══════════════════════════════════════════════════════════════
              // DIALOG TOPIC SECTION (1d100)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Dialog Topic', Icons.topic, color: _topicColor),
              _buildInfoBox(
                'What are NPCs talking about? More topics than the standard table. '
                'Also usable for News, letters, books, writing on walls, etc.',
                color: _topicColor,
              ),
              const SizedBox(height: 8),
              _buildRollButton(
                title: 'Roll Dialog Topic',
                subtitle: 'What NPCs are discussing (1d100)',
                icon: Icons.forum,
                color: _topicColor,
                onTap: () {
                  widget.onRoll(widget.extendedNpcConversation.rollDialogTopic());
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // ═══════════════════════════════════════════════════════════════
              // REFERENCE: RESPONSE FAVOR LEVELS
              // ═══════════════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.inkDark50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _companionColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sentiment_satisfied_alt, size: 14, color: _companionColor),
                        const SizedBox(width: 6),
                        Text(
                          'Response Favor Levels',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: JuiceTheme.fontFamilySerif,
                            color: _companionColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFavorLevelRow('1-20', 'Strongly Opposed', JuiceTheme.danger),
                    _buildFavorLevelRow('21-40', 'Hesitant', JuiceTheme.juiceOrange),
                    _buildFavorLevelRow('41-60', 'Neutral / Questioning', JuiceTheme.parchmentDark),
                    _buildFavorLevelRow('61-80', 'Cautious Support', JuiceTheme.info),
                    _buildFavorLevelRow('81-100', 'Strongly In Favor', JuiceTheme.success),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ═══════════════════════════════════════════════════════════════
              // TIP: DIALOG GRID
              // ═══════════════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JuiceTheme.mystic08,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: JuiceTheme.mystic25),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: JuiceTheme.mystic),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Use the Dialog Grid (Dialog button) for a more interactive '
                        'mini-game experience with position tracking.',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: JuiceTheme.parchment85,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}

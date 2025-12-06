import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../../presets/npc_action.dart';
import '../../models/roll_result.dart';

/// Dialog for NPC Action options.
/// Includes NPC creation, action tables, and combat tables.
class NpcActionDialog extends StatefulWidget {
  final NpcAction npcAction;
  final void Function(RollResult) onRoll;

  const NpcActionDialog({
    super.key,
    required this.npcAction,
    required this.onRoll,
  });

  @override
  State<NpcActionDialog> createState() => _NpcActionDialogState();
}

class _NpcActionDialogState extends State<NpcActionDialog> {
  // NPC Creation settings
  NeedSkew _needSkew = NeedSkew.none;
  
  // Action table settings
  NpcDisposition _disposition = NpcDisposition.active;
  NpcContext _context = NpcContext.active;
  
  // Combat table settings
  NpcFocus _focus = NpcFocus.active;
  NpcObjective _objective = NpcObjective.offensive;

  String _getActionDieLabel() => _disposition == NpcDisposition.passive ? 'd6' : 'd10';
  String _getActionSkewLabel() => _context == NpcContext.active ? '@+' : '@-';
  String _getCombatDieLabel() => _focus == NpcFocus.passive ? 'd6' : 'd10';
  String _getCombatSkewLabel() => _objective == NpcObjective.offensive ? '@+' : '@-';
  String _getNeedSkewLabel() {
    switch (_needSkew) {
      case NeedSkew.none: return '';
      case NeedSkew.primitive: return ' @- Primitive';
      case NeedSkew.complex: return ' @+ Complex';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('NPC'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 320,
        height: screenHeight * 0.6,
        child: ScrollableDialogContent(
          children: [
            // Header explanation
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disp: d10A/6P; Ctx: @+A/-P',
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'WH: ΔCtx, SH: ΔCtx & +/-1',
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // NPC Creation Section
            const SectionHeader(title: 'NPC Creation', icon: Icons.person_add),
            const SizedBox(height: 4),
            // Need skew setting
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need Skew (for people use @+, for monsters use @-)',
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('None'),
                        selected: _needSkew == NeedSkew.none,
                        onSelected: (s) => setState(() => _needSkew = NeedSkew.none),
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('@- Primitive'),
                        selected: _needSkew == NeedSkew.primitive,
                        onSelected: (s) => setState(() => _needSkew = NeedSkew.primitive),
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('@+ Complex'),
                        selected: _needSkew == NeedSkew.complex,
                        onSelected: (s) => setState(() => _needSkew = NeedSkew.complex),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Complex NPC Section - moved up since it's the most complete option
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
              ),
              child: const Text(
                'Complex NPCs (sidekicks, important characters):\n'
                'Name + 2 Personalities + Need + Motive + Color + 2 Properties.\n'
                'Use @+ for people, @- for monsters.',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 4),
            DialogOption(
              title: '⭐ Complex NPC (Person)',
              subtitle: 'Name + 2 Personalities + Need@+ + Motive + Color + Properties',
              onTap: () {
                widget.onRoll(widget.npcAction.generateComplexNpc(
                  needSkew: NeedSkew.complex,
                  includeName: true,
                  dualPersonality: true,
                ));
                Navigator.pop(context);
              },
            ),
            DialogOption(
              title: '⭐ Complex NPC (Monster)',
              subtitle: 'Name + 2 Personalities + Need@- + Motive + Color + Properties',
              onTap: () {
                widget.onRoll(widget.npcAction.generateComplexNpc(
                  needSkew: NeedSkew.primitive,
                  includeName: true,
                  dualPersonality: true,
                ));
                Navigator.pop(context);
              },
            ),
            DialogOption(
              title: 'Profile Only (No Name)',
              subtitle: '2 Personalities + Need${_getNeedSkewLabel()} + Motive + Color + Properties',
              onTap: () {
                widget.onRoll(widget.npcAction.generateProfile(needSkew: _needSkew));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            
            // Individual Rolls Section
            const SectionHeader(title: 'Individual Rolls', icon: Icons.casino),
            const SizedBox(height: 4),
            DialogOption(
              title: 'Personality',
              subtitle: 'd10 - Roll 2 for primary/secondary traits',
              onTap: () {
                widget.onRoll(widget.npcAction.rollPersonality());
                Navigator.pop(context);
              },
            ),
            DialogOption(
              title: 'Dual Personality',
              subtitle: '2d10 - "Primary, yet Secondary" (e.g., "Confident, yet Reserved")',
              onTap: () {
                widget.onRoll(widget.npcAction.rollDualPersonality());
                Navigator.pop(context);
              },
            ),
            DialogOption(
              title: 'Need',
              subtitle: 'd10${_getNeedSkewLabel()}',
              onTap: () {
                widget.onRoll(widget.npcAction.rollNeed(skew: _needSkew));
                Navigator.pop(context);
              },
            ),
            DialogOption(
              title: 'Motive / Topic',
              subtitle: 'd10 - Auto-rolls History/Focus tables',
              onTap: () {
                widget.onRoll(widget.npcAction.rollMotiveWithFollowUp());
                Navigator.pop(context);
              },
            ),
            const Divider(),
              
            // Action Table Section
            const SectionHeader(title: 'Action Table', icon: Icons.directions_run),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disposition (static): Passive=d6, Active=d10\n'
                      'Context (changeable): Active=@+, Passive=@-',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Disp: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Passive (d6)'),
                          selected: _disposition == NpcDisposition.passive,
                          onSelected: (s) => setState(() => _disposition = NpcDisposition.passive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Active (d10)'),
                          selected: _disposition == NpcDisposition.active,
                          onSelected: (s) => setState(() => _disposition = NpcDisposition.active),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Ctx: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Passive (@-)'),
                          selected: _context == NpcContext.passive,
                          onSelected: (s) => setState(() => _context = NpcContext.passive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Active (@+)'),
                          selected: _context == NpcContext.active,
                          onSelected: (s) => setState(() => _context = NpcContext.active),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              DialogOption(
                title: 'Roll Action',
                subtitle: '${_getActionDieLabel()}${_getActionSkewLabel()} - ${_disposition.name} / ${_context.name}',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollAction(
                    disposition: _disposition,
                    context: _context,
                  ));
                  Navigator.pop(context);
                },
              ),
            const Divider(),
              
            // Combat Table Section
            const SectionHeader(title: 'Combat Table', icon: Icons.sports_kabaddi),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Focus: Passive=d6 (warnings), Active=d10 (full combat)\n'
                      'Objective: Defensive=@-, Offensive=@+',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Focus: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Passive (d6)'),
                          selected: _focus == NpcFocus.passive,
                          onSelected: (s) => setState(() => _focus = NpcFocus.passive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Active (d10)'),
                          selected: _focus == NpcFocus.active,
                          onSelected: (s) => setState(() => _focus = NpcFocus.active),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Obj: ', style: TextStyle(fontSize: 12)),
                        ChoiceChip(
                          label: const Text('Defensive (@-)'),
                          selected: _objective == NpcObjective.defensive,
                          onSelected: (s) => setState(() => _objective = NpcObjective.defensive),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        ChoiceChip(
                          label: const Text('Offensive (@+)'),
                          selected: _objective == NpcObjective.offensive,
                          onSelected: (s) => setState(() => _objective = NpcObjective.offensive),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              DialogOption(
                title: 'Roll Combat',
                subtitle: '${_getCombatDieLabel()}${_getCombatSkewLabel()} - ${_focus.name} / ${_objective.name}',
                onTap: () {
                  widget.onRoll(widget.npcAction.rollCombatAction(
                    focus: _focus,
                    objective: _objective,
                  ));
                  Navigator.pop(context);
                },
              ),
            const Divider(),
              
            // Social Check reminder
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Social Check Effects:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  Text(
                    '• Weak Hit: Change Context (Active↔Passive)\n'
                    '• Strong Hit: Change Context AND +/-1 to roll',
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

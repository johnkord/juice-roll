import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/session.dart';
import '../../services/session_service.dart';
import '../theme/juice_theme.dart';
import '../shared/dialog_components.dart';

/// Dialog for managing session-specific settings.
class SessionSettingsDialog extends StatefulWidget {
  final Session session;
  final Future<void> Function(Session) onUpdate;

  const SessionSettingsDialog({
    super.key,
    required this.session,
    required this.onUpdate,
  });

  @override
  State<SessionSettingsDialog> createState() => _SessionSettingsDialogState();
}

class _SessionSettingsDialogState extends State<SessionSettingsDialog> {
  late TextEditingController _maxRollsController;
  late bool _useCustomMaxRolls;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _useCustomMaxRolls = widget.session.maxRollsPerSession != null;
    _maxRollsController = TextEditingController(
      text: (widget.session.maxRollsPerSession ?? SessionService.defaultMaxRollsPerSession).toString(),
    );
  }

  @override
  void dispose() {
    _maxRollsController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    int? maxRolls;
    if (_useCustomMaxRolls) {
      final parsed = int.tryParse(_maxRollsController.text);
      if (parsed != null && parsed > 0) {
        maxRolls = parsed;
      }
    }
    
    final updatedSession = widget.session.copyWith(
      maxRollsPerSession: maxRolls,
      clearMaxRollsPerSession: !_useCustomMaxRolls,
    );
    
    await widget.onUpdate(updatedSession);
    
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings, color: JuiceTheme.gold, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Session Settings',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.session.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: JuiceTheme.parchmentDark,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 350,
        ),
        child: ScrollableDialogContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // History Settings Section
              const SectionHeader(
                icon: Icons.history,
                title: 'History Settings',
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JuiceTheme.sepia08,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: JuiceTheme.sepia20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom max rolls toggle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Max Rolls in History',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Limit how many rolls are stored',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: JuiceTheme.parchmentDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _useCustomMaxRolls,
                          onChanged: (value) {
                            setState(() {
                              _useCustomMaxRolls = value;
                              if (value) {
                                _maxRollsController.text = 
                                    SessionService.defaultMaxRollsPerSession.toString();
                              }
                            });
                          },
                          activeColor: JuiceTheme.gold,
                        ),
                      ],
                    ),
                    
                    if (_useCustomMaxRolls) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _maxRollsController,
                              decoration: InputDecoration(
                                labelText: 'Maximum Rolls',
                                hintText: 'e.g., 1000',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixText: 'rolls',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quick presets
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _QuickPresetChip(
                            label: '500',
                            onTap: () => _maxRollsController.text = '500',
                          ),
                          _QuickPresetChip(
                            label: '1000',
                            onTap: () => _maxRollsController.text = '1000',
                          ),
                          _QuickPresetChip(
                            label: '2000',
                            onTap: () => _maxRollsController.text = '2000',
                          ),
                          _QuickPresetChip(
                            label: '5000',
                            onTap: () => _maxRollsController.text = '5000',
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: JuiceTheme.info10,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: JuiceTheme.info30,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: JuiceTheme.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Unlimited history (no limit)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: JuiceTheme.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Current session info
              const SectionHeader(
                icon: Icons.analytics,
                title: 'Current Usage',
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    DetailRow(
                      icon: Icons.casino,
                      label: 'Rolls in History',
                      value: '${widget.session.history.length}',
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.storage,
                      label: 'Current Limit',
                      value: widget.session.maxRollsPerSession != null 
                          ? '${widget.session.maxRollsPerSession}'
                          : 'Unlimited',
                    ),
                    if (widget.session.maxRollsPerSession != null) ...[
                      const SizedBox(height: 8),
                      _UsageBar(
                        current: widget.session.history.length,
                        max: widget.session.maxRollsPerSession!,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_isSaving)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
      ],
    );
  }
}

class _QuickPresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: JuiceTheme.gold10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: JuiceTheme.gold30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: JuiceTheme.gold,
          ),
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final int current;
  final int max;

  const _UsageBar({
    required this.current,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final color = percentage > 0.9
        ? JuiceTheme.danger
        : percentage > 0.7
            ? JuiceTheme.juiceOrange
            : JuiceTheme.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
